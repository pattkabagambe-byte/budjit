import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

// ── Tables ─────────────────────────────────────────────────────────────────

@DataClassName('TxEntry')
class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get title => text()();
  RealColumn get amount => real()();
  BoolColumn get isIncome => boolean()();
  TextColumn get category => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().nullable()();
  TextColumn get currency => text().withDefault(const Constant('UGX'))();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class Budgets extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get label => text().nullable()();
  TextColumn get category => text()();
  RealColumn get limitAmount => real()();
  TextColumn get period => text().withDefault(const Constant('monthly'))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('GoalEntry')
class SavingsGoals extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  RealColumn get targetAmount => real()();
  RealColumn get currentAmount => real().withDefault(const Constant(0.0))();
  DateTimeColumn get deadline => dateTime().nullable()();
  TextColumn get emoji => text().withDefault(const Constant('🎯'))();
  TextColumn get colorHex => text().withDefault(const Constant('#10B981'))();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CustomCategoryEntry')
class CustomCategories extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get label => text()();
  TextColumn get emoji => text().withDefault(const Constant('📦'))();
  TextColumn get colorHex => text().withDefault(const Constant('#6366F1'))();
  BoolColumn get isIncome => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SubEntry')
class SubscriptionEntries extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  RealColumn get amount => real()();
  TextColumn get period => text().withDefault(const Constant('monthly'))();
  DateTimeColumn get nextDate => dateTime()();
  TextColumn get category => text().withDefault(const Constant('subscriptions'))();
  TextColumn get emoji => text().withDefault(const Constant('📱'))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

// ── Database ────────────────────────────────────────────────────────────────

@DriftDatabase(tables: [Transactions, Budgets, SavingsGoals, SubscriptionEntries, CustomCategories])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(customCategories);
          }
          if (from < 3) {
            await m.addColumn(budgets, budgets.label);
          }
        },
      );

  // ── Transactions ────────────────────────────────────────────────────────

  Future<List<TxEntry>> getTransactions(String userId, {DateTime? month}) {
    if (month != null) {
      final start = DateTime(month.year, month.month, 1);
      final end = DateTime(month.year, month.month + 1, 1);
      return (select(transactions)
            ..where((t) =>
                t.userId.equals(userId) &
                t.date.isBiggerOrEqualValue(start) &
                t.date.isSmallerThanValue(end))
            ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]))
          .get();
    }
    return (select(transactions)
          ..where((t) => t.userId.equals(userId))
          ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]))
        .get();
  }

  Stream<List<TxEntry>> watchTransactions(String userId, {DateTime? month}) {
    if (month != null) {
      final start = DateTime(month.year, month.month, 1);
      final end = DateTime(month.year, month.month + 1, 1);
      return (select(transactions)
            ..where((t) =>
                t.userId.equals(userId) &
                t.date.isBiggerOrEqualValue(start) &
                t.date.isSmallerThanValue(end))
            ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]))
          .watch();
    }
    return (select(transactions)
          ..where((t) => t.userId.equals(userId))
          ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]))
        .watch();
  }

  Future<void> upsertTransaction(TxEntry entry) =>
      into(transactions).insertOnConflictUpdate(entry);

  Future<void> deleteTransaction(String id) =>
      (delete(transactions)..where((t) => t.id.equals(id))).go();

  // ── Budgets ─────────────────────────────────────────────────────────────

  Stream<List<Budget>> watchBudgets(String userId) =>
      (select(budgets)..where((b) => b.userId.equals(userId))).watch();

  Future<List<Budget>> getBudgets(String userId) =>
      (select(budgets)..where((b) => b.userId.equals(userId))).get();

  Future<void> upsertBudget(Budget budget) =>
      into(budgets).insertOnConflictUpdate(budget);

  Future<void> deleteBudget(String id) =>
      (delete(budgets)..where((b) => b.id.equals(id))).go();

  // ── Goals ───────────────────────────────────────────────────────────────

  Stream<List<GoalEntry>> watchGoals(String userId) =>
      (select(savingsGoals)
            ..where((g) => g.userId.equals(userId))
            ..orderBy([(g) => OrderingTerm(expression: g.createdAt, mode: OrderingMode.desc)]))
          .watch();

  Future<void> upsertGoal(GoalEntry goal) =>
      into(savingsGoals).insertOnConflictUpdate(goal);

  Future<void> deleteGoal(String id) =>
      (delete(savingsGoals)..where((g) => g.id.equals(id))).go();

  Future<void> addToGoal(String id, double additionalAmount) async {
    final goal = await (select(savingsGoals)..where((g) => g.id.equals(id))).getSingle();
    final newAmount = goal.currentAmount + additionalAmount;
    await (update(savingsGoals)..where((g) => g.id.equals(id))).write(
      SavingsGoalsCompanion(
        currentAmount: Value(newAmount),
        isCompleted: Value(newAmount >= goal.targetAmount),
      ),
    );
  }

  // ── Subscriptions ────────────────────────────────────────────────────────

  Stream<List<SubEntry>> watchSubscriptions(String userId) =>
      (select(subscriptionEntries)..where((s) => s.userId.equals(userId))).watch();

  Future<void> upsertSubscription(SubEntry sub) =>
      into(subscriptionEntries).insertOnConflictUpdate(sub);

  Future<void> deleteSubscription(String id) =>
      (delete(subscriptionEntries)..where((s) => s.id.equals(id))).go();

  // ── Custom Categories ─────────────────────────────────────────────────────

  Stream<List<CustomCategoryEntry>> watchCustomCategories(String userId) =>
      (select(customCategories)
            ..where((c) => c.userId.equals(userId))
            ..orderBy([(c) => OrderingTerm(expression: c.createdAt)]))
          .watch();

  Future<void> upsertCustomCategory(CustomCategoryEntry entry) =>
      into(customCategories).insertOnConflictUpdate(entry);

  Future<void> deleteCustomCategory(String id) =>
      (delete(customCategories)..where((c) => c.id.equals(id))).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'budjit_v2.db'));
    return NativeDatabase.createInBackground(file);
  });
}
