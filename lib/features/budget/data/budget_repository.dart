import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../domain/budget_models.dart';

class BudgetRepository {
  static const _localKey = 'budjit_entries_v1';

  Future<String> get _userId async => FirebaseAuth.instance.currentUser?.uid ?? 'local';

  CollectionReference<Map<String, dynamic>> get _collection =>
      FirebaseFirestore.instance.collection('budget_entries');

  Future<List<BudgetEntry>> getEntries({DateTime? month}) async {
    final uid = await _userId;
    try {
      Query<Map<String, dynamic>> query = _collection.where('userId', isEqualTo: uid).orderBy('date', descending: true);
      if (month != null) {
        final start = DateTime(month.year, month.month, 1);
        final end = DateTime(month.year, month.month + 1, 1);
        query = query
            .where('date', isGreaterThanOrEqualTo: start.millisecondsSinceEpoch)
            .where('date', isLessThan: end.millisecondsSinceEpoch);
      }
      final snap = await query.get();
      return snap.docs.map((d) => BudgetEntry.fromJson(d.data())).toList();
    } catch (_) {
      return _getLocalEntries(uid, month: month);
    }
  }

  Future<List<BudgetEntry>> _getLocalEntries(String uid, {DateTime? month}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_localKey);
    if (raw == null) return [];
    final list = (jsonDecode(raw) as List).map((e) => BudgetEntry.fromJson(e as Map<String, dynamic>)).toList();
    if (month == null) return list.where((e) => e.userId == uid).toList();
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);
    return list.where((e) => e.userId == uid && !e.date.isBefore(start) && e.date.isBefore(end)).toList();
  }

  Future<void> addEntry(BudgetEntry entry) async {
    try {
      await _collection.doc(entry.id).set(entry.toJson());
    } catch (_) {
      await _saveLocalEntry(entry);
    }
  }

  Future<void> _saveLocalEntry(BudgetEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_localKey);
    final list = raw == null ? <dynamic>[] : jsonDecode(raw) as List;
    list.add(entry.toJson());
    await prefs.setString(_localKey, jsonEncode(list));
  }

  Future<void> deleteEntry(String id) async {
    try {
      await _collection.doc(id).delete();
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_localKey);
      if (raw == null) return;
      final list = (jsonDecode(raw) as List).where((e) => (e as Map)['id'] != id).toList();
      await prefs.setString(_localKey, jsonEncode(list));
    }
  }

  BudgetSummary computeSummary(List<BudgetEntry> entries) {
    double totalIncome = 0, totalExpenses = 0;
    final expByCat = <String, double>{};
    final incByCat = <String, double>{};

    for (final e in entries) {
      if (e.isIncome) {
        totalIncome += e.amount;
        incByCat[e.category] = (incByCat[e.category] ?? 0) + e.amount;
      } else {
        totalExpenses += e.amount;
        expByCat[e.category] = (expByCat[e.category] ?? 0) + e.amount;
      }
    }

    return BudgetSummary(
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      expensesByCategory: expByCat,
      incomeByCategory: incByCat,
    );
  }
}
