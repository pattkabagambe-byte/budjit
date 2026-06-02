// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, TxEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _isIncomeMeta =
      const VerificationMeta('isIncome');
  @override
  late final GeneratedColumn<bool> isIncome = GeneratedColumn<bool>(
      'is_income', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_income" IN (0, 1))'));
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('UGX'));
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        title,
        amount,
        isIncome,
        category,
        date,
        note,
        currency,
        synced
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(Insertable<TxEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('is_income')) {
      context.handle(_isIncomeMeta,
          isIncome.isAcceptableOrUnknown(data['is_income']!, _isIncomeMeta));
    } else if (isInserting) {
      context.missing(_isIncomeMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TxEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TxEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      isIncome: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_income'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class TxEntry extends DataClass implements Insertable<TxEntry> {
  final String id;
  final String userId;
  final String title;
  final double amount;
  final bool isIncome;
  final String category;
  final DateTime date;
  final String? note;
  final String currency;
  final bool synced;
  const TxEntry(
      {required this.id,
      required this.userId,
      required this.title,
      required this.amount,
      required this.isIncome,
      required this.category,
      required this.date,
      this.note,
      required this.currency,
      required this.synced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['title'] = Variable<String>(title);
    map['amount'] = Variable<double>(amount);
    map['is_income'] = Variable<bool>(isIncome);
    map['category'] = Variable<String>(category);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['currency'] = Variable<String>(currency);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      userId: Value(userId),
      title: Value(title),
      amount: Value(amount),
      isIncome: Value(isIncome),
      category: Value(category),
      date: Value(date),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      currency: Value(currency),
      synced: Value(synced),
    );
  }

  factory TxEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TxEntry(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      title: serializer.fromJson<String>(json['title']),
      amount: serializer.fromJson<double>(json['amount']),
      isIncome: serializer.fromJson<bool>(json['isIncome']),
      category: serializer.fromJson<String>(json['category']),
      date: serializer.fromJson<DateTime>(json['date']),
      note: serializer.fromJson<String?>(json['note']),
      currency: serializer.fromJson<String>(json['currency']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'title': serializer.toJson<String>(title),
      'amount': serializer.toJson<double>(amount),
      'isIncome': serializer.toJson<bool>(isIncome),
      'category': serializer.toJson<String>(category),
      'date': serializer.toJson<DateTime>(date),
      'note': serializer.toJson<String?>(note),
      'currency': serializer.toJson<String>(currency),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  TxEntry copyWith(
          {String? id,
          String? userId,
          String? title,
          double? amount,
          bool? isIncome,
          String? category,
          DateTime? date,
          Value<String?> note = const Value.absent(),
          String? currency,
          bool? synced}) =>
      TxEntry(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        title: title ?? this.title,
        amount: amount ?? this.amount,
        isIncome: isIncome ?? this.isIncome,
        category: category ?? this.category,
        date: date ?? this.date,
        note: note.present ? note.value : this.note,
        currency: currency ?? this.currency,
        synced: synced ?? this.synced,
      );
  TxEntry copyWithCompanion(TransactionsCompanion data) {
    return TxEntry(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      title: data.title.present ? data.title.value : this.title,
      amount: data.amount.present ? data.amount.value : this.amount,
      isIncome: data.isIncome.present ? data.isIncome.value : this.isIncome,
      category: data.category.present ? data.category.value : this.category,
      date: data.date.present ? data.date.value : this.date,
      note: data.note.present ? data.note.value : this.note,
      currency: data.currency.present ? data.currency.value : this.currency,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TxEntry(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('amount: $amount, ')
          ..write('isIncome: $isIncome, ')
          ..write('category: $category, ')
          ..write('date: $date, ')
          ..write('note: $note, ')
          ..write('currency: $currency, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, title, amount, isIncome, category,
      date, note, currency, synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TxEntry &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.title == this.title &&
          other.amount == this.amount &&
          other.isIncome == this.isIncome &&
          other.category == this.category &&
          other.date == this.date &&
          other.note == this.note &&
          other.currency == this.currency &&
          other.synced == this.synced);
}

class TransactionsCompanion extends UpdateCompanion<TxEntry> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> title;
  final Value<double> amount;
  final Value<bool> isIncome;
  final Value<String> category;
  final Value<DateTime> date;
  final Value<String?> note;
  final Value<String> currency;
  final Value<bool> synced;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.title = const Value.absent(),
    this.amount = const Value.absent(),
    this.isIncome = const Value.absent(),
    this.category = const Value.absent(),
    this.date = const Value.absent(),
    this.note = const Value.absent(),
    this.currency = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    required String id,
    required String userId,
    required String title,
    required double amount,
    required bool isIncome,
    required String category,
    required DateTime date,
    this.note = const Value.absent(),
    this.currency = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        title = Value(title),
        amount = Value(amount),
        isIncome = Value(isIncome),
        category = Value(category),
        date = Value(date);
  static Insertable<TxEntry> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? title,
    Expression<double>? amount,
    Expression<bool>? isIncome,
    Expression<String>? category,
    Expression<DateTime>? date,
    Expression<String>? note,
    Expression<String>? currency,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (title != null) 'title': title,
      if (amount != null) 'amount': amount,
      if (isIncome != null) 'is_income': isIncome,
      if (category != null) 'category': category,
      if (date != null) 'date': date,
      if (note != null) 'note': note,
      if (currency != null) 'currency': currency,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? title,
      Value<double>? amount,
      Value<bool>? isIncome,
      Value<String>? category,
      Value<DateTime>? date,
      Value<String?>? note,
      Value<String>? currency,
      Value<bool>? synced,
      Value<int>? rowid}) {
    return TransactionsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      isIncome: isIncome ?? this.isIncome,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
      currency: currency ?? this.currency,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (isIncome.present) {
      map['is_income'] = Variable<bool>(isIncome.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('amount: $amount, ')
          ..write('isIncome: $isIncome, ')
          ..write('category: $category, ')
          ..write('date: $date, ')
          ..write('note: $note, ')
          ..write('currency: $currency, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BudgetsTable extends Budgets with TableInfo<$BudgetsTable, Budget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _limitAmountMeta =
      const VerificationMeta('limitAmount');
  @override
  late final GeneratedColumn<double> limitAmount = GeneratedColumn<double>(
      'limit_amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _periodMeta = const VerificationMeta('period');
  @override
  late final GeneratedColumn<String> period = GeneratedColumn<String>(
      'period', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('monthly'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, userId, label, category, limitAmount, period, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budgets';
  @override
  VerificationContext validateIntegrity(Insertable<Budget> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('limit_amount')) {
      context.handle(
          _limitAmountMeta,
          limitAmount.isAcceptableOrUnknown(
              data['limit_amount']!, _limitAmountMeta));
    } else if (isInserting) {
      context.missing(_limitAmountMeta);
    }
    if (data.containsKey('period')) {
      context.handle(_periodMeta,
          period.isAcceptableOrUnknown(data['period']!, _periodMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Budget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Budget(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label']),
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      limitAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}limit_amount'])!,
      period: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}period'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $BudgetsTable createAlias(String alias) {
    return $BudgetsTable(attachedDatabase, alias);
  }
}

class Budget extends DataClass implements Insertable<Budget> {
  final String id;
  final String userId;
  final String? label;
  final String category;
  final double limitAmount;
  final String period;
  final DateTime createdAt;
  const Budget(
      {required this.id,
      required this.userId,
      this.label,
      required this.category,
      required this.limitAmount,
      required this.period,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    map['category'] = Variable<String>(category);
    map['limit_amount'] = Variable<double>(limitAmount);
    map['period'] = Variable<String>(period);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BudgetsCompanion toCompanion(bool nullToAbsent) {
    return BudgetsCompanion(
      id: Value(id),
      userId: Value(userId),
      label:
          label == null && nullToAbsent ? const Value.absent() : Value(label),
      category: Value(category),
      limitAmount: Value(limitAmount),
      period: Value(period),
      createdAt: Value(createdAt),
    );
  }

  factory Budget.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Budget(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      label: serializer.fromJson<String?>(json['label']),
      category: serializer.fromJson<String>(json['category']),
      limitAmount: serializer.fromJson<double>(json['limitAmount']),
      period: serializer.fromJson<String>(json['period']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'label': serializer.toJson<String?>(label),
      'category': serializer.toJson<String>(category),
      'limitAmount': serializer.toJson<double>(limitAmount),
      'period': serializer.toJson<String>(period),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Budget copyWith(
          {String? id,
          String? userId,
          Value<String?> label = const Value.absent(),
          String? category,
          double? limitAmount,
          String? period,
          DateTime? createdAt}) =>
      Budget(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        label: label.present ? label.value : this.label,
        category: category ?? this.category,
        limitAmount: limitAmount ?? this.limitAmount,
        period: period ?? this.period,
        createdAt: createdAt ?? this.createdAt,
      );
  Budget copyWithCompanion(BudgetsCompanion data) {
    return Budget(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      label: data.label.present ? data.label.value : this.label,
      category: data.category.present ? data.category.value : this.category,
      limitAmount:
          data.limitAmount.present ? data.limitAmount.value : this.limitAmount,
      period: data.period.present ? data.period.value : this.period,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Budget(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('label: $label, ')
          ..write('category: $category, ')
          ..write('limitAmount: $limitAmount, ')
          ..write('period: $period, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, label, category, limitAmount, period, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Budget &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.label == this.label &&
          other.category == this.category &&
          other.limitAmount == this.limitAmount &&
          other.period == this.period &&
          other.createdAt == this.createdAt);
}

class BudgetsCompanion extends UpdateCompanion<Budget> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String?> label;
  final Value<String> category;
  final Value<double> limitAmount;
  final Value<String> period;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const BudgetsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.label = const Value.absent(),
    this.category = const Value.absent(),
    this.limitAmount = const Value.absent(),
    this.period = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BudgetsCompanion.insert({
    required String id,
    required String userId,
    this.label = const Value.absent(),
    required String category,
    required double limitAmount,
    this.period = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        category = Value(category),
        limitAmount = Value(limitAmount),
        createdAt = Value(createdAt);
  static Insertable<Budget> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? label,
    Expression<String>? category,
    Expression<double>? limitAmount,
    Expression<String>? period,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (label != null) 'label': label,
      if (category != null) 'category': category,
      if (limitAmount != null) 'limit_amount': limitAmount,
      if (period != null) 'period': period,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BudgetsCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String?>? label,
      Value<String>? category,
      Value<double>? limitAmount,
      Value<String>? period,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return BudgetsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      label: label ?? this.label,
      category: category ?? this.category,
      limitAmount: limitAmount ?? this.limitAmount,
      period: period ?? this.period,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (limitAmount.present) {
      map['limit_amount'] = Variable<double>(limitAmount.value);
    }
    if (period.present) {
      map['period'] = Variable<String>(period.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('label: $label, ')
          ..write('category: $category, ')
          ..write('limitAmount: $limitAmount, ')
          ..write('period: $period, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SavingsGoalsTable extends SavingsGoals
    with TableInfo<$SavingsGoalsTable, GoalEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavingsGoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _targetAmountMeta =
      const VerificationMeta('targetAmount');
  @override
  late final GeneratedColumn<double> targetAmount = GeneratedColumn<double>(
      'target_amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _currentAmountMeta =
      const VerificationMeta('currentAmount');
  @override
  late final GeneratedColumn<double> currentAmount = GeneratedColumn<double>(
      'current_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _deadlineMeta =
      const VerificationMeta('deadline');
  @override
  late final GeneratedColumn<DateTime> deadline = GeneratedColumn<DateTime>(
      'deadline', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
      'emoji', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('🎯'));
  static const VerificationMeta _colorHexMeta =
      const VerificationMeta('colorHex');
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
      'color_hex', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('#10B981'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isCompletedMeta =
      const VerificationMeta('isCompleted');
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
      'is_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        name,
        targetAmount,
        currentAmount,
        deadline,
        emoji,
        colorHex,
        createdAt,
        isCompleted
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'savings_goals';
  @override
  VerificationContext validateIntegrity(Insertable<GoalEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('target_amount')) {
      context.handle(
          _targetAmountMeta,
          targetAmount.isAcceptableOrUnknown(
              data['target_amount']!, _targetAmountMeta));
    } else if (isInserting) {
      context.missing(_targetAmountMeta);
    }
    if (data.containsKey('current_amount')) {
      context.handle(
          _currentAmountMeta,
          currentAmount.isAcceptableOrUnknown(
              data['current_amount']!, _currentAmountMeta));
    }
    if (data.containsKey('deadline')) {
      context.handle(_deadlineMeta,
          deadline.isAcceptableOrUnknown(data['deadline']!, _deadlineMeta));
    }
    if (data.containsKey('emoji')) {
      context.handle(
          _emojiMeta, emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta));
    }
    if (data.containsKey('color_hex')) {
      context.handle(_colorHexMeta,
          colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('is_completed')) {
      context.handle(
          _isCompletedMeta,
          isCompleted.isAcceptableOrUnknown(
              data['is_completed']!, _isCompletedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GoalEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GoalEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      targetAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}target_amount'])!,
      currentAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}current_amount'])!,
      deadline: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deadline']),
      emoji: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}emoji'])!,
      colorHex: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color_hex'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
    );
  }

  @override
  $SavingsGoalsTable createAlias(String alias) {
    return $SavingsGoalsTable(attachedDatabase, alias);
  }
}

class GoalEntry extends DataClass implements Insertable<GoalEntry> {
  final String id;
  final String userId;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime? deadline;
  final String emoji;
  final String colorHex;
  final DateTime createdAt;
  final bool isCompleted;
  const GoalEntry(
      {required this.id,
      required this.userId,
      required this.name,
      required this.targetAmount,
      required this.currentAmount,
      this.deadline,
      required this.emoji,
      required this.colorHex,
      required this.createdAt,
      required this.isCompleted});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    map['target_amount'] = Variable<double>(targetAmount);
    map['current_amount'] = Variable<double>(currentAmount);
    if (!nullToAbsent || deadline != null) {
      map['deadline'] = Variable<DateTime>(deadline);
    }
    map['emoji'] = Variable<String>(emoji);
    map['color_hex'] = Variable<String>(colorHex);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_completed'] = Variable<bool>(isCompleted);
    return map;
  }

  SavingsGoalsCompanion toCompanion(bool nullToAbsent) {
    return SavingsGoalsCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      targetAmount: Value(targetAmount),
      currentAmount: Value(currentAmount),
      deadline: deadline == null && nullToAbsent
          ? const Value.absent()
          : Value(deadline),
      emoji: Value(emoji),
      colorHex: Value(colorHex),
      createdAt: Value(createdAt),
      isCompleted: Value(isCompleted),
    );
  }

  factory GoalEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GoalEntry(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      targetAmount: serializer.fromJson<double>(json['targetAmount']),
      currentAmount: serializer.fromJson<double>(json['currentAmount']),
      deadline: serializer.fromJson<DateTime?>(json['deadline']),
      emoji: serializer.fromJson<String>(json['emoji']),
      colorHex: serializer.fromJson<String>(json['colorHex']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'targetAmount': serializer.toJson<double>(targetAmount),
      'currentAmount': serializer.toJson<double>(currentAmount),
      'deadline': serializer.toJson<DateTime?>(deadline),
      'emoji': serializer.toJson<String>(emoji),
      'colorHex': serializer.toJson<String>(colorHex),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isCompleted': serializer.toJson<bool>(isCompleted),
    };
  }

  GoalEntry copyWith(
          {String? id,
          String? userId,
          String? name,
          double? targetAmount,
          double? currentAmount,
          Value<DateTime?> deadline = const Value.absent(),
          String? emoji,
          String? colorHex,
          DateTime? createdAt,
          bool? isCompleted}) =>
      GoalEntry(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        targetAmount: targetAmount ?? this.targetAmount,
        currentAmount: currentAmount ?? this.currentAmount,
        deadline: deadline.present ? deadline.value : this.deadline,
        emoji: emoji ?? this.emoji,
        colorHex: colorHex ?? this.colorHex,
        createdAt: createdAt ?? this.createdAt,
        isCompleted: isCompleted ?? this.isCompleted,
      );
  GoalEntry copyWithCompanion(SavingsGoalsCompanion data) {
    return GoalEntry(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      targetAmount: data.targetAmount.present
          ? data.targetAmount.value
          : this.targetAmount,
      currentAmount: data.currentAmount.present
          ? data.currentAmount.value
          : this.currentAmount,
      deadline: data.deadline.present ? data.deadline.value : this.deadline,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GoalEntry(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('currentAmount: $currentAmount, ')
          ..write('deadline: $deadline, ')
          ..write('emoji: $emoji, ')
          ..write('colorHex: $colorHex, ')
          ..write('createdAt: $createdAt, ')
          ..write('isCompleted: $isCompleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, name, targetAmount, currentAmount,
      deadline, emoji, colorHex, createdAt, isCompleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoalEntry &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.targetAmount == this.targetAmount &&
          other.currentAmount == this.currentAmount &&
          other.deadline == this.deadline &&
          other.emoji == this.emoji &&
          other.colorHex == this.colorHex &&
          other.createdAt == this.createdAt &&
          other.isCompleted == this.isCompleted);
}

class SavingsGoalsCompanion extends UpdateCompanion<GoalEntry> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<double> targetAmount;
  final Value<double> currentAmount;
  final Value<DateTime?> deadline;
  final Value<String> emoji;
  final Value<String> colorHex;
  final Value<DateTime> createdAt;
  final Value<bool> isCompleted;
  final Value<int> rowid;
  const SavingsGoalsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.targetAmount = const Value.absent(),
    this.currentAmount = const Value.absent(),
    this.deadline = const Value.absent(),
    this.emoji = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavingsGoalsCompanion.insert({
    required String id,
    required String userId,
    required String name,
    required double targetAmount,
    this.currentAmount = const Value.absent(),
    this.deadline = const Value.absent(),
    this.emoji = const Value.absent(),
    this.colorHex = const Value.absent(),
    required DateTime createdAt,
    this.isCompleted = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        name = Value(name),
        targetAmount = Value(targetAmount),
        createdAt = Value(createdAt);
  static Insertable<GoalEntry> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<double>? targetAmount,
    Expression<double>? currentAmount,
    Expression<DateTime>? deadline,
    Expression<String>? emoji,
    Expression<String>? colorHex,
    Expression<DateTime>? createdAt,
    Expression<bool>? isCompleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (targetAmount != null) 'target_amount': targetAmount,
      if (currentAmount != null) 'current_amount': currentAmount,
      if (deadline != null) 'deadline': deadline,
      if (emoji != null) 'emoji': emoji,
      if (colorHex != null) 'color_hex': colorHex,
      if (createdAt != null) 'created_at': createdAt,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavingsGoalsCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? name,
      Value<double>? targetAmount,
      Value<double>? currentAmount,
      Value<DateTime?>? deadline,
      Value<String>? emoji,
      Value<String>? colorHex,
      Value<DateTime>? createdAt,
      Value<bool>? isCompleted,
      Value<int>? rowid}) {
    return SavingsGoalsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
      emoji: emoji ?? this.emoji,
      colorHex: colorHex ?? this.colorHex,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (targetAmount.present) {
      map['target_amount'] = Variable<double>(targetAmount.value);
    }
    if (currentAmount.present) {
      map['current_amount'] = Variable<double>(currentAmount.value);
    }
    if (deadline.present) {
      map['deadline'] = Variable<DateTime>(deadline.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavingsGoalsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('currentAmount: $currentAmount, ')
          ..write('deadline: $deadline, ')
          ..write('emoji: $emoji, ')
          ..write('colorHex: $colorHex, ')
          ..write('createdAt: $createdAt, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SubscriptionEntriesTable extends SubscriptionEntries
    with TableInfo<$SubscriptionEntriesTable, SubEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubscriptionEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _periodMeta = const VerificationMeta('period');
  @override
  late final GeneratedColumn<String> period = GeneratedColumn<String>(
      'period', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('monthly'));
  static const VerificationMeta _nextDateMeta =
      const VerificationMeta('nextDate');
  @override
  late final GeneratedColumn<DateTime> nextDate = GeneratedColumn<DateTime>(
      'next_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('subscriptions'));
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
      'emoji', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('📱'));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns =>
      [id, userId, name, amount, period, nextDate, category, emoji, isActive];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subscription_entries';
  @override
  VerificationContext validateIntegrity(Insertable<SubEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('period')) {
      context.handle(_periodMeta,
          period.isAcceptableOrUnknown(data['period']!, _periodMeta));
    }
    if (data.containsKey('next_date')) {
      context.handle(_nextDateMeta,
          nextDate.isAcceptableOrUnknown(data['next_date']!, _nextDateMeta));
    } else if (isInserting) {
      context.missing(_nextDateMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('emoji')) {
      context.handle(
          _emojiMeta, emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SubEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      period: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}period'])!,
      nextDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}next_date'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      emoji: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}emoji'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
    );
  }

  @override
  $SubscriptionEntriesTable createAlias(String alias) {
    return $SubscriptionEntriesTable(attachedDatabase, alias);
  }
}

class SubEntry extends DataClass implements Insertable<SubEntry> {
  final String id;
  final String userId;
  final String name;
  final double amount;
  final String period;
  final DateTime nextDate;
  final String category;
  final String emoji;
  final bool isActive;
  const SubEntry(
      {required this.id,
      required this.userId,
      required this.name,
      required this.amount,
      required this.period,
      required this.nextDate,
      required this.category,
      required this.emoji,
      required this.isActive});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    map['amount'] = Variable<double>(amount);
    map['period'] = Variable<String>(period);
    map['next_date'] = Variable<DateTime>(nextDate);
    map['category'] = Variable<String>(category);
    map['emoji'] = Variable<String>(emoji);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  SubscriptionEntriesCompanion toCompanion(bool nullToAbsent) {
    return SubscriptionEntriesCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      amount: Value(amount),
      period: Value(period),
      nextDate: Value(nextDate),
      category: Value(category),
      emoji: Value(emoji),
      isActive: Value(isActive),
    );
  }

  factory SubEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SubEntry(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      amount: serializer.fromJson<double>(json['amount']),
      period: serializer.fromJson<String>(json['period']),
      nextDate: serializer.fromJson<DateTime>(json['nextDate']),
      category: serializer.fromJson<String>(json['category']),
      emoji: serializer.fromJson<String>(json['emoji']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'amount': serializer.toJson<double>(amount),
      'period': serializer.toJson<String>(period),
      'nextDate': serializer.toJson<DateTime>(nextDate),
      'category': serializer.toJson<String>(category),
      'emoji': serializer.toJson<String>(emoji),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  SubEntry copyWith(
          {String? id,
          String? userId,
          String? name,
          double? amount,
          String? period,
          DateTime? nextDate,
          String? category,
          String? emoji,
          bool? isActive}) =>
      SubEntry(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        amount: amount ?? this.amount,
        period: period ?? this.period,
        nextDate: nextDate ?? this.nextDate,
        category: category ?? this.category,
        emoji: emoji ?? this.emoji,
        isActive: isActive ?? this.isActive,
      );
  SubEntry copyWithCompanion(SubscriptionEntriesCompanion data) {
    return SubEntry(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      amount: data.amount.present ? data.amount.value : this.amount,
      period: data.period.present ? data.period.value : this.period,
      nextDate: data.nextDate.present ? data.nextDate.value : this.nextDate,
      category: data.category.present ? data.category.value : this.category,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SubEntry(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('period: $period, ')
          ..write('nextDate: $nextDate, ')
          ..write('category: $category, ')
          ..write('emoji: $emoji, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, userId, name, amount, period, nextDate, category, emoji, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubEntry &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.amount == this.amount &&
          other.period == this.period &&
          other.nextDate == this.nextDate &&
          other.category == this.category &&
          other.emoji == this.emoji &&
          other.isActive == this.isActive);
}

class SubscriptionEntriesCompanion extends UpdateCompanion<SubEntry> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<double> amount;
  final Value<String> period;
  final Value<DateTime> nextDate;
  final Value<String> category;
  final Value<String> emoji;
  final Value<bool> isActive;
  final Value<int> rowid;
  const SubscriptionEntriesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.amount = const Value.absent(),
    this.period = const Value.absent(),
    this.nextDate = const Value.absent(),
    this.category = const Value.absent(),
    this.emoji = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SubscriptionEntriesCompanion.insert({
    required String id,
    required String userId,
    required String name,
    required double amount,
    this.period = const Value.absent(),
    required DateTime nextDate,
    this.category = const Value.absent(),
    this.emoji = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        name = Value(name),
        amount = Value(amount),
        nextDate = Value(nextDate);
  static Insertable<SubEntry> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<double>? amount,
    Expression<String>? period,
    Expression<DateTime>? nextDate,
    Expression<String>? category,
    Expression<String>? emoji,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (amount != null) 'amount': amount,
      if (period != null) 'period': period,
      if (nextDate != null) 'next_date': nextDate,
      if (category != null) 'category': category,
      if (emoji != null) 'emoji': emoji,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SubscriptionEntriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? name,
      Value<double>? amount,
      Value<String>? period,
      Value<DateTime>? nextDate,
      Value<String>? category,
      Value<String>? emoji,
      Value<bool>? isActive,
      Value<int>? rowid}) {
    return SubscriptionEntriesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      period: period ?? this.period,
      nextDate: nextDate ?? this.nextDate,
      category: category ?? this.category,
      emoji: emoji ?? this.emoji,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (period.present) {
      map['period'] = Variable<String>(period.value);
    }
    if (nextDate.present) {
      map['next_date'] = Variable<DateTime>(nextDate.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubscriptionEntriesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('period: $period, ')
          ..write('nextDate: $nextDate, ')
          ..write('category: $category, ')
          ..write('emoji: $emoji, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomCategoriesTable extends CustomCategories
    with TableInfo<$CustomCategoriesTable, CustomCategoryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
      'emoji', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('📦'));
  static const VerificationMeta _colorHexMeta =
      const VerificationMeta('colorHex');
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
      'color_hex', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('#6366F1'));
  static const VerificationMeta _isIncomeMeta =
      const VerificationMeta('isIncome');
  @override
  late final GeneratedColumn<bool> isIncome = GeneratedColumn<bool>(
      'is_income', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_income" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, userId, label, emoji, colorHex, isIncome, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_categories';
  @override
  VerificationContext validateIntegrity(
      Insertable<CustomCategoryEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('emoji')) {
      context.handle(
          _emojiMeta, emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta));
    }
    if (data.containsKey('color_hex')) {
      context.handle(_colorHexMeta,
          colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta));
    }
    if (data.containsKey('is_income')) {
      context.handle(_isIncomeMeta,
          isIncome.isAcceptableOrUnknown(data['is_income']!, _isIncomeMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomCategoryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomCategoryEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label'])!,
      emoji: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}emoji'])!,
      colorHex: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color_hex'])!,
      isIncome: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_income'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $CustomCategoriesTable createAlias(String alias) {
    return $CustomCategoriesTable(attachedDatabase, alias);
  }
}

class CustomCategoryEntry extends DataClass
    implements Insertable<CustomCategoryEntry> {
  final String id;
  final String userId;
  final String label;
  final String emoji;
  final String colorHex;
  final bool isIncome;
  final DateTime createdAt;
  const CustomCategoryEntry(
      {required this.id,
      required this.userId,
      required this.label,
      required this.emoji,
      required this.colorHex,
      required this.isIncome,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['label'] = Variable<String>(label);
    map['emoji'] = Variable<String>(emoji);
    map['color_hex'] = Variable<String>(colorHex);
    map['is_income'] = Variable<bool>(isIncome);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CustomCategoriesCompanion toCompanion(bool nullToAbsent) {
    return CustomCategoriesCompanion(
      id: Value(id),
      userId: Value(userId),
      label: Value(label),
      emoji: Value(emoji),
      colorHex: Value(colorHex),
      isIncome: Value(isIncome),
      createdAt: Value(createdAt),
    );
  }

  factory CustomCategoryEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomCategoryEntry(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      label: serializer.fromJson<String>(json['label']),
      emoji: serializer.fromJson<String>(json['emoji']),
      colorHex: serializer.fromJson<String>(json['colorHex']),
      isIncome: serializer.fromJson<bool>(json['isIncome']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'label': serializer.toJson<String>(label),
      'emoji': serializer.toJson<String>(emoji),
      'colorHex': serializer.toJson<String>(colorHex),
      'isIncome': serializer.toJson<bool>(isIncome),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CustomCategoryEntry copyWith(
          {String? id,
          String? userId,
          String? label,
          String? emoji,
          String? colorHex,
          bool? isIncome,
          DateTime? createdAt}) =>
      CustomCategoryEntry(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        label: label ?? this.label,
        emoji: emoji ?? this.emoji,
        colorHex: colorHex ?? this.colorHex,
        isIncome: isIncome ?? this.isIncome,
        createdAt: createdAt ?? this.createdAt,
      );
  CustomCategoryEntry copyWithCompanion(CustomCategoriesCompanion data) {
    return CustomCategoryEntry(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      label: data.label.present ? data.label.value : this.label,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      isIncome: data.isIncome.present ? data.isIncome.value : this.isIncome,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomCategoryEntry(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('label: $label, ')
          ..write('emoji: $emoji, ')
          ..write('colorHex: $colorHex, ')
          ..write('isIncome: $isIncome, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, label, emoji, colorHex, isIncome, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomCategoryEntry &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.label == this.label &&
          other.emoji == this.emoji &&
          other.colorHex == this.colorHex &&
          other.isIncome == this.isIncome &&
          other.createdAt == this.createdAt);
}

class CustomCategoriesCompanion extends UpdateCompanion<CustomCategoryEntry> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> label;
  final Value<String> emoji;
  final Value<String> colorHex;
  final Value<bool> isIncome;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CustomCategoriesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.label = const Value.absent(),
    this.emoji = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.isIncome = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomCategoriesCompanion.insert({
    required String id,
    required String userId,
    required String label,
    this.emoji = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.isIncome = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        label = Value(label),
        createdAt = Value(createdAt);
  static Insertable<CustomCategoryEntry> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? label,
    Expression<String>? emoji,
    Expression<String>? colorHex,
    Expression<bool>? isIncome,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (label != null) 'label': label,
      if (emoji != null) 'emoji': emoji,
      if (colorHex != null) 'color_hex': colorHex,
      if (isIncome != null) 'is_income': isIncome,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomCategoriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? label,
      Value<String>? emoji,
      Value<String>? colorHex,
      Value<bool>? isIncome,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return CustomCategoriesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      label: label ?? this.label,
      emoji: emoji ?? this.emoji,
      colorHex: colorHex ?? this.colorHex,
      isIncome: isIncome ?? this.isIncome,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (isIncome.present) {
      map['is_income'] = Variable<bool>(isIncome.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('label: $label, ')
          ..write('emoji: $emoji, ')
          ..write('colorHex: $colorHex, ')
          ..write('isIncome: $isIncome, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $BudgetsTable budgets = $BudgetsTable(this);
  late final $SavingsGoalsTable savingsGoals = $SavingsGoalsTable(this);
  late final $SubscriptionEntriesTable subscriptionEntries =
      $SubscriptionEntriesTable(this);
  late final $CustomCategoriesTable customCategories =
      $CustomCategoriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        transactions,
        budgets,
        savingsGoals,
        subscriptionEntries,
        customCategories
      ];
}

typedef $$TransactionsTableCreateCompanionBuilder = TransactionsCompanion
    Function({
  required String id,
  required String userId,
  required String title,
  required double amount,
  required bool isIncome,
  required String category,
  required DateTime date,
  Value<String?> note,
  Value<String> currency,
  Value<bool> synced,
  Value<int> rowid,
});
typedef $$TransactionsTableUpdateCompanionBuilder = TransactionsCompanion
    Function({
  Value<String> id,
  Value<String> userId,
  Value<String> title,
  Value<double> amount,
  Value<bool> isIncome,
  Value<String> category,
  Value<DateTime> date,
  Value<String?> note,
  Value<String> currency,
  Value<bool> synced,
  Value<int> rowid,
});

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isIncome => $composableBuilder(
      column: $table.isIncome, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isIncome => $composableBuilder(
      column: $table.isIncome, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<bool> get isIncome =>
      $composableBuilder(column: $table.isIncome, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$TransactionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TransactionsTable,
    TxEntry,
    $$TransactionsTableFilterComposer,
    $$TransactionsTableOrderingComposer,
    $$TransactionsTableAnnotationComposer,
    $$TransactionsTableCreateCompanionBuilder,
    $$TransactionsTableUpdateCompanionBuilder,
    (TxEntry, BaseReferences<_$AppDatabase, $TransactionsTable, TxEntry>),
    TxEntry,
    PrefetchHooks Function()> {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<bool> isIncome = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TransactionsCompanion(
            id: id,
            userId: userId,
            title: title,
            amount: amount,
            isIncome: isIncome,
            category: category,
            date: date,
            note: note,
            currency: currency,
            synced: synced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            required String title,
            required double amount,
            required bool isIncome,
            required String category,
            required DateTime date,
            Value<String?> note = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TransactionsCompanion.insert(
            id: id,
            userId: userId,
            title: title,
            amount: amount,
            isIncome: isIncome,
            category: category,
            date: date,
            note: note,
            currency: currency,
            synced: synced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TransactionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TransactionsTable,
    TxEntry,
    $$TransactionsTableFilterComposer,
    $$TransactionsTableOrderingComposer,
    $$TransactionsTableAnnotationComposer,
    $$TransactionsTableCreateCompanionBuilder,
    $$TransactionsTableUpdateCompanionBuilder,
    (TxEntry, BaseReferences<_$AppDatabase, $TransactionsTable, TxEntry>),
    TxEntry,
    PrefetchHooks Function()>;
typedef $$BudgetsTableCreateCompanionBuilder = BudgetsCompanion Function({
  required String id,
  required String userId,
  Value<String?> label,
  required String category,
  required double limitAmount,
  Value<String> period,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$BudgetsTableUpdateCompanionBuilder = BudgetsCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String?> label,
  Value<String> category,
  Value<double> limitAmount,
  Value<String> period,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$BudgetsTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get limitAmount => $composableBuilder(
      column: $table.limitAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get period => $composableBuilder(
      column: $table.period, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$BudgetsTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get limitAmount => $composableBuilder(
      column: $table.limitAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get period => $composableBuilder(
      column: $table.period, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$BudgetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get limitAmount => $composableBuilder(
      column: $table.limitAmount, builder: (column) => column);

  GeneratedColumn<String> get period =>
      $composableBuilder(column: $table.period, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BudgetsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BudgetsTable,
    Budget,
    $$BudgetsTableFilterComposer,
    $$BudgetsTableOrderingComposer,
    $$BudgetsTableAnnotationComposer,
    $$BudgetsTableCreateCompanionBuilder,
    $$BudgetsTableUpdateCompanionBuilder,
    (Budget, BaseReferences<_$AppDatabase, $BudgetsTable, Budget>),
    Budget,
    PrefetchHooks Function()> {
  $$BudgetsTableTableManager(_$AppDatabase db, $BudgetsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String?> label = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<double> limitAmount = const Value.absent(),
            Value<String> period = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BudgetsCompanion(
            id: id,
            userId: userId,
            label: label,
            category: category,
            limitAmount: limitAmount,
            period: period,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            Value<String?> label = const Value.absent(),
            required String category,
            required double limitAmount,
            Value<String> period = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              BudgetsCompanion.insert(
            id: id,
            userId: userId,
            label: label,
            category: category,
            limitAmount: limitAmount,
            period: period,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BudgetsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BudgetsTable,
    Budget,
    $$BudgetsTableFilterComposer,
    $$BudgetsTableOrderingComposer,
    $$BudgetsTableAnnotationComposer,
    $$BudgetsTableCreateCompanionBuilder,
    $$BudgetsTableUpdateCompanionBuilder,
    (Budget, BaseReferences<_$AppDatabase, $BudgetsTable, Budget>),
    Budget,
    PrefetchHooks Function()>;
typedef $$SavingsGoalsTableCreateCompanionBuilder = SavingsGoalsCompanion
    Function({
  required String id,
  required String userId,
  required String name,
  required double targetAmount,
  Value<double> currentAmount,
  Value<DateTime?> deadline,
  Value<String> emoji,
  Value<String> colorHex,
  required DateTime createdAt,
  Value<bool> isCompleted,
  Value<int> rowid,
});
typedef $$SavingsGoalsTableUpdateCompanionBuilder = SavingsGoalsCompanion
    Function({
  Value<String> id,
  Value<String> userId,
  Value<String> name,
  Value<double> targetAmount,
  Value<double> currentAmount,
  Value<DateTime?> deadline,
  Value<String> emoji,
  Value<String> colorHex,
  Value<DateTime> createdAt,
  Value<bool> isCompleted,
  Value<int> rowid,
});

class $$SavingsGoalsTableFilterComposer
    extends Composer<_$AppDatabase, $SavingsGoalsTable> {
  $$SavingsGoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get targetAmount => $composableBuilder(
      column: $table.targetAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get currentAmount => $composableBuilder(
      column: $table.currentAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deadline => $composableBuilder(
      column: $table.deadline, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get emoji => $composableBuilder(
      column: $table.emoji, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get colorHex => $composableBuilder(
      column: $table.colorHex, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnFilters(column));
}

class $$SavingsGoalsTableOrderingComposer
    extends Composer<_$AppDatabase, $SavingsGoalsTable> {
  $$SavingsGoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get targetAmount => $composableBuilder(
      column: $table.targetAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get currentAmount => $composableBuilder(
      column: $table.currentAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deadline => $composableBuilder(
      column: $table.deadline, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get emoji => $composableBuilder(
      column: $table.emoji, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get colorHex => $composableBuilder(
      column: $table.colorHex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnOrderings(column));
}

class $$SavingsGoalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavingsGoalsTable> {
  $$SavingsGoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get targetAmount => $composableBuilder(
      column: $table.targetAmount, builder: (column) => column);

  GeneratedColumn<double> get currentAmount => $composableBuilder(
      column: $table.currentAmount, builder: (column) => column);

  GeneratedColumn<DateTime> get deadline =>
      $composableBuilder(column: $table.deadline, builder: (column) => column);

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => column);
}

class $$SavingsGoalsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SavingsGoalsTable,
    GoalEntry,
    $$SavingsGoalsTableFilterComposer,
    $$SavingsGoalsTableOrderingComposer,
    $$SavingsGoalsTableAnnotationComposer,
    $$SavingsGoalsTableCreateCompanionBuilder,
    $$SavingsGoalsTableUpdateCompanionBuilder,
    (GoalEntry, BaseReferences<_$AppDatabase, $SavingsGoalsTable, GoalEntry>),
    GoalEntry,
    PrefetchHooks Function()> {
  $$SavingsGoalsTableTableManager(_$AppDatabase db, $SavingsGoalsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavingsGoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavingsGoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavingsGoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<double> targetAmount = const Value.absent(),
            Value<double> currentAmount = const Value.absent(),
            Value<DateTime?> deadline = const Value.absent(),
            Value<String> emoji = const Value.absent(),
            Value<String> colorHex = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SavingsGoalsCompanion(
            id: id,
            userId: userId,
            name: name,
            targetAmount: targetAmount,
            currentAmount: currentAmount,
            deadline: deadline,
            emoji: emoji,
            colorHex: colorHex,
            createdAt: createdAt,
            isCompleted: isCompleted,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            required String name,
            required double targetAmount,
            Value<double> currentAmount = const Value.absent(),
            Value<DateTime?> deadline = const Value.absent(),
            Value<String> emoji = const Value.absent(),
            Value<String> colorHex = const Value.absent(),
            required DateTime createdAt,
            Value<bool> isCompleted = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SavingsGoalsCompanion.insert(
            id: id,
            userId: userId,
            name: name,
            targetAmount: targetAmount,
            currentAmount: currentAmount,
            deadline: deadline,
            emoji: emoji,
            colorHex: colorHex,
            createdAt: createdAt,
            isCompleted: isCompleted,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SavingsGoalsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SavingsGoalsTable,
    GoalEntry,
    $$SavingsGoalsTableFilterComposer,
    $$SavingsGoalsTableOrderingComposer,
    $$SavingsGoalsTableAnnotationComposer,
    $$SavingsGoalsTableCreateCompanionBuilder,
    $$SavingsGoalsTableUpdateCompanionBuilder,
    (GoalEntry, BaseReferences<_$AppDatabase, $SavingsGoalsTable, GoalEntry>),
    GoalEntry,
    PrefetchHooks Function()>;
typedef $$SubscriptionEntriesTableCreateCompanionBuilder
    = SubscriptionEntriesCompanion Function({
  required String id,
  required String userId,
  required String name,
  required double amount,
  Value<String> period,
  required DateTime nextDate,
  Value<String> category,
  Value<String> emoji,
  Value<bool> isActive,
  Value<int> rowid,
});
typedef $$SubscriptionEntriesTableUpdateCompanionBuilder
    = SubscriptionEntriesCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String> name,
  Value<double> amount,
  Value<String> period,
  Value<DateTime> nextDate,
  Value<String> category,
  Value<String> emoji,
  Value<bool> isActive,
  Value<int> rowid,
});

class $$SubscriptionEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SubscriptionEntriesTable> {
  $$SubscriptionEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get period => $composableBuilder(
      column: $table.period, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextDate => $composableBuilder(
      column: $table.nextDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get emoji => $composableBuilder(
      column: $table.emoji, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));
}

class $$SubscriptionEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SubscriptionEntriesTable> {
  $$SubscriptionEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get period => $composableBuilder(
      column: $table.period, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextDate => $composableBuilder(
      column: $table.nextDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get emoji => $composableBuilder(
      column: $table.emoji, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));
}

class $$SubscriptionEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubscriptionEntriesTable> {
  $$SubscriptionEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get period =>
      $composableBuilder(column: $table.period, builder: (column) => column);

  GeneratedColumn<DateTime> get nextDate =>
      $composableBuilder(column: $table.nextDate, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$SubscriptionEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SubscriptionEntriesTable,
    SubEntry,
    $$SubscriptionEntriesTableFilterComposer,
    $$SubscriptionEntriesTableOrderingComposer,
    $$SubscriptionEntriesTableAnnotationComposer,
    $$SubscriptionEntriesTableCreateCompanionBuilder,
    $$SubscriptionEntriesTableUpdateCompanionBuilder,
    (
      SubEntry,
      BaseReferences<_$AppDatabase, $SubscriptionEntriesTable, SubEntry>
    ),
    SubEntry,
    PrefetchHooks Function()> {
  $$SubscriptionEntriesTableTableManager(
      _$AppDatabase db, $SubscriptionEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubscriptionEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubscriptionEntriesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubscriptionEntriesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String> period = const Value.absent(),
            Value<DateTime> nextDate = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> emoji = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SubscriptionEntriesCompanion(
            id: id,
            userId: userId,
            name: name,
            amount: amount,
            period: period,
            nextDate: nextDate,
            category: category,
            emoji: emoji,
            isActive: isActive,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            required String name,
            required double amount,
            Value<String> period = const Value.absent(),
            required DateTime nextDate,
            Value<String> category = const Value.absent(),
            Value<String> emoji = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SubscriptionEntriesCompanion.insert(
            id: id,
            userId: userId,
            name: name,
            amount: amount,
            period: period,
            nextDate: nextDate,
            category: category,
            emoji: emoji,
            isActive: isActive,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SubscriptionEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SubscriptionEntriesTable,
    SubEntry,
    $$SubscriptionEntriesTableFilterComposer,
    $$SubscriptionEntriesTableOrderingComposer,
    $$SubscriptionEntriesTableAnnotationComposer,
    $$SubscriptionEntriesTableCreateCompanionBuilder,
    $$SubscriptionEntriesTableUpdateCompanionBuilder,
    (
      SubEntry,
      BaseReferences<_$AppDatabase, $SubscriptionEntriesTable, SubEntry>
    ),
    SubEntry,
    PrefetchHooks Function()>;
typedef $$CustomCategoriesTableCreateCompanionBuilder
    = CustomCategoriesCompanion Function({
  required String id,
  required String userId,
  required String label,
  Value<String> emoji,
  Value<String> colorHex,
  Value<bool> isIncome,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$CustomCategoriesTableUpdateCompanionBuilder
    = CustomCategoriesCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String> label,
  Value<String> emoji,
  Value<String> colorHex,
  Value<bool> isIncome,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$CustomCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CustomCategoriesTable> {
  $$CustomCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get emoji => $composableBuilder(
      column: $table.emoji, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get colorHex => $composableBuilder(
      column: $table.colorHex, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isIncome => $composableBuilder(
      column: $table.isIncome, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$CustomCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomCategoriesTable> {
  $$CustomCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get emoji => $composableBuilder(
      column: $table.emoji, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get colorHex => $composableBuilder(
      column: $table.colorHex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isIncome => $composableBuilder(
      column: $table.isIncome, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$CustomCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomCategoriesTable> {
  $$CustomCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<bool> get isIncome =>
      $composableBuilder(column: $table.isIncome, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CustomCategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CustomCategoriesTable,
    CustomCategoryEntry,
    $$CustomCategoriesTableFilterComposer,
    $$CustomCategoriesTableOrderingComposer,
    $$CustomCategoriesTableAnnotationComposer,
    $$CustomCategoriesTableCreateCompanionBuilder,
    $$CustomCategoriesTableUpdateCompanionBuilder,
    (
      CustomCategoryEntry,
      BaseReferences<_$AppDatabase, $CustomCategoriesTable, CustomCategoryEntry>
    ),
    CustomCategoryEntry,
    PrefetchHooks Function()> {
  $$CustomCategoriesTableTableManager(
      _$AppDatabase db, $CustomCategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> label = const Value.absent(),
            Value<String> emoji = const Value.absent(),
            Value<String> colorHex = const Value.absent(),
            Value<bool> isIncome = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CustomCategoriesCompanion(
            id: id,
            userId: userId,
            label: label,
            emoji: emoji,
            colorHex: colorHex,
            isIncome: isIncome,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            required String label,
            Value<String> emoji = const Value.absent(),
            Value<String> colorHex = const Value.absent(),
            Value<bool> isIncome = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CustomCategoriesCompanion.insert(
            id: id,
            userId: userId,
            label: label,
            emoji: emoji,
            colorHex: colorHex,
            isIncome: isIncome,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CustomCategoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CustomCategoriesTable,
    CustomCategoryEntry,
    $$CustomCategoriesTableFilterComposer,
    $$CustomCategoriesTableOrderingComposer,
    $$CustomCategoriesTableAnnotationComposer,
    $$CustomCategoriesTableCreateCompanionBuilder,
    $$CustomCategoriesTableUpdateCompanionBuilder,
    (
      CustomCategoryEntry,
      BaseReferences<_$AppDatabase, $CustomCategoriesTable, CustomCategoryEntry>
    ),
    CustomCategoryEntry,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$BudgetsTableTableManager get budgets =>
      $$BudgetsTableTableManager(_db, _db.budgets);
  $$SavingsGoalsTableTableManager get savingsGoals =>
      $$SavingsGoalsTableTableManager(_db, _db.savingsGoals);
  $$SubscriptionEntriesTableTableManager get subscriptionEntries =>
      $$SubscriptionEntriesTableTableManager(_db, _db.subscriptionEntries);
  $$CustomCategoriesTableTableManager get customCategories =>
      $$CustomCategoriesTableTableManager(_db, _db.customCategories);
}
