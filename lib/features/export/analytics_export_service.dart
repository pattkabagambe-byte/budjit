import 'dart:io';

import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../core/database/app_database.dart';
import '../../core/utils/formatters.dart';
import '../transactions/domain/category_data.dart';

class AnalyticsReport {
  final DateTime month;
  final String currency;
  final double income;
  final double expenses;
  final List<TxEntry> transactions;
  final List<TxCategory> customCategories;

  const AnalyticsReport({
    required this.month,
    required this.currency,
    required this.income,
    required this.expenses,
    required this.transactions,
    this.customCategories = const [],
  });

  double get balance => income - expenses;

  double get savingsRate => income > 0 ? (balance / income * 100) : 0;

  Map<String, double> get expensesByCategory {
    final map = <String, double>{};
    for (final t in transactions.where((t) => !t.isIncome)) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return map;
  }

  List<MapEntry<String, double>> get sortedCategories {
    final entries = expensesByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  String categoryLabel(String id) =>
      categoryByIdOrDefault(id, custom: customCategories).label;
}

class AnalyticsExportService {
  static Future<void> exportPdf(AnalyticsReport report) async {
    final doc = pw.Document();
    final monthLabel = Fmt.month(report.month);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'Cashflo Analytics Report',
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Text(monthLabel, style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
          pw.SizedBox(height: 24),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _pdfStat('Income', Fmt.money(report.income, currency: report.currency)),
              _pdfStat('Expenses', Fmt.money(report.expenses, currency: report.currency)),
              _pdfStat('Balance', Fmt.money(report.balance, currency: report.currency)),
              _pdfStat('Savings', '${report.savingsRate.toStringAsFixed(0)}%'),
            ],
          ),
          pw.SizedBox(height: 32),
          pw.Text('Spending by Category', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 12),
          pw.Table.fromTextArray(
            headers: ['Category', 'Amount', '% of Total'],
            data: report.sortedCategories.map((e) {
              final pct = report.expenses > 0 ? (e.value / report.expenses * 100) : 0;
              return [
                report.categoryLabel(e.key),
                Fmt.money(e.value, currency: report.currency),
                '${pct.toStringAsFixed(1)}%',
              ];
            }).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.centerLeft,
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellHeight: 28,
          ),
          pw.SizedBox(height: 32),
          pw.Text('All Transactions', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 12),
          pw.Table.fromTextArray(
            headers: ['Date', 'Description', 'Category', 'Type', 'Amount'],
            data: report.transactions.map((t) {
              return [
                Fmt.date(t.date),
                t.title,
                report.categoryLabel(t.category),
                t.isIncome ? 'Income' : 'Expense',
                Fmt.money(t.amount, currency: report.currency),
              ];
            }).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.centerLeft,
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellHeight: 24,
            cellStyle: const pw.TextStyle(fontSize: 9),
          ),
        ],
      ),
    );

    final bytes = await doc.save();
    final dir = await getTemporaryDirectory();
    final fileName = 'cashflo_report_${DateFormat('yyyy_MM').format(report.month)}.pdf';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(file.path)], text: 'Cashflo report for $monthLabel');
  }

  static pw.Widget _pdfStat(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
        pw.SizedBox(height: 4),
        pw.Text(value, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  static Future<void> exportExcel(AnalyticsReport report) async {
    final excel = Excel.createExcel();
    final summary = excel['Summary'];
    excel.delete('Sheet1');

    final monthLabel = Fmt.month(report.month);
    summary.appendRow([TextCellValue('Cashflo Analytics Report')]);
    summary.appendRow([TextCellValue(monthLabel)]);
    summary.appendRow([]);
    summary.appendRow([
      TextCellValue('Income'),
      DoubleCellValue(report.income),
      TextCellValue(report.currency),
    ]);
    summary.appendRow([
      TextCellValue('Expenses'),
      DoubleCellValue(report.expenses),
      TextCellValue(report.currency),
    ]);
    summary.appendRow([
      TextCellValue('Balance'),
      DoubleCellValue(report.balance),
      TextCellValue(report.currency),
    ]);
    summary.appendRow([
      TextCellValue('Savings Rate'),
      TextCellValue('${report.savingsRate.toStringAsFixed(1)}%'),
    ]);
    summary.appendRow([]);

    summary.appendRow([TextCellValue('Category'), TextCellValue('Amount'), TextCellValue('% of Total')]);
    for (final e in report.sortedCategories) {
      final pct = report.expenses > 0 ? (e.value / report.expenses * 100) : 0;
      summary.appendRow([
        TextCellValue(report.categoryLabel(e.key)),
        DoubleCellValue(e.value),
        TextCellValue('${pct.toStringAsFixed(1)}%'),
      ]);
    }

    final txSheet = excel['Transactions'];
    txSheet.appendRow([
      TextCellValue('Date'),
      TextCellValue('Description'),
      TextCellValue('Category'),
      TextCellValue('Type'),
      TextCellValue('Amount'),
      TextCellValue('Currency'),
      TextCellValue('Note'),
    ]);
    for (final t in report.transactions) {
      txSheet.appendRow([
        TextCellValue(Fmt.date(t.date)),
        TextCellValue(t.title),
        TextCellValue(report.categoryLabel(t.category)),
        TextCellValue(t.isIncome ? 'Income' : 'Expense'),
        DoubleCellValue(t.amount),
        TextCellValue(t.currency),
        TextCellValue(t.note ?? ''),
      ]);
    }

    final bytes = excel.save();
    if (bytes == null) throw Exception('Failed to generate Excel file');

    final dir = await getTemporaryDirectory();
    final fileName = 'cashflo_report_${DateFormat('yyyy_MM').format(report.month)}.xlsx';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(file.path)], text: 'Cashflo report for $monthLabel');
  }
}
