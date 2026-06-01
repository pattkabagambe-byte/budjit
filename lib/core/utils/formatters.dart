import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class Fmt {
  static String money(double amount, {String currency = 'UGX'}) {
    final abs = amount.abs();
    if (currency == 'UGX' || currency == 'TZS' || currency == 'RWF') {
      return '$currency ${NumberFormat('#,##0').format(abs.toInt())}';
    }
    return '$currency ${NumberFormat('#,##0.##').format(abs)}';
  }

  static String compact(double amount, {String currency = 'UGX'}) {
    if (amount >= 1000000) return '$currency ${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return '$currency ${(amount / 1000).toStringAsFixed(0)}K';
    return '$currency ${amount.toStringAsFixed(0)}';
  }

  static String date(DateTime d) => DateFormat('d MMM yyyy').format(d);
  static String dateShort(DateTime d) => DateFormat('d MMM').format(d);
  static String month(DateTime d) => DateFormat('MMMM yyyy').format(d);
  static String monthShort(DateTime d) => DateFormat('MMM').format(d);

  static String timeAgo(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return date(d);
  }

  static String percent(double v) => '${v.toStringAsFixed(1)}%';
}

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    final intValue = int.tryParse(newValue.text.replaceAll(',', ''));
    if (intValue == null) return oldValue;
    final formatted = NumberFormat('#,##0').format(intValue);
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

const List<String> kCurrencies = [
  'UGX', 'USD', 'KES', 'TZS', 'GHS', 'NGN', 'ZAR', 'RWF',
  'EUR', 'GBP', 'INR', 'PKR', 'BDT', 'PHP', 'IDR', 'EGP', 'ETB',
];
