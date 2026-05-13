// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AccountsTable extends Accounts with TableInfo<$AccountsTable, Account> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _accountCategoryMeta =
      const VerificationMeta('accountCategory');
  @override
  late final GeneratedColumn<String> accountCategory = GeneratedColumn<String>(
      'account_category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _initialBalanceMinorMeta =
      const VerificationMeta('initialBalanceMinor');
  @override
  late final GeneratedColumn<int> initialBalanceMinor = GeneratedColumn<int>(
      'initial_balance_minor', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _currencyCodeMeta =
      const VerificationMeta('currencyCode');
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
      'currency_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _includeInNetWorthMeta =
      const VerificationMeta('includeInNetWorth');
  @override
  late final GeneratedColumn<bool> includeInNetWorth = GeneratedColumn<bool>(
      'include_in_net_worth', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("include_in_net_worth" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _isProtectedMeta =
      const VerificationMeta('isProtected');
  @override
  late final GeneratedColumn<bool> isProtected = GeneratedColumn<bool>(
      'is_protected', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_protected" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isSystemMeta =
      const VerificationMeta('isSystem');
  @override
  late final GeneratedColumn<bool> isSystem = GeneratedColumn<bool>(
      'is_system', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_system" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _displayOrderMeta =
      const VerificationMeta('displayOrder');
  @override
  late final GeneratedColumn<int> displayOrder = GeneratedColumn<int>(
      'display_order', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _metadataMeta =
      const VerificationMeta('metadata');
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
      'metadata', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _largeTxnThresholdMinorMeta =
      const VerificationMeta('largeTxnThresholdMinor');
  @override
  late final GeneratedColumn<int> largeTxnThresholdMinor = GeneratedColumn<int>(
      'large_txn_threshold_minor', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        accountCategory,
        initialBalanceMinor,
        currencyCode,
        includeInNetWorth,
        notes,
        isDeleted,
        deletedAt,
        isProtected,
        isSystem,
        displayOrder,
        createdAt,
        updatedAt,
        metadata,
        largeTxnThresholdMinor
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(Insertable<Account> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('account_category')) {
      context.handle(
          _accountCategoryMeta,
          accountCategory.isAcceptableOrUnknown(
              data['account_category']!, _accountCategoryMeta));
    } else if (isInserting) {
      context.missing(_accountCategoryMeta);
    }
    if (data.containsKey('initial_balance_minor')) {
      context.handle(
          _initialBalanceMinorMeta,
          initialBalanceMinor.isAcceptableOrUnknown(
              data['initial_balance_minor']!, _initialBalanceMinorMeta));
    }
    if (data.containsKey('currency_code')) {
      context.handle(
          _currencyCodeMeta,
          currencyCode.isAcceptableOrUnknown(
              data['currency_code']!, _currencyCodeMeta));
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('include_in_net_worth')) {
      context.handle(
          _includeInNetWorthMeta,
          includeInNetWorth.isAcceptableOrUnknown(
              data['include_in_net_worth']!, _includeInNetWorthMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('is_protected')) {
      context.handle(
          _isProtectedMeta,
          isProtected.isAcceptableOrUnknown(
              data['is_protected']!, _isProtectedMeta));
    }
    if (data.containsKey('is_system')) {
      context.handle(_isSystemMeta,
          isSystem.isAcceptableOrUnknown(data['is_system']!, _isSystemMeta));
    }
    if (data.containsKey('display_order')) {
      context.handle(
          _displayOrderMeta,
          displayOrder.isAcceptableOrUnknown(
              data['display_order']!, _displayOrderMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('metadata')) {
      context.handle(_metadataMeta,
          metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta));
    }
    if (data.containsKey('large_txn_threshold_minor')) {
      context.handle(
          _largeTxnThresholdMinorMeta,
          largeTxnThresholdMinor.isAcceptableOrUnknown(
              data['large_txn_threshold_minor']!, _largeTxnThresholdMinorMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Account map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Account(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      accountCategory: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}account_category'])!,
      initialBalanceMinor: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}initial_balance_minor'])!,
      currencyCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency_code'])!,
      includeInNetWorth: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}include_in_net_worth'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}deleted_at']),
      isProtected: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_protected'])!,
      isSystem: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_system'])!,
      displayOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}display_order']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      metadata: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metadata']),
      largeTxnThresholdMinor: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}large_txn_threshold_minor']),
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }
}

class Account extends DataClass implements Insertable<Account> {
  /// Stable UUID v4 identifier.
  final String id;

  /// Display name. Uniqueness enforced at app layer (including soft-deleted).
  final String name;

  /// Account type. CHECK constraint enforced at domain layer.
  final String accountCategory;

  /// Opening balance in minor units. Applied once as a ledger entry.
  final int initialBalanceMinor;

  /// ISO 4217 currency code. Immutable after creation.
  final String currencyCode;

  /// Whether this account is included in net worth computation.
  final bool includeInNetWorth;

  /// Optional free-form note.
  final String? notes;

  /// Soft-delete flag.
  final bool isDeleted;

  /// Unix epoch seconds set when account is soft-deleted.
  final int? deletedAt;

  /// True for EQ and BAI/BAE accounts; blocks user deletion.
  final bool isProtected;

  /// True for system-generated accounts (e.g. EQ per currency). Hidden from
  /// all user views.
  final bool isSystem;

  /// User-defined sort position; NULL means alphabetical ordering.
  final int? displayOrder;

  /// Unix epoch seconds when this row was created.
  final int createdAt;

  /// Unix epoch seconds when this row was last modified.
  final int updatedAt;

  /// JSON escape hatch for future extensibility.
  final String? metadata;

  /// Per-account large-transaction warning threshold in minor units of the
  /// account's native currency. NULL means no threshold is configured.
  ///
  /// Compared against transaction amount in the account's native currency
  /// (TC-047). Set to NULL by default; user configures via Settings >
  /// Warnings & Limits > Per-Account Limits.
  final int? largeTxnThresholdMinor;
  const Account(
      {required this.id,
      required this.name,
      required this.accountCategory,
      required this.initialBalanceMinor,
      required this.currencyCode,
      required this.includeInNetWorth,
      this.notes,
      required this.isDeleted,
      this.deletedAt,
      required this.isProtected,
      required this.isSystem,
      this.displayOrder,
      required this.createdAt,
      required this.updatedAt,
      this.metadata,
      this.largeTxnThresholdMinor});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['account_category'] = Variable<String>(accountCategory);
    map['initial_balance_minor'] = Variable<int>(initialBalanceMinor);
    map['currency_code'] = Variable<String>(currencyCode);
    map['include_in_net_worth'] = Variable<bool>(includeInNetWorth);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['is_protected'] = Variable<bool>(isProtected);
    map['is_system'] = Variable<bool>(isSystem);
    if (!nullToAbsent || displayOrder != null) {
      map['display_order'] = Variable<int>(displayOrder);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || metadata != null) {
      map['metadata'] = Variable<String>(metadata);
    }
    if (!nullToAbsent || largeTxnThresholdMinor != null) {
      map['large_txn_threshold_minor'] = Variable<int>(largeTxnThresholdMinor);
    }
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      id: Value(id),
      name: Value(name),
      accountCategory: Value(accountCategory),
      initialBalanceMinor: Value(initialBalanceMinor),
      currencyCode: Value(currencyCode),
      includeInNetWorth: Value(includeInNetWorth),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      isDeleted: Value(isDeleted),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      isProtected: Value(isProtected),
      isSystem: Value(isSystem),
      displayOrder: displayOrder == null && nullToAbsent
          ? const Value.absent()
          : Value(displayOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      metadata: metadata == null && nullToAbsent
          ? const Value.absent()
          : Value(metadata),
      largeTxnThresholdMinor: largeTxnThresholdMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(largeTxnThresholdMinor),
    );
  }

  factory Account.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Account(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      accountCategory: serializer.fromJson<String>(json['accountCategory']),
      initialBalanceMinor:
          serializer.fromJson<int>(json['initialBalanceMinor']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      includeInNetWorth: serializer.fromJson<bool>(json['includeInNetWorth']),
      notes: serializer.fromJson<String?>(json['notes']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      isProtected: serializer.fromJson<bool>(json['isProtected']),
      isSystem: serializer.fromJson<bool>(json['isSystem']),
      displayOrder: serializer.fromJson<int?>(json['displayOrder']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      metadata: serializer.fromJson<String?>(json['metadata']),
      largeTxnThresholdMinor:
          serializer.fromJson<int?>(json['largeTxnThresholdMinor']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'accountCategory': serializer.toJson<String>(accountCategory),
      'initialBalanceMinor': serializer.toJson<int>(initialBalanceMinor),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'includeInNetWorth': serializer.toJson<bool>(includeInNetWorth),
      'notes': serializer.toJson<String?>(notes),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'isProtected': serializer.toJson<bool>(isProtected),
      'isSystem': serializer.toJson<bool>(isSystem),
      'displayOrder': serializer.toJson<int?>(displayOrder),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'metadata': serializer.toJson<String?>(metadata),
      'largeTxnThresholdMinor': serializer.toJson<int?>(largeTxnThresholdMinor),
    };
  }

  Account copyWith(
          {String? id,
          String? name,
          String? accountCategory,
          int? initialBalanceMinor,
          String? currencyCode,
          bool? includeInNetWorth,
          Value<String?> notes = const Value.absent(),
          bool? isDeleted,
          Value<int?> deletedAt = const Value.absent(),
          bool? isProtected,
          bool? isSystem,
          Value<int?> displayOrder = const Value.absent(),
          int? createdAt,
          int? updatedAt,
          Value<String?> metadata = const Value.absent(),
          Value<int?> largeTxnThresholdMinor = const Value.absent()}) =>
      Account(
        id: id ?? this.id,
        name: name ?? this.name,
        accountCategory: accountCategory ?? this.accountCategory,
        initialBalanceMinor: initialBalanceMinor ?? this.initialBalanceMinor,
        currencyCode: currencyCode ?? this.currencyCode,
        includeInNetWorth: includeInNetWorth ?? this.includeInNetWorth,
        notes: notes.present ? notes.value : this.notes,
        isDeleted: isDeleted ?? this.isDeleted,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        isProtected: isProtected ?? this.isProtected,
        isSystem: isSystem ?? this.isSystem,
        displayOrder:
            displayOrder.present ? displayOrder.value : this.displayOrder,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        metadata: metadata.present ? metadata.value : this.metadata,
        largeTxnThresholdMinor: largeTxnThresholdMinor.present
            ? largeTxnThresholdMinor.value
            : this.largeTxnThresholdMinor,
      );
  Account copyWithCompanion(AccountsCompanion data) {
    return Account(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      accountCategory: data.accountCategory.present
          ? data.accountCategory.value
          : this.accountCategory,
      initialBalanceMinor: data.initialBalanceMinor.present
          ? data.initialBalanceMinor.value
          : this.initialBalanceMinor,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      includeInNetWorth: data.includeInNetWorth.present
          ? data.includeInNetWorth.value
          : this.includeInNetWorth,
      notes: data.notes.present ? data.notes.value : this.notes,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      isProtected:
          data.isProtected.present ? data.isProtected.value : this.isProtected,
      isSystem: data.isSystem.present ? data.isSystem.value : this.isSystem,
      displayOrder: data.displayOrder.present
          ? data.displayOrder.value
          : this.displayOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
      largeTxnThresholdMinor: data.largeTxnThresholdMinor.present
          ? data.largeTxnThresholdMinor.value
          : this.largeTxnThresholdMinor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Account(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('accountCategory: $accountCategory, ')
          ..write('initialBalanceMinor: $initialBalanceMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('includeInNetWorth: $includeInNetWorth, ')
          ..write('notes: $notes, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isProtected: $isProtected, ')
          ..write('isSystem: $isSystem, ')
          ..write('displayOrder: $displayOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('metadata: $metadata, ')
          ..write('largeTxnThresholdMinor: $largeTxnThresholdMinor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      accountCategory,
      initialBalanceMinor,
      currencyCode,
      includeInNetWorth,
      notes,
      isDeleted,
      deletedAt,
      isProtected,
      isSystem,
      displayOrder,
      createdAt,
      updatedAt,
      metadata,
      largeTxnThresholdMinor);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Account &&
          other.id == this.id &&
          other.name == this.name &&
          other.accountCategory == this.accountCategory &&
          other.initialBalanceMinor == this.initialBalanceMinor &&
          other.currencyCode == this.currencyCode &&
          other.includeInNetWorth == this.includeInNetWorth &&
          other.notes == this.notes &&
          other.isDeleted == this.isDeleted &&
          other.deletedAt == this.deletedAt &&
          other.isProtected == this.isProtected &&
          other.isSystem == this.isSystem &&
          other.displayOrder == this.displayOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.metadata == this.metadata &&
          other.largeTxnThresholdMinor == this.largeTxnThresholdMinor);
}

class AccountsCompanion extends UpdateCompanion<Account> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> accountCategory;
  final Value<int> initialBalanceMinor;
  final Value<String> currencyCode;
  final Value<bool> includeInNetWorth;
  final Value<String?> notes;
  final Value<bool> isDeleted;
  final Value<int?> deletedAt;
  final Value<bool> isProtected;
  final Value<bool> isSystem;
  final Value<int?> displayOrder;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String?> metadata;
  final Value<int?> largeTxnThresholdMinor;
  final Value<int> rowid;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.accountCategory = const Value.absent(),
    this.initialBalanceMinor = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.includeInNetWorth = const Value.absent(),
    this.notes = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.isProtected = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.displayOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.metadata = const Value.absent(),
    this.largeTxnThresholdMinor = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountsCompanion.insert({
    required String id,
    required String name,
    required String accountCategory,
    this.initialBalanceMinor = const Value.absent(),
    required String currencyCode,
    this.includeInNetWorth = const Value.absent(),
    this.notes = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.isProtected = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.displayOrder = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.metadata = const Value.absent(),
    this.largeTxnThresholdMinor = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        accountCategory = Value(accountCategory),
        currencyCode = Value(currencyCode),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Account> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? accountCategory,
    Expression<int>? initialBalanceMinor,
    Expression<String>? currencyCode,
    Expression<bool>? includeInNetWorth,
    Expression<String>? notes,
    Expression<bool>? isDeleted,
    Expression<int>? deletedAt,
    Expression<bool>? isProtected,
    Expression<bool>? isSystem,
    Expression<int>? displayOrder,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? metadata,
    Expression<int>? largeTxnThresholdMinor,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (accountCategory != null) 'account_category': accountCategory,
      if (initialBalanceMinor != null)
        'initial_balance_minor': initialBalanceMinor,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (includeInNetWorth != null) 'include_in_net_worth': includeInNetWorth,
      if (notes != null) 'notes': notes,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (isProtected != null) 'is_protected': isProtected,
      if (isSystem != null) 'is_system': isSystem,
      if (displayOrder != null) 'display_order': displayOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (metadata != null) 'metadata': metadata,
      if (largeTxnThresholdMinor != null)
        'large_txn_threshold_minor': largeTxnThresholdMinor,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? accountCategory,
      Value<int>? initialBalanceMinor,
      Value<String>? currencyCode,
      Value<bool>? includeInNetWorth,
      Value<String?>? notes,
      Value<bool>? isDeleted,
      Value<int?>? deletedAt,
      Value<bool>? isProtected,
      Value<bool>? isSystem,
      Value<int?>? displayOrder,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<String?>? metadata,
      Value<int?>? largeTxnThresholdMinor,
      Value<int>? rowid}) {
    return AccountsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      accountCategory: accountCategory ?? this.accountCategory,
      initialBalanceMinor: initialBalanceMinor ?? this.initialBalanceMinor,
      currencyCode: currencyCode ?? this.currencyCode,
      includeInNetWorth: includeInNetWorth ?? this.includeInNetWorth,
      notes: notes ?? this.notes,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      isProtected: isProtected ?? this.isProtected,
      isSystem: isSystem ?? this.isSystem,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
      largeTxnThresholdMinor:
          largeTxnThresholdMinor ?? this.largeTxnThresholdMinor,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (accountCategory.present) {
      map['account_category'] = Variable<String>(accountCategory.value);
    }
    if (initialBalanceMinor.present) {
      map['initial_balance_minor'] = Variable<int>(initialBalanceMinor.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (includeInNetWorth.present) {
      map['include_in_net_worth'] = Variable<bool>(includeInNetWorth.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (isProtected.present) {
      map['is_protected'] = Variable<bool>(isProtected.value);
    }
    if (isSystem.present) {
      map['is_system'] = Variable<bool>(isSystem.value);
    }
    if (displayOrder.present) {
      map['display_order'] = Variable<int>(displayOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    if (largeTxnThresholdMinor.present) {
      map['large_txn_threshold_minor'] =
          Variable<int>(largeTxnThresholdMinor.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('accountCategory: $accountCategory, ')
          ..write('initialBalanceMinor: $initialBalanceMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('includeInNetWorth: $includeInNetWorth, ')
          ..write('notes: $notes, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isProtected: $isProtected, ')
          ..write('isSystem: $isSystem, ')
          ..write('displayOrder: $displayOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('metadata: $metadata, ')
          ..write('largeTxnThresholdMinor: $largeTxnThresholdMinor, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AccountDetailsTable extends AccountDetails
    with TableInfo<$AccountDetailsTable, AccountDetail> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountDetailsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _accountIdMeta =
      const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
      'account_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES accounts (id) ON DELETE CASCADE'));
  static const VerificationMeta _detailKeyMeta =
      const VerificationMeta('detailKey');
  @override
  late final GeneratedColumn<String> detailKey = GeneratedColumn<String>(
      'detail_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _detailValueMeta =
      const VerificationMeta('detailValue');
  @override
  late final GeneratedColumn<String> detailValue = GeneratedColumn<String>(
      'detail_value', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _detailValueEncryptedMeta =
      const VerificationMeta('detailValueEncrypted');
  @override
  late final GeneratedColumn<String> detailValueEncrypted =
      GeneratedColumn<String>('detail_value_encrypted', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, accountId, detailKey, detailValue, detailValueEncrypted, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'account_details';
  @override
  VerificationContext validateIntegrity(Insertable<AccountDetail> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta,
          accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('detail_key')) {
      context.handle(_detailKeyMeta,
          detailKey.isAcceptableOrUnknown(data['detail_key']!, _detailKeyMeta));
    } else if (isInserting) {
      context.missing(_detailKeyMeta);
    }
    if (data.containsKey('detail_value')) {
      context.handle(
          _detailValueMeta,
          detailValue.isAcceptableOrUnknown(
              data['detail_value']!, _detailValueMeta));
    }
    if (data.containsKey('detail_value_encrypted')) {
      context.handle(
          _detailValueEncryptedMeta,
          detailValueEncrypted.isAcceptableOrUnknown(
              data['detail_value_encrypted']!, _detailValueEncryptedMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AccountDetail map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccountDetail(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_id'])!,
      detailKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}detail_key'])!,
      detailValue: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}detail_value']),
      detailValueEncrypted: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}detail_value_encrypted']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $AccountDetailsTable createAlias(String alias) {
    return $AccountDetailsTable(attachedDatabase, alias);
  }
}

class AccountDetail extends DataClass implements Insertable<AccountDetail> {
  /// Stable UUID v4 identifier.
  final String id;

  /// FK → accounts(id) ON DELETE CASCADE.
  final String accountId;

  /// Field name (e.g. `bank_name`, `card_number`). Valid values are
  /// enforced at the application layer.
  final String detailKey;

  /// Plain-text value (used for non-sensitive fields).
  final String? detailValue;

  /// AES-encrypted blob for sensitive fields (e.g. card_number, account_number).
  final String? detailValueEncrypted;

  /// Unix epoch seconds when this row was last modified.
  final int updatedAt;
  const AccountDetail(
      {required this.id,
      required this.accountId,
      required this.detailKey,
      this.detailValue,
      this.detailValueEncrypted,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['account_id'] = Variable<String>(accountId);
    map['detail_key'] = Variable<String>(detailKey);
    if (!nullToAbsent || detailValue != null) {
      map['detail_value'] = Variable<String>(detailValue);
    }
    if (!nullToAbsent || detailValueEncrypted != null) {
      map['detail_value_encrypted'] = Variable<String>(detailValueEncrypted);
    }
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  AccountDetailsCompanion toCompanion(bool nullToAbsent) {
    return AccountDetailsCompanion(
      id: Value(id),
      accountId: Value(accountId),
      detailKey: Value(detailKey),
      detailValue: detailValue == null && nullToAbsent
          ? const Value.absent()
          : Value(detailValue),
      detailValueEncrypted: detailValueEncrypted == null && nullToAbsent
          ? const Value.absent()
          : Value(detailValueEncrypted),
      updatedAt: Value(updatedAt),
    );
  }

  factory AccountDetail.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccountDetail(
      id: serializer.fromJson<String>(json['id']),
      accountId: serializer.fromJson<String>(json['accountId']),
      detailKey: serializer.fromJson<String>(json['detailKey']),
      detailValue: serializer.fromJson<String?>(json['detailValue']),
      detailValueEncrypted:
          serializer.fromJson<String?>(json['detailValueEncrypted']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'accountId': serializer.toJson<String>(accountId),
      'detailKey': serializer.toJson<String>(detailKey),
      'detailValue': serializer.toJson<String?>(detailValue),
      'detailValueEncrypted': serializer.toJson<String?>(detailValueEncrypted),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  AccountDetail copyWith(
          {String? id,
          String? accountId,
          String? detailKey,
          Value<String?> detailValue = const Value.absent(),
          Value<String?> detailValueEncrypted = const Value.absent(),
          int? updatedAt}) =>
      AccountDetail(
        id: id ?? this.id,
        accountId: accountId ?? this.accountId,
        detailKey: detailKey ?? this.detailKey,
        detailValue: detailValue.present ? detailValue.value : this.detailValue,
        detailValueEncrypted: detailValueEncrypted.present
            ? detailValueEncrypted.value
            : this.detailValueEncrypted,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AccountDetail copyWithCompanion(AccountDetailsCompanion data) {
    return AccountDetail(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      detailKey: data.detailKey.present ? data.detailKey.value : this.detailKey,
      detailValue:
          data.detailValue.present ? data.detailValue.value : this.detailValue,
      detailValueEncrypted: data.detailValueEncrypted.present
          ? data.detailValueEncrypted.value
          : this.detailValueEncrypted,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AccountDetail(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('detailKey: $detailKey, ')
          ..write('detailValue: $detailValue, ')
          ..write('detailValueEncrypted: $detailValueEncrypted, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, accountId, detailKey, detailValue, detailValueEncrypted, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccountDetail &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.detailKey == this.detailKey &&
          other.detailValue == this.detailValue &&
          other.detailValueEncrypted == this.detailValueEncrypted &&
          other.updatedAt == this.updatedAt);
}

class AccountDetailsCompanion extends UpdateCompanion<AccountDetail> {
  final Value<String> id;
  final Value<String> accountId;
  final Value<String> detailKey;
  final Value<String?> detailValue;
  final Value<String?> detailValueEncrypted;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const AccountDetailsCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.detailKey = const Value.absent(),
    this.detailValue = const Value.absent(),
    this.detailValueEncrypted = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountDetailsCompanion.insert({
    required String id,
    required String accountId,
    required String detailKey,
    this.detailValue = const Value.absent(),
    this.detailValueEncrypted = const Value.absent(),
    required int updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        accountId = Value(accountId),
        detailKey = Value(detailKey),
        updatedAt = Value(updatedAt);
  static Insertable<AccountDetail> custom({
    Expression<String>? id,
    Expression<String>? accountId,
    Expression<String>? detailKey,
    Expression<String>? detailValue,
    Expression<String>? detailValueEncrypted,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (detailKey != null) 'detail_key': detailKey,
      if (detailValue != null) 'detail_value': detailValue,
      if (detailValueEncrypted != null)
        'detail_value_encrypted': detailValueEncrypted,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountDetailsCompanion copyWith(
      {Value<String>? id,
      Value<String>? accountId,
      Value<String>? detailKey,
      Value<String?>? detailValue,
      Value<String?>? detailValueEncrypted,
      Value<int>? updatedAt,
      Value<int>? rowid}) {
    return AccountDetailsCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      detailKey: detailKey ?? this.detailKey,
      detailValue: detailValue ?? this.detailValue,
      detailValueEncrypted: detailValueEncrypted ?? this.detailValueEncrypted,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (detailKey.present) {
      map['detail_key'] = Variable<String>(detailKey.value);
    }
    if (detailValue.present) {
      map['detail_value'] = Variable<String>(detailValue.value);
    }
    if (detailValueEncrypted.present) {
      map['detail_value_encrypted'] =
          Variable<String>(detailValueEncrypted.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountDetailsCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('detailKey: $detailKey, ')
          ..write('detailValue: $detailValue, ')
          ..write('detailValueEncrypted: $detailValueEncrypted, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CurrenciesTable extends Currencies
    with TableInfo<$CurrenciesTable, Currency> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CurrenciesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
      'symbol', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _minorUnitsMeta =
      const VerificationMeta('minorUnits');
  @override
  late final GeneratedColumn<int> minorUnits = GeneratedColumn<int>(
      'minor_units', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(2));
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
      [code, name, symbol, minorUnits, isActive];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'currencies';
  @override
  VerificationContext validateIntegrity(Insertable<Currency> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('symbol')) {
      context.handle(_symbolMeta,
          symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta));
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    if (data.containsKey('minor_units')) {
      context.handle(
          _minorUnitsMeta,
          minorUnits.isAcceptableOrUnknown(
              data['minor_units']!, _minorUnitsMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {code};
  @override
  Currency map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Currency(
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      symbol: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}symbol'])!,
      minorUnits: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}minor_units'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
    );
  }

  @override
  $CurrenciesTable createAlias(String alias) {
    return $CurrenciesTable(attachedDatabase, alias);
  }
}

class Currency extends DataClass implements Insertable<Currency> {
  /// ISO 4217 3-letter currency code (e.g. 'USD', 'INR').
  final String code;

  /// Full currency name (e.g. 'US Dollar').
  final String name;

  /// Display symbol (e.g. '$', '₹').
  final String symbol;

  /// Number of decimal places. Valid values: 0 (JPY), 2 (USD), 3 (BHD).
  final int minorUnits;

  /// False for retired ISO currencies.
  final bool isActive;
  const Currency(
      {required this.code,
      required this.name,
      required this.symbol,
      required this.minorUnits,
      required this.isActive});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    map['symbol'] = Variable<String>(symbol);
    map['minor_units'] = Variable<int>(minorUnits);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  CurrenciesCompanion toCompanion(bool nullToAbsent) {
    return CurrenciesCompanion(
      code: Value(code),
      name: Value(name),
      symbol: Value(symbol),
      minorUnits: Value(minorUnits),
      isActive: Value(isActive),
    );
  }

  factory Currency.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Currency(
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      symbol: serializer.fromJson<String>(json['symbol']),
      minorUnits: serializer.fromJson<int>(json['minorUnits']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'symbol': serializer.toJson<String>(symbol),
      'minorUnits': serializer.toJson<int>(minorUnits),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  Currency copyWith(
          {String? code,
          String? name,
          String? symbol,
          int? minorUnits,
          bool? isActive}) =>
      Currency(
        code: code ?? this.code,
        name: name ?? this.name,
        symbol: symbol ?? this.symbol,
        minorUnits: minorUnits ?? this.minorUnits,
        isActive: isActive ?? this.isActive,
      );
  Currency copyWithCompanion(CurrenciesCompanion data) {
    return Currency(
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      minorUnits:
          data.minorUnits.present ? data.minorUnits.value : this.minorUnits,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Currency(')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('symbol: $symbol, ')
          ..write('minorUnits: $minorUnits, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(code, name, symbol, minorUnits, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Currency &&
          other.code == this.code &&
          other.name == this.name &&
          other.symbol == this.symbol &&
          other.minorUnits == this.minorUnits &&
          other.isActive == this.isActive);
}

class CurrenciesCompanion extends UpdateCompanion<Currency> {
  final Value<String> code;
  final Value<String> name;
  final Value<String> symbol;
  final Value<int> minorUnits;
  final Value<bool> isActive;
  final Value<int> rowid;
  const CurrenciesCompanion({
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.symbol = const Value.absent(),
    this.minorUnits = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CurrenciesCompanion.insert({
    required String code,
    required String name,
    required String symbol,
    this.minorUnits = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : code = Value(code),
        name = Value(name),
        symbol = Value(symbol);
  static Insertable<Currency> custom({
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? symbol,
    Expression<int>? minorUnits,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (symbol != null) 'symbol': symbol,
      if (minorUnits != null) 'minor_units': minorUnits,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CurrenciesCompanion copyWith(
      {Value<String>? code,
      Value<String>? name,
      Value<String>? symbol,
      Value<int>? minorUnits,
      Value<bool>? isActive,
      Value<int>? rowid}) {
    return CurrenciesCompanion(
      code: code ?? this.code,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      minorUnits: minorUnits ?? this.minorUnits,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (minorUnits.present) {
      map['minor_units'] = Variable<int>(minorUnits.value);
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
    return (StringBuffer('CurrenciesCompanion(')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('symbol: $symbol, ')
          ..write('minorUnits: $minorUnits, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _parentIdMeta =
      const VerificationMeta('parentId');
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
      'parent_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES categories (id)'));
  static const VerificationMeta _treeTypeMeta =
      const VerificationMeta('treeType');
  @override
  late final GeneratedColumn<String> treeType = GeneratedColumn<String>(
      'tree_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _iconRefMeta =
      const VerificationMeta('iconRef');
  @override
  late final GeneratedColumn<String> iconRef = GeneratedColumn<String>(
      'icon_ref', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _isProtectedMeta =
      const VerificationMeta('isProtected');
  @override
  late final GeneratedColumn<bool> isProtected = GeneratedColumn<bool>(
      'is_protected', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_protected" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _largeTxnThresholdMinorMeta =
      const VerificationMeta('largeTxnThresholdMinor');
  @override
  late final GeneratedColumn<int> largeTxnThresholdMinor = GeneratedColumn<int>(
      'large_txn_threshold_minor', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        parentId,
        treeType,
        name,
        iconRef,
        isDeleted,
        deletedAt,
        isProtected,
        sortOrder,
        createdAt,
        updatedAt,
        largeTxnThresholdMinor
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(Insertable<Category> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(_parentIdMeta,
          parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta));
    }
    if (data.containsKey('tree_type')) {
      context.handle(_treeTypeMeta,
          treeType.isAcceptableOrUnknown(data['tree_type']!, _treeTypeMeta));
    } else if (isInserting) {
      context.missing(_treeTypeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon_ref')) {
      context.handle(_iconRefMeta,
          iconRef.isAcceptableOrUnknown(data['icon_ref']!, _iconRefMeta));
    } else if (isInserting) {
      context.missing(_iconRefMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('is_protected')) {
      context.handle(
          _isProtectedMeta,
          isProtected.isAcceptableOrUnknown(
              data['is_protected']!, _isProtectedMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('large_txn_threshold_minor')) {
      context.handle(
          _largeTxnThresholdMinorMeta,
          largeTxnThresholdMinor.isAcceptableOrUnknown(
              data['large_txn_threshold_minor']!, _largeTxnThresholdMinorMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      parentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parent_id']),
      treeType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tree_type'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      iconRef: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon_ref'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}deleted_at']),
      isProtected: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_protected'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      largeTxnThresholdMinor: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}large_txn_threshold_minor']),
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  /// Stable UUID v4 identifier.
  final String id;

  /// Parent category id for subcategories; NULL for root categories.
  final String? parentId;

  /// Which category tree: `income` or `expense`.
  final String treeType;

  /// Display name. Case-insensitive uniqueness enforced at app layer.
  final String name;

  /// Material Symbols icon identifier.
  final String iconRef;

  /// Soft-delete flag.
  final bool isDeleted;

  /// Unix epoch seconds set on soft-delete.
  final int? deletedAt;

  /// True for BAI/BAE and "Balance Adjustment" parent. Blocks user deletion.
  final bool isProtected;

  /// Manual sort position. NULL = alphabetical (v1 default).
  final int? sortOrder;

  /// Unix epoch seconds when this row was created.
  final int createdAt;

  /// Unix epoch seconds when this row was last modified.
  final int updatedAt;

  /// Per-category large-transaction warning threshold in home-currency minor
  /// units. NULL means no threshold is configured.
  ///
  /// Always denominated in the app's home currency (TC-047). Set to NULL by
  /// default; user configures via Settings > Warnings & Limits >
  /// Per-Category Limits.
  final int? largeTxnThresholdMinor;
  const Category(
      {required this.id,
      this.parentId,
      required this.treeType,
      required this.name,
      required this.iconRef,
      required this.isDeleted,
      this.deletedAt,
      required this.isProtected,
      this.sortOrder,
      required this.createdAt,
      required this.updatedAt,
      this.largeTxnThresholdMinor});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    map['tree_type'] = Variable<String>(treeType);
    map['name'] = Variable<String>(name);
    map['icon_ref'] = Variable<String>(iconRef);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['is_protected'] = Variable<bool>(isProtected);
    if (!nullToAbsent || sortOrder != null) {
      map['sort_order'] = Variable<int>(sortOrder);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || largeTxnThresholdMinor != null) {
      map['large_txn_threshold_minor'] = Variable<int>(largeTxnThresholdMinor);
    }
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      treeType: Value(treeType),
      name: Value(name),
      iconRef: Value(iconRef),
      isDeleted: Value(isDeleted),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      isProtected: Value(isProtected),
      sortOrder: sortOrder == null && nullToAbsent
          ? const Value.absent()
          : Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      largeTxnThresholdMinor: largeTxnThresholdMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(largeTxnThresholdMinor),
    );
  }

  factory Category.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<String>(json['id']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      treeType: serializer.fromJson<String>(json['treeType']),
      name: serializer.fromJson<String>(json['name']),
      iconRef: serializer.fromJson<String>(json['iconRef']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      isProtected: serializer.fromJson<bool>(json['isProtected']),
      sortOrder: serializer.fromJson<int?>(json['sortOrder']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      largeTxnThresholdMinor:
          serializer.fromJson<int?>(json['largeTxnThresholdMinor']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'parentId': serializer.toJson<String?>(parentId),
      'treeType': serializer.toJson<String>(treeType),
      'name': serializer.toJson<String>(name),
      'iconRef': serializer.toJson<String>(iconRef),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'isProtected': serializer.toJson<bool>(isProtected),
      'sortOrder': serializer.toJson<int?>(sortOrder),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'largeTxnThresholdMinor': serializer.toJson<int?>(largeTxnThresholdMinor),
    };
  }

  Category copyWith(
          {String? id,
          Value<String?> parentId = const Value.absent(),
          String? treeType,
          String? name,
          String? iconRef,
          bool? isDeleted,
          Value<int?> deletedAt = const Value.absent(),
          bool? isProtected,
          Value<int?> sortOrder = const Value.absent(),
          int? createdAt,
          int? updatedAt,
          Value<int?> largeTxnThresholdMinor = const Value.absent()}) =>
      Category(
        id: id ?? this.id,
        parentId: parentId.present ? parentId.value : this.parentId,
        treeType: treeType ?? this.treeType,
        name: name ?? this.name,
        iconRef: iconRef ?? this.iconRef,
        isDeleted: isDeleted ?? this.isDeleted,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        isProtected: isProtected ?? this.isProtected,
        sortOrder: sortOrder.present ? sortOrder.value : this.sortOrder,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        largeTxnThresholdMinor: largeTxnThresholdMinor.present
            ? largeTxnThresholdMinor.value
            : this.largeTxnThresholdMinor,
      );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      treeType: data.treeType.present ? data.treeType.value : this.treeType,
      name: data.name.present ? data.name.value : this.name,
      iconRef: data.iconRef.present ? data.iconRef.value : this.iconRef,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      isProtected:
          data.isProtected.present ? data.isProtected.value : this.isProtected,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      largeTxnThresholdMinor: data.largeTxnThresholdMinor.present
          ? data.largeTxnThresholdMinor.value
          : this.largeTxnThresholdMinor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('parentId: $parentId, ')
          ..write('treeType: $treeType, ')
          ..write('name: $name, ')
          ..write('iconRef: $iconRef, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isProtected: $isProtected, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('largeTxnThresholdMinor: $largeTxnThresholdMinor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      parentId,
      treeType,
      name,
      iconRef,
      isDeleted,
      deletedAt,
      isProtected,
      sortOrder,
      createdAt,
      updatedAt,
      largeTxnThresholdMinor);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.parentId == this.parentId &&
          other.treeType == this.treeType &&
          other.name == this.name &&
          other.iconRef == this.iconRef &&
          other.isDeleted == this.isDeleted &&
          other.deletedAt == this.deletedAt &&
          other.isProtected == this.isProtected &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.largeTxnThresholdMinor == this.largeTxnThresholdMinor);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<String> id;
  final Value<String?> parentId;
  final Value<String> treeType;
  final Value<String> name;
  final Value<String> iconRef;
  final Value<bool> isDeleted;
  final Value<int?> deletedAt;
  final Value<bool> isProtected;
  final Value<int?> sortOrder;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> largeTxnThresholdMinor;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.parentId = const Value.absent(),
    this.treeType = const Value.absent(),
    this.name = const Value.absent(),
    this.iconRef = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.isProtected = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.largeTxnThresholdMinor = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    this.parentId = const Value.absent(),
    required String treeType,
    required String name,
    required String iconRef,
    this.isDeleted = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.isProtected = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.largeTxnThresholdMinor = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        treeType = Value(treeType),
        name = Value(name),
        iconRef = Value(iconRef),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Category> custom({
    Expression<String>? id,
    Expression<String>? parentId,
    Expression<String>? treeType,
    Expression<String>? name,
    Expression<String>? iconRef,
    Expression<bool>? isDeleted,
    Expression<int>? deletedAt,
    Expression<bool>? isProtected,
    Expression<int>? sortOrder,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? largeTxnThresholdMinor,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (parentId != null) 'parent_id': parentId,
      if (treeType != null) 'tree_type': treeType,
      if (name != null) 'name': name,
      if (iconRef != null) 'icon_ref': iconRef,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (isProtected != null) 'is_protected': isProtected,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (largeTxnThresholdMinor != null)
        'large_txn_threshold_minor': largeTxnThresholdMinor,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith(
      {Value<String>? id,
      Value<String?>? parentId,
      Value<String>? treeType,
      Value<String>? name,
      Value<String>? iconRef,
      Value<bool>? isDeleted,
      Value<int?>? deletedAt,
      Value<bool>? isProtected,
      Value<int?>? sortOrder,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<int?>? largeTxnThresholdMinor,
      Value<int>? rowid}) {
    return CategoriesCompanion(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      treeType: treeType ?? this.treeType,
      name: name ?? this.name,
      iconRef: iconRef ?? this.iconRef,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      isProtected: isProtected ?? this.isProtected,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      largeTxnThresholdMinor:
          largeTxnThresholdMinor ?? this.largeTxnThresholdMinor,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (treeType.present) {
      map['tree_type'] = Variable<String>(treeType.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (iconRef.present) {
      map['icon_ref'] = Variable<String>(iconRef.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (isProtected.present) {
      map['is_protected'] = Variable<bool>(isProtected.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (largeTxnThresholdMinor.present) {
      map['large_txn_threshold_minor'] =
          Variable<int>(largeTxnThresholdMinor.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('parentId: $parentId, ')
          ..write('treeType: $treeType, ')
          ..write('name: $name, ')
          ..write('iconRef: $iconRef, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isProtected: $isProtected, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('largeTxnThresholdMinor: $largeTxnThresholdMinor, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PayeesTable extends Payees with TableInfo<$PayeesTable, Payee> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PayeesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, isDeleted, deletedAt, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payees';
  @override
  VerificationContext validateIntegrity(Insertable<Payee> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Payee map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Payee(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}deleted_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $PayeesTable createAlias(String alias) {
    return $PayeesTable(attachedDatabase, alias);
  }
}

class Payee extends DataClass implements Insertable<Payee> {
  /// Stable UUID v4 identifier.
  final String id;

  /// Payee name. Case-insensitive uniqueness enforced at app layer.
  final String name;

  /// Soft-delete flag.
  final bool isDeleted;

  /// Unix epoch seconds set on soft-delete.
  final int? deletedAt;

  /// Unix epoch seconds when this row was created.
  final int createdAt;

  /// Unix epoch seconds when this row was last modified.
  final int updatedAt;
  const Payee(
      {required this.id,
      required this.name,
      required this.isDeleted,
      this.deletedAt,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  PayeesCompanion toCompanion(bool nullToAbsent) {
    return PayeesCompanion(
      id: Value(id),
      name: Value(name),
      isDeleted: Value(isDeleted),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Payee.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Payee(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  Payee copyWith(
          {String? id,
          String? name,
          bool? isDeleted,
          Value<int?> deletedAt = const Value.absent(),
          int? createdAt,
          int? updatedAt}) =>
      Payee(
        id: id ?? this.id,
        name: name ?? this.name,
        isDeleted: isDeleted ?? this.isDeleted,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Payee copyWithCompanion(PayeesCompanion data) {
    return Payee(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Payee(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, isDeleted, deletedAt, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Payee &&
          other.id == this.id &&
          other.name == this.name &&
          other.isDeleted == this.isDeleted &&
          other.deletedAt == this.deletedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PayeesCompanion extends UpdateCompanion<Payee> {
  final Value<String> id;
  final Value<String> name;
  final Value<bool> isDeleted;
  final Value<int?> deletedAt;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const PayeesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PayeesCompanion.insert({
    required String id,
    required String name,
    this.isDeleted = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Payee> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<bool>? isDeleted,
    Expression<int>? deletedAt,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PayeesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<bool>? isDeleted,
      Value<int?>? deletedAt,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<int>? rowid}) {
    return PayeesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PayeesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecurringTemplatesTable extends RecurringTemplates
    with TableInfo<$RecurringTemplatesTable, RecurringTemplate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _transactionTypeMeta =
      const VerificationMeta('transactionType');
  @override
  late final GeneratedColumn<String> transactionType = GeneratedColumn<String>(
      'transaction_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('active'));
  static const VerificationMeta _amountMinorMeta =
      const VerificationMeta('amountMinor');
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
      'amount_minor', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _currencyCodeMeta =
      const VerificationMeta('currencyCode');
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
      'currency_code', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES currencies (code)'));
  static const VerificationMeta _accountSourceIdMeta =
      const VerificationMeta('accountSourceId');
  @override
  late final GeneratedColumn<String> accountSourceId = GeneratedColumn<String>(
      'account_source_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES accounts (id)'));
  static const VerificationMeta _accountDestinationIdMeta =
      const VerificationMeta('accountDestinationId');
  @override
  late final GeneratedColumn<String> accountDestinationId =
      GeneratedColumn<String>(
          'account_destination_id', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultConstraints:
              GeneratedColumn.constraintIsAlways('REFERENCES accounts (id)'));
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES categories (id)'));
  static const VerificationMeta _subcategoryIdMeta =
      const VerificationMeta('subcategoryId');
  @override
  late final GeneratedColumn<String> subcategoryId = GeneratedColumn<String>(
      'subcategory_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES categories (id)'));
  static const VerificationMeta _payeeIdMeta =
      const VerificationMeta('payeeId');
  @override
  late final GeneratedColumn<String> payeeId = GeneratedColumn<String>(
      'payee_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES payees (id)'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _recurrenceNMeta =
      const VerificationMeta('recurrenceN');
  @override
  late final GeneratedColumn<int> recurrenceN = GeneratedColumn<int>(
      'recurrence_n', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _recurrenceUnitMeta =
      const VerificationMeta('recurrenceUnit');
  @override
  late final GeneratedColumn<String> recurrenceUnit = GeneratedColumn<String>(
      'recurrence_unit', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _recurrenceConstraintsMeta =
      const VerificationMeta('recurrenceConstraints');
  @override
  late final GeneratedColumn<String> recurrenceConstraints =
      GeneratedColumn<String>('recurrence_constraints', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<int> startDate = GeneratedColumn<int>(
      'start_date', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<int> endDate = GeneratedColumn<int>(
      'end_date', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _postingBehaviourMeta =
      const VerificationMeta('postingBehaviour');
  @override
  late final GeneratedColumn<String> postingBehaviour = GeneratedColumn<String>(
      'posting_behaviour', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('auto_post'));
  static const VerificationMeta _feeModeMeta =
      const VerificationMeta('feeMode');
  @override
  late final GeneratedColumn<String> feeMode = GeneratedColumn<String>(
      'fee_mode', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _feeAmountMinorMeta =
      const VerificationMeta('feeAmountMinor');
  @override
  late final GeneratedColumn<int> feeAmountMinor = GeneratedColumn<int>(
      'fee_amount_minor', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _feePercentageMicroMeta =
      const VerificationMeta('feePercentageMicro');
  @override
  late final GeneratedColumn<int> feePercentageMicro = GeneratedColumn<int>(
      'fee_percentage_micro', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _feeCategoryIdMeta =
      const VerificationMeta('feeCategoryId');
  @override
  late final GeneratedColumn<String> feeCategoryId = GeneratedColumn<String>(
      'fee_category_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES categories (id)'));
  static const VerificationMeta _pauseUntilMeta =
      const VerificationMeta('pauseUntil');
  @override
  late final GeneratedColumn<int> pauseUntil = GeneratedColumn<int>(
      'pause_until', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _archivedAtMeta =
      const VerificationMeta('archivedAt');
  @override
  late final GeneratedColumn<int> archivedAt = GeneratedColumn<int>(
      'archived_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _archivedReasonMeta =
      const VerificationMeta('archivedReason');
  @override
  late final GeneratedColumn<String> archivedReason = GeneratedColumn<String>(
      'archived_reason', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isInstallmentMeta =
      const VerificationMeta('isInstallment');
  @override
  late final GeneratedColumn<bool> isInstallment = GeneratedColumn<bool>(
      'is_installment', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_installment" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _metadataMeta =
      const VerificationMeta('metadata');
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
      'metadata', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        transactionType,
        status,
        amountMinor,
        currencyCode,
        accountSourceId,
        accountDestinationId,
        categoryId,
        subcategoryId,
        payeeId,
        title,
        description,
        recurrenceN,
        recurrenceUnit,
        recurrenceConstraints,
        startDate,
        endDate,
        postingBehaviour,
        feeMode,
        feeAmountMinor,
        feePercentageMicro,
        feeCategoryId,
        pauseUntil,
        archivedAt,
        archivedReason,
        isInstallment,
        isDeleted,
        deletedAt,
        createdAt,
        updatedAt,
        metadata
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_templates';
  @override
  VerificationContext validateIntegrity(Insertable<RecurringTemplate> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('transaction_type')) {
      context.handle(
          _transactionTypeMeta,
          transactionType.isAcceptableOrUnknown(
              data['transaction_type']!, _transactionTypeMeta));
    } else if (isInserting) {
      context.missing(_transactionTypeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
          _amountMinorMeta,
          amountMinor.isAcceptableOrUnknown(
              data['amount_minor']!, _amountMinorMeta));
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
          _currencyCodeMeta,
          currencyCode.isAcceptableOrUnknown(
              data['currency_code']!, _currencyCodeMeta));
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('account_source_id')) {
      context.handle(
          _accountSourceIdMeta,
          accountSourceId.isAcceptableOrUnknown(
              data['account_source_id']!, _accountSourceIdMeta));
    }
    if (data.containsKey('account_destination_id')) {
      context.handle(
          _accountDestinationIdMeta,
          accountDestinationId.isAcceptableOrUnknown(
              data['account_destination_id']!, _accountDestinationIdMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    if (data.containsKey('subcategory_id')) {
      context.handle(
          _subcategoryIdMeta,
          subcategoryId.isAcceptableOrUnknown(
              data['subcategory_id']!, _subcategoryIdMeta));
    }
    if (data.containsKey('payee_id')) {
      context.handle(_payeeIdMeta,
          payeeId.isAcceptableOrUnknown(data['payee_id']!, _payeeIdMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('recurrence_n')) {
      context.handle(
          _recurrenceNMeta,
          recurrenceN.isAcceptableOrUnknown(
              data['recurrence_n']!, _recurrenceNMeta));
    } else if (isInserting) {
      context.missing(_recurrenceNMeta);
    }
    if (data.containsKey('recurrence_unit')) {
      context.handle(
          _recurrenceUnitMeta,
          recurrenceUnit.isAcceptableOrUnknown(
              data['recurrence_unit']!, _recurrenceUnitMeta));
    } else if (isInserting) {
      context.missing(_recurrenceUnitMeta);
    }
    if (data.containsKey('recurrence_constraints')) {
      context.handle(
          _recurrenceConstraintsMeta,
          recurrenceConstraints.isAcceptableOrUnknown(
              data['recurrence_constraints']!, _recurrenceConstraintsMeta));
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    }
    if (data.containsKey('posting_behaviour')) {
      context.handle(
          _postingBehaviourMeta,
          postingBehaviour.isAcceptableOrUnknown(
              data['posting_behaviour']!, _postingBehaviourMeta));
    }
    if (data.containsKey('fee_mode')) {
      context.handle(_feeModeMeta,
          feeMode.isAcceptableOrUnknown(data['fee_mode']!, _feeModeMeta));
    }
    if (data.containsKey('fee_amount_minor')) {
      context.handle(
          _feeAmountMinorMeta,
          feeAmountMinor.isAcceptableOrUnknown(
              data['fee_amount_minor']!, _feeAmountMinorMeta));
    }
    if (data.containsKey('fee_percentage_micro')) {
      context.handle(
          _feePercentageMicroMeta,
          feePercentageMicro.isAcceptableOrUnknown(
              data['fee_percentage_micro']!, _feePercentageMicroMeta));
    }
    if (data.containsKey('fee_category_id')) {
      context.handle(
          _feeCategoryIdMeta,
          feeCategoryId.isAcceptableOrUnknown(
              data['fee_category_id']!, _feeCategoryIdMeta));
    }
    if (data.containsKey('pause_until')) {
      context.handle(
          _pauseUntilMeta,
          pauseUntil.isAcceptableOrUnknown(
              data['pause_until']!, _pauseUntilMeta));
    }
    if (data.containsKey('archived_at')) {
      context.handle(
          _archivedAtMeta,
          archivedAt.isAcceptableOrUnknown(
              data['archived_at']!, _archivedAtMeta));
    }
    if (data.containsKey('archived_reason')) {
      context.handle(
          _archivedReasonMeta,
          archivedReason.isAcceptableOrUnknown(
              data['archived_reason']!, _archivedReasonMeta));
    }
    if (data.containsKey('is_installment')) {
      context.handle(
          _isInstallmentMeta,
          isInstallment.isAcceptableOrUnknown(
              data['is_installment']!, _isInstallmentMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('metadata')) {
      context.handle(_metadataMeta,
          metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurringTemplate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringTemplate(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      transactionType: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}transaction_type'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      amountMinor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount_minor'])!,
      currencyCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency_code'])!,
      accountSourceId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}account_source_id']),
      accountDestinationId: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}account_destination_id']),
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id']),
      subcategoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subcategory_id']),
      payeeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payee_id']),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      recurrenceN: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}recurrence_n'])!,
      recurrenceUnit: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}recurrence_unit'])!,
      recurrenceConstraints: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}recurrence_constraints']),
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}start_date'])!,
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}end_date']),
      postingBehaviour: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}posting_behaviour'])!,
      feeMode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fee_mode']),
      feeAmountMinor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}fee_amount_minor']),
      feePercentageMicro: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}fee_percentage_micro']),
      feeCategoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fee_category_id']),
      pauseUntil: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}pause_until']),
      archivedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}archived_at']),
      archivedReason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}archived_reason']),
      isInstallment: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_installment'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}deleted_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      metadata: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metadata']),
    );
  }

  @override
  $RecurringTemplatesTable createAlias(String alias) {
    return $RecurringTemplatesTable(attachedDatabase, alias);
  }
}

class RecurringTemplate extends DataClass
    implements Insertable<RecurringTemplate> {
  /// Stable UUID v4 identifier.
  final String id;

  /// Transaction type: `income`, `expense`, or `transfer`. Immutable.
  final String transactionType;

  /// Lifecycle state. Valid values: `active`, `paused`, `archived`, `deleted`.
  final String status;

  /// Per-occurrence amount in minor units. Editable in-place.
  final int amountMinor;

  /// Currency derived from source account.
  final String currencyCode;

  /// Source account for expense/transfer; NULL for income.
  final String? accountSourceId;

  /// Destination account for income/transfer; NULL for expense.
  final String? accountDestinationId;

  /// Top-level category. NULL for transfers. Editable.
  final String? categoryId;

  /// Optional subcategory. Editable.
  final String? subcategoryId;

  /// Optional payee. Editable.
  final String? payeeId;

  /// Optional user label. Editable.
  final String? title;

  /// Optional description. Editable.
  final String? description;

  /// N in "every N <unit>". Immutable.
  final int recurrenceN;

  /// Time unit for recurrence. Valid values: `day`, `week`, `month`, `year`.
  /// Immutable.
  final String recurrenceUnit;

  /// JSON array of recurrence constraint enums. Immutable.
  final String? recurrenceConstraints;

  /// First occurrence date as Unix epoch. Immutable.
  final int startDate;

  /// Last valid occurrence date. Immutable for recurring; computed for
  /// installments.
  final int? endDate;

  /// Posting behaviour: `auto_post` or `remind_and_confirm`. Editable.
  final String postingBehaviour;

  /// Transfer fee mode: `flat`, `percentage`, or NULL (no fee).
  final String? feeMode;

  /// Flat fee amount in minor units.
  final int? feeAmountMinor;

  /// Fee as percentage × 1,000,000.
  final int? feePercentageMicro;

  /// Fee expense category.
  final String? feeCategoryId;

  /// Unix epoch; resume from pause after this time.
  final int? pauseUntil;

  /// Unix epoch when this template was archived.
  final int? archivedAt;

  /// Reason for archival.
  final String? archivedReason;

  /// Discriminator: 0 = recurring, 1 = installment.
  final bool isInstallment;

  /// Soft-delete flag.
  final bool isDeleted;

  /// Unix epoch seconds set on soft-delete.
  final int? deletedAt;

  /// Unix epoch seconds when this row was created.
  final int createdAt;

  /// Unix epoch seconds when this row was last modified.
  final int updatedAt;

  /// JSON escape hatch for future extensibility.
  final String? metadata;
  const RecurringTemplate(
      {required this.id,
      required this.transactionType,
      required this.status,
      required this.amountMinor,
      required this.currencyCode,
      this.accountSourceId,
      this.accountDestinationId,
      this.categoryId,
      this.subcategoryId,
      this.payeeId,
      this.title,
      this.description,
      required this.recurrenceN,
      required this.recurrenceUnit,
      this.recurrenceConstraints,
      required this.startDate,
      this.endDate,
      required this.postingBehaviour,
      this.feeMode,
      this.feeAmountMinor,
      this.feePercentageMicro,
      this.feeCategoryId,
      this.pauseUntil,
      this.archivedAt,
      this.archivedReason,
      required this.isInstallment,
      required this.isDeleted,
      this.deletedAt,
      required this.createdAt,
      required this.updatedAt,
      this.metadata});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['transaction_type'] = Variable<String>(transactionType);
    map['status'] = Variable<String>(status);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency_code'] = Variable<String>(currencyCode);
    if (!nullToAbsent || accountSourceId != null) {
      map['account_source_id'] = Variable<String>(accountSourceId);
    }
    if (!nullToAbsent || accountDestinationId != null) {
      map['account_destination_id'] = Variable<String>(accountDestinationId);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    if (!nullToAbsent || subcategoryId != null) {
      map['subcategory_id'] = Variable<String>(subcategoryId);
    }
    if (!nullToAbsent || payeeId != null) {
      map['payee_id'] = Variable<String>(payeeId);
    }
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['recurrence_n'] = Variable<int>(recurrenceN);
    map['recurrence_unit'] = Variable<String>(recurrenceUnit);
    if (!nullToAbsent || recurrenceConstraints != null) {
      map['recurrence_constraints'] = Variable<String>(recurrenceConstraints);
    }
    map['start_date'] = Variable<int>(startDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<int>(endDate);
    }
    map['posting_behaviour'] = Variable<String>(postingBehaviour);
    if (!nullToAbsent || feeMode != null) {
      map['fee_mode'] = Variable<String>(feeMode);
    }
    if (!nullToAbsent || feeAmountMinor != null) {
      map['fee_amount_minor'] = Variable<int>(feeAmountMinor);
    }
    if (!nullToAbsent || feePercentageMicro != null) {
      map['fee_percentage_micro'] = Variable<int>(feePercentageMicro);
    }
    if (!nullToAbsent || feeCategoryId != null) {
      map['fee_category_id'] = Variable<String>(feeCategoryId);
    }
    if (!nullToAbsent || pauseUntil != null) {
      map['pause_until'] = Variable<int>(pauseUntil);
    }
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<int>(archivedAt);
    }
    if (!nullToAbsent || archivedReason != null) {
      map['archived_reason'] = Variable<String>(archivedReason);
    }
    map['is_installment'] = Variable<bool>(isInstallment);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || metadata != null) {
      map['metadata'] = Variable<String>(metadata);
    }
    return map;
  }

  RecurringTemplatesCompanion toCompanion(bool nullToAbsent) {
    return RecurringTemplatesCompanion(
      id: Value(id),
      transactionType: Value(transactionType),
      status: Value(status),
      amountMinor: Value(amountMinor),
      currencyCode: Value(currencyCode),
      accountSourceId: accountSourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountSourceId),
      accountDestinationId: accountDestinationId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountDestinationId),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      subcategoryId: subcategoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(subcategoryId),
      payeeId: payeeId == null && nullToAbsent
          ? const Value.absent()
          : Value(payeeId),
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      recurrenceN: Value(recurrenceN),
      recurrenceUnit: Value(recurrenceUnit),
      recurrenceConstraints: recurrenceConstraints == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceConstraints),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      postingBehaviour: Value(postingBehaviour),
      feeMode: feeMode == null && nullToAbsent
          ? const Value.absent()
          : Value(feeMode),
      feeAmountMinor: feeAmountMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(feeAmountMinor),
      feePercentageMicro: feePercentageMicro == null && nullToAbsent
          ? const Value.absent()
          : Value(feePercentageMicro),
      feeCategoryId: feeCategoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(feeCategoryId),
      pauseUntil: pauseUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(pauseUntil),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
      archivedReason: archivedReason == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedReason),
      isInstallment: Value(isInstallment),
      isDeleted: Value(isDeleted),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      metadata: metadata == null && nullToAbsent
          ? const Value.absent()
          : Value(metadata),
    );
  }

  factory RecurringTemplate.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringTemplate(
      id: serializer.fromJson<String>(json['id']),
      transactionType: serializer.fromJson<String>(json['transactionType']),
      status: serializer.fromJson<String>(json['status']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      accountSourceId: serializer.fromJson<String?>(json['accountSourceId']),
      accountDestinationId:
          serializer.fromJson<String?>(json['accountDestinationId']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      subcategoryId: serializer.fromJson<String?>(json['subcategoryId']),
      payeeId: serializer.fromJson<String?>(json['payeeId']),
      title: serializer.fromJson<String?>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      recurrenceN: serializer.fromJson<int>(json['recurrenceN']),
      recurrenceUnit: serializer.fromJson<String>(json['recurrenceUnit']),
      recurrenceConstraints:
          serializer.fromJson<String?>(json['recurrenceConstraints']),
      startDate: serializer.fromJson<int>(json['startDate']),
      endDate: serializer.fromJson<int?>(json['endDate']),
      postingBehaviour: serializer.fromJson<String>(json['postingBehaviour']),
      feeMode: serializer.fromJson<String?>(json['feeMode']),
      feeAmountMinor: serializer.fromJson<int?>(json['feeAmountMinor']),
      feePercentageMicro: serializer.fromJson<int?>(json['feePercentageMicro']),
      feeCategoryId: serializer.fromJson<String?>(json['feeCategoryId']),
      pauseUntil: serializer.fromJson<int?>(json['pauseUntil']),
      archivedAt: serializer.fromJson<int?>(json['archivedAt']),
      archivedReason: serializer.fromJson<String?>(json['archivedReason']),
      isInstallment: serializer.fromJson<bool>(json['isInstallment']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      metadata: serializer.fromJson<String?>(json['metadata']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'transactionType': serializer.toJson<String>(transactionType),
      'status': serializer.toJson<String>(status),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'accountSourceId': serializer.toJson<String?>(accountSourceId),
      'accountDestinationId': serializer.toJson<String?>(accountDestinationId),
      'categoryId': serializer.toJson<String?>(categoryId),
      'subcategoryId': serializer.toJson<String?>(subcategoryId),
      'payeeId': serializer.toJson<String?>(payeeId),
      'title': serializer.toJson<String?>(title),
      'description': serializer.toJson<String?>(description),
      'recurrenceN': serializer.toJson<int>(recurrenceN),
      'recurrenceUnit': serializer.toJson<String>(recurrenceUnit),
      'recurrenceConstraints':
          serializer.toJson<String?>(recurrenceConstraints),
      'startDate': serializer.toJson<int>(startDate),
      'endDate': serializer.toJson<int?>(endDate),
      'postingBehaviour': serializer.toJson<String>(postingBehaviour),
      'feeMode': serializer.toJson<String?>(feeMode),
      'feeAmountMinor': serializer.toJson<int?>(feeAmountMinor),
      'feePercentageMicro': serializer.toJson<int?>(feePercentageMicro),
      'feeCategoryId': serializer.toJson<String?>(feeCategoryId),
      'pauseUntil': serializer.toJson<int?>(pauseUntil),
      'archivedAt': serializer.toJson<int?>(archivedAt),
      'archivedReason': serializer.toJson<String?>(archivedReason),
      'isInstallment': serializer.toJson<bool>(isInstallment),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'metadata': serializer.toJson<String?>(metadata),
    };
  }

  RecurringTemplate copyWith(
          {String? id,
          String? transactionType,
          String? status,
          int? amountMinor,
          String? currencyCode,
          Value<String?> accountSourceId = const Value.absent(),
          Value<String?> accountDestinationId = const Value.absent(),
          Value<String?> categoryId = const Value.absent(),
          Value<String?> subcategoryId = const Value.absent(),
          Value<String?> payeeId = const Value.absent(),
          Value<String?> title = const Value.absent(),
          Value<String?> description = const Value.absent(),
          int? recurrenceN,
          String? recurrenceUnit,
          Value<String?> recurrenceConstraints = const Value.absent(),
          int? startDate,
          Value<int?> endDate = const Value.absent(),
          String? postingBehaviour,
          Value<String?> feeMode = const Value.absent(),
          Value<int?> feeAmountMinor = const Value.absent(),
          Value<int?> feePercentageMicro = const Value.absent(),
          Value<String?> feeCategoryId = const Value.absent(),
          Value<int?> pauseUntil = const Value.absent(),
          Value<int?> archivedAt = const Value.absent(),
          Value<String?> archivedReason = const Value.absent(),
          bool? isInstallment,
          bool? isDeleted,
          Value<int?> deletedAt = const Value.absent(),
          int? createdAt,
          int? updatedAt,
          Value<String?> metadata = const Value.absent()}) =>
      RecurringTemplate(
        id: id ?? this.id,
        transactionType: transactionType ?? this.transactionType,
        status: status ?? this.status,
        amountMinor: amountMinor ?? this.amountMinor,
        currencyCode: currencyCode ?? this.currencyCode,
        accountSourceId: accountSourceId.present
            ? accountSourceId.value
            : this.accountSourceId,
        accountDestinationId: accountDestinationId.present
            ? accountDestinationId.value
            : this.accountDestinationId,
        categoryId: categoryId.present ? categoryId.value : this.categoryId,
        subcategoryId:
            subcategoryId.present ? subcategoryId.value : this.subcategoryId,
        payeeId: payeeId.present ? payeeId.value : this.payeeId,
        title: title.present ? title.value : this.title,
        description: description.present ? description.value : this.description,
        recurrenceN: recurrenceN ?? this.recurrenceN,
        recurrenceUnit: recurrenceUnit ?? this.recurrenceUnit,
        recurrenceConstraints: recurrenceConstraints.present
            ? recurrenceConstraints.value
            : this.recurrenceConstraints,
        startDate: startDate ?? this.startDate,
        endDate: endDate.present ? endDate.value : this.endDate,
        postingBehaviour: postingBehaviour ?? this.postingBehaviour,
        feeMode: feeMode.present ? feeMode.value : this.feeMode,
        feeAmountMinor:
            feeAmountMinor.present ? feeAmountMinor.value : this.feeAmountMinor,
        feePercentageMicro: feePercentageMicro.present
            ? feePercentageMicro.value
            : this.feePercentageMicro,
        feeCategoryId:
            feeCategoryId.present ? feeCategoryId.value : this.feeCategoryId,
        pauseUntil: pauseUntil.present ? pauseUntil.value : this.pauseUntil,
        archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
        archivedReason:
            archivedReason.present ? archivedReason.value : this.archivedReason,
        isInstallment: isInstallment ?? this.isInstallment,
        isDeleted: isDeleted ?? this.isDeleted,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        metadata: metadata.present ? metadata.value : this.metadata,
      );
  RecurringTemplate copyWithCompanion(RecurringTemplatesCompanion data) {
    return RecurringTemplate(
      id: data.id.present ? data.id.value : this.id,
      transactionType: data.transactionType.present
          ? data.transactionType.value
          : this.transactionType,
      status: data.status.present ? data.status.value : this.status,
      amountMinor:
          data.amountMinor.present ? data.amountMinor.value : this.amountMinor,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      accountSourceId: data.accountSourceId.present
          ? data.accountSourceId.value
          : this.accountSourceId,
      accountDestinationId: data.accountDestinationId.present
          ? data.accountDestinationId.value
          : this.accountDestinationId,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      subcategoryId: data.subcategoryId.present
          ? data.subcategoryId.value
          : this.subcategoryId,
      payeeId: data.payeeId.present ? data.payeeId.value : this.payeeId,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      recurrenceN:
          data.recurrenceN.present ? data.recurrenceN.value : this.recurrenceN,
      recurrenceUnit: data.recurrenceUnit.present
          ? data.recurrenceUnit.value
          : this.recurrenceUnit,
      recurrenceConstraints: data.recurrenceConstraints.present
          ? data.recurrenceConstraints.value
          : this.recurrenceConstraints,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      postingBehaviour: data.postingBehaviour.present
          ? data.postingBehaviour.value
          : this.postingBehaviour,
      feeMode: data.feeMode.present ? data.feeMode.value : this.feeMode,
      feeAmountMinor: data.feeAmountMinor.present
          ? data.feeAmountMinor.value
          : this.feeAmountMinor,
      feePercentageMicro: data.feePercentageMicro.present
          ? data.feePercentageMicro.value
          : this.feePercentageMicro,
      feeCategoryId: data.feeCategoryId.present
          ? data.feeCategoryId.value
          : this.feeCategoryId,
      pauseUntil:
          data.pauseUntil.present ? data.pauseUntil.value : this.pauseUntil,
      archivedAt:
          data.archivedAt.present ? data.archivedAt.value : this.archivedAt,
      archivedReason: data.archivedReason.present
          ? data.archivedReason.value
          : this.archivedReason,
      isInstallment: data.isInstallment.present
          ? data.isInstallment.value
          : this.isInstallment,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringTemplate(')
          ..write('id: $id, ')
          ..write('transactionType: $transactionType, ')
          ..write('status: $status, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('accountSourceId: $accountSourceId, ')
          ..write('accountDestinationId: $accountDestinationId, ')
          ..write('categoryId: $categoryId, ')
          ..write('subcategoryId: $subcategoryId, ')
          ..write('payeeId: $payeeId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('recurrenceN: $recurrenceN, ')
          ..write('recurrenceUnit: $recurrenceUnit, ')
          ..write('recurrenceConstraints: $recurrenceConstraints, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('postingBehaviour: $postingBehaviour, ')
          ..write('feeMode: $feeMode, ')
          ..write('feeAmountMinor: $feeAmountMinor, ')
          ..write('feePercentageMicro: $feePercentageMicro, ')
          ..write('feeCategoryId: $feeCategoryId, ')
          ..write('pauseUntil: $pauseUntil, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('archivedReason: $archivedReason, ')
          ..write('isInstallment: $isInstallment, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('metadata: $metadata')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        transactionType,
        status,
        amountMinor,
        currencyCode,
        accountSourceId,
        accountDestinationId,
        categoryId,
        subcategoryId,
        payeeId,
        title,
        description,
        recurrenceN,
        recurrenceUnit,
        recurrenceConstraints,
        startDate,
        endDate,
        postingBehaviour,
        feeMode,
        feeAmountMinor,
        feePercentageMicro,
        feeCategoryId,
        pauseUntil,
        archivedAt,
        archivedReason,
        isInstallment,
        isDeleted,
        deletedAt,
        createdAt,
        updatedAt,
        metadata
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringTemplate &&
          other.id == this.id &&
          other.transactionType == this.transactionType &&
          other.status == this.status &&
          other.amountMinor == this.amountMinor &&
          other.currencyCode == this.currencyCode &&
          other.accountSourceId == this.accountSourceId &&
          other.accountDestinationId == this.accountDestinationId &&
          other.categoryId == this.categoryId &&
          other.subcategoryId == this.subcategoryId &&
          other.payeeId == this.payeeId &&
          other.title == this.title &&
          other.description == this.description &&
          other.recurrenceN == this.recurrenceN &&
          other.recurrenceUnit == this.recurrenceUnit &&
          other.recurrenceConstraints == this.recurrenceConstraints &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.postingBehaviour == this.postingBehaviour &&
          other.feeMode == this.feeMode &&
          other.feeAmountMinor == this.feeAmountMinor &&
          other.feePercentageMicro == this.feePercentageMicro &&
          other.feeCategoryId == this.feeCategoryId &&
          other.pauseUntil == this.pauseUntil &&
          other.archivedAt == this.archivedAt &&
          other.archivedReason == this.archivedReason &&
          other.isInstallment == this.isInstallment &&
          other.isDeleted == this.isDeleted &&
          other.deletedAt == this.deletedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.metadata == this.metadata);
}

class RecurringTemplatesCompanion extends UpdateCompanion<RecurringTemplate> {
  final Value<String> id;
  final Value<String> transactionType;
  final Value<String> status;
  final Value<int> amountMinor;
  final Value<String> currencyCode;
  final Value<String?> accountSourceId;
  final Value<String?> accountDestinationId;
  final Value<String?> categoryId;
  final Value<String?> subcategoryId;
  final Value<String?> payeeId;
  final Value<String?> title;
  final Value<String?> description;
  final Value<int> recurrenceN;
  final Value<String> recurrenceUnit;
  final Value<String?> recurrenceConstraints;
  final Value<int> startDate;
  final Value<int?> endDate;
  final Value<String> postingBehaviour;
  final Value<String?> feeMode;
  final Value<int?> feeAmountMinor;
  final Value<int?> feePercentageMicro;
  final Value<String?> feeCategoryId;
  final Value<int?> pauseUntil;
  final Value<int?> archivedAt;
  final Value<String?> archivedReason;
  final Value<bool> isInstallment;
  final Value<bool> isDeleted;
  final Value<int?> deletedAt;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String?> metadata;
  final Value<int> rowid;
  const RecurringTemplatesCompanion({
    this.id = const Value.absent(),
    this.transactionType = const Value.absent(),
    this.status = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.accountSourceId = const Value.absent(),
    this.accountDestinationId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.subcategoryId = const Value.absent(),
    this.payeeId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.recurrenceN = const Value.absent(),
    this.recurrenceUnit = const Value.absent(),
    this.recurrenceConstraints = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.postingBehaviour = const Value.absent(),
    this.feeMode = const Value.absent(),
    this.feeAmountMinor = const Value.absent(),
    this.feePercentageMicro = const Value.absent(),
    this.feeCategoryId = const Value.absent(),
    this.pauseUntil = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.archivedReason = const Value.absent(),
    this.isInstallment = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.metadata = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecurringTemplatesCompanion.insert({
    required String id,
    required String transactionType,
    this.status = const Value.absent(),
    required int amountMinor,
    required String currencyCode,
    this.accountSourceId = const Value.absent(),
    this.accountDestinationId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.subcategoryId = const Value.absent(),
    this.payeeId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    required int recurrenceN,
    required String recurrenceUnit,
    this.recurrenceConstraints = const Value.absent(),
    required int startDate,
    this.endDate = const Value.absent(),
    this.postingBehaviour = const Value.absent(),
    this.feeMode = const Value.absent(),
    this.feeAmountMinor = const Value.absent(),
    this.feePercentageMicro = const Value.absent(),
    this.feeCategoryId = const Value.absent(),
    this.pauseUntil = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.archivedReason = const Value.absent(),
    this.isInstallment = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.metadata = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        transactionType = Value(transactionType),
        amountMinor = Value(amountMinor),
        currencyCode = Value(currencyCode),
        recurrenceN = Value(recurrenceN),
        recurrenceUnit = Value(recurrenceUnit),
        startDate = Value(startDate),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<RecurringTemplate> custom({
    Expression<String>? id,
    Expression<String>? transactionType,
    Expression<String>? status,
    Expression<int>? amountMinor,
    Expression<String>? currencyCode,
    Expression<String>? accountSourceId,
    Expression<String>? accountDestinationId,
    Expression<String>? categoryId,
    Expression<String>? subcategoryId,
    Expression<String>? payeeId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? recurrenceN,
    Expression<String>? recurrenceUnit,
    Expression<String>? recurrenceConstraints,
    Expression<int>? startDate,
    Expression<int>? endDate,
    Expression<String>? postingBehaviour,
    Expression<String>? feeMode,
    Expression<int>? feeAmountMinor,
    Expression<int>? feePercentageMicro,
    Expression<String>? feeCategoryId,
    Expression<int>? pauseUntil,
    Expression<int>? archivedAt,
    Expression<String>? archivedReason,
    Expression<bool>? isInstallment,
    Expression<bool>? isDeleted,
    Expression<int>? deletedAt,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? metadata,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionType != null) 'transaction_type': transactionType,
      if (status != null) 'status': status,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (accountSourceId != null) 'account_source_id': accountSourceId,
      if (accountDestinationId != null)
        'account_destination_id': accountDestinationId,
      if (categoryId != null) 'category_id': categoryId,
      if (subcategoryId != null) 'subcategory_id': subcategoryId,
      if (payeeId != null) 'payee_id': payeeId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (recurrenceN != null) 'recurrence_n': recurrenceN,
      if (recurrenceUnit != null) 'recurrence_unit': recurrenceUnit,
      if (recurrenceConstraints != null)
        'recurrence_constraints': recurrenceConstraints,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (postingBehaviour != null) 'posting_behaviour': postingBehaviour,
      if (feeMode != null) 'fee_mode': feeMode,
      if (feeAmountMinor != null) 'fee_amount_minor': feeAmountMinor,
      if (feePercentageMicro != null)
        'fee_percentage_micro': feePercentageMicro,
      if (feeCategoryId != null) 'fee_category_id': feeCategoryId,
      if (pauseUntil != null) 'pause_until': pauseUntil,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (archivedReason != null) 'archived_reason': archivedReason,
      if (isInstallment != null) 'is_installment': isInstallment,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (metadata != null) 'metadata': metadata,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecurringTemplatesCompanion copyWith(
      {Value<String>? id,
      Value<String>? transactionType,
      Value<String>? status,
      Value<int>? amountMinor,
      Value<String>? currencyCode,
      Value<String?>? accountSourceId,
      Value<String?>? accountDestinationId,
      Value<String?>? categoryId,
      Value<String?>? subcategoryId,
      Value<String?>? payeeId,
      Value<String?>? title,
      Value<String?>? description,
      Value<int>? recurrenceN,
      Value<String>? recurrenceUnit,
      Value<String?>? recurrenceConstraints,
      Value<int>? startDate,
      Value<int?>? endDate,
      Value<String>? postingBehaviour,
      Value<String?>? feeMode,
      Value<int?>? feeAmountMinor,
      Value<int?>? feePercentageMicro,
      Value<String?>? feeCategoryId,
      Value<int?>? pauseUntil,
      Value<int?>? archivedAt,
      Value<String?>? archivedReason,
      Value<bool>? isInstallment,
      Value<bool>? isDeleted,
      Value<int?>? deletedAt,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<String?>? metadata,
      Value<int>? rowid}) {
    return RecurringTemplatesCompanion(
      id: id ?? this.id,
      transactionType: transactionType ?? this.transactionType,
      status: status ?? this.status,
      amountMinor: amountMinor ?? this.amountMinor,
      currencyCode: currencyCode ?? this.currencyCode,
      accountSourceId: accountSourceId ?? this.accountSourceId,
      accountDestinationId: accountDestinationId ?? this.accountDestinationId,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      payeeId: payeeId ?? this.payeeId,
      title: title ?? this.title,
      description: description ?? this.description,
      recurrenceN: recurrenceN ?? this.recurrenceN,
      recurrenceUnit: recurrenceUnit ?? this.recurrenceUnit,
      recurrenceConstraints:
          recurrenceConstraints ?? this.recurrenceConstraints,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      postingBehaviour: postingBehaviour ?? this.postingBehaviour,
      feeMode: feeMode ?? this.feeMode,
      feeAmountMinor: feeAmountMinor ?? this.feeAmountMinor,
      feePercentageMicro: feePercentageMicro ?? this.feePercentageMicro,
      feeCategoryId: feeCategoryId ?? this.feeCategoryId,
      pauseUntil: pauseUntil ?? this.pauseUntil,
      archivedAt: archivedAt ?? this.archivedAt,
      archivedReason: archivedReason ?? this.archivedReason,
      isInstallment: isInstallment ?? this.isInstallment,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (transactionType.present) {
      map['transaction_type'] = Variable<String>(transactionType.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (accountSourceId.present) {
      map['account_source_id'] = Variable<String>(accountSourceId.value);
    }
    if (accountDestinationId.present) {
      map['account_destination_id'] =
          Variable<String>(accountDestinationId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (subcategoryId.present) {
      map['subcategory_id'] = Variable<String>(subcategoryId.value);
    }
    if (payeeId.present) {
      map['payee_id'] = Variable<String>(payeeId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (recurrenceN.present) {
      map['recurrence_n'] = Variable<int>(recurrenceN.value);
    }
    if (recurrenceUnit.present) {
      map['recurrence_unit'] = Variable<String>(recurrenceUnit.value);
    }
    if (recurrenceConstraints.present) {
      map['recurrence_constraints'] =
          Variable<String>(recurrenceConstraints.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<int>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<int>(endDate.value);
    }
    if (postingBehaviour.present) {
      map['posting_behaviour'] = Variable<String>(postingBehaviour.value);
    }
    if (feeMode.present) {
      map['fee_mode'] = Variable<String>(feeMode.value);
    }
    if (feeAmountMinor.present) {
      map['fee_amount_minor'] = Variable<int>(feeAmountMinor.value);
    }
    if (feePercentageMicro.present) {
      map['fee_percentage_micro'] = Variable<int>(feePercentageMicro.value);
    }
    if (feeCategoryId.present) {
      map['fee_category_id'] = Variable<String>(feeCategoryId.value);
    }
    if (pauseUntil.present) {
      map['pause_until'] = Variable<int>(pauseUntil.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<int>(archivedAt.value);
    }
    if (archivedReason.present) {
      map['archived_reason'] = Variable<String>(archivedReason.value);
    }
    if (isInstallment.present) {
      map['is_installment'] = Variable<bool>(isInstallment.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('transactionType: $transactionType, ')
          ..write('status: $status, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('accountSourceId: $accountSourceId, ')
          ..write('accountDestinationId: $accountDestinationId, ')
          ..write('categoryId: $categoryId, ')
          ..write('subcategoryId: $subcategoryId, ')
          ..write('payeeId: $payeeId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('recurrenceN: $recurrenceN, ')
          ..write('recurrenceUnit: $recurrenceUnit, ')
          ..write('recurrenceConstraints: $recurrenceConstraints, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('postingBehaviour: $postingBehaviour, ')
          ..write('feeMode: $feeMode, ')
          ..write('feeAmountMinor: $feeAmountMinor, ')
          ..write('feePercentageMicro: $feePercentageMicro, ')
          ..write('feeCategoryId: $feeCategoryId, ')
          ..write('pauseUntil: $pauseUntil, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('archivedReason: $archivedReason, ')
          ..write('isInstallment: $isInstallment, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('metadata: $metadata, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _purposeMeta =
      const VerificationMeta('purpose');
  @override
  late final GeneratedColumn<String> purpose = GeneratedColumn<String>(
      'purpose', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('user'));
  static const VerificationMeta _transactionDateMeta =
      const VerificationMeta('transactionDate');
  @override
  late final GeneratedColumn<int> transactionDate = GeneratedColumn<int>(
      'transaction_date', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _amountMinorMeta =
      const VerificationMeta('amountMinor');
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
      'amount_minor', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _currencyCodeMeta =
      const VerificationMeta('currencyCode');
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
      'currency_code', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES currencies (code)'));
  static const VerificationMeta _exchangeRateMicroMeta =
      const VerificationMeta('exchangeRateMicro');
  @override
  late final GeneratedColumn<int> exchangeRateMicro = GeneratedColumn<int>(
      'exchange_rate_micro', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _homeCurrencyAtCaptureMeta =
      const VerificationMeta('homeCurrencyAtCapture');
  @override
  late final GeneratedColumn<String> homeCurrencyAtCapture =
      GeneratedColumn<String>('home_currency_at_capture', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'REFERENCES currencies (code)'));
  static const VerificationMeta _accountSourceIdMeta =
      const VerificationMeta('accountSourceId');
  @override
  late final GeneratedColumn<String> accountSourceId = GeneratedColumn<String>(
      'account_source_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES accounts (id)'));
  static const VerificationMeta _accountDestinationIdMeta =
      const VerificationMeta('accountDestinationId');
  @override
  late final GeneratedColumn<String> accountDestinationId =
      GeneratedColumn<String>(
          'account_destination_id', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultConstraints:
              GeneratedColumn.constraintIsAlways('REFERENCES accounts (id)'));
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES categories (id)'));
  static const VerificationMeta _subcategoryIdMeta =
      const VerificationMeta('subcategoryId');
  @override
  late final GeneratedColumn<String> subcategoryId = GeneratedColumn<String>(
      'subcategory_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES categories (id)'));
  static const VerificationMeta _payeeIdMeta =
      const VerificationMeta('payeeId');
  @override
  late final GeneratedColumn<String> payeeId = GeneratedColumn<String>(
      'payee_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES payees (id)'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _compoundGroupIdMeta =
      const VerificationMeta('compoundGroupId');
  @override
  late final GeneratedColumn<String> compoundGroupId = GeneratedColumn<String>(
      'compound_group_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _compoundRoleMeta =
      const VerificationMeta('compoundRole');
  @override
  late final GeneratedColumn<String> compoundRole = GeneratedColumn<String>(
      'compound_role', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _parentTemplateIdMeta =
      const VerificationMeta('parentTemplateId');
  @override
  late final GeneratedColumn<String> parentTemplateId = GeneratedColumn<String>(
      'parent_template_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES recurring_templates (id)'));
  static const VerificationMeta _correctsTransactionIdMeta =
      const VerificationMeta('correctsTransactionId');
  @override
  late final GeneratedColumn<String> correctsTransactionId =
      GeneratedColumn<String>('corrects_transaction_id', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'REFERENCES transactions (id)'));
  static const VerificationMeta _isManuallyHandledMeta =
      const VerificationMeta('isManuallyHandled');
  @override
  late final GeneratedColumn<bool> isManuallyHandled = GeneratedColumn<bool>(
      'is_manually_handled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_manually_handled" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _metadataMeta =
      const VerificationMeta('metadata');
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
      'metadata', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        type,
        status,
        purpose,
        transactionDate,
        amountMinor,
        currencyCode,
        exchangeRateMicro,
        homeCurrencyAtCapture,
        accountSourceId,
        accountDestinationId,
        categoryId,
        subcategoryId,
        payeeId,
        title,
        description,
        compoundGroupId,
        compoundRole,
        parentTemplateId,
        correctsTransactionId,
        isManuallyHandled,
        createdAt,
        updatedAt,
        metadata
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(Insertable<Transaction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('purpose')) {
      context.handle(_purposeMeta,
          purpose.isAcceptableOrUnknown(data['purpose']!, _purposeMeta));
    }
    if (data.containsKey('transaction_date')) {
      context.handle(
          _transactionDateMeta,
          transactionDate.isAcceptableOrUnknown(
              data['transaction_date']!, _transactionDateMeta));
    } else if (isInserting) {
      context.missing(_transactionDateMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
          _amountMinorMeta,
          amountMinor.isAcceptableOrUnknown(
              data['amount_minor']!, _amountMinorMeta));
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
          _currencyCodeMeta,
          currencyCode.isAcceptableOrUnknown(
              data['currency_code']!, _currencyCodeMeta));
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('exchange_rate_micro')) {
      context.handle(
          _exchangeRateMicroMeta,
          exchangeRateMicro.isAcceptableOrUnknown(
              data['exchange_rate_micro']!, _exchangeRateMicroMeta));
    }
    if (data.containsKey('home_currency_at_capture')) {
      context.handle(
          _homeCurrencyAtCaptureMeta,
          homeCurrencyAtCapture.isAcceptableOrUnknown(
              data['home_currency_at_capture']!, _homeCurrencyAtCaptureMeta));
    }
    if (data.containsKey('account_source_id')) {
      context.handle(
          _accountSourceIdMeta,
          accountSourceId.isAcceptableOrUnknown(
              data['account_source_id']!, _accountSourceIdMeta));
    }
    if (data.containsKey('account_destination_id')) {
      context.handle(
          _accountDestinationIdMeta,
          accountDestinationId.isAcceptableOrUnknown(
              data['account_destination_id']!, _accountDestinationIdMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    if (data.containsKey('subcategory_id')) {
      context.handle(
          _subcategoryIdMeta,
          subcategoryId.isAcceptableOrUnknown(
              data['subcategory_id']!, _subcategoryIdMeta));
    }
    if (data.containsKey('payee_id')) {
      context.handle(_payeeIdMeta,
          payeeId.isAcceptableOrUnknown(data['payee_id']!, _payeeIdMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('compound_group_id')) {
      context.handle(
          _compoundGroupIdMeta,
          compoundGroupId.isAcceptableOrUnknown(
              data['compound_group_id']!, _compoundGroupIdMeta));
    }
    if (data.containsKey('compound_role')) {
      context.handle(
          _compoundRoleMeta,
          compoundRole.isAcceptableOrUnknown(
              data['compound_role']!, _compoundRoleMeta));
    }
    if (data.containsKey('parent_template_id')) {
      context.handle(
          _parentTemplateIdMeta,
          parentTemplateId.isAcceptableOrUnknown(
              data['parent_template_id']!, _parentTemplateIdMeta));
    }
    if (data.containsKey('corrects_transaction_id')) {
      context.handle(
          _correctsTransactionIdMeta,
          correctsTransactionId.isAcceptableOrUnknown(
              data['corrects_transaction_id']!, _correctsTransactionIdMeta));
    }
    if (data.containsKey('is_manually_handled')) {
      context.handle(
          _isManuallyHandledMeta,
          isManuallyHandled.isAcceptableOrUnknown(
              data['is_manually_handled']!, _isManuallyHandledMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('metadata')) {
      context.handle(_metadataMeta,
          metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      purpose: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}purpose'])!,
      transactionDate: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}transaction_date'])!,
      amountMinor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount_minor'])!,
      currencyCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency_code'])!,
      exchangeRateMicro: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}exchange_rate_micro']),
      homeCurrencyAtCapture: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}home_currency_at_capture']),
      accountSourceId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}account_source_id']),
      accountDestinationId: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}account_destination_id']),
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id']),
      subcategoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subcategory_id']),
      payeeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payee_id']),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      compoundGroupId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}compound_group_id']),
      compoundRole: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}compound_role']),
      parentTemplateId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}parent_template_id']),
      correctsTransactionId: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}corrects_transaction_id']),
      isManuallyHandled: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}is_manually_handled'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      metadata: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metadata']),
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class Transaction extends DataClass implements Insertable<Transaction> {
  /// Stable UUID v4 identifier.
  final String id;

  /// Transaction type: `income`, `expense`, or `transfer`.
  final String type;

  /// Ledger participation state. Defaults to `pending`.
  final String status;

  /// Role in the correction/reversal chain. Defaults to `user`.
  final String purpose;

  /// User-specified business date as Unix epoch seconds.
  /// Named [transactionDate] to avoid collision with Drift's built-in
  /// `dateTime()` method on Table.
  final int transactionDate;

  /// Transaction amount in minor units of [currencyCode]. Must be > 0.
  final int amountMinor;

  /// Currency derived from source account. Immutable after creation.
  final String currencyCode;

  /// Rate × 1,000,000 from account currency to [homeCurrencyAtCapture].
  /// NULL when transaction currency equals home currency.
  final int? exchangeRateMicro;

  /// Home currency code captured at rate-fetch time.
  /// NULL when transaction currency equals home currency.
  final String? homeCurrencyAtCapture;

  /// Source account for expense/transfer. NULL for income.
  final String? accountSourceId;

  /// Destination account for income/transfer. NULL for expense.
  final String? accountDestinationId;

  /// Top-level category. NULL for transfers.
  final String? categoryId;

  /// Optional subcategory. NULL for transfers.
  final String? subcategoryId;

  /// Optional payee/merchant reference.
  final String? payeeId;

  /// User-defined label. Updatable in-place.
  final String? title;

  /// Long-form note. Updatable in-place.
  final String? description;

  /// UUID shared by compound group members (e.g. transfer + fee).
  final String? compoundGroupId;

  /// Role within a compound group: `primary`, `secondary`, or NULL.
  final String? compoundRole;

  /// FK to the generating recurring template.
  final String? parentTemplateId;

  /// For purpose=correction/reversal: ID of the transaction being corrected.
  final String? correctsTransactionId;

  /// True when a child was edited/deleted outside normal scheduling.
  final bool isManuallyHandled;

  /// Unix epoch seconds when this row was created.
  final int createdAt;

  /// Unix epoch seconds when this row was last modified.
  final int updatedAt;

  /// JSON escape hatch for future extensibility.
  final String? metadata;
  const Transaction(
      {required this.id,
      required this.type,
      required this.status,
      required this.purpose,
      required this.transactionDate,
      required this.amountMinor,
      required this.currencyCode,
      this.exchangeRateMicro,
      this.homeCurrencyAtCapture,
      this.accountSourceId,
      this.accountDestinationId,
      this.categoryId,
      this.subcategoryId,
      this.payeeId,
      this.title,
      this.description,
      this.compoundGroupId,
      this.compoundRole,
      this.parentTemplateId,
      this.correctsTransactionId,
      required this.isManuallyHandled,
      required this.createdAt,
      required this.updatedAt,
      this.metadata});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['status'] = Variable<String>(status);
    map['purpose'] = Variable<String>(purpose);
    map['transaction_date'] = Variable<int>(transactionDate);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency_code'] = Variable<String>(currencyCode);
    if (!nullToAbsent || exchangeRateMicro != null) {
      map['exchange_rate_micro'] = Variable<int>(exchangeRateMicro);
    }
    if (!nullToAbsent || homeCurrencyAtCapture != null) {
      map['home_currency_at_capture'] = Variable<String>(homeCurrencyAtCapture);
    }
    if (!nullToAbsent || accountSourceId != null) {
      map['account_source_id'] = Variable<String>(accountSourceId);
    }
    if (!nullToAbsent || accountDestinationId != null) {
      map['account_destination_id'] = Variable<String>(accountDestinationId);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    if (!nullToAbsent || subcategoryId != null) {
      map['subcategory_id'] = Variable<String>(subcategoryId);
    }
    if (!nullToAbsent || payeeId != null) {
      map['payee_id'] = Variable<String>(payeeId);
    }
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || compoundGroupId != null) {
      map['compound_group_id'] = Variable<String>(compoundGroupId);
    }
    if (!nullToAbsent || compoundRole != null) {
      map['compound_role'] = Variable<String>(compoundRole);
    }
    if (!nullToAbsent || parentTemplateId != null) {
      map['parent_template_id'] = Variable<String>(parentTemplateId);
    }
    if (!nullToAbsent || correctsTransactionId != null) {
      map['corrects_transaction_id'] = Variable<String>(correctsTransactionId);
    }
    map['is_manually_handled'] = Variable<bool>(isManuallyHandled);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || metadata != null) {
      map['metadata'] = Variable<String>(metadata);
    }
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      type: Value(type),
      status: Value(status),
      purpose: Value(purpose),
      transactionDate: Value(transactionDate),
      amountMinor: Value(amountMinor),
      currencyCode: Value(currencyCode),
      exchangeRateMicro: exchangeRateMicro == null && nullToAbsent
          ? const Value.absent()
          : Value(exchangeRateMicro),
      homeCurrencyAtCapture: homeCurrencyAtCapture == null && nullToAbsent
          ? const Value.absent()
          : Value(homeCurrencyAtCapture),
      accountSourceId: accountSourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountSourceId),
      accountDestinationId: accountDestinationId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountDestinationId),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      subcategoryId: subcategoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(subcategoryId),
      payeeId: payeeId == null && nullToAbsent
          ? const Value.absent()
          : Value(payeeId),
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      compoundGroupId: compoundGroupId == null && nullToAbsent
          ? const Value.absent()
          : Value(compoundGroupId),
      compoundRole: compoundRole == null && nullToAbsent
          ? const Value.absent()
          : Value(compoundRole),
      parentTemplateId: parentTemplateId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentTemplateId),
      correctsTransactionId: correctsTransactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(correctsTransactionId),
      isManuallyHandled: Value(isManuallyHandled),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      metadata: metadata == null && nullToAbsent
          ? const Value.absent()
          : Value(metadata),
    );
  }

  factory Transaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      status: serializer.fromJson<String>(json['status']),
      purpose: serializer.fromJson<String>(json['purpose']),
      transactionDate: serializer.fromJson<int>(json['transactionDate']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      exchangeRateMicro: serializer.fromJson<int?>(json['exchangeRateMicro']),
      homeCurrencyAtCapture:
          serializer.fromJson<String?>(json['homeCurrencyAtCapture']),
      accountSourceId: serializer.fromJson<String?>(json['accountSourceId']),
      accountDestinationId:
          serializer.fromJson<String?>(json['accountDestinationId']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      subcategoryId: serializer.fromJson<String?>(json['subcategoryId']),
      payeeId: serializer.fromJson<String?>(json['payeeId']),
      title: serializer.fromJson<String?>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      compoundGroupId: serializer.fromJson<String?>(json['compoundGroupId']),
      compoundRole: serializer.fromJson<String?>(json['compoundRole']),
      parentTemplateId: serializer.fromJson<String?>(json['parentTemplateId']),
      correctsTransactionId:
          serializer.fromJson<String?>(json['correctsTransactionId']),
      isManuallyHandled: serializer.fromJson<bool>(json['isManuallyHandled']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      metadata: serializer.fromJson<String?>(json['metadata']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'status': serializer.toJson<String>(status),
      'purpose': serializer.toJson<String>(purpose),
      'transactionDate': serializer.toJson<int>(transactionDate),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'exchangeRateMicro': serializer.toJson<int?>(exchangeRateMicro),
      'homeCurrencyAtCapture':
          serializer.toJson<String?>(homeCurrencyAtCapture),
      'accountSourceId': serializer.toJson<String?>(accountSourceId),
      'accountDestinationId': serializer.toJson<String?>(accountDestinationId),
      'categoryId': serializer.toJson<String?>(categoryId),
      'subcategoryId': serializer.toJson<String?>(subcategoryId),
      'payeeId': serializer.toJson<String?>(payeeId),
      'title': serializer.toJson<String?>(title),
      'description': serializer.toJson<String?>(description),
      'compoundGroupId': serializer.toJson<String?>(compoundGroupId),
      'compoundRole': serializer.toJson<String?>(compoundRole),
      'parentTemplateId': serializer.toJson<String?>(parentTemplateId),
      'correctsTransactionId':
          serializer.toJson<String?>(correctsTransactionId),
      'isManuallyHandled': serializer.toJson<bool>(isManuallyHandled),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'metadata': serializer.toJson<String?>(metadata),
    };
  }

  Transaction copyWith(
          {String? id,
          String? type,
          String? status,
          String? purpose,
          int? transactionDate,
          int? amountMinor,
          String? currencyCode,
          Value<int?> exchangeRateMicro = const Value.absent(),
          Value<String?> homeCurrencyAtCapture = const Value.absent(),
          Value<String?> accountSourceId = const Value.absent(),
          Value<String?> accountDestinationId = const Value.absent(),
          Value<String?> categoryId = const Value.absent(),
          Value<String?> subcategoryId = const Value.absent(),
          Value<String?> payeeId = const Value.absent(),
          Value<String?> title = const Value.absent(),
          Value<String?> description = const Value.absent(),
          Value<String?> compoundGroupId = const Value.absent(),
          Value<String?> compoundRole = const Value.absent(),
          Value<String?> parentTemplateId = const Value.absent(),
          Value<String?> correctsTransactionId = const Value.absent(),
          bool? isManuallyHandled,
          int? createdAt,
          int? updatedAt,
          Value<String?> metadata = const Value.absent()}) =>
      Transaction(
        id: id ?? this.id,
        type: type ?? this.type,
        status: status ?? this.status,
        purpose: purpose ?? this.purpose,
        transactionDate: transactionDate ?? this.transactionDate,
        amountMinor: amountMinor ?? this.amountMinor,
        currencyCode: currencyCode ?? this.currencyCode,
        exchangeRateMicro: exchangeRateMicro.present
            ? exchangeRateMicro.value
            : this.exchangeRateMicro,
        homeCurrencyAtCapture: homeCurrencyAtCapture.present
            ? homeCurrencyAtCapture.value
            : this.homeCurrencyAtCapture,
        accountSourceId: accountSourceId.present
            ? accountSourceId.value
            : this.accountSourceId,
        accountDestinationId: accountDestinationId.present
            ? accountDestinationId.value
            : this.accountDestinationId,
        categoryId: categoryId.present ? categoryId.value : this.categoryId,
        subcategoryId:
            subcategoryId.present ? subcategoryId.value : this.subcategoryId,
        payeeId: payeeId.present ? payeeId.value : this.payeeId,
        title: title.present ? title.value : this.title,
        description: description.present ? description.value : this.description,
        compoundGroupId: compoundGroupId.present
            ? compoundGroupId.value
            : this.compoundGroupId,
        compoundRole:
            compoundRole.present ? compoundRole.value : this.compoundRole,
        parentTemplateId: parentTemplateId.present
            ? parentTemplateId.value
            : this.parentTemplateId,
        correctsTransactionId: correctsTransactionId.present
            ? correctsTransactionId.value
            : this.correctsTransactionId,
        isManuallyHandled: isManuallyHandled ?? this.isManuallyHandled,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        metadata: metadata.present ? metadata.value : this.metadata,
      );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      status: data.status.present ? data.status.value : this.status,
      purpose: data.purpose.present ? data.purpose.value : this.purpose,
      transactionDate: data.transactionDate.present
          ? data.transactionDate.value
          : this.transactionDate,
      amountMinor:
          data.amountMinor.present ? data.amountMinor.value : this.amountMinor,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      exchangeRateMicro: data.exchangeRateMicro.present
          ? data.exchangeRateMicro.value
          : this.exchangeRateMicro,
      homeCurrencyAtCapture: data.homeCurrencyAtCapture.present
          ? data.homeCurrencyAtCapture.value
          : this.homeCurrencyAtCapture,
      accountSourceId: data.accountSourceId.present
          ? data.accountSourceId.value
          : this.accountSourceId,
      accountDestinationId: data.accountDestinationId.present
          ? data.accountDestinationId.value
          : this.accountDestinationId,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      subcategoryId: data.subcategoryId.present
          ? data.subcategoryId.value
          : this.subcategoryId,
      payeeId: data.payeeId.present ? data.payeeId.value : this.payeeId,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      compoundGroupId: data.compoundGroupId.present
          ? data.compoundGroupId.value
          : this.compoundGroupId,
      compoundRole: data.compoundRole.present
          ? data.compoundRole.value
          : this.compoundRole,
      parentTemplateId: data.parentTemplateId.present
          ? data.parentTemplateId.value
          : this.parentTemplateId,
      correctsTransactionId: data.correctsTransactionId.present
          ? data.correctsTransactionId.value
          : this.correctsTransactionId,
      isManuallyHandled: data.isManuallyHandled.present
          ? data.isManuallyHandled.value
          : this.isManuallyHandled,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('purpose: $purpose, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('exchangeRateMicro: $exchangeRateMicro, ')
          ..write('homeCurrencyAtCapture: $homeCurrencyAtCapture, ')
          ..write('accountSourceId: $accountSourceId, ')
          ..write('accountDestinationId: $accountDestinationId, ')
          ..write('categoryId: $categoryId, ')
          ..write('subcategoryId: $subcategoryId, ')
          ..write('payeeId: $payeeId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('compoundGroupId: $compoundGroupId, ')
          ..write('compoundRole: $compoundRole, ')
          ..write('parentTemplateId: $parentTemplateId, ')
          ..write('correctsTransactionId: $correctsTransactionId, ')
          ..write('isManuallyHandled: $isManuallyHandled, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('metadata: $metadata')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        type,
        status,
        purpose,
        transactionDate,
        amountMinor,
        currencyCode,
        exchangeRateMicro,
        homeCurrencyAtCapture,
        accountSourceId,
        accountDestinationId,
        categoryId,
        subcategoryId,
        payeeId,
        title,
        description,
        compoundGroupId,
        compoundRole,
        parentTemplateId,
        correctsTransactionId,
        isManuallyHandled,
        createdAt,
        updatedAt,
        metadata
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.type == this.type &&
          other.status == this.status &&
          other.purpose == this.purpose &&
          other.transactionDate == this.transactionDate &&
          other.amountMinor == this.amountMinor &&
          other.currencyCode == this.currencyCode &&
          other.exchangeRateMicro == this.exchangeRateMicro &&
          other.homeCurrencyAtCapture == this.homeCurrencyAtCapture &&
          other.accountSourceId == this.accountSourceId &&
          other.accountDestinationId == this.accountDestinationId &&
          other.categoryId == this.categoryId &&
          other.subcategoryId == this.subcategoryId &&
          other.payeeId == this.payeeId &&
          other.title == this.title &&
          other.description == this.description &&
          other.compoundGroupId == this.compoundGroupId &&
          other.compoundRole == this.compoundRole &&
          other.parentTemplateId == this.parentTemplateId &&
          other.correctsTransactionId == this.correctsTransactionId &&
          other.isManuallyHandled == this.isManuallyHandled &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.metadata == this.metadata);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<String> id;
  final Value<String> type;
  final Value<String> status;
  final Value<String> purpose;
  final Value<int> transactionDate;
  final Value<int> amountMinor;
  final Value<String> currencyCode;
  final Value<int?> exchangeRateMicro;
  final Value<String?> homeCurrencyAtCapture;
  final Value<String?> accountSourceId;
  final Value<String?> accountDestinationId;
  final Value<String?> categoryId;
  final Value<String?> subcategoryId;
  final Value<String?> payeeId;
  final Value<String?> title;
  final Value<String?> description;
  final Value<String?> compoundGroupId;
  final Value<String?> compoundRole;
  final Value<String?> parentTemplateId;
  final Value<String?> correctsTransactionId;
  final Value<bool> isManuallyHandled;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String?> metadata;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.status = const Value.absent(),
    this.purpose = const Value.absent(),
    this.transactionDate = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.exchangeRateMicro = const Value.absent(),
    this.homeCurrencyAtCapture = const Value.absent(),
    this.accountSourceId = const Value.absent(),
    this.accountDestinationId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.subcategoryId = const Value.absent(),
    this.payeeId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.compoundGroupId = const Value.absent(),
    this.compoundRole = const Value.absent(),
    this.parentTemplateId = const Value.absent(),
    this.correctsTransactionId = const Value.absent(),
    this.isManuallyHandled = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.metadata = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    required String id,
    required String type,
    this.status = const Value.absent(),
    this.purpose = const Value.absent(),
    required int transactionDate,
    required int amountMinor,
    required String currencyCode,
    this.exchangeRateMicro = const Value.absent(),
    this.homeCurrencyAtCapture = const Value.absent(),
    this.accountSourceId = const Value.absent(),
    this.accountDestinationId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.subcategoryId = const Value.absent(),
    this.payeeId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.compoundGroupId = const Value.absent(),
    this.compoundRole = const Value.absent(),
    this.parentTemplateId = const Value.absent(),
    this.correctsTransactionId = const Value.absent(),
    this.isManuallyHandled = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.metadata = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        type = Value(type),
        transactionDate = Value(transactionDate),
        amountMinor = Value(amountMinor),
        currencyCode = Value(currencyCode),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Transaction> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? status,
    Expression<String>? purpose,
    Expression<int>? transactionDate,
    Expression<int>? amountMinor,
    Expression<String>? currencyCode,
    Expression<int>? exchangeRateMicro,
    Expression<String>? homeCurrencyAtCapture,
    Expression<String>? accountSourceId,
    Expression<String>? accountDestinationId,
    Expression<String>? categoryId,
    Expression<String>? subcategoryId,
    Expression<String>? payeeId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? compoundGroupId,
    Expression<String>? compoundRole,
    Expression<String>? parentTemplateId,
    Expression<String>? correctsTransactionId,
    Expression<bool>? isManuallyHandled,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? metadata,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (status != null) 'status': status,
      if (purpose != null) 'purpose': purpose,
      if (transactionDate != null) 'transaction_date': transactionDate,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (exchangeRateMicro != null) 'exchange_rate_micro': exchangeRateMicro,
      if (homeCurrencyAtCapture != null)
        'home_currency_at_capture': homeCurrencyAtCapture,
      if (accountSourceId != null) 'account_source_id': accountSourceId,
      if (accountDestinationId != null)
        'account_destination_id': accountDestinationId,
      if (categoryId != null) 'category_id': categoryId,
      if (subcategoryId != null) 'subcategory_id': subcategoryId,
      if (payeeId != null) 'payee_id': payeeId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (compoundGroupId != null) 'compound_group_id': compoundGroupId,
      if (compoundRole != null) 'compound_role': compoundRole,
      if (parentTemplateId != null) 'parent_template_id': parentTemplateId,
      if (correctsTransactionId != null)
        'corrects_transaction_id': correctsTransactionId,
      if (isManuallyHandled != null) 'is_manually_handled': isManuallyHandled,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (metadata != null) 'metadata': metadata,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? type,
      Value<String>? status,
      Value<String>? purpose,
      Value<int>? transactionDate,
      Value<int>? amountMinor,
      Value<String>? currencyCode,
      Value<int?>? exchangeRateMicro,
      Value<String?>? homeCurrencyAtCapture,
      Value<String?>? accountSourceId,
      Value<String?>? accountDestinationId,
      Value<String?>? categoryId,
      Value<String?>? subcategoryId,
      Value<String?>? payeeId,
      Value<String?>? title,
      Value<String?>? description,
      Value<String?>? compoundGroupId,
      Value<String?>? compoundRole,
      Value<String?>? parentTemplateId,
      Value<String?>? correctsTransactionId,
      Value<bool>? isManuallyHandled,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<String?>? metadata,
      Value<int>? rowid}) {
    return TransactionsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      status: status ?? this.status,
      purpose: purpose ?? this.purpose,
      transactionDate: transactionDate ?? this.transactionDate,
      amountMinor: amountMinor ?? this.amountMinor,
      currencyCode: currencyCode ?? this.currencyCode,
      exchangeRateMicro: exchangeRateMicro ?? this.exchangeRateMicro,
      homeCurrencyAtCapture:
          homeCurrencyAtCapture ?? this.homeCurrencyAtCapture,
      accountSourceId: accountSourceId ?? this.accountSourceId,
      accountDestinationId: accountDestinationId ?? this.accountDestinationId,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      payeeId: payeeId ?? this.payeeId,
      title: title ?? this.title,
      description: description ?? this.description,
      compoundGroupId: compoundGroupId ?? this.compoundGroupId,
      compoundRole: compoundRole ?? this.compoundRole,
      parentTemplateId: parentTemplateId ?? this.parentTemplateId,
      correctsTransactionId:
          correctsTransactionId ?? this.correctsTransactionId,
      isManuallyHandled: isManuallyHandled ?? this.isManuallyHandled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (purpose.present) {
      map['purpose'] = Variable<String>(purpose.value);
    }
    if (transactionDate.present) {
      map['transaction_date'] = Variable<int>(transactionDate.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (exchangeRateMicro.present) {
      map['exchange_rate_micro'] = Variable<int>(exchangeRateMicro.value);
    }
    if (homeCurrencyAtCapture.present) {
      map['home_currency_at_capture'] =
          Variable<String>(homeCurrencyAtCapture.value);
    }
    if (accountSourceId.present) {
      map['account_source_id'] = Variable<String>(accountSourceId.value);
    }
    if (accountDestinationId.present) {
      map['account_destination_id'] =
          Variable<String>(accountDestinationId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (subcategoryId.present) {
      map['subcategory_id'] = Variable<String>(subcategoryId.value);
    }
    if (payeeId.present) {
      map['payee_id'] = Variable<String>(payeeId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (compoundGroupId.present) {
      map['compound_group_id'] = Variable<String>(compoundGroupId.value);
    }
    if (compoundRole.present) {
      map['compound_role'] = Variable<String>(compoundRole.value);
    }
    if (parentTemplateId.present) {
      map['parent_template_id'] = Variable<String>(parentTemplateId.value);
    }
    if (correctsTransactionId.present) {
      map['corrects_transaction_id'] =
          Variable<String>(correctsTransactionId.value);
    }
    if (isManuallyHandled.present) {
      map['is_manually_handled'] = Variable<bool>(isManuallyHandled.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
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
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('purpose: $purpose, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('exchangeRateMicro: $exchangeRateMicro, ')
          ..write('homeCurrencyAtCapture: $homeCurrencyAtCapture, ')
          ..write('accountSourceId: $accountSourceId, ')
          ..write('accountDestinationId: $accountDestinationId, ')
          ..write('categoryId: $categoryId, ')
          ..write('subcategoryId: $subcategoryId, ')
          ..write('payeeId: $payeeId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('compoundGroupId: $compoundGroupId, ')
          ..write('compoundRole: $compoundRole, ')
          ..write('parentTemplateId: $parentTemplateId, ')
          ..write('correctsTransactionId: $correctsTransactionId, ')
          ..write('isManuallyHandled: $isManuallyHandled, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('metadata: $metadata, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EntriesTable extends Entries with TableInfo<$EntriesTable, Entry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _transactionIdMeta =
      const VerificationMeta('transactionId');
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
      'transaction_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES transactions (id) ON DELETE RESTRICT'));
  static const VerificationMeta _accountIdMeta =
      const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
      'account_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES accounts (id)'));
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES categories (id)'));
  static const VerificationMeta _sideMeta = const VerificationMeta('side');
  @override
  late final GeneratedColumn<String> side = GeneratedColumn<String>(
      'side', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMinorMeta =
      const VerificationMeta('amountMinor');
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
      'amount_minor', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _currencyCodeMeta =
      const VerificationMeta('currencyCode');
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
      'currency_code', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES currencies (code)'));
  static const VerificationMeta _exchangeRateMicroMeta =
      const VerificationMeta('exchangeRateMicro');
  @override
  late final GeneratedColumn<int> exchangeRateMicro = GeneratedColumn<int>(
      'exchange_rate_micro', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        transactionId,
        accountId,
        categoryId,
        side,
        amountMinor,
        currencyCode,
        exchangeRateMicro,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entries';
  @override
  VerificationContext validateIntegrity(Insertable<Entry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
          _transactionIdMeta,
          transactionId.isAcceptableOrUnknown(
              data['transaction_id']!, _transactionIdMeta));
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta,
          accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    if (data.containsKey('side')) {
      context.handle(
          _sideMeta, side.isAcceptableOrUnknown(data['side']!, _sideMeta));
    } else if (isInserting) {
      context.missing(_sideMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
          _amountMinorMeta,
          amountMinor.isAcceptableOrUnknown(
              data['amount_minor']!, _amountMinorMeta));
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
          _currencyCodeMeta,
          currencyCode.isAcceptableOrUnknown(
              data['currency_code']!, _currencyCodeMeta));
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('exchange_rate_micro')) {
      context.handle(
          _exchangeRateMicroMeta,
          exchangeRateMicro.isAcceptableOrUnknown(
              data['exchange_rate_micro']!, _exchangeRateMicroMeta));
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
  Entry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Entry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      transactionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}transaction_id'])!,
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_id']),
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id']),
      side: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}side'])!,
      amountMinor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount_minor'])!,
      currencyCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency_code'])!,
      exchangeRateMicro: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}exchange_rate_micro']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $EntriesTable createAlias(String alias) {
    return $EntriesTable(attachedDatabase, alias);
  }
}

class Entry extends DataClass implements Insertable<Entry> {
  /// Stable UUID v4 identifier.
  final String id;

  /// FK → transactions(id) ON DELETE RESTRICT. Cascade delete is blocked
  /// intentionally — void/reversal must go through the domain layer.
  final String transactionId;

  /// Account leg; mutually exclusive with [categoryId].
  final String? accountId;

  /// Category leg; mutually exclusive with [accountId].
  final String? categoryId;

  /// Double-entry side: `debit` or `credit`.
  final String side;

  /// Amount in minor units of [currencyCode]. Must be > 0.
  final int amountMinor;

  /// Currency of this entry (derived from account currency).
  final String currencyCode;

  /// Rate to home currency × 1,000,000. NULL if same as home currency.
  final int? exchangeRateMicro;

  /// Unix epoch seconds when this row was written (TC-025).
  final int createdAt;
  const Entry(
      {required this.id,
      required this.transactionId,
      this.accountId,
      this.categoryId,
      required this.side,
      required this.amountMinor,
      required this.currencyCode,
      this.exchangeRateMicro,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['transaction_id'] = Variable<String>(transactionId);
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<String>(accountId);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    map['side'] = Variable<String>(side);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency_code'] = Variable<String>(currencyCode);
    if (!nullToAbsent || exchangeRateMicro != null) {
      map['exchange_rate_micro'] = Variable<int>(exchangeRateMicro);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  EntriesCompanion toCompanion(bool nullToAbsent) {
    return EntriesCompanion(
      id: Value(id),
      transactionId: Value(transactionId),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      side: Value(side),
      amountMinor: Value(amountMinor),
      currencyCode: Value(currencyCode),
      exchangeRateMicro: exchangeRateMicro == null && nullToAbsent
          ? const Value.absent()
          : Value(exchangeRateMicro),
      createdAt: Value(createdAt),
    );
  }

  factory Entry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Entry(
      id: serializer.fromJson<String>(json['id']),
      transactionId: serializer.fromJson<String>(json['transactionId']),
      accountId: serializer.fromJson<String?>(json['accountId']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      side: serializer.fromJson<String>(json['side']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      exchangeRateMicro: serializer.fromJson<int?>(json['exchangeRateMicro']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'transactionId': serializer.toJson<String>(transactionId),
      'accountId': serializer.toJson<String?>(accountId),
      'categoryId': serializer.toJson<String?>(categoryId),
      'side': serializer.toJson<String>(side),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'exchangeRateMicro': serializer.toJson<int?>(exchangeRateMicro),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  Entry copyWith(
          {String? id,
          String? transactionId,
          Value<String?> accountId = const Value.absent(),
          Value<String?> categoryId = const Value.absent(),
          String? side,
          int? amountMinor,
          String? currencyCode,
          Value<int?> exchangeRateMicro = const Value.absent(),
          int? createdAt}) =>
      Entry(
        id: id ?? this.id,
        transactionId: transactionId ?? this.transactionId,
        accountId: accountId.present ? accountId.value : this.accountId,
        categoryId: categoryId.present ? categoryId.value : this.categoryId,
        side: side ?? this.side,
        amountMinor: amountMinor ?? this.amountMinor,
        currencyCode: currencyCode ?? this.currencyCode,
        exchangeRateMicro: exchangeRateMicro.present
            ? exchangeRateMicro.value
            : this.exchangeRateMicro,
        createdAt: createdAt ?? this.createdAt,
      );
  Entry copyWithCompanion(EntriesCompanion data) {
    return Entry(
      id: data.id.present ? data.id.value : this.id,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      side: data.side.present ? data.side.value : this.side,
      amountMinor:
          data.amountMinor.present ? data.amountMinor.value : this.amountMinor,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      exchangeRateMicro: data.exchangeRateMicro.present
          ? data.exchangeRateMicro.value
          : this.exchangeRateMicro,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Entry(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('accountId: $accountId, ')
          ..write('categoryId: $categoryId, ')
          ..write('side: $side, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('exchangeRateMicro: $exchangeRateMicro, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, transactionId, accountId, categoryId,
      side, amountMinor, currencyCode, exchangeRateMicro, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Entry &&
          other.id == this.id &&
          other.transactionId == this.transactionId &&
          other.accountId == this.accountId &&
          other.categoryId == this.categoryId &&
          other.side == this.side &&
          other.amountMinor == this.amountMinor &&
          other.currencyCode == this.currencyCode &&
          other.exchangeRateMicro == this.exchangeRateMicro &&
          other.createdAt == this.createdAt);
}

class EntriesCompanion extends UpdateCompanion<Entry> {
  final Value<String> id;
  final Value<String> transactionId;
  final Value<String?> accountId;
  final Value<String?> categoryId;
  final Value<String> side;
  final Value<int> amountMinor;
  final Value<String> currencyCode;
  final Value<int?> exchangeRateMicro;
  final Value<int> createdAt;
  final Value<int> rowid;
  const EntriesCompanion({
    this.id = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.side = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.exchangeRateMicro = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EntriesCompanion.insert({
    required String id,
    required String transactionId,
    this.accountId = const Value.absent(),
    this.categoryId = const Value.absent(),
    required String side,
    required int amountMinor,
    required String currencyCode,
    this.exchangeRateMicro = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        transactionId = Value(transactionId),
        side = Value(side),
        amountMinor = Value(amountMinor),
        currencyCode = Value(currencyCode),
        createdAt = Value(createdAt);
  static Insertable<Entry> custom({
    Expression<String>? id,
    Expression<String>? transactionId,
    Expression<String>? accountId,
    Expression<String>? categoryId,
    Expression<String>? side,
    Expression<int>? amountMinor,
    Expression<String>? currencyCode,
    Expression<int>? exchangeRateMicro,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionId != null) 'transaction_id': transactionId,
      if (accountId != null) 'account_id': accountId,
      if (categoryId != null) 'category_id': categoryId,
      if (side != null) 'side': side,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (exchangeRateMicro != null) 'exchange_rate_micro': exchangeRateMicro,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EntriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? transactionId,
      Value<String?>? accountId,
      Value<String?>? categoryId,
      Value<String>? side,
      Value<int>? amountMinor,
      Value<String>? currencyCode,
      Value<int?>? exchangeRateMicro,
      Value<int>? createdAt,
      Value<int>? rowid}) {
    return EntriesCompanion(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      side: side ?? this.side,
      amountMinor: amountMinor ?? this.amountMinor,
      currencyCode: currencyCode ?? this.currencyCode,
      exchangeRateMicro: exchangeRateMicro ?? this.exchangeRateMicro,
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
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (side.present) {
      map['side'] = Variable<String>(side.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (exchangeRateMicro.present) {
      map['exchange_rate_micro'] = Variable<int>(exchangeRateMicro.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntriesCompanion(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('accountId: $accountId, ')
          ..write('categoryId: $categoryId, ')
          ..write('side: $side, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('exchangeRateMicro: $exchangeRateMicro, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(Insertable<Tag> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
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
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class Tag extends DataClass implements Insertable<Tag> {
  /// Stable UUID v4 identifier.
  final String id;

  /// Tag label. Case-insensitive uniqueness enforced at app layer.
  final String name;

  /// Unix epoch seconds when this row was created.
  final int createdAt;
  const Tag({required this.id, required this.name, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
    );
  }

  factory Tag.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  Tag copyWith({String? id, String? name, int? createdAt}) => Tag(
        id: id ?? this.id,
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
      );
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> createdAt;
  final Value<int> rowid;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagsCompanion.insert({
    required String id,
    required String name,
    required int createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        createdAt = Value(createdAt);
  static Insertable<Tag> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<int>? createdAt,
      Value<int>? rowid}) {
    return TagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionTagsTable extends TransactionTags
    with TableInfo<$TransactionTagsTable, TransactionTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _transactionIdMeta =
      const VerificationMeta('transactionId');
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
      'transaction_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES transactions (id) ON DELETE CASCADE'));
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
      'tag_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES tags (id) ON DELETE CASCADE'));
  @override
  List<GeneratedColumn> get $columns => [transactionId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transaction_tags';
  @override
  VerificationContext validateIntegrity(Insertable<TransactionTag> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('transaction_id')) {
      context.handle(
          _transactionIdMeta,
          transactionId.isAcceptableOrUnknown(
              data['transaction_id']!, _transactionIdMeta));
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
          _tagIdMeta, tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta));
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {transactionId, tagId};
  @override
  TransactionTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionTag(
      transactionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}transaction_id'])!,
      tagId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tag_id'])!,
    );
  }

  @override
  $TransactionTagsTable createAlias(String alias) {
    return $TransactionTagsTable(attachedDatabase, alias);
  }
}

class TransactionTag extends DataClass implements Insertable<TransactionTag> {
  /// FK → transactions(id) ON DELETE CASCADE.
  final String transactionId;

  /// FK → tags(id) ON DELETE CASCADE.
  final String tagId;
  const TransactionTag({required this.transactionId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['transaction_id'] = Variable<String>(transactionId);
    map['tag_id'] = Variable<String>(tagId);
    return map;
  }

  TransactionTagsCompanion toCompanion(bool nullToAbsent) {
    return TransactionTagsCompanion(
      transactionId: Value(transactionId),
      tagId: Value(tagId),
    );
  }

  factory TransactionTag.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionTag(
      transactionId: serializer.fromJson<String>(json['transactionId']),
      tagId: serializer.fromJson<String>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'transactionId': serializer.toJson<String>(transactionId),
      'tagId': serializer.toJson<String>(tagId),
    };
  }

  TransactionTag copyWith({String? transactionId, String? tagId}) =>
      TransactionTag(
        transactionId: transactionId ?? this.transactionId,
        tagId: tagId ?? this.tagId,
      );
  TransactionTag copyWithCompanion(TransactionTagsCompanion data) {
    return TransactionTag(
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionTag(')
          ..write('transactionId: $transactionId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(transactionId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionTag &&
          other.transactionId == this.transactionId &&
          other.tagId == this.tagId);
}

class TransactionTagsCompanion extends UpdateCompanion<TransactionTag> {
  final Value<String> transactionId;
  final Value<String> tagId;
  final Value<int> rowid;
  const TransactionTagsCompanion({
    this.transactionId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionTagsCompanion.insert({
    required String transactionId,
    required String tagId,
    this.rowid = const Value.absent(),
  })  : transactionId = Value(transactionId),
        tagId = Value(tagId);
  static Insertable<TransactionTag> custom({
    Expression<String>? transactionId,
    Expression<String>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (transactionId != null) 'transaction_id': transactionId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionTagsCompanion copyWith(
      {Value<String>? transactionId, Value<String>? tagId, Value<int>? rowid}) {
    return TransactionTagsCompanion(
      transactionId: transactionId ?? this.transactionId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionTagsCompanion(')
          ..write('transactionId: $transactionId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExchangeRatesTable extends ExchangeRates
    with TableInfo<$ExchangeRatesTable, ExchangeRate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExchangeRatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _fromCurrencyMeta =
      const VerificationMeta('fromCurrency');
  @override
  late final GeneratedColumn<String> fromCurrency = GeneratedColumn<String>(
      'from_currency', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES currencies (code)'));
  static const VerificationMeta _toCurrencyMeta =
      const VerificationMeta('toCurrency');
  @override
  late final GeneratedColumn<String> toCurrency = GeneratedColumn<String>(
      'to_currency', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES currencies (code)'));
  static const VerificationMeta _rateMicroMeta =
      const VerificationMeta('rateMicro');
  @override
  late final GeneratedColumn<int> rateMicro = GeneratedColumn<int>(
      'rate_micro', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _fetchedAtMeta =
      const VerificationMeta('fetchedAt');
  @override
  late final GeneratedColumn<int> fetchedAt = GeneratedColumn<int>(
      'fetched_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _rateDateMeta =
      const VerificationMeta('rateDate');
  @override
  late final GeneratedColumn<String> rateDate = GeneratedColumn<String>(
      'rate_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, fromCurrency, toCurrency, rateMicro, fetchedAt, rateDate];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exchange_rates';
  @override
  VerificationContext validateIntegrity(Insertable<ExchangeRate> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('from_currency')) {
      context.handle(
          _fromCurrencyMeta,
          fromCurrency.isAcceptableOrUnknown(
              data['from_currency']!, _fromCurrencyMeta));
    } else if (isInserting) {
      context.missing(_fromCurrencyMeta);
    }
    if (data.containsKey('to_currency')) {
      context.handle(
          _toCurrencyMeta,
          toCurrency.isAcceptableOrUnknown(
              data['to_currency']!, _toCurrencyMeta));
    } else if (isInserting) {
      context.missing(_toCurrencyMeta);
    }
    if (data.containsKey('rate_micro')) {
      context.handle(_rateMicroMeta,
          rateMicro.isAcceptableOrUnknown(data['rate_micro']!, _rateMicroMeta));
    } else if (isInserting) {
      context.missing(_rateMicroMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(_fetchedAtMeta,
          fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta));
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    if (data.containsKey('rate_date')) {
      context.handle(_rateDateMeta,
          rateDate.isAcceptableOrUnknown(data['rate_date']!, _rateDateMeta));
    } else if (isInserting) {
      context.missing(_rateDateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {fromCurrency, toCurrency},
      ];
  @override
  ExchangeRate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExchangeRate(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      fromCurrency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}from_currency'])!,
      toCurrency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}to_currency'])!,
      rateMicro: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}rate_micro'])!,
      fetchedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}fetched_at'])!,
      rateDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rate_date'])!,
    );
  }

  @override
  $ExchangeRatesTable createAlias(String alias) {
    return $ExchangeRatesTable(attachedDatabase, alias);
  }
}

class ExchangeRate extends DataClass implements Insertable<ExchangeRate> {
  /// Auto-incrementing row identifier (internal cache; no sync requirement).
  final int id;

  /// Base currency code.
  final String fromCurrency;

  /// Target currency code.
  final String toCurrency;

  /// Exchange rate × 1,000,000 (6 decimal places). Must be > 0.
  final int rateMicro;

  /// Wall-clock Unix epoch seconds when this rate was fetched.
  final int fetchedAt;

  /// ISO 8601 date string from the API `date` field (e.g. `2025-05-07`).
  final String rateDate;
  const ExchangeRate(
      {required this.id,
      required this.fromCurrency,
      required this.toCurrency,
      required this.rateMicro,
      required this.fetchedAt,
      required this.rateDate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['from_currency'] = Variable<String>(fromCurrency);
    map['to_currency'] = Variable<String>(toCurrency);
    map['rate_micro'] = Variable<int>(rateMicro);
    map['fetched_at'] = Variable<int>(fetchedAt);
    map['rate_date'] = Variable<String>(rateDate);
    return map;
  }

  ExchangeRatesCompanion toCompanion(bool nullToAbsent) {
    return ExchangeRatesCompanion(
      id: Value(id),
      fromCurrency: Value(fromCurrency),
      toCurrency: Value(toCurrency),
      rateMicro: Value(rateMicro),
      fetchedAt: Value(fetchedAt),
      rateDate: Value(rateDate),
    );
  }

  factory ExchangeRate.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExchangeRate(
      id: serializer.fromJson<int>(json['id']),
      fromCurrency: serializer.fromJson<String>(json['fromCurrency']),
      toCurrency: serializer.fromJson<String>(json['toCurrency']),
      rateMicro: serializer.fromJson<int>(json['rateMicro']),
      fetchedAt: serializer.fromJson<int>(json['fetchedAt']),
      rateDate: serializer.fromJson<String>(json['rateDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'fromCurrency': serializer.toJson<String>(fromCurrency),
      'toCurrency': serializer.toJson<String>(toCurrency),
      'rateMicro': serializer.toJson<int>(rateMicro),
      'fetchedAt': serializer.toJson<int>(fetchedAt),
      'rateDate': serializer.toJson<String>(rateDate),
    };
  }

  ExchangeRate copyWith(
          {int? id,
          String? fromCurrency,
          String? toCurrency,
          int? rateMicro,
          int? fetchedAt,
          String? rateDate}) =>
      ExchangeRate(
        id: id ?? this.id,
        fromCurrency: fromCurrency ?? this.fromCurrency,
        toCurrency: toCurrency ?? this.toCurrency,
        rateMicro: rateMicro ?? this.rateMicro,
        fetchedAt: fetchedAt ?? this.fetchedAt,
        rateDate: rateDate ?? this.rateDate,
      );
  ExchangeRate copyWithCompanion(ExchangeRatesCompanion data) {
    return ExchangeRate(
      id: data.id.present ? data.id.value : this.id,
      fromCurrency: data.fromCurrency.present
          ? data.fromCurrency.value
          : this.fromCurrency,
      toCurrency:
          data.toCurrency.present ? data.toCurrency.value : this.toCurrency,
      rateMicro: data.rateMicro.present ? data.rateMicro.value : this.rateMicro,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
      rateDate: data.rateDate.present ? data.rateDate.value : this.rateDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExchangeRate(')
          ..write('id: $id, ')
          ..write('fromCurrency: $fromCurrency, ')
          ..write('toCurrency: $toCurrency, ')
          ..write('rateMicro: $rateMicro, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rateDate: $rateDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, fromCurrency, toCurrency, rateMicro, fetchedAt, rateDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExchangeRate &&
          other.id == this.id &&
          other.fromCurrency == this.fromCurrency &&
          other.toCurrency == this.toCurrency &&
          other.rateMicro == this.rateMicro &&
          other.fetchedAt == this.fetchedAt &&
          other.rateDate == this.rateDate);
}

class ExchangeRatesCompanion extends UpdateCompanion<ExchangeRate> {
  final Value<int> id;
  final Value<String> fromCurrency;
  final Value<String> toCurrency;
  final Value<int> rateMicro;
  final Value<int> fetchedAt;
  final Value<String> rateDate;
  const ExchangeRatesCompanion({
    this.id = const Value.absent(),
    this.fromCurrency = const Value.absent(),
    this.toCurrency = const Value.absent(),
    this.rateMicro = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rateDate = const Value.absent(),
  });
  ExchangeRatesCompanion.insert({
    this.id = const Value.absent(),
    required String fromCurrency,
    required String toCurrency,
    required int rateMicro,
    required int fetchedAt,
    required String rateDate,
  })  : fromCurrency = Value(fromCurrency),
        toCurrency = Value(toCurrency),
        rateMicro = Value(rateMicro),
        fetchedAt = Value(fetchedAt),
        rateDate = Value(rateDate);
  static Insertable<ExchangeRate> custom({
    Expression<int>? id,
    Expression<String>? fromCurrency,
    Expression<String>? toCurrency,
    Expression<int>? rateMicro,
    Expression<int>? fetchedAt,
    Expression<String>? rateDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fromCurrency != null) 'from_currency': fromCurrency,
      if (toCurrency != null) 'to_currency': toCurrency,
      if (rateMicro != null) 'rate_micro': rateMicro,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rateDate != null) 'rate_date': rateDate,
    });
  }

  ExchangeRatesCompanion copyWith(
      {Value<int>? id,
      Value<String>? fromCurrency,
      Value<String>? toCurrency,
      Value<int>? rateMicro,
      Value<int>? fetchedAt,
      Value<String>? rateDate}) {
    return ExchangeRatesCompanion(
      id: id ?? this.id,
      fromCurrency: fromCurrency ?? this.fromCurrency,
      toCurrency: toCurrency ?? this.toCurrency,
      rateMicro: rateMicro ?? this.rateMicro,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rateDate: rateDate ?? this.rateDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (fromCurrency.present) {
      map['from_currency'] = Variable<String>(fromCurrency.value);
    }
    if (toCurrency.present) {
      map['to_currency'] = Variable<String>(toCurrency.value);
    }
    if (rateMicro.present) {
      map['rate_micro'] = Variable<int>(rateMicro.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<int>(fetchedAt.value);
    }
    if (rateDate.present) {
      map['rate_date'] = Variable<String>(rateDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExchangeRatesCompanion(')
          ..write('id: $id, ')
          ..write('fromCurrency: $fromCurrency, ')
          ..write('toCurrency: $toCurrency, ')
          ..write('rateMicro: $rateMicro, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rateDate: $rateDate')
          ..write(')'))
        .toString();
  }
}

class $AttachmentsTable extends Attachments
    with TableInfo<$AttachmentsTable, Attachment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _transactionIdMeta =
      const VerificationMeta('transactionId');
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
      'transaction_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES transactions (id) ON DELETE RESTRICT'));
  static const VerificationMeta _filePathMeta =
      const VerificationMeta('filePath');
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
      'file_path', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _fileSizeBytesMeta =
      const VerificationMeta('fileSizeBytes');
  @override
  late final GeneratedColumn<int> fileSizeBytes = GeneratedColumn<int>(
      'file_size_bytes', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _mimeTypeMeta =
      const VerificationMeta('mimeType');
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
      'mime_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('image/jpeg'));
  static const VerificationMeta _widthPxMeta =
      const VerificationMeta('widthPx');
  @override
  late final GeneratedColumn<int> widthPx = GeneratedColumn<int>(
      'width_px', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _heightPxMeta =
      const VerificationMeta('heightPx');
  @override
  late final GeneratedColumn<int> heightPx = GeneratedColumn<int>(
      'height_px', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        transactionId,
        filePath,
        fileSizeBytes,
        mimeType,
        widthPx,
        heightPx,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attachments';
  @override
  VerificationContext validateIntegrity(Insertable<Attachment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
          _transactionIdMeta,
          transactionId.isAcceptableOrUnknown(
              data['transaction_id']!, _transactionIdMeta));
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(_filePathMeta,
          filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta));
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('file_size_bytes')) {
      context.handle(
          _fileSizeBytesMeta,
          fileSizeBytes.isAcceptableOrUnknown(
              data['file_size_bytes']!, _fileSizeBytesMeta));
    } else if (isInserting) {
      context.missing(_fileSizeBytesMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(_mimeTypeMeta,
          mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta));
    }
    if (data.containsKey('width_px')) {
      context.handle(_widthPxMeta,
          widthPx.isAcceptableOrUnknown(data['width_px']!, _widthPxMeta));
    }
    if (data.containsKey('height_px')) {
      context.handle(_heightPxMeta,
          heightPx.isAcceptableOrUnknown(data['height_px']!, _heightPxMeta));
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
  Attachment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Attachment(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      transactionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}transaction_id'])!,
      filePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_path'])!,
      fileSizeBytes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}file_size_bytes'])!,
      mimeType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mime_type'])!,
      widthPx: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}width_px']),
      heightPx: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}height_px']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $AttachmentsTable createAlias(String alias) {
    return $AttachmentsTable(attachedDatabase, alias);
  }
}

class Attachment extends DataClass implements Insertable<Attachment> {
  /// Stable UUID v4 identifier.
  final String id;

  /// FK → transactions(id) ON DELETE RESTRICT. Physical deletion is managed
  /// by the domain service, not the cascade.
  final String transactionId;

  /// Relative path within app-private storage. Unique across all attachments.
  final String filePath;

  /// Compressed file size in bytes.
  final int fileSizeBytes;

  /// MIME type. Always `image/jpeg` after TC-007 compression.
  final String mimeType;

  /// Compressed width in pixels. NULL if unavailable.
  final int? widthPx;

  /// Compressed height in pixels. NULL if unavailable.
  final int? heightPx;

  /// Unix epoch seconds when this row was created.
  final int createdAt;
  const Attachment(
      {required this.id,
      required this.transactionId,
      required this.filePath,
      required this.fileSizeBytes,
      required this.mimeType,
      this.widthPx,
      this.heightPx,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['transaction_id'] = Variable<String>(transactionId);
    map['file_path'] = Variable<String>(filePath);
    map['file_size_bytes'] = Variable<int>(fileSizeBytes);
    map['mime_type'] = Variable<String>(mimeType);
    if (!nullToAbsent || widthPx != null) {
      map['width_px'] = Variable<int>(widthPx);
    }
    if (!nullToAbsent || heightPx != null) {
      map['height_px'] = Variable<int>(heightPx);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  AttachmentsCompanion toCompanion(bool nullToAbsent) {
    return AttachmentsCompanion(
      id: Value(id),
      transactionId: Value(transactionId),
      filePath: Value(filePath),
      fileSizeBytes: Value(fileSizeBytes),
      mimeType: Value(mimeType),
      widthPx: widthPx == null && nullToAbsent
          ? const Value.absent()
          : Value(widthPx),
      heightPx: heightPx == null && nullToAbsent
          ? const Value.absent()
          : Value(heightPx),
      createdAt: Value(createdAt),
    );
  }

  factory Attachment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Attachment(
      id: serializer.fromJson<String>(json['id']),
      transactionId: serializer.fromJson<String>(json['transactionId']),
      filePath: serializer.fromJson<String>(json['filePath']),
      fileSizeBytes: serializer.fromJson<int>(json['fileSizeBytes']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      widthPx: serializer.fromJson<int?>(json['widthPx']),
      heightPx: serializer.fromJson<int?>(json['heightPx']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'transactionId': serializer.toJson<String>(transactionId),
      'filePath': serializer.toJson<String>(filePath),
      'fileSizeBytes': serializer.toJson<int>(fileSizeBytes),
      'mimeType': serializer.toJson<String>(mimeType),
      'widthPx': serializer.toJson<int?>(widthPx),
      'heightPx': serializer.toJson<int?>(heightPx),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  Attachment copyWith(
          {String? id,
          String? transactionId,
          String? filePath,
          int? fileSizeBytes,
          String? mimeType,
          Value<int?> widthPx = const Value.absent(),
          Value<int?> heightPx = const Value.absent(),
          int? createdAt}) =>
      Attachment(
        id: id ?? this.id,
        transactionId: transactionId ?? this.transactionId,
        filePath: filePath ?? this.filePath,
        fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
        mimeType: mimeType ?? this.mimeType,
        widthPx: widthPx.present ? widthPx.value : this.widthPx,
        heightPx: heightPx.present ? heightPx.value : this.heightPx,
        createdAt: createdAt ?? this.createdAt,
      );
  Attachment copyWithCompanion(AttachmentsCompanion data) {
    return Attachment(
      id: data.id.present ? data.id.value : this.id,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      fileSizeBytes: data.fileSizeBytes.present
          ? data.fileSizeBytes.value
          : this.fileSizeBytes,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      widthPx: data.widthPx.present ? data.widthPx.value : this.widthPx,
      heightPx: data.heightPx.present ? data.heightPx.value : this.heightPx,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Attachment(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('filePath: $filePath, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('mimeType: $mimeType, ')
          ..write('widthPx: $widthPx, ')
          ..write('heightPx: $heightPx, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, transactionId, filePath, fileSizeBytes,
      mimeType, widthPx, heightPx, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Attachment &&
          other.id == this.id &&
          other.transactionId == this.transactionId &&
          other.filePath == this.filePath &&
          other.fileSizeBytes == this.fileSizeBytes &&
          other.mimeType == this.mimeType &&
          other.widthPx == this.widthPx &&
          other.heightPx == this.heightPx &&
          other.createdAt == this.createdAt);
}

class AttachmentsCompanion extends UpdateCompanion<Attachment> {
  final Value<String> id;
  final Value<String> transactionId;
  final Value<String> filePath;
  final Value<int> fileSizeBytes;
  final Value<String> mimeType;
  final Value<int?> widthPx;
  final Value<int?> heightPx;
  final Value<int> createdAt;
  final Value<int> rowid;
  const AttachmentsCompanion({
    this.id = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.filePath = const Value.absent(),
    this.fileSizeBytes = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.widthPx = const Value.absent(),
    this.heightPx = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttachmentsCompanion.insert({
    required String id,
    required String transactionId,
    required String filePath,
    required int fileSizeBytes,
    this.mimeType = const Value.absent(),
    this.widthPx = const Value.absent(),
    this.heightPx = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        transactionId = Value(transactionId),
        filePath = Value(filePath),
        fileSizeBytes = Value(fileSizeBytes),
        createdAt = Value(createdAt);
  static Insertable<Attachment> custom({
    Expression<String>? id,
    Expression<String>? transactionId,
    Expression<String>? filePath,
    Expression<int>? fileSizeBytes,
    Expression<String>? mimeType,
    Expression<int>? widthPx,
    Expression<int>? heightPx,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionId != null) 'transaction_id': transactionId,
      if (filePath != null) 'file_path': filePath,
      if (fileSizeBytes != null) 'file_size_bytes': fileSizeBytes,
      if (mimeType != null) 'mime_type': mimeType,
      if (widthPx != null) 'width_px': widthPx,
      if (heightPx != null) 'height_px': heightPx,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttachmentsCompanion copyWith(
      {Value<String>? id,
      Value<String>? transactionId,
      Value<String>? filePath,
      Value<int>? fileSizeBytes,
      Value<String>? mimeType,
      Value<int?>? widthPx,
      Value<int?>? heightPx,
      Value<int>? createdAt,
      Value<int>? rowid}) {
    return AttachmentsCompanion(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      filePath: filePath ?? this.filePath,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      mimeType: mimeType ?? this.mimeType,
      widthPx: widthPx ?? this.widthPx,
      heightPx: heightPx ?? this.heightPx,
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
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (fileSizeBytes.present) {
      map['file_size_bytes'] = Variable<int>(fileSizeBytes.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (widthPx.present) {
      map['width_px'] = Variable<int>(widthPx.value);
    }
    if (heightPx.present) {
      map['height_px'] = Variable<int>(heightPx.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('filePath: $filePath, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('mimeType: $mimeType, ')
          ..write('widthPx: $widthPx, ')
          ..write('heightPx: $heightPx, ')
          ..write('createdAt: $createdAt, ')
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES categories (id)'));
  static const VerificationMeta _amountMinorMeta =
      const VerificationMeta('amountMinor');
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
      'amount_minor', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _currencyCodeMeta =
      const VerificationMeta('currencyCode');
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
      'currency_code', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES currencies (code)'));
  static const VerificationMeta _periodTypeMeta =
      const VerificationMeta('periodType');
  @override
  late final GeneratedColumn<String> periodType = GeneratedColumn<String>(
      'period_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _periodNMeta =
      const VerificationMeta('periodN');
  @override
  late final GeneratedColumn<int> periodN = GeneratedColumn<int>(
      'period_n', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _rolloverMeta =
      const VerificationMeta('rollover');
  @override
  late final GeneratedColumn<bool> rollover = GeneratedColumn<bool>(
      'rollover', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("rollover" IN (0, 1))'),
      defaultValue: const Constant(false));
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
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        categoryId,
        amountMinor,
        currencyCode,
        periodType,
        periodN,
        rollover,
        isActive,
        createdAt,
        updatedAt
      ];
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
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
          _amountMinorMeta,
          amountMinor.isAcceptableOrUnknown(
              data['amount_minor']!, _amountMinorMeta));
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
          _currencyCodeMeta,
          currencyCode.isAcceptableOrUnknown(
              data['currency_code']!, _currencyCodeMeta));
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('period_type')) {
      context.handle(
          _periodTypeMeta,
          periodType.isAcceptableOrUnknown(
              data['period_type']!, _periodTypeMeta));
    } else if (isInserting) {
      context.missing(_periodTypeMeta);
    }
    if (data.containsKey('period_n')) {
      context.handle(_periodNMeta,
          periodN.isAcceptableOrUnknown(data['period_n']!, _periodNMeta));
    }
    if (data.containsKey('rollover')) {
      context.handle(_rolloverMeta,
          rollover.isAcceptableOrUnknown(data['rollover']!, _rolloverMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
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
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id']),
      amountMinor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount_minor'])!,
      currencyCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency_code'])!,
      periodType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}period_type'])!,
      periodN: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}period_n'])!,
      rollover: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}rollover'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $BudgetsTable createAlias(String alias) {
    return $BudgetsTable(attachedDatabase, alias);
  }
}

class Budget extends DataClass implements Insertable<Budget> {
  /// Stable UUID v4 identifier.
  final String id;

  /// User-defined label.
  final String name;

  /// NULL = total budget; non-null = per-category budget.
  final String? categoryId;

  /// Budget ceiling in minor units. Must be > 0.
  final int amountMinor;

  /// Home currency of this budget.
  final String currencyCode;

  /// Recurrence horizon: `weekly`, `monthly`, `quarterly`, or `annual`.
  final String periodType;

  /// Number of periods (e.g. periodN=1 + periodType=monthly = monthly).
  final int periodN;

  /// Whether unused amount carries over to the next period.
  final bool rollover;

  /// Whether this budget is active.
  final bool isActive;

  /// Unix epoch seconds when this row was created.
  final int createdAt;

  /// Unix epoch seconds when this row was last modified.
  final int updatedAt;
  const Budget(
      {required this.id,
      required this.name,
      this.categoryId,
      required this.amountMinor,
      required this.currencyCode,
      required this.periodType,
      required this.periodN,
      required this.rollover,
      required this.isActive,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency_code'] = Variable<String>(currencyCode);
    map['period_type'] = Variable<String>(periodType);
    map['period_n'] = Variable<int>(periodN);
    map['rollover'] = Variable<bool>(rollover);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  BudgetsCompanion toCompanion(bool nullToAbsent) {
    return BudgetsCompanion(
      id: Value(id),
      name: Value(name),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      amountMinor: Value(amountMinor),
      currencyCode: Value(currencyCode),
      periodType: Value(periodType),
      periodN: Value(periodN),
      rollover: Value(rollover),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Budget.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Budget(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      periodType: serializer.fromJson<String>(json['periodType']),
      periodN: serializer.fromJson<int>(json['periodN']),
      rollover: serializer.fromJson<bool>(json['rollover']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'categoryId': serializer.toJson<String?>(categoryId),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'periodType': serializer.toJson<String>(periodType),
      'periodN': serializer.toJson<int>(periodN),
      'rollover': serializer.toJson<bool>(rollover),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  Budget copyWith(
          {String? id,
          String? name,
          Value<String?> categoryId = const Value.absent(),
          int? amountMinor,
          String? currencyCode,
          String? periodType,
          int? periodN,
          bool? rollover,
          bool? isActive,
          int? createdAt,
          int? updatedAt}) =>
      Budget(
        id: id ?? this.id,
        name: name ?? this.name,
        categoryId: categoryId.present ? categoryId.value : this.categoryId,
        amountMinor: amountMinor ?? this.amountMinor,
        currencyCode: currencyCode ?? this.currencyCode,
        periodType: periodType ?? this.periodType,
        periodN: periodN ?? this.periodN,
        rollover: rollover ?? this.rollover,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Budget copyWithCompanion(BudgetsCompanion data) {
    return Budget(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      amountMinor:
          data.amountMinor.present ? data.amountMinor.value : this.amountMinor,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      periodType:
          data.periodType.present ? data.periodType.value : this.periodType,
      periodN: data.periodN.present ? data.periodN.value : this.periodN,
      rollover: data.rollover.present ? data.rollover.value : this.rollover,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Budget(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('categoryId: $categoryId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('periodType: $periodType, ')
          ..write('periodN: $periodN, ')
          ..write('rollover: $rollover, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      categoryId,
      amountMinor,
      currencyCode,
      periodType,
      periodN,
      rollover,
      isActive,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Budget &&
          other.id == this.id &&
          other.name == this.name &&
          other.categoryId == this.categoryId &&
          other.amountMinor == this.amountMinor &&
          other.currencyCode == this.currencyCode &&
          other.periodType == this.periodType &&
          other.periodN == this.periodN &&
          other.rollover == this.rollover &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class BudgetsCompanion extends UpdateCompanion<Budget> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> categoryId;
  final Value<int> amountMinor;
  final Value<String> currencyCode;
  final Value<String> periodType;
  final Value<int> periodN;
  final Value<bool> rollover;
  final Value<bool> isActive;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const BudgetsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.periodType = const Value.absent(),
    this.periodN = const Value.absent(),
    this.rollover = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BudgetsCompanion.insert({
    required String id,
    required String name,
    this.categoryId = const Value.absent(),
    required int amountMinor,
    required String currencyCode,
    required String periodType,
    this.periodN = const Value.absent(),
    this.rollover = const Value.absent(),
    this.isActive = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        amountMinor = Value(amountMinor),
        currencyCode = Value(currencyCode),
        periodType = Value(periodType),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Budget> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? categoryId,
    Expression<int>? amountMinor,
    Expression<String>? currencyCode,
    Expression<String>? periodType,
    Expression<int>? periodN,
    Expression<bool>? rollover,
    Expression<bool>? isActive,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (categoryId != null) 'category_id': categoryId,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (periodType != null) 'period_type': periodType,
      if (periodN != null) 'period_n': periodN,
      if (rollover != null) 'rollover': rollover,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BudgetsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? categoryId,
      Value<int>? amountMinor,
      Value<String>? currencyCode,
      Value<String>? periodType,
      Value<int>? periodN,
      Value<bool>? rollover,
      Value<bool>? isActive,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<int>? rowid}) {
    return BudgetsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      amountMinor: amountMinor ?? this.amountMinor,
      currencyCode: currencyCode ?? this.currencyCode,
      periodType: periodType ?? this.periodType,
      periodN: periodN ?? this.periodN,
      rollover: rollover ?? this.rollover,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (periodType.present) {
      map['period_type'] = Variable<String>(periodType.value);
    }
    if (periodN.present) {
      map['period_n'] = Variable<int>(periodN.value);
    }
    if (rollover.present) {
      map['rollover'] = Variable<bool>(rollover.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
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
          ..write('name: $name, ')
          ..write('categoryId: $categoryId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('periodType: $periodType, ')
          ..write('periodN: $periodN, ')
          ..write('rollover: $rollover, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BudgetPeriodsTable extends BudgetPeriods
    with TableInfo<$BudgetPeriodsTable, BudgetPeriod> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetPeriodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _budgetIdMeta =
      const VerificationMeta('budgetId');
  @override
  late final GeneratedColumn<String> budgetId = GeneratedColumn<String>(
      'budget_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES budgets (id)'));
  static const VerificationMeta _periodStartMeta =
      const VerificationMeta('periodStart');
  @override
  late final GeneratedColumn<int> periodStart = GeneratedColumn<int>(
      'period_start', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _periodEndMeta =
      const VerificationMeta('periodEnd');
  @override
  late final GeneratedColumn<int> periodEnd = GeneratedColumn<int>(
      'period_end', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _budgetedMinorMeta =
      const VerificationMeta('budgetedMinor');
  @override
  late final GeneratedColumn<int> budgetedMinor = GeneratedColumn<int>(
      'budgeted_minor', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _carriedOverMinorMeta =
      const VerificationMeta('carriedOverMinor');
  @override
  late final GeneratedColumn<int> carriedOverMinor = GeneratedColumn<int>(
      'carried_over_minor', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        budgetId,
        periodStart,
        periodEnd,
        budgetedMinor,
        carriedOverMinor,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budget_periods';
  @override
  VerificationContext validateIntegrity(Insertable<BudgetPeriod> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('budget_id')) {
      context.handle(_budgetIdMeta,
          budgetId.isAcceptableOrUnknown(data['budget_id']!, _budgetIdMeta));
    } else if (isInserting) {
      context.missing(_budgetIdMeta);
    }
    if (data.containsKey('period_start')) {
      context.handle(
          _periodStartMeta,
          periodStart.isAcceptableOrUnknown(
              data['period_start']!, _periodStartMeta));
    } else if (isInserting) {
      context.missing(_periodStartMeta);
    }
    if (data.containsKey('period_end')) {
      context.handle(_periodEndMeta,
          periodEnd.isAcceptableOrUnknown(data['period_end']!, _periodEndMeta));
    } else if (isInserting) {
      context.missing(_periodEndMeta);
    }
    if (data.containsKey('budgeted_minor')) {
      context.handle(
          _budgetedMinorMeta,
          budgetedMinor.isAcceptableOrUnknown(
              data['budgeted_minor']!, _budgetedMinorMeta));
    } else if (isInserting) {
      context.missing(_budgetedMinorMeta);
    }
    if (data.containsKey('carried_over_minor')) {
      context.handle(
          _carriedOverMinorMeta,
          carriedOverMinor.isAcceptableOrUnknown(
              data['carried_over_minor']!, _carriedOverMinorMeta));
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
  BudgetPeriod map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BudgetPeriod(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      budgetId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}budget_id'])!,
      periodStart: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}period_start'])!,
      periodEnd: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}period_end'])!,
      budgetedMinor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}budgeted_minor'])!,
      carriedOverMinor: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}carried_over_minor'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $BudgetPeriodsTable createAlias(String alias) {
    return $BudgetPeriodsTable(attachedDatabase, alias);
  }
}

class BudgetPeriod extends DataClass implements Insertable<BudgetPeriod> {
  /// Stable UUID v4 identifier.
  final String id;

  /// FK → budgets(id).
  final String budgetId;

  /// Period start epoch (inclusive).
  final int periodStart;

  /// Period end epoch (exclusive).
  final int periodEnd;

  /// Effective ceiling including carryover.
  final int budgetedMinor;

  /// Rolled-over amount from the previous period.
  final int carriedOverMinor;

  /// Unix epoch seconds when this row was created.
  final int createdAt;
  const BudgetPeriod(
      {required this.id,
      required this.budgetId,
      required this.periodStart,
      required this.periodEnd,
      required this.budgetedMinor,
      required this.carriedOverMinor,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['budget_id'] = Variable<String>(budgetId);
    map['period_start'] = Variable<int>(periodStart);
    map['period_end'] = Variable<int>(periodEnd);
    map['budgeted_minor'] = Variable<int>(budgetedMinor);
    map['carried_over_minor'] = Variable<int>(carriedOverMinor);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  BudgetPeriodsCompanion toCompanion(bool nullToAbsent) {
    return BudgetPeriodsCompanion(
      id: Value(id),
      budgetId: Value(budgetId),
      periodStart: Value(periodStart),
      periodEnd: Value(periodEnd),
      budgetedMinor: Value(budgetedMinor),
      carriedOverMinor: Value(carriedOverMinor),
      createdAt: Value(createdAt),
    );
  }

  factory BudgetPeriod.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BudgetPeriod(
      id: serializer.fromJson<String>(json['id']),
      budgetId: serializer.fromJson<String>(json['budgetId']),
      periodStart: serializer.fromJson<int>(json['periodStart']),
      periodEnd: serializer.fromJson<int>(json['periodEnd']),
      budgetedMinor: serializer.fromJson<int>(json['budgetedMinor']),
      carriedOverMinor: serializer.fromJson<int>(json['carriedOverMinor']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'budgetId': serializer.toJson<String>(budgetId),
      'periodStart': serializer.toJson<int>(periodStart),
      'periodEnd': serializer.toJson<int>(periodEnd),
      'budgetedMinor': serializer.toJson<int>(budgetedMinor),
      'carriedOverMinor': serializer.toJson<int>(carriedOverMinor),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  BudgetPeriod copyWith(
          {String? id,
          String? budgetId,
          int? periodStart,
          int? periodEnd,
          int? budgetedMinor,
          int? carriedOverMinor,
          int? createdAt}) =>
      BudgetPeriod(
        id: id ?? this.id,
        budgetId: budgetId ?? this.budgetId,
        periodStart: periodStart ?? this.periodStart,
        periodEnd: periodEnd ?? this.periodEnd,
        budgetedMinor: budgetedMinor ?? this.budgetedMinor,
        carriedOverMinor: carriedOverMinor ?? this.carriedOverMinor,
        createdAt: createdAt ?? this.createdAt,
      );
  BudgetPeriod copyWithCompanion(BudgetPeriodsCompanion data) {
    return BudgetPeriod(
      id: data.id.present ? data.id.value : this.id,
      budgetId: data.budgetId.present ? data.budgetId.value : this.budgetId,
      periodStart:
          data.periodStart.present ? data.periodStart.value : this.periodStart,
      periodEnd: data.periodEnd.present ? data.periodEnd.value : this.periodEnd,
      budgetedMinor: data.budgetedMinor.present
          ? data.budgetedMinor.value
          : this.budgetedMinor,
      carriedOverMinor: data.carriedOverMinor.present
          ? data.carriedOverMinor.value
          : this.carriedOverMinor,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BudgetPeriod(')
          ..write('id: $id, ')
          ..write('budgetId: $budgetId, ')
          ..write('periodStart: $periodStart, ')
          ..write('periodEnd: $periodEnd, ')
          ..write('budgetedMinor: $budgetedMinor, ')
          ..write('carriedOverMinor: $carriedOverMinor, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, budgetId, periodStart, periodEnd,
      budgetedMinor, carriedOverMinor, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BudgetPeriod &&
          other.id == this.id &&
          other.budgetId == this.budgetId &&
          other.periodStart == this.periodStart &&
          other.periodEnd == this.periodEnd &&
          other.budgetedMinor == this.budgetedMinor &&
          other.carriedOverMinor == this.carriedOverMinor &&
          other.createdAt == this.createdAt);
}

class BudgetPeriodsCompanion extends UpdateCompanion<BudgetPeriod> {
  final Value<String> id;
  final Value<String> budgetId;
  final Value<int> periodStart;
  final Value<int> periodEnd;
  final Value<int> budgetedMinor;
  final Value<int> carriedOverMinor;
  final Value<int> createdAt;
  final Value<int> rowid;
  const BudgetPeriodsCompanion({
    this.id = const Value.absent(),
    this.budgetId = const Value.absent(),
    this.periodStart = const Value.absent(),
    this.periodEnd = const Value.absent(),
    this.budgetedMinor = const Value.absent(),
    this.carriedOverMinor = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BudgetPeriodsCompanion.insert({
    required String id,
    required String budgetId,
    required int periodStart,
    required int periodEnd,
    required int budgetedMinor,
    this.carriedOverMinor = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        budgetId = Value(budgetId),
        periodStart = Value(periodStart),
        periodEnd = Value(periodEnd),
        budgetedMinor = Value(budgetedMinor),
        createdAt = Value(createdAt);
  static Insertable<BudgetPeriod> custom({
    Expression<String>? id,
    Expression<String>? budgetId,
    Expression<int>? periodStart,
    Expression<int>? periodEnd,
    Expression<int>? budgetedMinor,
    Expression<int>? carriedOverMinor,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (budgetId != null) 'budget_id': budgetId,
      if (periodStart != null) 'period_start': periodStart,
      if (periodEnd != null) 'period_end': periodEnd,
      if (budgetedMinor != null) 'budgeted_minor': budgetedMinor,
      if (carriedOverMinor != null) 'carried_over_minor': carriedOverMinor,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BudgetPeriodsCompanion copyWith(
      {Value<String>? id,
      Value<String>? budgetId,
      Value<int>? periodStart,
      Value<int>? periodEnd,
      Value<int>? budgetedMinor,
      Value<int>? carriedOverMinor,
      Value<int>? createdAt,
      Value<int>? rowid}) {
    return BudgetPeriodsCompanion(
      id: id ?? this.id,
      budgetId: budgetId ?? this.budgetId,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      budgetedMinor: budgetedMinor ?? this.budgetedMinor,
      carriedOverMinor: carriedOverMinor ?? this.carriedOverMinor,
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
    if (budgetId.present) {
      map['budget_id'] = Variable<String>(budgetId.value);
    }
    if (periodStart.present) {
      map['period_start'] = Variable<int>(periodStart.value);
    }
    if (periodEnd.present) {
      map['period_end'] = Variable<int>(periodEnd.value);
    }
    if (budgetedMinor.present) {
      map['budgeted_minor'] = Variable<int>(budgetedMinor.value);
    }
    if (carriedOverMinor.present) {
      map['carried_over_minor'] = Variable<int>(carriedOverMinor.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetPeriodsCompanion(')
          ..write('id: $id, ')
          ..write('budgetId: $budgetId, ')
          ..write('periodStart: $periodStart, ')
          ..write('periodEnd: $periodEnd, ')
          ..write('budgetedMinor: $budgetedMinor, ')
          ..write('carriedOverMinor: $carriedOverMinor, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScheduledOccurrencesTable extends ScheduledOccurrences
    with TableInfo<$ScheduledOccurrencesTable, ScheduledOccurrence> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScheduledOccurrencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _templateIdMeta =
      const VerificationMeta('templateId');
  @override
  late final GeneratedColumn<String> templateId = GeneratedColumn<String>(
      'template_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES recurring_templates (id) ON DELETE CASCADE'));
  static const VerificationMeta _scheduledDateMeta =
      const VerificationMeta('scheduledDate');
  @override
  late final GeneratedColumn<int> scheduledDate = GeneratedColumn<int>(
      'scheduled_date', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _childTransactionIdMeta =
      const VerificationMeta('childTransactionId');
  @override
  late final GeneratedColumn<String> childTransactionId =
      GeneratedColumn<String>('child_transaction_id', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'REFERENCES transactions (id)'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        templateId,
        scheduledDate,
        status,
        childTransactionId,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scheduled_occurrences';
  @override
  VerificationContext validateIntegrity(
      Insertable<ScheduledOccurrence> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('template_id')) {
      context.handle(
          _templateIdMeta,
          templateId.isAcceptableOrUnknown(
              data['template_id']!, _templateIdMeta));
    } else if (isInserting) {
      context.missing(_templateIdMeta);
    }
    if (data.containsKey('scheduled_date')) {
      context.handle(
          _scheduledDateMeta,
          scheduledDate.isAcceptableOrUnknown(
              data['scheduled_date']!, _scheduledDateMeta));
    } else if (isInserting) {
      context.missing(_scheduledDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('child_transaction_id')) {
      context.handle(
          _childTransactionIdMeta,
          childTransactionId.isAcceptableOrUnknown(
              data['child_transaction_id']!, _childTransactionIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScheduledOccurrence map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScheduledOccurrence(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      templateId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}template_id'])!,
      scheduledDate: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}scheduled_date'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      childTransactionId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}child_transaction_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ScheduledOccurrencesTable createAlias(String alias) {
    return $ScheduledOccurrencesTable(attachedDatabase, alias);
  }
}

class ScheduledOccurrence extends DataClass
    implements Insertable<ScheduledOccurrence> {
  /// Stable UUID v4 identifier.
  final String id;

  /// FK → recurring_templates(id) ON DELETE CASCADE.
  final String templateId;

  /// When this occurrence should fire (Unix epoch date).
  final int scheduledDate;

  /// Status: `pending`, `posted`, `skipped`, or `cancelled`.
  final String status;

  /// FK to the transaction created when this occurrence is posted.
  final String? childTransactionId;

  /// Unix epoch seconds when this row was created.
  final int createdAt;

  /// Unix epoch seconds when this row was last modified.
  final int updatedAt;
  const ScheduledOccurrence(
      {required this.id,
      required this.templateId,
      required this.scheduledDate,
      required this.status,
      this.childTransactionId,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['template_id'] = Variable<String>(templateId);
    map['scheduled_date'] = Variable<int>(scheduledDate);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || childTransactionId != null) {
      map['child_transaction_id'] = Variable<String>(childTransactionId);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  ScheduledOccurrencesCompanion toCompanion(bool nullToAbsent) {
    return ScheduledOccurrencesCompanion(
      id: Value(id),
      templateId: Value(templateId),
      scheduledDate: Value(scheduledDate),
      status: Value(status),
      childTransactionId: childTransactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(childTransactionId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ScheduledOccurrence.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScheduledOccurrence(
      id: serializer.fromJson<String>(json['id']),
      templateId: serializer.fromJson<String>(json['templateId']),
      scheduledDate: serializer.fromJson<int>(json['scheduledDate']),
      status: serializer.fromJson<String>(json['status']),
      childTransactionId:
          serializer.fromJson<String?>(json['childTransactionId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'templateId': serializer.toJson<String>(templateId),
      'scheduledDate': serializer.toJson<int>(scheduledDate),
      'status': serializer.toJson<String>(status),
      'childTransactionId': serializer.toJson<String?>(childTransactionId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  ScheduledOccurrence copyWith(
          {String? id,
          String? templateId,
          int? scheduledDate,
          String? status,
          Value<String?> childTransactionId = const Value.absent(),
          int? createdAt,
          int? updatedAt}) =>
      ScheduledOccurrence(
        id: id ?? this.id,
        templateId: templateId ?? this.templateId,
        scheduledDate: scheduledDate ?? this.scheduledDate,
        status: status ?? this.status,
        childTransactionId: childTransactionId.present
            ? childTransactionId.value
            : this.childTransactionId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ScheduledOccurrence copyWithCompanion(ScheduledOccurrencesCompanion data) {
    return ScheduledOccurrence(
      id: data.id.present ? data.id.value : this.id,
      templateId:
          data.templateId.present ? data.templateId.value : this.templateId,
      scheduledDate: data.scheduledDate.present
          ? data.scheduledDate.value
          : this.scheduledDate,
      status: data.status.present ? data.status.value : this.status,
      childTransactionId: data.childTransactionId.present
          ? data.childTransactionId.value
          : this.childTransactionId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScheduledOccurrence(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('scheduledDate: $scheduledDate, ')
          ..write('status: $status, ')
          ..write('childTransactionId: $childTransactionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, templateId, scheduledDate, status,
      childTransactionId, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScheduledOccurrence &&
          other.id == this.id &&
          other.templateId == this.templateId &&
          other.scheduledDate == this.scheduledDate &&
          other.status == this.status &&
          other.childTransactionId == this.childTransactionId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ScheduledOccurrencesCompanion
    extends UpdateCompanion<ScheduledOccurrence> {
  final Value<String> id;
  final Value<String> templateId;
  final Value<int> scheduledDate;
  final Value<String> status;
  final Value<String?> childTransactionId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const ScheduledOccurrencesCompanion({
    this.id = const Value.absent(),
    this.templateId = const Value.absent(),
    this.scheduledDate = const Value.absent(),
    this.status = const Value.absent(),
    this.childTransactionId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScheduledOccurrencesCompanion.insert({
    required String id,
    required String templateId,
    required int scheduledDate,
    this.status = const Value.absent(),
    this.childTransactionId = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        templateId = Value(templateId),
        scheduledDate = Value(scheduledDate),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<ScheduledOccurrence> custom({
    Expression<String>? id,
    Expression<String>? templateId,
    Expression<int>? scheduledDate,
    Expression<String>? status,
    Expression<String>? childTransactionId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (templateId != null) 'template_id': templateId,
      if (scheduledDate != null) 'scheduled_date': scheduledDate,
      if (status != null) 'status': status,
      if (childTransactionId != null)
        'child_transaction_id': childTransactionId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScheduledOccurrencesCompanion copyWith(
      {Value<String>? id,
      Value<String>? templateId,
      Value<int>? scheduledDate,
      Value<String>? status,
      Value<String?>? childTransactionId,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<int>? rowid}) {
    return ScheduledOccurrencesCompanion(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      status: status ?? this.status,
      childTransactionId: childTransactionId ?? this.childTransactionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (templateId.present) {
      map['template_id'] = Variable<String>(templateId.value);
    }
    if (scheduledDate.present) {
      map['scheduled_date'] = Variable<int>(scheduledDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (childTransactionId.present) {
      map['child_transaction_id'] = Variable<String>(childTransactionId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScheduledOccurrencesCompanion(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('scheduledDate: $scheduledDate, ')
          ..write('status: $status, ')
          ..write('childTransactionId: $childTransactionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InstallmentPlansTable extends InstallmentPlans
    with TableInfo<$InstallmentPlansTable, InstallmentPlan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InstallmentPlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _templateIdMeta =
      const VerificationMeta('templateId');
  @override
  late final GeneratedColumn<String> templateId = GeneratedColumn<String>(
      'template_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES recurring_templates (id) ON DELETE CASCADE'));
  static const VerificationMeta _totalConfiguredMinorMeta =
      const VerificationMeta('totalConfiguredMinor');
  @override
  late final GeneratedColumn<int> totalConfiguredMinor = GeneratedColumn<int>(
      'total_configured_minor', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _numberOfInstallmentsMeta =
      const VerificationMeta('numberOfInstallments');
  @override
  late final GeneratedColumn<int> numberOfInstallments = GeneratedColumn<int>(
      'number_of_installments', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [templateId, totalConfiguredMinor, numberOfInstallments, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'installment_plans';
  @override
  VerificationContext validateIntegrity(Insertable<InstallmentPlan> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('template_id')) {
      context.handle(
          _templateIdMeta,
          templateId.isAcceptableOrUnknown(
              data['template_id']!, _templateIdMeta));
    } else if (isInserting) {
      context.missing(_templateIdMeta);
    }
    if (data.containsKey('total_configured_minor')) {
      context.handle(
          _totalConfiguredMinorMeta,
          totalConfiguredMinor.isAcceptableOrUnknown(
              data['total_configured_minor']!, _totalConfiguredMinorMeta));
    } else if (isInserting) {
      context.missing(_totalConfiguredMinorMeta);
    }
    if (data.containsKey('number_of_installments')) {
      context.handle(
          _numberOfInstallmentsMeta,
          numberOfInstallments.isAcceptableOrUnknown(
              data['number_of_installments']!, _numberOfInstallmentsMeta));
    } else if (isInserting) {
      context.missing(_numberOfInstallmentsMeta);
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
  Set<GeneratedColumn> get $primaryKey => {templateId};
  @override
  InstallmentPlan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InstallmentPlan(
      templateId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}template_id'])!,
      totalConfiguredMinor: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}total_configured_minor'])!,
      numberOfInstallments: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}number_of_installments'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $InstallmentPlansTable createAlias(String alias) {
    return $InstallmentPlansTable(attachedDatabase, alias);
  }
}

class InstallmentPlan extends DataClass implements Insertable<InstallmentPlan> {
  /// PK and FK → recurring_templates(id) ON DELETE CASCADE.
  final String templateId;

  /// Target total amount in minor units. Immutable except during early close.
  final int totalConfiguredMinor;

  /// Total planned installment count. Editable for future installments.
  final int numberOfInstallments;

  /// Unix epoch seconds when this row was created.
  final int createdAt;
  const InstallmentPlan(
      {required this.templateId,
      required this.totalConfiguredMinor,
      required this.numberOfInstallments,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['template_id'] = Variable<String>(templateId);
    map['total_configured_minor'] = Variable<int>(totalConfiguredMinor);
    map['number_of_installments'] = Variable<int>(numberOfInstallments);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  InstallmentPlansCompanion toCompanion(bool nullToAbsent) {
    return InstallmentPlansCompanion(
      templateId: Value(templateId),
      totalConfiguredMinor: Value(totalConfiguredMinor),
      numberOfInstallments: Value(numberOfInstallments),
      createdAt: Value(createdAt),
    );
  }

  factory InstallmentPlan.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InstallmentPlan(
      templateId: serializer.fromJson<String>(json['templateId']),
      totalConfiguredMinor:
          serializer.fromJson<int>(json['totalConfiguredMinor']),
      numberOfInstallments:
          serializer.fromJson<int>(json['numberOfInstallments']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'templateId': serializer.toJson<String>(templateId),
      'totalConfiguredMinor': serializer.toJson<int>(totalConfiguredMinor),
      'numberOfInstallments': serializer.toJson<int>(numberOfInstallments),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  InstallmentPlan copyWith(
          {String? templateId,
          int? totalConfiguredMinor,
          int? numberOfInstallments,
          int? createdAt}) =>
      InstallmentPlan(
        templateId: templateId ?? this.templateId,
        totalConfiguredMinor: totalConfiguredMinor ?? this.totalConfiguredMinor,
        numberOfInstallments: numberOfInstallments ?? this.numberOfInstallments,
        createdAt: createdAt ?? this.createdAt,
      );
  InstallmentPlan copyWithCompanion(InstallmentPlansCompanion data) {
    return InstallmentPlan(
      templateId:
          data.templateId.present ? data.templateId.value : this.templateId,
      totalConfiguredMinor: data.totalConfiguredMinor.present
          ? data.totalConfiguredMinor.value
          : this.totalConfiguredMinor,
      numberOfInstallments: data.numberOfInstallments.present
          ? data.numberOfInstallments.value
          : this.numberOfInstallments,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InstallmentPlan(')
          ..write('templateId: $templateId, ')
          ..write('totalConfiguredMinor: $totalConfiguredMinor, ')
          ..write('numberOfInstallments: $numberOfInstallments, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      templateId, totalConfiguredMinor, numberOfInstallments, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InstallmentPlan &&
          other.templateId == this.templateId &&
          other.totalConfiguredMinor == this.totalConfiguredMinor &&
          other.numberOfInstallments == this.numberOfInstallments &&
          other.createdAt == this.createdAt);
}

class InstallmentPlansCompanion extends UpdateCompanion<InstallmentPlan> {
  final Value<String> templateId;
  final Value<int> totalConfiguredMinor;
  final Value<int> numberOfInstallments;
  final Value<int> createdAt;
  final Value<int> rowid;
  const InstallmentPlansCompanion({
    this.templateId = const Value.absent(),
    this.totalConfiguredMinor = const Value.absent(),
    this.numberOfInstallments = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InstallmentPlansCompanion.insert({
    required String templateId,
    required int totalConfiguredMinor,
    required int numberOfInstallments,
    required int createdAt,
    this.rowid = const Value.absent(),
  })  : templateId = Value(templateId),
        totalConfiguredMinor = Value(totalConfiguredMinor),
        numberOfInstallments = Value(numberOfInstallments),
        createdAt = Value(createdAt);
  static Insertable<InstallmentPlan> custom({
    Expression<String>? templateId,
    Expression<int>? totalConfiguredMinor,
    Expression<int>? numberOfInstallments,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (templateId != null) 'template_id': templateId,
      if (totalConfiguredMinor != null)
        'total_configured_minor': totalConfiguredMinor,
      if (numberOfInstallments != null)
        'number_of_installments': numberOfInstallments,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InstallmentPlansCompanion copyWith(
      {Value<String>? templateId,
      Value<int>? totalConfiguredMinor,
      Value<int>? numberOfInstallments,
      Value<int>? createdAt,
      Value<int>? rowid}) {
    return InstallmentPlansCompanion(
      templateId: templateId ?? this.templateId,
      totalConfiguredMinor: totalConfiguredMinor ?? this.totalConfiguredMinor,
      numberOfInstallments: numberOfInstallments ?? this.numberOfInstallments,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (templateId.present) {
      map['template_id'] = Variable<String>(templateId.value);
    }
    if (totalConfiguredMinor.present) {
      map['total_configured_minor'] = Variable<int>(totalConfiguredMinor.value);
    }
    if (numberOfInstallments.present) {
      map['number_of_installments'] = Variable<int>(numberOfInstallments.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InstallmentPlansCompanion(')
          ..write('templateId: $templateId, ')
          ..write('totalConfiguredMinor: $totalConfiguredMinor, ')
          ..write('numberOfInstallments: $numberOfInstallments, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InstallmentOccurrencesTable extends InstallmentOccurrences
    with TableInfo<$InstallmentOccurrencesTable, InstallmentOccurrence> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InstallmentOccurrencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _templateIdMeta =
      const VerificationMeta('templateId');
  @override
  late final GeneratedColumn<String> templateId = GeneratedColumn<String>(
      'template_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES recurring_templates (id) ON DELETE CASCADE'));
  static const VerificationMeta _sequenceNumberMeta =
      const VerificationMeta('sequenceNumber');
  @override
  late final GeneratedColumn<int> sequenceNumber = GeneratedColumn<int>(
      'sequence_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _scheduledDateMeta =
      const VerificationMeta('scheduledDate');
  @override
  late final GeneratedColumn<int> scheduledDate = GeneratedColumn<int>(
      'scheduled_date', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _amountMinorMeta =
      const VerificationMeta('amountMinor');
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
      'amount_minor', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _childTransactionIdMeta =
      const VerificationMeta('childTransactionId');
  @override
  late final GeneratedColumn<String> childTransactionId =
      GeneratedColumn<String>('child_transaction_id', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'REFERENCES transactions (id)'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        templateId,
        sequenceNumber,
        scheduledDate,
        amountMinor,
        status,
        childTransactionId,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'installment_occurrences';
  @override
  VerificationContext validateIntegrity(
      Insertable<InstallmentOccurrence> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('template_id')) {
      context.handle(
          _templateIdMeta,
          templateId.isAcceptableOrUnknown(
              data['template_id']!, _templateIdMeta));
    } else if (isInserting) {
      context.missing(_templateIdMeta);
    }
    if (data.containsKey('sequence_number')) {
      context.handle(
          _sequenceNumberMeta,
          sequenceNumber.isAcceptableOrUnknown(
              data['sequence_number']!, _sequenceNumberMeta));
    } else if (isInserting) {
      context.missing(_sequenceNumberMeta);
    }
    if (data.containsKey('scheduled_date')) {
      context.handle(
          _scheduledDateMeta,
          scheduledDate.isAcceptableOrUnknown(
              data['scheduled_date']!, _scheduledDateMeta));
    } else if (isInserting) {
      context.missing(_scheduledDateMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
          _amountMinorMeta,
          amountMinor.isAcceptableOrUnknown(
              data['amount_minor']!, _amountMinorMeta));
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('child_transaction_id')) {
      context.handle(
          _childTransactionIdMeta,
          childTransactionId.isAcceptableOrUnknown(
              data['child_transaction_id']!, _childTransactionIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InstallmentOccurrence map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InstallmentOccurrence(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      templateId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}template_id'])!,
      sequenceNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sequence_number'])!,
      scheduledDate: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}scheduled_date'])!,
      amountMinor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount_minor'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      childTransactionId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}child_transaction_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $InstallmentOccurrencesTable createAlias(String alias) {
    return $InstallmentOccurrencesTable(attachedDatabase, alias);
  }
}

class InstallmentOccurrence extends DataClass
    implements Insertable<InstallmentOccurrence> {
  /// Stable UUID v4 identifier.
  final String id;

  /// FK → recurring_templates(id) ON DELETE CASCADE.
  final String templateId;

  /// 1-based position in the series. Unique per template.
  final int sequenceNumber;

  /// When this installment should be posted (Unix epoch date).
  final int scheduledDate;

  /// Per-installment amount in minor units. Adjustable for unposted rows.
  final int amountMinor;

  /// Status: `pending`, `posted`, or `cancelled`.
  final String status;

  /// FK to the transaction created when this installment is posted.
  final String? childTransactionId;

  /// Unix epoch seconds when this row was created.
  final int createdAt;

  /// Unix epoch seconds when this row was last modified.
  final int updatedAt;
  const InstallmentOccurrence(
      {required this.id,
      required this.templateId,
      required this.sequenceNumber,
      required this.scheduledDate,
      required this.amountMinor,
      required this.status,
      this.childTransactionId,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['template_id'] = Variable<String>(templateId);
    map['sequence_number'] = Variable<int>(sequenceNumber);
    map['scheduled_date'] = Variable<int>(scheduledDate);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || childTransactionId != null) {
      map['child_transaction_id'] = Variable<String>(childTransactionId);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  InstallmentOccurrencesCompanion toCompanion(bool nullToAbsent) {
    return InstallmentOccurrencesCompanion(
      id: Value(id),
      templateId: Value(templateId),
      sequenceNumber: Value(sequenceNumber),
      scheduledDate: Value(scheduledDate),
      amountMinor: Value(amountMinor),
      status: Value(status),
      childTransactionId: childTransactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(childTransactionId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory InstallmentOccurrence.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InstallmentOccurrence(
      id: serializer.fromJson<String>(json['id']),
      templateId: serializer.fromJson<String>(json['templateId']),
      sequenceNumber: serializer.fromJson<int>(json['sequenceNumber']),
      scheduledDate: serializer.fromJson<int>(json['scheduledDate']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      status: serializer.fromJson<String>(json['status']),
      childTransactionId:
          serializer.fromJson<String?>(json['childTransactionId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'templateId': serializer.toJson<String>(templateId),
      'sequenceNumber': serializer.toJson<int>(sequenceNumber),
      'scheduledDate': serializer.toJson<int>(scheduledDate),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'status': serializer.toJson<String>(status),
      'childTransactionId': serializer.toJson<String?>(childTransactionId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  InstallmentOccurrence copyWith(
          {String? id,
          String? templateId,
          int? sequenceNumber,
          int? scheduledDate,
          int? amountMinor,
          String? status,
          Value<String?> childTransactionId = const Value.absent(),
          int? createdAt,
          int? updatedAt}) =>
      InstallmentOccurrence(
        id: id ?? this.id,
        templateId: templateId ?? this.templateId,
        sequenceNumber: sequenceNumber ?? this.sequenceNumber,
        scheduledDate: scheduledDate ?? this.scheduledDate,
        amountMinor: amountMinor ?? this.amountMinor,
        status: status ?? this.status,
        childTransactionId: childTransactionId.present
            ? childTransactionId.value
            : this.childTransactionId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  InstallmentOccurrence copyWithCompanion(
      InstallmentOccurrencesCompanion data) {
    return InstallmentOccurrence(
      id: data.id.present ? data.id.value : this.id,
      templateId:
          data.templateId.present ? data.templateId.value : this.templateId,
      sequenceNumber: data.sequenceNumber.present
          ? data.sequenceNumber.value
          : this.sequenceNumber,
      scheduledDate: data.scheduledDate.present
          ? data.scheduledDate.value
          : this.scheduledDate,
      amountMinor:
          data.amountMinor.present ? data.amountMinor.value : this.amountMinor,
      status: data.status.present ? data.status.value : this.status,
      childTransactionId: data.childTransactionId.present
          ? data.childTransactionId.value
          : this.childTransactionId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InstallmentOccurrence(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('sequenceNumber: $sequenceNumber, ')
          ..write('scheduledDate: $scheduledDate, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('status: $status, ')
          ..write('childTransactionId: $childTransactionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, templateId, sequenceNumber, scheduledDate,
      amountMinor, status, childTransactionId, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InstallmentOccurrence &&
          other.id == this.id &&
          other.templateId == this.templateId &&
          other.sequenceNumber == this.sequenceNumber &&
          other.scheduledDate == this.scheduledDate &&
          other.amountMinor == this.amountMinor &&
          other.status == this.status &&
          other.childTransactionId == this.childTransactionId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class InstallmentOccurrencesCompanion
    extends UpdateCompanion<InstallmentOccurrence> {
  final Value<String> id;
  final Value<String> templateId;
  final Value<int> sequenceNumber;
  final Value<int> scheduledDate;
  final Value<int> amountMinor;
  final Value<String> status;
  final Value<String?> childTransactionId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const InstallmentOccurrencesCompanion({
    this.id = const Value.absent(),
    this.templateId = const Value.absent(),
    this.sequenceNumber = const Value.absent(),
    this.scheduledDate = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.status = const Value.absent(),
    this.childTransactionId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InstallmentOccurrencesCompanion.insert({
    required String id,
    required String templateId,
    required int sequenceNumber,
    required int scheduledDate,
    required int amountMinor,
    this.status = const Value.absent(),
    this.childTransactionId = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        templateId = Value(templateId),
        sequenceNumber = Value(sequenceNumber),
        scheduledDate = Value(scheduledDate),
        amountMinor = Value(amountMinor),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<InstallmentOccurrence> custom({
    Expression<String>? id,
    Expression<String>? templateId,
    Expression<int>? sequenceNumber,
    Expression<int>? scheduledDate,
    Expression<int>? amountMinor,
    Expression<String>? status,
    Expression<String>? childTransactionId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (templateId != null) 'template_id': templateId,
      if (sequenceNumber != null) 'sequence_number': sequenceNumber,
      if (scheduledDate != null) 'scheduled_date': scheduledDate,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (status != null) 'status': status,
      if (childTransactionId != null)
        'child_transaction_id': childTransactionId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InstallmentOccurrencesCompanion copyWith(
      {Value<String>? id,
      Value<String>? templateId,
      Value<int>? sequenceNumber,
      Value<int>? scheduledDate,
      Value<int>? amountMinor,
      Value<String>? status,
      Value<String?>? childTransactionId,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<int>? rowid}) {
    return InstallmentOccurrencesCompanion(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      amountMinor: amountMinor ?? this.amountMinor,
      status: status ?? this.status,
      childTransactionId: childTransactionId ?? this.childTransactionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (templateId.present) {
      map['template_id'] = Variable<String>(templateId.value);
    }
    if (sequenceNumber.present) {
      map['sequence_number'] = Variable<int>(sequenceNumber.value);
    }
    if (scheduledDate.present) {
      map['scheduled_date'] = Variable<int>(scheduledDate.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (childTransactionId.present) {
      map['child_transaction_id'] = Variable<String>(childTransactionId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InstallmentOccurrencesCompanion(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('sequenceNumber: $sequenceNumber, ')
          ..write('scheduledDate: $scheduledDate, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('status: $status, ')
          ..write('childTransactionId: $childTransactionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(Insertable<AppSetting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  /// Setting identifier (PK). See data model §9.1 for the full key list.
  final String key;

  /// Setting value as a TEXT string. Type is inferred by the key.
  final String? value;

  /// Unix epoch seconds when this row was last modified.
  final int updatedAt;
  const AppSetting({required this.key, this.value, required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      value:
          value == null && nullToAbsent ? const Value.absent() : Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppSetting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String?>(json['value']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String?>(value),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  AppSetting copyWith(
          {String? key,
          Value<String?> value = const Value.absent(),
          int? updatedAt}) =>
      AppSetting(
        key: key ?? this.key,
        value: value.present ? value.value : this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String?> value;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    this.value = const Value.absent(),
    required int updatedAt,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        updatedAt = Value(updatedAt);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith(
      {Value<String>? key,
      Value<String?>? value,
      Value<int>? updatedAt,
      Value<int>? rowid}) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DraftsTable extends Drafts with TableInfo<$DraftsTable, Draft> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DraftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, payloadJson, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'drafts';
  @override
  VerificationContext validateIntegrity(Insertable<Draft> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Draft map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Draft(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $DraftsTable createAlias(String alias) {
    return $DraftsTable(attachedDatabase, alias);
  }
}

class Draft extends DataClass implements Insertable<Draft> {
  /// Stable UUID v4 identifier.
  final String id;

  /// Serialized form state as a JSON string.
  final String payloadJson;

  /// Unix epoch seconds when this draft was first saved. Used for FIFO
  /// eviction ordering.
  final int createdAt;

  /// Unix epoch seconds of the most recent auto-save.
  final int updatedAt;
  const Draft(
      {required this.id,
      required this.payloadJson,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  DraftsCompanion toCompanion(bool nullToAbsent) {
    return DraftsCompanion(
      id: Value(id),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Draft.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Draft(
      id: serializer.fromJson<String>(json['id']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  Draft copyWith(
          {String? id, String? payloadJson, int? createdAt, int? updatedAt}) =>
      Draft(
        id: id ?? this.id,
        payloadJson: payloadJson ?? this.payloadJson,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Draft copyWithCompanion(DraftsCompanion data) {
    return Draft(
      id: data.id.present ? data.id.value : this.id,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Draft(')
          ..write('id: $id, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, payloadJson, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Draft &&
          other.id == this.id &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DraftsCompanion extends UpdateCompanion<Draft> {
  final Value<String> id;
  final Value<String> payloadJson;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const DraftsCompanion({
    this.id = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DraftsCompanion.insert({
    required String id,
    required String payloadJson,
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        payloadJson = Value(payloadJson),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Draft> custom({
    Expression<String>? id,
    Expression<String>? payloadJson,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DraftsCompanion copyWith(
      {Value<String>? id,
      Value<String>? payloadJson,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<int>? rowid}) {
    return DraftsCompanion(
      id: id ?? this.id,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DraftsCompanion(')
          ..write('id: $id, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $AccountDetailsTable accountDetails = $AccountDetailsTable(this);
  late final $CurrenciesTable currencies = $CurrenciesTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $PayeesTable payees = $PayeesTable(this);
  late final $RecurringTemplatesTable recurringTemplates =
      $RecurringTemplatesTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $EntriesTable entries = $EntriesTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $TransactionTagsTable transactionTags =
      $TransactionTagsTable(this);
  late final $ExchangeRatesTable exchangeRates = $ExchangeRatesTable(this);
  late final $AttachmentsTable attachments = $AttachmentsTable(this);
  late final $BudgetsTable budgets = $BudgetsTable(this);
  late final $BudgetPeriodsTable budgetPeriods = $BudgetPeriodsTable(this);
  late final $ScheduledOccurrencesTable scheduledOccurrences =
      $ScheduledOccurrencesTable(this);
  late final $InstallmentPlansTable installmentPlans =
      $InstallmentPlansTable(this);
  late final $InstallmentOccurrencesTable installmentOccurrences =
      $InstallmentOccurrencesTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $DraftsTable drafts = $DraftsTable(this);
  late final TransactionDao transactionDao =
      TransactionDao(this as AppDatabase);
  late final AccountDao accountDao = AccountDao(this as AppDatabase);
  late final CategoryDao categoryDao = CategoryDao(this as AppDatabase);
  late final TemplateDao templateDao = TemplateDao(this as AppDatabase);
  late final ExchangeRateDao exchangeRateDao =
      ExchangeRateDao(this as AppDatabase);
  late final CurrencyDao currencyDao = CurrencyDao(this as AppDatabase);
  late final AppSettingsDao appSettingsDao =
      AppSettingsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        accounts,
        accountDetails,
        currencies,
        categories,
        payees,
        recurringTemplates,
        transactions,
        entries,
        tags,
        transactionTags,
        exchangeRates,
        attachments,
        budgets,
        budgetPeriods,
        scheduledOccurrences,
        installmentPlans,
        installmentOccurrences,
        appSettings,
        drafts
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('accounts',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('account_details', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('transactions',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('transaction_tags', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('tags',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('transaction_tags', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('recurring_templates',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('scheduled_occurrences', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('recurring_templates',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('installment_plans', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('recurring_templates',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('installment_occurrences', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$AccountsTableCreateCompanionBuilder = AccountsCompanion Function({
  required String id,
  required String name,
  required String accountCategory,
  Value<int> initialBalanceMinor,
  required String currencyCode,
  Value<bool> includeInNetWorth,
  Value<String?> notes,
  Value<bool> isDeleted,
  Value<int?> deletedAt,
  Value<bool> isProtected,
  Value<bool> isSystem,
  Value<int?> displayOrder,
  required int createdAt,
  required int updatedAt,
  Value<String?> metadata,
  Value<int?> largeTxnThresholdMinor,
  Value<int> rowid,
});
typedef $$AccountsTableUpdateCompanionBuilder = AccountsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> accountCategory,
  Value<int> initialBalanceMinor,
  Value<String> currencyCode,
  Value<bool> includeInNetWorth,
  Value<String?> notes,
  Value<bool> isDeleted,
  Value<int?> deletedAt,
  Value<bool> isProtected,
  Value<bool> isSystem,
  Value<int?> displayOrder,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<String?> metadata,
  Value<int?> largeTxnThresholdMinor,
  Value<int> rowid,
});

final class $$AccountsTableReferences
    extends BaseReferences<_$AppDatabase, $AccountsTable, Account> {
  $$AccountsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AccountDetailsTable, List<AccountDetail>>
      _accountDetailsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.accountDetails,
              aliasName: $_aliasNameGenerator(
                  db.accounts.id, db.accountDetails.accountId));

  $$AccountDetailsTableProcessedTableManager get accountDetailsRefs {
    final manager = $$AccountDetailsTableTableManager($_db, $_db.accountDetails)
        .filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_accountDetailsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$EntriesTable, List<Entry>> _entriesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.entries,
          aliasName:
              $_aliasNameGenerator(db.accounts.id, db.entries.accountId));

  $$EntriesTableProcessedTableManager get entriesRefs {
    final manager = $$EntriesTableTableManager($_db, $_db.entries)
        .filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_entriesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$AccountsTableFilterComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accountCategory => $composableBuilder(
      column: $table.accountCategory,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get initialBalanceMinor => $composableBuilder(
      column: $table.initialBalanceMinor,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currencyCode => $composableBuilder(
      column: $table.currencyCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get includeInNetWorth => $composableBuilder(
      column: $table.includeInNetWorth,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isProtected => $composableBuilder(
      column: $table.isProtected, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSystem => $composableBuilder(
      column: $table.isSystem, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get displayOrder => $composableBuilder(
      column: $table.displayOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metadata => $composableBuilder(
      column: $table.metadata, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get largeTxnThresholdMinor => $composableBuilder(
      column: $table.largeTxnThresholdMinor,
      builder: (column) => ColumnFilters(column));

  Expression<bool> accountDetailsRefs(
      Expression<bool> Function($$AccountDetailsTableFilterComposer f) f) {
    final $$AccountDetailsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.accountDetails,
        getReferencedColumn: (t) => t.accountId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountDetailsTableFilterComposer(
              $db: $db,
              $table: $db.accountDetails,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> entriesRefs(
      Expression<bool> Function($$EntriesTableFilterComposer f) f) {
    final $$EntriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.entries,
        getReferencedColumn: (t) => t.accountId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EntriesTableFilterComposer(
              $db: $db,
              $table: $db.entries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$AccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accountCategory => $composableBuilder(
      column: $table.accountCategory,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get initialBalanceMinor => $composableBuilder(
      column: $table.initialBalanceMinor,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currencyCode => $composableBuilder(
      column: $table.currencyCode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get includeInNetWorth => $composableBuilder(
      column: $table.includeInNetWorth,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isProtected => $composableBuilder(
      column: $table.isProtected, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSystem => $composableBuilder(
      column: $table.isSystem, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get displayOrder => $composableBuilder(
      column: $table.displayOrder,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metadata => $composableBuilder(
      column: $table.metadata, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get largeTxnThresholdMinor => $composableBuilder(
      column: $table.largeTxnThresholdMinor,
      builder: (column) => ColumnOrderings(column));
}

class $$AccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get accountCategory => $composableBuilder(
      column: $table.accountCategory, builder: (column) => column);

  GeneratedColumn<int> get initialBalanceMinor => $composableBuilder(
      column: $table.initialBalanceMinor, builder: (column) => column);

  GeneratedColumn<String> get currencyCode => $composableBuilder(
      column: $table.currencyCode, builder: (column) => column);

  GeneratedColumn<bool> get includeInNetWorth => $composableBuilder(
      column: $table.includeInNetWorth, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get isProtected => $composableBuilder(
      column: $table.isProtected, builder: (column) => column);

  GeneratedColumn<bool> get isSystem =>
      $composableBuilder(column: $table.isSystem, builder: (column) => column);

  GeneratedColumn<int> get displayOrder => $composableBuilder(
      column: $table.displayOrder, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);

  GeneratedColumn<int> get largeTxnThresholdMinor => $composableBuilder(
      column: $table.largeTxnThresholdMinor, builder: (column) => column);

  Expression<T> accountDetailsRefs<T extends Object>(
      Expression<T> Function($$AccountDetailsTableAnnotationComposer a) f) {
    final $$AccountDetailsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.accountDetails,
        getReferencedColumn: (t) => t.accountId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountDetailsTableAnnotationComposer(
              $db: $db,
              $table: $db.accountDetails,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> entriesRefs<T extends Object>(
      Expression<T> Function($$EntriesTableAnnotationComposer a) f) {
    final $$EntriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.entries,
        getReferencedColumn: (t) => t.accountId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EntriesTableAnnotationComposer(
              $db: $db,
              $table: $db.entries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$AccountsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AccountsTable,
    Account,
    $$AccountsTableFilterComposer,
    $$AccountsTableOrderingComposer,
    $$AccountsTableAnnotationComposer,
    $$AccountsTableCreateCompanionBuilder,
    $$AccountsTableUpdateCompanionBuilder,
    (Account, $$AccountsTableReferences),
    Account,
    PrefetchHooks Function({bool accountDetailsRefs, bool entriesRefs})> {
  $$AccountsTableTableManager(_$AppDatabase db, $AccountsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> accountCategory = const Value.absent(),
            Value<int> initialBalanceMinor = const Value.absent(),
            Value<String> currencyCode = const Value.absent(),
            Value<bool> includeInNetWorth = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int?> deletedAt = const Value.absent(),
            Value<bool> isProtected = const Value.absent(),
            Value<bool> isSystem = const Value.absent(),
            Value<int?> displayOrder = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<String?> metadata = const Value.absent(),
            Value<int?> largeTxnThresholdMinor = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AccountsCompanion(
            id: id,
            name: name,
            accountCategory: accountCategory,
            initialBalanceMinor: initialBalanceMinor,
            currencyCode: currencyCode,
            includeInNetWorth: includeInNetWorth,
            notes: notes,
            isDeleted: isDeleted,
            deletedAt: deletedAt,
            isProtected: isProtected,
            isSystem: isSystem,
            displayOrder: displayOrder,
            createdAt: createdAt,
            updatedAt: updatedAt,
            metadata: metadata,
            largeTxnThresholdMinor: largeTxnThresholdMinor,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String accountCategory,
            Value<int> initialBalanceMinor = const Value.absent(),
            required String currencyCode,
            Value<bool> includeInNetWorth = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int?> deletedAt = const Value.absent(),
            Value<bool> isProtected = const Value.absent(),
            Value<bool> isSystem = const Value.absent(),
            Value<int?> displayOrder = const Value.absent(),
            required int createdAt,
            required int updatedAt,
            Value<String?> metadata = const Value.absent(),
            Value<int?> largeTxnThresholdMinor = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AccountsCompanion.insert(
            id: id,
            name: name,
            accountCategory: accountCategory,
            initialBalanceMinor: initialBalanceMinor,
            currencyCode: currencyCode,
            includeInNetWorth: includeInNetWorth,
            notes: notes,
            isDeleted: isDeleted,
            deletedAt: deletedAt,
            isProtected: isProtected,
            isSystem: isSystem,
            displayOrder: displayOrder,
            createdAt: createdAt,
            updatedAt: updatedAt,
            metadata: metadata,
            largeTxnThresholdMinor: largeTxnThresholdMinor,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$AccountsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {accountDetailsRefs = false, entriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (accountDetailsRefs) db.accountDetails,
                if (entriesRefs) db.entries
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (accountDetailsRefs)
                    await $_getPrefetchedData<Account, $AccountsTable,
                            AccountDetail>(
                        currentTable: table,
                        referencedTable: $$AccountsTableReferences
                            ._accountDetailsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AccountsTableReferences(db, table, p0)
                                .accountDetailsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.accountId == item.id),
                        typedResults: items),
                  if (entriesRefs)
                    await $_getPrefetchedData<Account, $AccountsTable, Entry>(
                        currentTable: table,
                        referencedTable:
                            $$AccountsTableReferences._entriesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AccountsTableReferences(db, table, p0)
                                .entriesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.accountId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$AccountsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AccountsTable,
    Account,
    $$AccountsTableFilterComposer,
    $$AccountsTableOrderingComposer,
    $$AccountsTableAnnotationComposer,
    $$AccountsTableCreateCompanionBuilder,
    $$AccountsTableUpdateCompanionBuilder,
    (Account, $$AccountsTableReferences),
    Account,
    PrefetchHooks Function({bool accountDetailsRefs, bool entriesRefs})>;
typedef $$AccountDetailsTableCreateCompanionBuilder = AccountDetailsCompanion
    Function({
  required String id,
  required String accountId,
  required String detailKey,
  Value<String?> detailValue,
  Value<String?> detailValueEncrypted,
  required int updatedAt,
  Value<int> rowid,
});
typedef $$AccountDetailsTableUpdateCompanionBuilder = AccountDetailsCompanion
    Function({
  Value<String> id,
  Value<String> accountId,
  Value<String> detailKey,
  Value<String?> detailValue,
  Value<String?> detailValueEncrypted,
  Value<int> updatedAt,
  Value<int> rowid,
});

final class $$AccountDetailsTableReferences
    extends BaseReferences<_$AppDatabase, $AccountDetailsTable, AccountDetail> {
  $$AccountDetailsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $AccountsTable _accountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias(
          $_aliasNameGenerator(db.accountDetails.accountId, db.accounts.id));

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<String>('account_id')!;

    final manager = $$AccountsTableTableManager($_db, $_db.accounts)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$AccountDetailsTableFilterComposer
    extends Composer<_$AppDatabase, $AccountDetailsTable> {
  $$AccountDetailsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get detailKey => $composableBuilder(
      column: $table.detailKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get detailValue => $composableBuilder(
      column: $table.detailValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get detailValueEncrypted => $composableBuilder(
      column: $table.detailValueEncrypted,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableFilterComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AccountDetailsTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountDetailsTable> {
  $$AccountDetailsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get detailKey => $composableBuilder(
      column: $table.detailKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get detailValue => $composableBuilder(
      column: $table.detailValue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get detailValueEncrypted => $composableBuilder(
      column: $table.detailValueEncrypted,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableOrderingComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AccountDetailsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountDetailsTable> {
  $$AccountDetailsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get detailKey =>
      $composableBuilder(column: $table.detailKey, builder: (column) => column);

  GeneratedColumn<String> get detailValue => $composableBuilder(
      column: $table.detailValue, builder: (column) => column);

  GeneratedColumn<String> get detailValueEncrypted => $composableBuilder(
      column: $table.detailValueEncrypted, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableAnnotationComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AccountDetailsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AccountDetailsTable,
    AccountDetail,
    $$AccountDetailsTableFilterComposer,
    $$AccountDetailsTableOrderingComposer,
    $$AccountDetailsTableAnnotationComposer,
    $$AccountDetailsTableCreateCompanionBuilder,
    $$AccountDetailsTableUpdateCompanionBuilder,
    (AccountDetail, $$AccountDetailsTableReferences),
    AccountDetail,
    PrefetchHooks Function({bool accountId})> {
  $$AccountDetailsTableTableManager(
      _$AppDatabase db, $AccountDetailsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountDetailsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountDetailsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountDetailsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> accountId = const Value.absent(),
            Value<String> detailKey = const Value.absent(),
            Value<String?> detailValue = const Value.absent(),
            Value<String?> detailValueEncrypted = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AccountDetailsCompanion(
            id: id,
            accountId: accountId,
            detailKey: detailKey,
            detailValue: detailValue,
            detailValueEncrypted: detailValueEncrypted,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String accountId,
            required String detailKey,
            Value<String?> detailValue = const Value.absent(),
            Value<String?> detailValueEncrypted = const Value.absent(),
            required int updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              AccountDetailsCompanion.insert(
            id: id,
            accountId: accountId,
            detailKey: detailKey,
            detailValue: detailValue,
            detailValueEncrypted: detailValueEncrypted,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$AccountDetailsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({accountId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (accountId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.accountId,
                    referencedTable:
                        $$AccountDetailsTableReferences._accountIdTable(db),
                    referencedColumn:
                        $$AccountDetailsTableReferences._accountIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$AccountDetailsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AccountDetailsTable,
    AccountDetail,
    $$AccountDetailsTableFilterComposer,
    $$AccountDetailsTableOrderingComposer,
    $$AccountDetailsTableAnnotationComposer,
    $$AccountDetailsTableCreateCompanionBuilder,
    $$AccountDetailsTableUpdateCompanionBuilder,
    (AccountDetail, $$AccountDetailsTableReferences),
    AccountDetail,
    PrefetchHooks Function({bool accountId})>;
typedef $$CurrenciesTableCreateCompanionBuilder = CurrenciesCompanion Function({
  required String code,
  required String name,
  required String symbol,
  Value<int> minorUnits,
  Value<bool> isActive,
  Value<int> rowid,
});
typedef $$CurrenciesTableUpdateCompanionBuilder = CurrenciesCompanion Function({
  Value<String> code,
  Value<String> name,
  Value<String> symbol,
  Value<int> minorUnits,
  Value<bool> isActive,
  Value<int> rowid,
});

final class $$CurrenciesTableReferences
    extends BaseReferences<_$AppDatabase, $CurrenciesTable, Currency> {
  $$CurrenciesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RecurringTemplatesTable, List<RecurringTemplate>>
      _recurringTemplatesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.recurringTemplates,
              aliasName: $_aliasNameGenerator(
                  db.currencies.code, db.recurringTemplates.currencyCode));

  $$RecurringTemplatesTableProcessedTableManager get recurringTemplatesRefs {
    final manager =
        $$RecurringTemplatesTableTableManager($_db, $_db.recurringTemplates)
            .filter((f) =>
                f.currencyCode.code.sqlEquals($_itemColumn<String>('code')!));

    final cache =
        $_typedResult.readTableOrNull(_recurringTemplatesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$EntriesTable, List<Entry>> _entriesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.entries,
          aliasName: $_aliasNameGenerator(
              db.currencies.code, db.entries.currencyCode));

  $$EntriesTableProcessedTableManager get entriesRefs {
    final manager = $$EntriesTableTableManager($_db, $_db.entries).filter(
        (f) => f.currencyCode.code.sqlEquals($_itemColumn<String>('code')!));

    final cache = $_typedResult.readTableOrNull(_entriesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$BudgetsTable, List<Budget>> _budgetsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.budgets,
          aliasName: $_aliasNameGenerator(
              db.currencies.code, db.budgets.currencyCode));

  $$BudgetsTableProcessedTableManager get budgetsRefs {
    final manager = $$BudgetsTableTableManager($_db, $_db.budgets).filter(
        (f) => f.currencyCode.code.sqlEquals($_itemColumn<String>('code')!));

    final cache = $_typedResult.readTableOrNull(_budgetsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CurrenciesTableFilterComposer
    extends Composer<_$AppDatabase, $CurrenciesTable> {
  $$CurrenciesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get symbol => $composableBuilder(
      column: $table.symbol, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get minorUnits => $composableBuilder(
      column: $table.minorUnits, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  Expression<bool> recurringTemplatesRefs(
      Expression<bool> Function($$RecurringTemplatesTableFilterComposer f) f) {
    final $$RecurringTemplatesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.code,
        referencedTable: $db.recurringTemplates,
        getReferencedColumn: (t) => t.currencyCode,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecurringTemplatesTableFilterComposer(
              $db: $db,
              $table: $db.recurringTemplates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> entriesRefs(
      Expression<bool> Function($$EntriesTableFilterComposer f) f) {
    final $$EntriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.code,
        referencedTable: $db.entries,
        getReferencedColumn: (t) => t.currencyCode,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EntriesTableFilterComposer(
              $db: $db,
              $table: $db.entries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> budgetsRefs(
      Expression<bool> Function($$BudgetsTableFilterComposer f) f) {
    final $$BudgetsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.code,
        referencedTable: $db.budgets,
        getReferencedColumn: (t) => t.currencyCode,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BudgetsTableFilterComposer(
              $db: $db,
              $table: $db.budgets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CurrenciesTableOrderingComposer
    extends Composer<_$AppDatabase, $CurrenciesTable> {
  $$CurrenciesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get symbol => $composableBuilder(
      column: $table.symbol, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get minorUnits => $composableBuilder(
      column: $table.minorUnits, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));
}

class $$CurrenciesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CurrenciesTable> {
  $$CurrenciesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<int> get minorUnits => $composableBuilder(
      column: $table.minorUnits, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  Expression<T> recurringTemplatesRefs<T extends Object>(
      Expression<T> Function($$RecurringTemplatesTableAnnotationComposer a) f) {
    final $$RecurringTemplatesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.code,
            referencedTable: $db.recurringTemplates,
            getReferencedColumn: (t) => t.currencyCode,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$RecurringTemplatesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.recurringTemplates,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> entriesRefs<T extends Object>(
      Expression<T> Function($$EntriesTableAnnotationComposer a) f) {
    final $$EntriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.code,
        referencedTable: $db.entries,
        getReferencedColumn: (t) => t.currencyCode,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EntriesTableAnnotationComposer(
              $db: $db,
              $table: $db.entries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> budgetsRefs<T extends Object>(
      Expression<T> Function($$BudgetsTableAnnotationComposer a) f) {
    final $$BudgetsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.code,
        referencedTable: $db.budgets,
        getReferencedColumn: (t) => t.currencyCode,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BudgetsTableAnnotationComposer(
              $db: $db,
              $table: $db.budgets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CurrenciesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CurrenciesTable,
    Currency,
    $$CurrenciesTableFilterComposer,
    $$CurrenciesTableOrderingComposer,
    $$CurrenciesTableAnnotationComposer,
    $$CurrenciesTableCreateCompanionBuilder,
    $$CurrenciesTableUpdateCompanionBuilder,
    (Currency, $$CurrenciesTableReferences),
    Currency,
    PrefetchHooks Function(
        {bool recurringTemplatesRefs, bool entriesRefs, bool budgetsRefs})> {
  $$CurrenciesTableTableManager(_$AppDatabase db, $CurrenciesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CurrenciesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CurrenciesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CurrenciesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> code = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> symbol = const Value.absent(),
            Value<int> minorUnits = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CurrenciesCompanion(
            code: code,
            name: name,
            symbol: symbol,
            minorUnits: minorUnits,
            isActive: isActive,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String code,
            required String name,
            required String symbol,
            Value<int> minorUnits = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CurrenciesCompanion.insert(
            code: code,
            name: name,
            symbol: symbol,
            minorUnits: minorUnits,
            isActive: isActive,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CurrenciesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {recurringTemplatesRefs = false,
              entriesRefs = false,
              budgetsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (recurringTemplatesRefs) db.recurringTemplates,
                if (entriesRefs) db.entries,
                if (budgetsRefs) db.budgets
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (recurringTemplatesRefs)
                    await $_getPrefetchedData<Currency, $CurrenciesTable,
                            RecurringTemplate>(
                        currentTable: table,
                        referencedTable: $$CurrenciesTableReferences
                            ._recurringTemplatesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CurrenciesTableReferences(db, table, p0)
                                .recurringTemplatesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.currencyCode == item.code),
                        typedResults: items),
                  if (entriesRefs)
                    await $_getPrefetchedData<Currency, $CurrenciesTable,
                            Entry>(
                        currentTable: table,
                        referencedTable:
                            $$CurrenciesTableReferences._entriesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CurrenciesTableReferences(db, table, p0)
                                .entriesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.currencyCode == item.code),
                        typedResults: items),
                  if (budgetsRefs)
                    await $_getPrefetchedData<Currency, $CurrenciesTable,
                            Budget>(
                        currentTable: table,
                        referencedTable:
                            $$CurrenciesTableReferences._budgetsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CurrenciesTableReferences(db, table, p0)
                                .budgetsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.currencyCode == item.code),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CurrenciesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CurrenciesTable,
    Currency,
    $$CurrenciesTableFilterComposer,
    $$CurrenciesTableOrderingComposer,
    $$CurrenciesTableAnnotationComposer,
    $$CurrenciesTableCreateCompanionBuilder,
    $$CurrenciesTableUpdateCompanionBuilder,
    (Currency, $$CurrenciesTableReferences),
    Currency,
    PrefetchHooks Function(
        {bool recurringTemplatesRefs, bool entriesRefs, bool budgetsRefs})>;
typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  required String id,
  Value<String?> parentId,
  required String treeType,
  required String name,
  required String iconRef,
  Value<bool> isDeleted,
  Value<int?> deletedAt,
  Value<bool> isProtected,
  Value<int?> sortOrder,
  required int createdAt,
  required int updatedAt,
  Value<int?> largeTxnThresholdMinor,
  Value<int> rowid,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<String> id,
  Value<String?> parentId,
  Value<String> treeType,
  Value<String> name,
  Value<String> iconRef,
  Value<bool> isDeleted,
  Value<int?> deletedAt,
  Value<bool> isProtected,
  Value<int?> sortOrder,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> largeTxnThresholdMinor,
  Value<int> rowid,
});

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, Category> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _parentIdTable(_$AppDatabase db) =>
      db.categories.createAlias(
          $_aliasNameGenerator(db.categories.parentId, db.categories.id));

  $$CategoriesTableProcessedTableManager? get parentId {
    final $_column = $_itemColumn<String>('parent_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager($_db, $_db.categories)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$EntriesTable, List<Entry>> _entriesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.entries,
          aliasName:
              $_aliasNameGenerator(db.categories.id, db.entries.categoryId));

  $$EntriesTableProcessedTableManager get entriesRefs {
    final manager = $$EntriesTableTableManager($_db, $_db.entries)
        .filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_entriesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$BudgetsTable, List<Budget>> _budgetsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.budgets,
          aliasName:
              $_aliasNameGenerator(db.categories.id, db.budgets.categoryId));

  $$BudgetsTableProcessedTableManager get budgetsRefs {
    final manager = $$BudgetsTableTableManager($_db, $_db.budgets)
        .filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_budgetsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get treeType => $composableBuilder(
      column: $table.treeType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get iconRef => $composableBuilder(
      column: $table.iconRef, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isProtected => $composableBuilder(
      column: $table.isProtected, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get largeTxnThresholdMinor => $composableBuilder(
      column: $table.largeTxnThresholdMinor,
      builder: (column) => ColumnFilters(column));

  $$CategoriesTableFilterComposer get parentId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.parentId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableFilterComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> entriesRefs(
      Expression<bool> Function($$EntriesTableFilterComposer f) f) {
    final $$EntriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.entries,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EntriesTableFilterComposer(
              $db: $db,
              $table: $db.entries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> budgetsRefs(
      Expression<bool> Function($$BudgetsTableFilterComposer f) f) {
    final $$BudgetsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.budgets,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BudgetsTableFilterComposer(
              $db: $db,
              $table: $db.budgets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get treeType => $composableBuilder(
      column: $table.treeType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get iconRef => $composableBuilder(
      column: $table.iconRef, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isProtected => $composableBuilder(
      column: $table.isProtected, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get largeTxnThresholdMinor => $composableBuilder(
      column: $table.largeTxnThresholdMinor,
      builder: (column) => ColumnOrderings(column));

  $$CategoriesTableOrderingComposer get parentId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.parentId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get treeType =>
      $composableBuilder(column: $table.treeType, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get iconRef =>
      $composableBuilder(column: $table.iconRef, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get isProtected => $composableBuilder(
      column: $table.isProtected, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get largeTxnThresholdMinor => $composableBuilder(
      column: $table.largeTxnThresholdMinor, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get parentId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.parentId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> entriesRefs<T extends Object>(
      Expression<T> Function($$EntriesTableAnnotationComposer a) f) {
    final $$EntriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.entries,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EntriesTableAnnotationComposer(
              $db: $db,
              $table: $db.entries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> budgetsRefs<T extends Object>(
      Expression<T> Function($$BudgetsTableAnnotationComposer a) f) {
    final $$BudgetsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.budgets,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BudgetsTableAnnotationComposer(
              $db: $db,
              $table: $db.budgets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CategoriesTable,
    Category,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (Category, $$CategoriesTableReferences),
    Category,
    PrefetchHooks Function(
        {bool parentId, bool entriesRefs, bool budgetsRefs})> {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> parentId = const Value.absent(),
            Value<String> treeType = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> iconRef = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int?> deletedAt = const Value.absent(),
            Value<bool> isProtected = const Value.absent(),
            Value<int?> sortOrder = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int?> largeTxnThresholdMinor = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CategoriesCompanion(
            id: id,
            parentId: parentId,
            treeType: treeType,
            name: name,
            iconRef: iconRef,
            isDeleted: isDeleted,
            deletedAt: deletedAt,
            isProtected: isProtected,
            sortOrder: sortOrder,
            createdAt: createdAt,
            updatedAt: updatedAt,
            largeTxnThresholdMinor: largeTxnThresholdMinor,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> parentId = const Value.absent(),
            required String treeType,
            required String name,
            required String iconRef,
            Value<bool> isDeleted = const Value.absent(),
            Value<int?> deletedAt = const Value.absent(),
            Value<bool> isProtected = const Value.absent(),
            Value<int?> sortOrder = const Value.absent(),
            required int createdAt,
            required int updatedAt,
            Value<int?> largeTxnThresholdMinor = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CategoriesCompanion.insert(
            id: id,
            parentId: parentId,
            treeType: treeType,
            name: name,
            iconRef: iconRef,
            isDeleted: isDeleted,
            deletedAt: deletedAt,
            isProtected: isProtected,
            sortOrder: sortOrder,
            createdAt: createdAt,
            updatedAt: updatedAt,
            largeTxnThresholdMinor: largeTxnThresholdMinor,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CategoriesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {parentId = false, entriesRefs = false, budgetsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (entriesRefs) db.entries,
                if (budgetsRefs) db.budgets
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (parentId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.parentId,
                    referencedTable:
                        $$CategoriesTableReferences._parentIdTable(db),
                    referencedColumn:
                        $$CategoriesTableReferences._parentIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (entriesRefs)
                    await $_getPrefetchedData<Category, $CategoriesTable,
                            Entry>(
                        currentTable: table,
                        referencedTable:
                            $$CategoriesTableReferences._entriesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CategoriesTableReferences(db, table, p0)
                                .entriesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.categoryId == item.id),
                        typedResults: items),
                  if (budgetsRefs)
                    await $_getPrefetchedData<Category, $CategoriesTable,
                            Budget>(
                        currentTable: table,
                        referencedTable:
                            $$CategoriesTableReferences._budgetsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CategoriesTableReferences(db, table, p0)
                                .budgetsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.categoryId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CategoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CategoriesTable,
    Category,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (Category, $$CategoriesTableReferences),
    Category,
    PrefetchHooks Function(
        {bool parentId, bool entriesRefs, bool budgetsRefs})>;
typedef $$PayeesTableCreateCompanionBuilder = PayeesCompanion Function({
  required String id,
  required String name,
  Value<bool> isDeleted,
  Value<int?> deletedAt,
  required int createdAt,
  required int updatedAt,
  Value<int> rowid,
});
typedef $$PayeesTableUpdateCompanionBuilder = PayeesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<bool> isDeleted,
  Value<int?> deletedAt,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int> rowid,
});

final class $$PayeesTableReferences
    extends BaseReferences<_$AppDatabase, $PayeesTable, Payee> {
  $$PayeesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RecurringTemplatesTable, List<RecurringTemplate>>
      _recurringTemplatesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.recurringTemplates,
              aliasName: $_aliasNameGenerator(
                  db.payees.id, db.recurringTemplates.payeeId));

  $$RecurringTemplatesTableProcessedTableManager get recurringTemplatesRefs {
    final manager =
        $$RecurringTemplatesTableTableManager($_db, $_db.recurringTemplates)
            .filter((f) => f.payeeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_recurringTemplatesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$TransactionsTable, List<Transaction>>
      _transactionsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.transactions,
              aliasName:
                  $_aliasNameGenerator(db.payees.id, db.transactions.payeeId));

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager($_db, $_db.transactions)
        .filter((f) => f.payeeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$PayeesTableFilterComposer
    extends Composer<_$AppDatabase, $PayeesTable> {
  $$PayeesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> recurringTemplatesRefs(
      Expression<bool> Function($$RecurringTemplatesTableFilterComposer f) f) {
    final $$RecurringTemplatesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.recurringTemplates,
        getReferencedColumn: (t) => t.payeeId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecurringTemplatesTableFilterComposer(
              $db: $db,
              $table: $db.recurringTemplates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> transactionsRefs(
      Expression<bool> Function($$TransactionsTableFilterComposer f) f) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.payeeId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableFilterComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PayeesTableOrderingComposer
    extends Composer<_$AppDatabase, $PayeesTable> {
  $$PayeesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$PayeesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PayeesTable> {
  $$PayeesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> recurringTemplatesRefs<T extends Object>(
      Expression<T> Function($$RecurringTemplatesTableAnnotationComposer a) f) {
    final $$RecurringTemplatesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.recurringTemplates,
            getReferencedColumn: (t) => t.payeeId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$RecurringTemplatesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.recurringTemplates,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> transactionsRefs<T extends Object>(
      Expression<T> Function($$TransactionsTableAnnotationComposer a) f) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.payeeId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableAnnotationComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PayeesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PayeesTable,
    Payee,
    $$PayeesTableFilterComposer,
    $$PayeesTableOrderingComposer,
    $$PayeesTableAnnotationComposer,
    $$PayeesTableCreateCompanionBuilder,
    $$PayeesTableUpdateCompanionBuilder,
    (Payee, $$PayeesTableReferences),
    Payee,
    PrefetchHooks Function(
        {bool recurringTemplatesRefs, bool transactionsRefs})> {
  $$PayeesTableTableManager(_$AppDatabase db, $PayeesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PayeesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PayeesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PayeesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int?> deletedAt = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PayeesCompanion(
            id: id,
            name: name,
            isDeleted: isDeleted,
            deletedAt: deletedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<bool> isDeleted = const Value.absent(),
            Value<int?> deletedAt = const Value.absent(),
            required int createdAt,
            required int updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              PayeesCompanion.insert(
            id: id,
            name: name,
            isDeleted: isDeleted,
            deletedAt: deletedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$PayeesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {recurringTemplatesRefs = false, transactionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (recurringTemplatesRefs) db.recurringTemplates,
                if (transactionsRefs) db.transactions
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (recurringTemplatesRefs)
                    await $_getPrefetchedData<Payee, $PayeesTable,
                            RecurringTemplate>(
                        currentTable: table,
                        referencedTable: $$PayeesTableReferences
                            ._recurringTemplatesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PayeesTableReferences(db, table, p0)
                                .recurringTemplatesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.payeeId == item.id),
                        typedResults: items),
                  if (transactionsRefs)
                    await $_getPrefetchedData<Payee, $PayeesTable, Transaction>(
                        currentTable: table,
                        referencedTable:
                            $$PayeesTableReferences._transactionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PayeesTableReferences(db, table, p0)
                                .transactionsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.payeeId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$PayeesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PayeesTable,
    Payee,
    $$PayeesTableFilterComposer,
    $$PayeesTableOrderingComposer,
    $$PayeesTableAnnotationComposer,
    $$PayeesTableCreateCompanionBuilder,
    $$PayeesTableUpdateCompanionBuilder,
    (Payee, $$PayeesTableReferences),
    Payee,
    PrefetchHooks Function(
        {bool recurringTemplatesRefs, bool transactionsRefs})>;
typedef $$RecurringTemplatesTableCreateCompanionBuilder
    = RecurringTemplatesCompanion Function({
  required String id,
  required String transactionType,
  Value<String> status,
  required int amountMinor,
  required String currencyCode,
  Value<String?> accountSourceId,
  Value<String?> accountDestinationId,
  Value<String?> categoryId,
  Value<String?> subcategoryId,
  Value<String?> payeeId,
  Value<String?> title,
  Value<String?> description,
  required int recurrenceN,
  required String recurrenceUnit,
  Value<String?> recurrenceConstraints,
  required int startDate,
  Value<int?> endDate,
  Value<String> postingBehaviour,
  Value<String?> feeMode,
  Value<int?> feeAmountMinor,
  Value<int?> feePercentageMicro,
  Value<String?> feeCategoryId,
  Value<int?> pauseUntil,
  Value<int?> archivedAt,
  Value<String?> archivedReason,
  Value<bool> isInstallment,
  Value<bool> isDeleted,
  Value<int?> deletedAt,
  required int createdAt,
  required int updatedAt,
  Value<String?> metadata,
  Value<int> rowid,
});
typedef $$RecurringTemplatesTableUpdateCompanionBuilder
    = RecurringTemplatesCompanion Function({
  Value<String> id,
  Value<String> transactionType,
  Value<String> status,
  Value<int> amountMinor,
  Value<String> currencyCode,
  Value<String?> accountSourceId,
  Value<String?> accountDestinationId,
  Value<String?> categoryId,
  Value<String?> subcategoryId,
  Value<String?> payeeId,
  Value<String?> title,
  Value<String?> description,
  Value<int> recurrenceN,
  Value<String> recurrenceUnit,
  Value<String?> recurrenceConstraints,
  Value<int> startDate,
  Value<int?> endDate,
  Value<String> postingBehaviour,
  Value<String?> feeMode,
  Value<int?> feeAmountMinor,
  Value<int?> feePercentageMicro,
  Value<String?> feeCategoryId,
  Value<int?> pauseUntil,
  Value<int?> archivedAt,
  Value<String?> archivedReason,
  Value<bool> isInstallment,
  Value<bool> isDeleted,
  Value<int?> deletedAt,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<String?> metadata,
  Value<int> rowid,
});

final class $$RecurringTemplatesTableReferences extends BaseReferences<
    _$AppDatabase, $RecurringTemplatesTable, RecurringTemplate> {
  $$RecurringTemplatesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $CurrenciesTable _currencyCodeTable(_$AppDatabase db) =>
      db.currencies.createAlias($_aliasNameGenerator(
          db.recurringTemplates.currencyCode, db.currencies.code));

  $$CurrenciesTableProcessedTableManager get currencyCode {
    final $_column = $_itemColumn<String>('currency_code')!;

    final manager = $$CurrenciesTableTableManager($_db, $_db.currencies)
        .filter((f) => f.code.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_currencyCodeTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $AccountsTable _accountSourceIdTable(_$AppDatabase db) =>
      db.accounts.createAlias($_aliasNameGenerator(
          db.recurringTemplates.accountSourceId, db.accounts.id));

  $$AccountsTableProcessedTableManager? get accountSourceId {
    final $_column = $_itemColumn<String>('account_source_id');
    if ($_column == null) return null;
    final manager = $$AccountsTableTableManager($_db, $_db.accounts)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountSourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $AccountsTable _accountDestinationIdTable(_$AppDatabase db) =>
      db.accounts.createAlias($_aliasNameGenerator(
          db.recurringTemplates.accountDestinationId, db.accounts.id));

  $$AccountsTableProcessedTableManager? get accountDestinationId {
    final $_column = $_itemColumn<String>('account_destination_id');
    if ($_column == null) return null;
    final manager = $$AccountsTableTableManager($_db, $_db.accounts)
        .filter((f) => f.id.sqlEquals($_column));
    final item =
        $_typedResult.readTableOrNull(_accountDestinationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias($_aliasNameGenerator(
          db.recurringTemplates.categoryId, db.categories.id));

  $$CategoriesTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<String>('category_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager($_db, $_db.categories)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $CategoriesTable _subcategoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias($_aliasNameGenerator(
          db.recurringTemplates.subcategoryId, db.categories.id));

  $$CategoriesTableProcessedTableManager? get subcategoryId {
    final $_column = $_itemColumn<String>('subcategory_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager($_db, $_db.categories)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_subcategoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $PayeesTable _payeeIdTable(_$AppDatabase db) => db.payees.createAlias(
      $_aliasNameGenerator(db.recurringTemplates.payeeId, db.payees.id));

  $$PayeesTableProcessedTableManager? get payeeId {
    final $_column = $_itemColumn<String>('payee_id');
    if ($_column == null) return null;
    final manager = $$PayeesTableTableManager($_db, $_db.payees)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_payeeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $CategoriesTable _feeCategoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias($_aliasNameGenerator(
          db.recurringTemplates.feeCategoryId, db.categories.id));

  $$CategoriesTableProcessedTableManager? get feeCategoryId {
    final $_column = $_itemColumn<String>('fee_category_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager($_db, $_db.categories)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_feeCategoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$TransactionsTable, List<Transaction>>
      _transactionsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.transactions,
              aliasName: $_aliasNameGenerator(
                  db.recurringTemplates.id, db.transactions.parentTemplateId));

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager($_db, $_db.transactions)
        .filter((f) =>
            f.parentTemplateId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ScheduledOccurrencesTable,
      List<ScheduledOccurrence>> _scheduledOccurrencesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.scheduledOccurrences,
          aliasName: $_aliasNameGenerator(
              db.recurringTemplates.id, db.scheduledOccurrences.templateId));

  $$ScheduledOccurrencesTableProcessedTableManager
      get scheduledOccurrencesRefs {
    final manager = $$ScheduledOccurrencesTableTableManager(
            $_db, $_db.scheduledOccurrences)
        .filter((f) => f.templateId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_scheduledOccurrencesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$InstallmentPlansTable, List<InstallmentPlan>>
      _installmentPlansRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.installmentPlans,
              aliasName: $_aliasNameGenerator(
                  db.recurringTemplates.id, db.installmentPlans.templateId));

  $$InstallmentPlansTableProcessedTableManager get installmentPlansRefs {
    final manager = $$InstallmentPlansTableTableManager(
            $_db, $_db.installmentPlans)
        .filter((f) => f.templateId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_installmentPlansRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$InstallmentOccurrencesTable,
      List<InstallmentOccurrence>> _installmentOccurrencesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.installmentOccurrences,
          aliasName: $_aliasNameGenerator(
              db.recurringTemplates.id, db.installmentOccurrences.templateId));

  $$InstallmentOccurrencesTableProcessedTableManager
      get installmentOccurrencesRefs {
    final manager = $$InstallmentOccurrencesTableTableManager(
            $_db, $_db.installmentOccurrences)
        .filter((f) => f.templateId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_installmentOccurrencesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$RecurringTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $RecurringTemplatesTable> {
  $$RecurringTemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get transactionType => $composableBuilder(
      column: $table.transactionType,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amountMinor => $composableBuilder(
      column: $table.amountMinor, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get recurrenceN => $composableBuilder(
      column: $table.recurrenceN, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recurrenceUnit => $composableBuilder(
      column: $table.recurrenceUnit,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recurrenceConstraints => $composableBuilder(
      column: $table.recurrenceConstraints,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get postingBehaviour => $composableBuilder(
      column: $table.postingBehaviour,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get feeMode => $composableBuilder(
      column: $table.feeMode, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get feeAmountMinor => $composableBuilder(
      column: $table.feeAmountMinor,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get feePercentageMicro => $composableBuilder(
      column: $table.feePercentageMicro,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pauseUntil => $composableBuilder(
      column: $table.pauseUntil, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get archivedAt => $composableBuilder(
      column: $table.archivedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get archivedReason => $composableBuilder(
      column: $table.archivedReason,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isInstallment => $composableBuilder(
      column: $table.isInstallment, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metadata => $composableBuilder(
      column: $table.metadata, builder: (column) => ColumnFilters(column));

  $$CurrenciesTableFilterComposer get currencyCode {
    final $$CurrenciesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.currencyCode,
        referencedTable: $db.currencies,
        getReferencedColumn: (t) => t.code,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CurrenciesTableFilterComposer(
              $db: $db,
              $table: $db.currencies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountsTableFilterComposer get accountSourceId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountSourceId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableFilterComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountsTableFilterComposer get accountDestinationId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountDestinationId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableFilterComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableFilterComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CategoriesTableFilterComposer get subcategoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.subcategoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableFilterComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$PayeesTableFilterComposer get payeeId {
    final $$PayeesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.payeeId,
        referencedTable: $db.payees,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PayeesTableFilterComposer(
              $db: $db,
              $table: $db.payees,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CategoriesTableFilterComposer get feeCategoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.feeCategoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableFilterComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> transactionsRefs(
      Expression<bool> Function($$TransactionsTableFilterComposer f) f) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.parentTemplateId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableFilterComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> scheduledOccurrencesRefs(
      Expression<bool> Function($$ScheduledOccurrencesTableFilterComposer f)
          f) {
    final $$ScheduledOccurrencesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.scheduledOccurrences,
        getReferencedColumn: (t) => t.templateId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ScheduledOccurrencesTableFilterComposer(
              $db: $db,
              $table: $db.scheduledOccurrences,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> installmentPlansRefs(
      Expression<bool> Function($$InstallmentPlansTableFilterComposer f) f) {
    final $$InstallmentPlansTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.installmentPlans,
        getReferencedColumn: (t) => t.templateId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InstallmentPlansTableFilterComposer(
              $db: $db,
              $table: $db.installmentPlans,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> installmentOccurrencesRefs(
      Expression<bool> Function($$InstallmentOccurrencesTableFilterComposer f)
          f) {
    final $$InstallmentOccurrencesTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.installmentOccurrences,
            getReferencedColumn: (t) => t.templateId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$InstallmentOccurrencesTableFilterComposer(
                  $db: $db,
                  $table: $db.installmentOccurrences,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$RecurringTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurringTemplatesTable> {
  $$RecurringTemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get transactionType => $composableBuilder(
      column: $table.transactionType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amountMinor => $composableBuilder(
      column: $table.amountMinor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get recurrenceN => $composableBuilder(
      column: $table.recurrenceN, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recurrenceUnit => $composableBuilder(
      column: $table.recurrenceUnit,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recurrenceConstraints => $composableBuilder(
      column: $table.recurrenceConstraints,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get postingBehaviour => $composableBuilder(
      column: $table.postingBehaviour,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get feeMode => $composableBuilder(
      column: $table.feeMode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get feeAmountMinor => $composableBuilder(
      column: $table.feeAmountMinor,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get feePercentageMicro => $composableBuilder(
      column: $table.feePercentageMicro,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pauseUntil => $composableBuilder(
      column: $table.pauseUntil, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get archivedAt => $composableBuilder(
      column: $table.archivedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get archivedReason => $composableBuilder(
      column: $table.archivedReason,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isInstallment => $composableBuilder(
      column: $table.isInstallment,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metadata => $composableBuilder(
      column: $table.metadata, builder: (column) => ColumnOrderings(column));

  $$CurrenciesTableOrderingComposer get currencyCode {
    final $$CurrenciesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.currencyCode,
        referencedTable: $db.currencies,
        getReferencedColumn: (t) => t.code,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CurrenciesTableOrderingComposer(
              $db: $db,
              $table: $db.currencies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountsTableOrderingComposer get accountSourceId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountSourceId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableOrderingComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountsTableOrderingComposer get accountDestinationId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountDestinationId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableOrderingComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CategoriesTableOrderingComposer get subcategoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.subcategoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$PayeesTableOrderingComposer get payeeId {
    final $$PayeesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.payeeId,
        referencedTable: $db.payees,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PayeesTableOrderingComposer(
              $db: $db,
              $table: $db.payees,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CategoriesTableOrderingComposer get feeCategoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.feeCategoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RecurringTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurringTemplatesTable> {
  $$RecurringTemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get transactionType => $composableBuilder(
      column: $table.transactionType, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
      column: $table.amountMinor, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<int> get recurrenceN => $composableBuilder(
      column: $table.recurrenceN, builder: (column) => column);

  GeneratedColumn<String> get recurrenceUnit => $composableBuilder(
      column: $table.recurrenceUnit, builder: (column) => column);

  GeneratedColumn<String> get recurrenceConstraints => $composableBuilder(
      column: $table.recurrenceConstraints, builder: (column) => column);

  GeneratedColumn<int> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<int> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get postingBehaviour => $composableBuilder(
      column: $table.postingBehaviour, builder: (column) => column);

  GeneratedColumn<String> get feeMode =>
      $composableBuilder(column: $table.feeMode, builder: (column) => column);

  GeneratedColumn<int> get feeAmountMinor => $composableBuilder(
      column: $table.feeAmountMinor, builder: (column) => column);

  GeneratedColumn<int> get feePercentageMicro => $composableBuilder(
      column: $table.feePercentageMicro, builder: (column) => column);

  GeneratedColumn<int> get pauseUntil => $composableBuilder(
      column: $table.pauseUntil, builder: (column) => column);

  GeneratedColumn<int> get archivedAt => $composableBuilder(
      column: $table.archivedAt, builder: (column) => column);

  GeneratedColumn<String> get archivedReason => $composableBuilder(
      column: $table.archivedReason, builder: (column) => column);

  GeneratedColumn<bool> get isInstallment => $composableBuilder(
      column: $table.isInstallment, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);

  $$CurrenciesTableAnnotationComposer get currencyCode {
    final $$CurrenciesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.currencyCode,
        referencedTable: $db.currencies,
        getReferencedColumn: (t) => t.code,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CurrenciesTableAnnotationComposer(
              $db: $db,
              $table: $db.currencies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountsTableAnnotationComposer get accountSourceId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountSourceId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableAnnotationComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountsTableAnnotationComposer get accountDestinationId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountDestinationId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableAnnotationComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CategoriesTableAnnotationComposer get subcategoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.subcategoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$PayeesTableAnnotationComposer get payeeId {
    final $$PayeesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.payeeId,
        referencedTable: $db.payees,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PayeesTableAnnotationComposer(
              $db: $db,
              $table: $db.payees,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CategoriesTableAnnotationComposer get feeCategoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.feeCategoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> transactionsRefs<T extends Object>(
      Expression<T> Function($$TransactionsTableAnnotationComposer a) f) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.parentTemplateId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableAnnotationComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> scheduledOccurrencesRefs<T extends Object>(
      Expression<T> Function($$ScheduledOccurrencesTableAnnotationComposer a)
          f) {
    final $$ScheduledOccurrencesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.scheduledOccurrences,
            getReferencedColumn: (t) => t.templateId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ScheduledOccurrencesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.scheduledOccurrences,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> installmentPlansRefs<T extends Object>(
      Expression<T> Function($$InstallmentPlansTableAnnotationComposer a) f) {
    final $$InstallmentPlansTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.installmentPlans,
        getReferencedColumn: (t) => t.templateId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InstallmentPlansTableAnnotationComposer(
              $db: $db,
              $table: $db.installmentPlans,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> installmentOccurrencesRefs<T extends Object>(
      Expression<T> Function($$InstallmentOccurrencesTableAnnotationComposer a)
          f) {
    final $$InstallmentOccurrencesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.installmentOccurrences,
            getReferencedColumn: (t) => t.templateId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$InstallmentOccurrencesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.installmentOccurrences,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$RecurringTemplatesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RecurringTemplatesTable,
    RecurringTemplate,
    $$RecurringTemplatesTableFilterComposer,
    $$RecurringTemplatesTableOrderingComposer,
    $$RecurringTemplatesTableAnnotationComposer,
    $$RecurringTemplatesTableCreateCompanionBuilder,
    $$RecurringTemplatesTableUpdateCompanionBuilder,
    (RecurringTemplate, $$RecurringTemplatesTableReferences),
    RecurringTemplate,
    PrefetchHooks Function(
        {bool currencyCode,
        bool accountSourceId,
        bool accountDestinationId,
        bool categoryId,
        bool subcategoryId,
        bool payeeId,
        bool feeCategoryId,
        bool transactionsRefs,
        bool scheduledOccurrencesRefs,
        bool installmentPlansRefs,
        bool installmentOccurrencesRefs})> {
  $$RecurringTemplatesTableTableManager(
      _$AppDatabase db, $RecurringTemplatesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringTemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecurringTemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecurringTemplatesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> transactionType = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> amountMinor = const Value.absent(),
            Value<String> currencyCode = const Value.absent(),
            Value<String?> accountSourceId = const Value.absent(),
            Value<String?> accountDestinationId = const Value.absent(),
            Value<String?> categoryId = const Value.absent(),
            Value<String?> subcategoryId = const Value.absent(),
            Value<String?> payeeId = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<int> recurrenceN = const Value.absent(),
            Value<String> recurrenceUnit = const Value.absent(),
            Value<String?> recurrenceConstraints = const Value.absent(),
            Value<int> startDate = const Value.absent(),
            Value<int?> endDate = const Value.absent(),
            Value<String> postingBehaviour = const Value.absent(),
            Value<String?> feeMode = const Value.absent(),
            Value<int?> feeAmountMinor = const Value.absent(),
            Value<int?> feePercentageMicro = const Value.absent(),
            Value<String?> feeCategoryId = const Value.absent(),
            Value<int?> pauseUntil = const Value.absent(),
            Value<int?> archivedAt = const Value.absent(),
            Value<String?> archivedReason = const Value.absent(),
            Value<bool> isInstallment = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int?> deletedAt = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<String?> metadata = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RecurringTemplatesCompanion(
            id: id,
            transactionType: transactionType,
            status: status,
            amountMinor: amountMinor,
            currencyCode: currencyCode,
            accountSourceId: accountSourceId,
            accountDestinationId: accountDestinationId,
            categoryId: categoryId,
            subcategoryId: subcategoryId,
            payeeId: payeeId,
            title: title,
            description: description,
            recurrenceN: recurrenceN,
            recurrenceUnit: recurrenceUnit,
            recurrenceConstraints: recurrenceConstraints,
            startDate: startDate,
            endDate: endDate,
            postingBehaviour: postingBehaviour,
            feeMode: feeMode,
            feeAmountMinor: feeAmountMinor,
            feePercentageMicro: feePercentageMicro,
            feeCategoryId: feeCategoryId,
            pauseUntil: pauseUntil,
            archivedAt: archivedAt,
            archivedReason: archivedReason,
            isInstallment: isInstallment,
            isDeleted: isDeleted,
            deletedAt: deletedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            metadata: metadata,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String transactionType,
            Value<String> status = const Value.absent(),
            required int amountMinor,
            required String currencyCode,
            Value<String?> accountSourceId = const Value.absent(),
            Value<String?> accountDestinationId = const Value.absent(),
            Value<String?> categoryId = const Value.absent(),
            Value<String?> subcategoryId = const Value.absent(),
            Value<String?> payeeId = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            required int recurrenceN,
            required String recurrenceUnit,
            Value<String?> recurrenceConstraints = const Value.absent(),
            required int startDate,
            Value<int?> endDate = const Value.absent(),
            Value<String> postingBehaviour = const Value.absent(),
            Value<String?> feeMode = const Value.absent(),
            Value<int?> feeAmountMinor = const Value.absent(),
            Value<int?> feePercentageMicro = const Value.absent(),
            Value<String?> feeCategoryId = const Value.absent(),
            Value<int?> pauseUntil = const Value.absent(),
            Value<int?> archivedAt = const Value.absent(),
            Value<String?> archivedReason = const Value.absent(),
            Value<bool> isInstallment = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int?> deletedAt = const Value.absent(),
            required int createdAt,
            required int updatedAt,
            Value<String?> metadata = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RecurringTemplatesCompanion.insert(
            id: id,
            transactionType: transactionType,
            status: status,
            amountMinor: amountMinor,
            currencyCode: currencyCode,
            accountSourceId: accountSourceId,
            accountDestinationId: accountDestinationId,
            categoryId: categoryId,
            subcategoryId: subcategoryId,
            payeeId: payeeId,
            title: title,
            description: description,
            recurrenceN: recurrenceN,
            recurrenceUnit: recurrenceUnit,
            recurrenceConstraints: recurrenceConstraints,
            startDate: startDate,
            endDate: endDate,
            postingBehaviour: postingBehaviour,
            feeMode: feeMode,
            feeAmountMinor: feeAmountMinor,
            feePercentageMicro: feePercentageMicro,
            feeCategoryId: feeCategoryId,
            pauseUntil: pauseUntil,
            archivedAt: archivedAt,
            archivedReason: archivedReason,
            isInstallment: isInstallment,
            isDeleted: isDeleted,
            deletedAt: deletedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            metadata: metadata,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$RecurringTemplatesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {currencyCode = false,
              accountSourceId = false,
              accountDestinationId = false,
              categoryId = false,
              subcategoryId = false,
              payeeId = false,
              feeCategoryId = false,
              transactionsRefs = false,
              scheduledOccurrencesRefs = false,
              installmentPlansRefs = false,
              installmentOccurrencesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (transactionsRefs) db.transactions,
                if (scheduledOccurrencesRefs) db.scheduledOccurrences,
                if (installmentPlansRefs) db.installmentPlans,
                if (installmentOccurrencesRefs) db.installmentOccurrences
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (currencyCode) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.currencyCode,
                    referencedTable: $$RecurringTemplatesTableReferences
                        ._currencyCodeTable(db),
                    referencedColumn: $$RecurringTemplatesTableReferences
                        ._currencyCodeTable(db)
                        .code,
                  ) as T;
                }
                if (accountSourceId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.accountSourceId,
                    referencedTable: $$RecurringTemplatesTableReferences
                        ._accountSourceIdTable(db),
                    referencedColumn: $$RecurringTemplatesTableReferences
                        ._accountSourceIdTable(db)
                        .id,
                  ) as T;
                }
                if (accountDestinationId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.accountDestinationId,
                    referencedTable: $$RecurringTemplatesTableReferences
                        ._accountDestinationIdTable(db),
                    referencedColumn: $$RecurringTemplatesTableReferences
                        ._accountDestinationIdTable(db)
                        .id,
                  ) as T;
                }
                if (categoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoryId,
                    referencedTable: $$RecurringTemplatesTableReferences
                        ._categoryIdTable(db),
                    referencedColumn: $$RecurringTemplatesTableReferences
                        ._categoryIdTable(db)
                        .id,
                  ) as T;
                }
                if (subcategoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.subcategoryId,
                    referencedTable: $$RecurringTemplatesTableReferences
                        ._subcategoryIdTable(db),
                    referencedColumn: $$RecurringTemplatesTableReferences
                        ._subcategoryIdTable(db)
                        .id,
                  ) as T;
                }
                if (payeeId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.payeeId,
                    referencedTable:
                        $$RecurringTemplatesTableReferences._payeeIdTable(db),
                    referencedColumn: $$RecurringTemplatesTableReferences
                        ._payeeIdTable(db)
                        .id,
                  ) as T;
                }
                if (feeCategoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.feeCategoryId,
                    referencedTable: $$RecurringTemplatesTableReferences
                        ._feeCategoryIdTable(db),
                    referencedColumn: $$RecurringTemplatesTableReferences
                        ._feeCategoryIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (transactionsRefs)
                    await $_getPrefetchedData<RecurringTemplate,
                            $RecurringTemplatesTable, Transaction>(
                        currentTable: table,
                        referencedTable: $$RecurringTemplatesTableReferences
                            ._transactionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$RecurringTemplatesTableReferences(db, table, p0)
                                .transactionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.parentTemplateId == item.id),
                        typedResults: items),
                  if (scheduledOccurrencesRefs)
                    await $_getPrefetchedData<RecurringTemplate,
                            $RecurringTemplatesTable, ScheduledOccurrence>(
                        currentTable: table,
                        referencedTable: $$RecurringTemplatesTableReferences
                            ._scheduledOccurrencesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$RecurringTemplatesTableReferences(db, table, p0)
                                .scheduledOccurrencesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.templateId == item.id),
                        typedResults: items),
                  if (installmentPlansRefs)
                    await $_getPrefetchedData<RecurringTemplate,
                            $RecurringTemplatesTable, InstallmentPlan>(
                        currentTable: table,
                        referencedTable: $$RecurringTemplatesTableReferences
                            ._installmentPlansRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$RecurringTemplatesTableReferences(db, table, p0)
                                .installmentPlansRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.templateId == item.id),
                        typedResults: items),
                  if (installmentOccurrencesRefs)
                    await $_getPrefetchedData<RecurringTemplate,
                            $RecurringTemplatesTable, InstallmentOccurrence>(
                        currentTable: table,
                        referencedTable: $$RecurringTemplatesTableReferences
                            ._installmentOccurrencesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$RecurringTemplatesTableReferences(db, table, p0)
                                .installmentOccurrencesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.templateId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$RecurringTemplatesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RecurringTemplatesTable,
    RecurringTemplate,
    $$RecurringTemplatesTableFilterComposer,
    $$RecurringTemplatesTableOrderingComposer,
    $$RecurringTemplatesTableAnnotationComposer,
    $$RecurringTemplatesTableCreateCompanionBuilder,
    $$RecurringTemplatesTableUpdateCompanionBuilder,
    (RecurringTemplate, $$RecurringTemplatesTableReferences),
    RecurringTemplate,
    PrefetchHooks Function(
        {bool currencyCode,
        bool accountSourceId,
        bool accountDestinationId,
        bool categoryId,
        bool subcategoryId,
        bool payeeId,
        bool feeCategoryId,
        bool transactionsRefs,
        bool scheduledOccurrencesRefs,
        bool installmentPlansRefs,
        bool installmentOccurrencesRefs})>;
typedef $$TransactionsTableCreateCompanionBuilder = TransactionsCompanion
    Function({
  required String id,
  required String type,
  Value<String> status,
  Value<String> purpose,
  required int transactionDate,
  required int amountMinor,
  required String currencyCode,
  Value<int?> exchangeRateMicro,
  Value<String?> homeCurrencyAtCapture,
  Value<String?> accountSourceId,
  Value<String?> accountDestinationId,
  Value<String?> categoryId,
  Value<String?> subcategoryId,
  Value<String?> payeeId,
  Value<String?> title,
  Value<String?> description,
  Value<String?> compoundGroupId,
  Value<String?> compoundRole,
  Value<String?> parentTemplateId,
  Value<String?> correctsTransactionId,
  Value<bool> isManuallyHandled,
  required int createdAt,
  required int updatedAt,
  Value<String?> metadata,
  Value<int> rowid,
});
typedef $$TransactionsTableUpdateCompanionBuilder = TransactionsCompanion
    Function({
  Value<String> id,
  Value<String> type,
  Value<String> status,
  Value<String> purpose,
  Value<int> transactionDate,
  Value<int> amountMinor,
  Value<String> currencyCode,
  Value<int?> exchangeRateMicro,
  Value<String?> homeCurrencyAtCapture,
  Value<String?> accountSourceId,
  Value<String?> accountDestinationId,
  Value<String?> categoryId,
  Value<String?> subcategoryId,
  Value<String?> payeeId,
  Value<String?> title,
  Value<String?> description,
  Value<String?> compoundGroupId,
  Value<String?> compoundRole,
  Value<String?> parentTemplateId,
  Value<String?> correctsTransactionId,
  Value<bool> isManuallyHandled,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<String?> metadata,
  Value<int> rowid,
});

final class $$TransactionsTableReferences
    extends BaseReferences<_$AppDatabase, $TransactionsTable, Transaction> {
  $$TransactionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CurrenciesTable _currencyCodeTable(_$AppDatabase db) =>
      db.currencies.createAlias($_aliasNameGenerator(
          db.transactions.currencyCode, db.currencies.code));

  $$CurrenciesTableProcessedTableManager get currencyCode {
    final $_column = $_itemColumn<String>('currency_code')!;

    final manager = $$CurrenciesTableTableManager($_db, $_db.currencies)
        .filter((f) => f.code.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_currencyCodeTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $CurrenciesTable _homeCurrencyAtCaptureTable(_$AppDatabase db) =>
      db.currencies.createAlias($_aliasNameGenerator(
          db.transactions.homeCurrencyAtCapture, db.currencies.code));

  $$CurrenciesTableProcessedTableManager? get homeCurrencyAtCapture {
    final $_column = $_itemColumn<String>('home_currency_at_capture');
    if ($_column == null) return null;
    final manager = $$CurrenciesTableTableManager($_db, $_db.currencies)
        .filter((f) => f.code.sqlEquals($_column));
    final item =
        $_typedResult.readTableOrNull(_homeCurrencyAtCaptureTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $AccountsTable _accountSourceIdTable(_$AppDatabase db) =>
      db.accounts.createAlias($_aliasNameGenerator(
          db.transactions.accountSourceId, db.accounts.id));

  $$AccountsTableProcessedTableManager? get accountSourceId {
    final $_column = $_itemColumn<String>('account_source_id');
    if ($_column == null) return null;
    final manager = $$AccountsTableTableManager($_db, $_db.accounts)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountSourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $AccountsTable _accountDestinationIdTable(_$AppDatabase db) =>
      db.accounts.createAlias($_aliasNameGenerator(
          db.transactions.accountDestinationId, db.accounts.id));

  $$AccountsTableProcessedTableManager? get accountDestinationId {
    final $_column = $_itemColumn<String>('account_destination_id');
    if ($_column == null) return null;
    final manager = $$AccountsTableTableManager($_db, $_db.accounts)
        .filter((f) => f.id.sqlEquals($_column));
    final item =
        $_typedResult.readTableOrNull(_accountDestinationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias(
          $_aliasNameGenerator(db.transactions.categoryId, db.categories.id));

  $$CategoriesTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<String>('category_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager($_db, $_db.categories)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $CategoriesTable _subcategoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias($_aliasNameGenerator(
          db.transactions.subcategoryId, db.categories.id));

  $$CategoriesTableProcessedTableManager? get subcategoryId {
    final $_column = $_itemColumn<String>('subcategory_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager($_db, $_db.categories)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_subcategoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $PayeesTable _payeeIdTable(_$AppDatabase db) => db.payees
      .createAlias($_aliasNameGenerator(db.transactions.payeeId, db.payees.id));

  $$PayeesTableProcessedTableManager? get payeeId {
    final $_column = $_itemColumn<String>('payee_id');
    if ($_column == null) return null;
    final manager = $$PayeesTableTableManager($_db, $_db.payees)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_payeeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $RecurringTemplatesTable _parentTemplateIdTable(_$AppDatabase db) =>
      db.recurringTemplates.createAlias($_aliasNameGenerator(
          db.transactions.parentTemplateId, db.recurringTemplates.id));

  $$RecurringTemplatesTableProcessedTableManager? get parentTemplateId {
    final $_column = $_itemColumn<String>('parent_template_id');
    if ($_column == null) return null;
    final manager =
        $$RecurringTemplatesTableTableManager($_db, $_db.recurringTemplates)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parentTemplateIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $TransactionsTable _correctsTransactionIdTable(_$AppDatabase db) =>
      db.transactions.createAlias($_aliasNameGenerator(
          db.transactions.correctsTransactionId, db.transactions.id));

  $$TransactionsTableProcessedTableManager? get correctsTransactionId {
    final $_column = $_itemColumn<String>('corrects_transaction_id');
    if ($_column == null) return null;
    final manager = $$TransactionsTableTableManager($_db, $_db.transactions)
        .filter((f) => f.id.sqlEquals($_column));
    final item =
        $_typedResult.readTableOrNull(_correctsTransactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$EntriesTable, List<Entry>> _entriesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.entries,
          aliasName: $_aliasNameGenerator(
              db.transactions.id, db.entries.transactionId));

  $$EntriesTableProcessedTableManager get entriesRefs {
    final manager = $$EntriesTableTableManager($_db, $_db.entries).filter(
        (f) => f.transactionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_entriesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$TransactionTagsTable, List<TransactionTag>>
      _transactionTagsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.transactionTags,
              aliasName: $_aliasNameGenerator(
                  db.transactions.id, db.transactionTags.transactionId));

  $$TransactionTagsTableProcessedTableManager get transactionTagsRefs {
    final manager =
        $$TransactionTagsTableTableManager($_db, $_db.transactionTags).filter(
            (f) => f.transactionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_transactionTagsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$AttachmentsTable, List<Attachment>>
      _attachmentsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.attachments,
              aliasName: $_aliasNameGenerator(
                  db.transactions.id, db.attachments.transactionId));

  $$AttachmentsTableProcessedTableManager get attachmentsRefs {
    final manager = $$AttachmentsTableTableManager($_db, $_db.attachments)
        .filter(
            (f) => f.transactionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_attachmentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ScheduledOccurrencesTable,
      List<ScheduledOccurrence>> _scheduledOccurrencesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.scheduledOccurrences,
          aliasName: $_aliasNameGenerator(
              db.transactions.id, db.scheduledOccurrences.childTransactionId));

  $$ScheduledOccurrencesTableProcessedTableManager
      get scheduledOccurrencesRefs {
    final manager =
        $$ScheduledOccurrencesTableTableManager($_db, $_db.scheduledOccurrences)
            .filter((f) =>
                f.childTransactionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_scheduledOccurrencesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$InstallmentOccurrencesTable,
      List<InstallmentOccurrence>> _installmentOccurrencesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.installmentOccurrences,
          aliasName: $_aliasNameGenerator(db.transactions.id,
              db.installmentOccurrences.childTransactionId));

  $$InstallmentOccurrencesTableProcessedTableManager
      get installmentOccurrencesRefs {
    final manager = $$InstallmentOccurrencesTableTableManager(
            $_db, $_db.installmentOccurrences)
        .filter((f) =>
            f.childTransactionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_installmentOccurrencesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

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

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get purpose => $composableBuilder(
      column: $table.purpose, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get transactionDate => $composableBuilder(
      column: $table.transactionDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amountMinor => $composableBuilder(
      column: $table.amountMinor, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get exchangeRateMicro => $composableBuilder(
      column: $table.exchangeRateMicro,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get compoundGroupId => $composableBuilder(
      column: $table.compoundGroupId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get compoundRole => $composableBuilder(
      column: $table.compoundRole, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isManuallyHandled => $composableBuilder(
      column: $table.isManuallyHandled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metadata => $composableBuilder(
      column: $table.metadata, builder: (column) => ColumnFilters(column));

  $$CurrenciesTableFilterComposer get currencyCode {
    final $$CurrenciesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.currencyCode,
        referencedTable: $db.currencies,
        getReferencedColumn: (t) => t.code,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CurrenciesTableFilterComposer(
              $db: $db,
              $table: $db.currencies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CurrenciesTableFilterComposer get homeCurrencyAtCapture {
    final $$CurrenciesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.homeCurrencyAtCapture,
        referencedTable: $db.currencies,
        getReferencedColumn: (t) => t.code,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CurrenciesTableFilterComposer(
              $db: $db,
              $table: $db.currencies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountsTableFilterComposer get accountSourceId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountSourceId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableFilterComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountsTableFilterComposer get accountDestinationId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountDestinationId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableFilterComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableFilterComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CategoriesTableFilterComposer get subcategoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.subcategoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableFilterComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$PayeesTableFilterComposer get payeeId {
    final $$PayeesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.payeeId,
        referencedTable: $db.payees,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PayeesTableFilterComposer(
              $db: $db,
              $table: $db.payees,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$RecurringTemplatesTableFilterComposer get parentTemplateId {
    final $$RecurringTemplatesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.parentTemplateId,
        referencedTable: $db.recurringTemplates,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecurringTemplatesTableFilterComposer(
              $db: $db,
              $table: $db.recurringTemplates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TransactionsTableFilterComposer get correctsTransactionId {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.correctsTransactionId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableFilterComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> entriesRefs(
      Expression<bool> Function($$EntriesTableFilterComposer f) f) {
    final $$EntriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.entries,
        getReferencedColumn: (t) => t.transactionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EntriesTableFilterComposer(
              $db: $db,
              $table: $db.entries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> transactionTagsRefs(
      Expression<bool> Function($$TransactionTagsTableFilterComposer f) f) {
    final $$TransactionTagsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.transactionTags,
        getReferencedColumn: (t) => t.transactionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionTagsTableFilterComposer(
              $db: $db,
              $table: $db.transactionTags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> attachmentsRefs(
      Expression<bool> Function($$AttachmentsTableFilterComposer f) f) {
    final $$AttachmentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.attachments,
        getReferencedColumn: (t) => t.transactionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AttachmentsTableFilterComposer(
              $db: $db,
              $table: $db.attachments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> scheduledOccurrencesRefs(
      Expression<bool> Function($$ScheduledOccurrencesTableFilterComposer f)
          f) {
    final $$ScheduledOccurrencesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.scheduledOccurrences,
        getReferencedColumn: (t) => t.childTransactionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ScheduledOccurrencesTableFilterComposer(
              $db: $db,
              $table: $db.scheduledOccurrences,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> installmentOccurrencesRefs(
      Expression<bool> Function($$InstallmentOccurrencesTableFilterComposer f)
          f) {
    final $$InstallmentOccurrencesTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.installmentOccurrences,
            getReferencedColumn: (t) => t.childTransactionId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$InstallmentOccurrencesTableFilterComposer(
                  $db: $db,
                  $table: $db.installmentOccurrences,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
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

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get purpose => $composableBuilder(
      column: $table.purpose, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get transactionDate => $composableBuilder(
      column: $table.transactionDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amountMinor => $composableBuilder(
      column: $table.amountMinor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get exchangeRateMicro => $composableBuilder(
      column: $table.exchangeRateMicro,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get compoundGroupId => $composableBuilder(
      column: $table.compoundGroupId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get compoundRole => $composableBuilder(
      column: $table.compoundRole,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isManuallyHandled => $composableBuilder(
      column: $table.isManuallyHandled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metadata => $composableBuilder(
      column: $table.metadata, builder: (column) => ColumnOrderings(column));

  $$CurrenciesTableOrderingComposer get currencyCode {
    final $$CurrenciesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.currencyCode,
        referencedTable: $db.currencies,
        getReferencedColumn: (t) => t.code,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CurrenciesTableOrderingComposer(
              $db: $db,
              $table: $db.currencies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CurrenciesTableOrderingComposer get homeCurrencyAtCapture {
    final $$CurrenciesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.homeCurrencyAtCapture,
        referencedTable: $db.currencies,
        getReferencedColumn: (t) => t.code,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CurrenciesTableOrderingComposer(
              $db: $db,
              $table: $db.currencies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountsTableOrderingComposer get accountSourceId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountSourceId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableOrderingComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountsTableOrderingComposer get accountDestinationId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountDestinationId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableOrderingComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CategoriesTableOrderingComposer get subcategoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.subcategoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$PayeesTableOrderingComposer get payeeId {
    final $$PayeesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.payeeId,
        referencedTable: $db.payees,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PayeesTableOrderingComposer(
              $db: $db,
              $table: $db.payees,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$RecurringTemplatesTableOrderingComposer get parentTemplateId {
    final $$RecurringTemplatesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.parentTemplateId,
        referencedTable: $db.recurringTemplates,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecurringTemplatesTableOrderingComposer(
              $db: $db,
              $table: $db.recurringTemplates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TransactionsTableOrderingComposer get correctsTransactionId {
    final $$TransactionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.correctsTransactionId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableOrderingComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
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

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get purpose =>
      $composableBuilder(column: $table.purpose, builder: (column) => column);

  GeneratedColumn<int> get transactionDate => $composableBuilder(
      column: $table.transactionDate, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
      column: $table.amountMinor, builder: (column) => column);

  GeneratedColumn<int> get exchangeRateMicro => $composableBuilder(
      column: $table.exchangeRateMicro, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get compoundGroupId => $composableBuilder(
      column: $table.compoundGroupId, builder: (column) => column);

  GeneratedColumn<String> get compoundRole => $composableBuilder(
      column: $table.compoundRole, builder: (column) => column);

  GeneratedColumn<bool> get isManuallyHandled => $composableBuilder(
      column: $table.isManuallyHandled, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);

  $$CurrenciesTableAnnotationComposer get currencyCode {
    final $$CurrenciesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.currencyCode,
        referencedTable: $db.currencies,
        getReferencedColumn: (t) => t.code,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CurrenciesTableAnnotationComposer(
              $db: $db,
              $table: $db.currencies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CurrenciesTableAnnotationComposer get homeCurrencyAtCapture {
    final $$CurrenciesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.homeCurrencyAtCapture,
        referencedTable: $db.currencies,
        getReferencedColumn: (t) => t.code,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CurrenciesTableAnnotationComposer(
              $db: $db,
              $table: $db.currencies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountsTableAnnotationComposer get accountSourceId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountSourceId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableAnnotationComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountsTableAnnotationComposer get accountDestinationId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountDestinationId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableAnnotationComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CategoriesTableAnnotationComposer get subcategoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.subcategoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$PayeesTableAnnotationComposer get payeeId {
    final $$PayeesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.payeeId,
        referencedTable: $db.payees,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PayeesTableAnnotationComposer(
              $db: $db,
              $table: $db.payees,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$RecurringTemplatesTableAnnotationComposer get parentTemplateId {
    final $$RecurringTemplatesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.parentTemplateId,
            referencedTable: $db.recurringTemplates,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$RecurringTemplatesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.recurringTemplates,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  $$TransactionsTableAnnotationComposer get correctsTransactionId {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.correctsTransactionId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableAnnotationComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> entriesRefs<T extends Object>(
      Expression<T> Function($$EntriesTableAnnotationComposer a) f) {
    final $$EntriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.entries,
        getReferencedColumn: (t) => t.transactionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EntriesTableAnnotationComposer(
              $db: $db,
              $table: $db.entries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> transactionTagsRefs<T extends Object>(
      Expression<T> Function($$TransactionTagsTableAnnotationComposer a) f) {
    final $$TransactionTagsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.transactionTags,
        getReferencedColumn: (t) => t.transactionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionTagsTableAnnotationComposer(
              $db: $db,
              $table: $db.transactionTags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> attachmentsRefs<T extends Object>(
      Expression<T> Function($$AttachmentsTableAnnotationComposer a) f) {
    final $$AttachmentsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.attachments,
        getReferencedColumn: (t) => t.transactionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AttachmentsTableAnnotationComposer(
              $db: $db,
              $table: $db.attachments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> scheduledOccurrencesRefs<T extends Object>(
      Expression<T> Function($$ScheduledOccurrencesTableAnnotationComposer a)
          f) {
    final $$ScheduledOccurrencesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.scheduledOccurrences,
            getReferencedColumn: (t) => t.childTransactionId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ScheduledOccurrencesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.scheduledOccurrences,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> installmentOccurrencesRefs<T extends Object>(
      Expression<T> Function($$InstallmentOccurrencesTableAnnotationComposer a)
          f) {
    final $$InstallmentOccurrencesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.installmentOccurrences,
            getReferencedColumn: (t) => t.childTransactionId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$InstallmentOccurrencesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.installmentOccurrences,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$TransactionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TransactionsTable,
    Transaction,
    $$TransactionsTableFilterComposer,
    $$TransactionsTableOrderingComposer,
    $$TransactionsTableAnnotationComposer,
    $$TransactionsTableCreateCompanionBuilder,
    $$TransactionsTableUpdateCompanionBuilder,
    (Transaction, $$TransactionsTableReferences),
    Transaction,
    PrefetchHooks Function(
        {bool currencyCode,
        bool homeCurrencyAtCapture,
        bool accountSourceId,
        bool accountDestinationId,
        bool categoryId,
        bool subcategoryId,
        bool payeeId,
        bool parentTemplateId,
        bool correctsTransactionId,
        bool entriesRefs,
        bool transactionTagsRefs,
        bool attachmentsRefs,
        bool scheduledOccurrencesRefs,
        bool installmentOccurrencesRefs})> {
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
            Value<String> type = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> purpose = const Value.absent(),
            Value<int> transactionDate = const Value.absent(),
            Value<int> amountMinor = const Value.absent(),
            Value<String> currencyCode = const Value.absent(),
            Value<int?> exchangeRateMicro = const Value.absent(),
            Value<String?> homeCurrencyAtCapture = const Value.absent(),
            Value<String?> accountSourceId = const Value.absent(),
            Value<String?> accountDestinationId = const Value.absent(),
            Value<String?> categoryId = const Value.absent(),
            Value<String?> subcategoryId = const Value.absent(),
            Value<String?> payeeId = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> compoundGroupId = const Value.absent(),
            Value<String?> compoundRole = const Value.absent(),
            Value<String?> parentTemplateId = const Value.absent(),
            Value<String?> correctsTransactionId = const Value.absent(),
            Value<bool> isManuallyHandled = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<String?> metadata = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TransactionsCompanion(
            id: id,
            type: type,
            status: status,
            purpose: purpose,
            transactionDate: transactionDate,
            amountMinor: amountMinor,
            currencyCode: currencyCode,
            exchangeRateMicro: exchangeRateMicro,
            homeCurrencyAtCapture: homeCurrencyAtCapture,
            accountSourceId: accountSourceId,
            accountDestinationId: accountDestinationId,
            categoryId: categoryId,
            subcategoryId: subcategoryId,
            payeeId: payeeId,
            title: title,
            description: description,
            compoundGroupId: compoundGroupId,
            compoundRole: compoundRole,
            parentTemplateId: parentTemplateId,
            correctsTransactionId: correctsTransactionId,
            isManuallyHandled: isManuallyHandled,
            createdAt: createdAt,
            updatedAt: updatedAt,
            metadata: metadata,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String type,
            Value<String> status = const Value.absent(),
            Value<String> purpose = const Value.absent(),
            required int transactionDate,
            required int amountMinor,
            required String currencyCode,
            Value<int?> exchangeRateMicro = const Value.absent(),
            Value<String?> homeCurrencyAtCapture = const Value.absent(),
            Value<String?> accountSourceId = const Value.absent(),
            Value<String?> accountDestinationId = const Value.absent(),
            Value<String?> categoryId = const Value.absent(),
            Value<String?> subcategoryId = const Value.absent(),
            Value<String?> payeeId = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> compoundGroupId = const Value.absent(),
            Value<String?> compoundRole = const Value.absent(),
            Value<String?> parentTemplateId = const Value.absent(),
            Value<String?> correctsTransactionId = const Value.absent(),
            Value<bool> isManuallyHandled = const Value.absent(),
            required int createdAt,
            required int updatedAt,
            Value<String?> metadata = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TransactionsCompanion.insert(
            id: id,
            type: type,
            status: status,
            purpose: purpose,
            transactionDate: transactionDate,
            amountMinor: amountMinor,
            currencyCode: currencyCode,
            exchangeRateMicro: exchangeRateMicro,
            homeCurrencyAtCapture: homeCurrencyAtCapture,
            accountSourceId: accountSourceId,
            accountDestinationId: accountDestinationId,
            categoryId: categoryId,
            subcategoryId: subcategoryId,
            payeeId: payeeId,
            title: title,
            description: description,
            compoundGroupId: compoundGroupId,
            compoundRole: compoundRole,
            parentTemplateId: parentTemplateId,
            correctsTransactionId: correctsTransactionId,
            isManuallyHandled: isManuallyHandled,
            createdAt: createdAt,
            updatedAt: updatedAt,
            metadata: metadata,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TransactionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {currencyCode = false,
              homeCurrencyAtCapture = false,
              accountSourceId = false,
              accountDestinationId = false,
              categoryId = false,
              subcategoryId = false,
              payeeId = false,
              parentTemplateId = false,
              correctsTransactionId = false,
              entriesRefs = false,
              transactionTagsRefs = false,
              attachmentsRefs = false,
              scheduledOccurrencesRefs = false,
              installmentOccurrencesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (entriesRefs) db.entries,
                if (transactionTagsRefs) db.transactionTags,
                if (attachmentsRefs) db.attachments,
                if (scheduledOccurrencesRefs) db.scheduledOccurrences,
                if (installmentOccurrencesRefs) db.installmentOccurrences
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (currencyCode) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.currencyCode,
                    referencedTable:
                        $$TransactionsTableReferences._currencyCodeTable(db),
                    referencedColumn: $$TransactionsTableReferences
                        ._currencyCodeTable(db)
                        .code,
                  ) as T;
                }
                if (homeCurrencyAtCapture) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.homeCurrencyAtCapture,
                    referencedTable: $$TransactionsTableReferences
                        ._homeCurrencyAtCaptureTable(db),
                    referencedColumn: $$TransactionsTableReferences
                        ._homeCurrencyAtCaptureTable(db)
                        .code,
                  ) as T;
                }
                if (accountSourceId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.accountSourceId,
                    referencedTable:
                        $$TransactionsTableReferences._accountSourceIdTable(db),
                    referencedColumn: $$TransactionsTableReferences
                        ._accountSourceIdTable(db)
                        .id,
                  ) as T;
                }
                if (accountDestinationId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.accountDestinationId,
                    referencedTable: $$TransactionsTableReferences
                        ._accountDestinationIdTable(db),
                    referencedColumn: $$TransactionsTableReferences
                        ._accountDestinationIdTable(db)
                        .id,
                  ) as T;
                }
                if (categoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoryId,
                    referencedTable:
                        $$TransactionsTableReferences._categoryIdTable(db),
                    referencedColumn:
                        $$TransactionsTableReferences._categoryIdTable(db).id,
                  ) as T;
                }
                if (subcategoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.subcategoryId,
                    referencedTable:
                        $$TransactionsTableReferences._subcategoryIdTable(db),
                    referencedColumn: $$TransactionsTableReferences
                        ._subcategoryIdTable(db)
                        .id,
                  ) as T;
                }
                if (payeeId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.payeeId,
                    referencedTable:
                        $$TransactionsTableReferences._payeeIdTable(db),
                    referencedColumn:
                        $$TransactionsTableReferences._payeeIdTable(db).id,
                  ) as T;
                }
                if (parentTemplateId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.parentTemplateId,
                    referencedTable: $$TransactionsTableReferences
                        ._parentTemplateIdTable(db),
                    referencedColumn: $$TransactionsTableReferences
                        ._parentTemplateIdTable(db)
                        .id,
                  ) as T;
                }
                if (correctsTransactionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.correctsTransactionId,
                    referencedTable: $$TransactionsTableReferences
                        ._correctsTransactionIdTable(db),
                    referencedColumn: $$TransactionsTableReferences
                        ._correctsTransactionIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (entriesRefs)
                    await $_getPrefetchedData<Transaction, $TransactionsTable,
                            Entry>(
                        currentTable: table,
                        referencedTable:
                            $$TransactionsTableReferences._entriesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TransactionsTableReferences(db, table, p0)
                                .entriesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.transactionId == item.id),
                        typedResults: items),
                  if (transactionTagsRefs)
                    await $_getPrefetchedData<Transaction, $TransactionsTable,
                            TransactionTag>(
                        currentTable: table,
                        referencedTable: $$TransactionsTableReferences
                            ._transactionTagsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TransactionsTableReferences(db, table, p0)
                                .transactionTagsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.transactionId == item.id),
                        typedResults: items),
                  if (attachmentsRefs)
                    await $_getPrefetchedData<Transaction, $TransactionsTable,
                            Attachment>(
                        currentTable: table,
                        referencedTable: $$TransactionsTableReferences
                            ._attachmentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TransactionsTableReferences(db, table, p0)
                                .attachmentsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.transactionId == item.id),
                        typedResults: items),
                  if (scheduledOccurrencesRefs)
                    await $_getPrefetchedData<Transaction, $TransactionsTable,
                            ScheduledOccurrence>(
                        currentTable: table,
                        referencedTable: $$TransactionsTableReferences
                            ._scheduledOccurrencesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TransactionsTableReferences(db, table, p0)
                                .scheduledOccurrencesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.childTransactionId == item.id),
                        typedResults: items),
                  if (installmentOccurrencesRefs)
                    await $_getPrefetchedData<Transaction, $TransactionsTable,
                            InstallmentOccurrence>(
                        currentTable: table,
                        referencedTable: $$TransactionsTableReferences
                            ._installmentOccurrencesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TransactionsTableReferences(db, table, p0)
                                .installmentOccurrencesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.childTransactionId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TransactionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TransactionsTable,
    Transaction,
    $$TransactionsTableFilterComposer,
    $$TransactionsTableOrderingComposer,
    $$TransactionsTableAnnotationComposer,
    $$TransactionsTableCreateCompanionBuilder,
    $$TransactionsTableUpdateCompanionBuilder,
    (Transaction, $$TransactionsTableReferences),
    Transaction,
    PrefetchHooks Function(
        {bool currencyCode,
        bool homeCurrencyAtCapture,
        bool accountSourceId,
        bool accountDestinationId,
        bool categoryId,
        bool subcategoryId,
        bool payeeId,
        bool parentTemplateId,
        bool correctsTransactionId,
        bool entriesRefs,
        bool transactionTagsRefs,
        bool attachmentsRefs,
        bool scheduledOccurrencesRefs,
        bool installmentOccurrencesRefs})>;
typedef $$EntriesTableCreateCompanionBuilder = EntriesCompanion Function({
  required String id,
  required String transactionId,
  Value<String?> accountId,
  Value<String?> categoryId,
  required String side,
  required int amountMinor,
  required String currencyCode,
  Value<int?> exchangeRateMicro,
  required int createdAt,
  Value<int> rowid,
});
typedef $$EntriesTableUpdateCompanionBuilder = EntriesCompanion Function({
  Value<String> id,
  Value<String> transactionId,
  Value<String?> accountId,
  Value<String?> categoryId,
  Value<String> side,
  Value<int> amountMinor,
  Value<String> currencyCode,
  Value<int?> exchangeRateMicro,
  Value<int> createdAt,
  Value<int> rowid,
});

final class $$EntriesTableReferences
    extends BaseReferences<_$AppDatabase, $EntriesTable, Entry> {
  $$EntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TransactionsTable _transactionIdTable(_$AppDatabase db) =>
      db.transactions.createAlias(
          $_aliasNameGenerator(db.entries.transactionId, db.transactions.id));

  $$TransactionsTableProcessedTableManager get transactionId {
    final $_column = $_itemColumn<String>('transaction_id')!;

    final manager = $$TransactionsTableTableManager($_db, $_db.transactions)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $AccountsTable _accountIdTable(_$AppDatabase db) => db.accounts
      .createAlias($_aliasNameGenerator(db.entries.accountId, db.accounts.id));

  $$AccountsTableProcessedTableManager? get accountId {
    final $_column = $_itemColumn<String>('account_id');
    if ($_column == null) return null;
    final manager = $$AccountsTableTableManager($_db, $_db.accounts)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias(
          $_aliasNameGenerator(db.entries.categoryId, db.categories.id));

  $$CategoriesTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<String>('category_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager($_db, $_db.categories)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $CurrenciesTable _currencyCodeTable(_$AppDatabase db) =>
      db.currencies.createAlias(
          $_aliasNameGenerator(db.entries.currencyCode, db.currencies.code));

  $$CurrenciesTableProcessedTableManager get currencyCode {
    final $_column = $_itemColumn<String>('currency_code')!;

    final manager = $$CurrenciesTableTableManager($_db, $_db.currencies)
        .filter((f) => f.code.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_currencyCodeTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$EntriesTableFilterComposer
    extends Composer<_$AppDatabase, $EntriesTable> {
  $$EntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get side => $composableBuilder(
      column: $table.side, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amountMinor => $composableBuilder(
      column: $table.amountMinor, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get exchangeRateMicro => $composableBuilder(
      column: $table.exchangeRateMicro,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$TransactionsTableFilterComposer get transactionId {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.transactionId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableFilterComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableFilterComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableFilterComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CurrenciesTableFilterComposer get currencyCode {
    final $$CurrenciesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.currencyCode,
        referencedTable: $db.currencies,
        getReferencedColumn: (t) => t.code,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CurrenciesTableFilterComposer(
              $db: $db,
              $table: $db.currencies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$EntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $EntriesTable> {
  $$EntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get side => $composableBuilder(
      column: $table.side, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amountMinor => $composableBuilder(
      column: $table.amountMinor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get exchangeRateMicro => $composableBuilder(
      column: $table.exchangeRateMicro,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$TransactionsTableOrderingComposer get transactionId {
    final $$TransactionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.transactionId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableOrderingComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableOrderingComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CurrenciesTableOrderingComposer get currencyCode {
    final $$CurrenciesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.currencyCode,
        referencedTable: $db.currencies,
        getReferencedColumn: (t) => t.code,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CurrenciesTableOrderingComposer(
              $db: $db,
              $table: $db.currencies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$EntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntriesTable> {
  $$EntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get side =>
      $composableBuilder(column: $table.side, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
      column: $table.amountMinor, builder: (column) => column);

  GeneratedColumn<int> get exchangeRateMicro => $composableBuilder(
      column: $table.exchangeRateMicro, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$TransactionsTableAnnotationComposer get transactionId {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.transactionId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableAnnotationComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableAnnotationComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CurrenciesTableAnnotationComposer get currencyCode {
    final $$CurrenciesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.currencyCode,
        referencedTable: $db.currencies,
        getReferencedColumn: (t) => t.code,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CurrenciesTableAnnotationComposer(
              $db: $db,
              $table: $db.currencies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$EntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EntriesTable,
    Entry,
    $$EntriesTableFilterComposer,
    $$EntriesTableOrderingComposer,
    $$EntriesTableAnnotationComposer,
    $$EntriesTableCreateCompanionBuilder,
    $$EntriesTableUpdateCompanionBuilder,
    (Entry, $$EntriesTableReferences),
    Entry,
    PrefetchHooks Function(
        {bool transactionId,
        bool accountId,
        bool categoryId,
        bool currencyCode})> {
  $$EntriesTableTableManager(_$AppDatabase db, $EntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> transactionId = const Value.absent(),
            Value<String?> accountId = const Value.absent(),
            Value<String?> categoryId = const Value.absent(),
            Value<String> side = const Value.absent(),
            Value<int> amountMinor = const Value.absent(),
            Value<String> currencyCode = const Value.absent(),
            Value<int?> exchangeRateMicro = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EntriesCompanion(
            id: id,
            transactionId: transactionId,
            accountId: accountId,
            categoryId: categoryId,
            side: side,
            amountMinor: amountMinor,
            currencyCode: currencyCode,
            exchangeRateMicro: exchangeRateMicro,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String transactionId,
            Value<String?> accountId = const Value.absent(),
            Value<String?> categoryId = const Value.absent(),
            required String side,
            required int amountMinor,
            required String currencyCode,
            Value<int?> exchangeRateMicro = const Value.absent(),
            required int createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              EntriesCompanion.insert(
            id: id,
            transactionId: transactionId,
            accountId: accountId,
            categoryId: categoryId,
            side: side,
            amountMinor: amountMinor,
            currencyCode: currencyCode,
            exchangeRateMicro: exchangeRateMicro,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$EntriesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {transactionId = false,
              accountId = false,
              categoryId = false,
              currencyCode = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (transactionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.transactionId,
                    referencedTable:
                        $$EntriesTableReferences._transactionIdTable(db),
                    referencedColumn:
                        $$EntriesTableReferences._transactionIdTable(db).id,
                  ) as T;
                }
                if (accountId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.accountId,
                    referencedTable:
                        $$EntriesTableReferences._accountIdTable(db),
                    referencedColumn:
                        $$EntriesTableReferences._accountIdTable(db).id,
                  ) as T;
                }
                if (categoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoryId,
                    referencedTable:
                        $$EntriesTableReferences._categoryIdTable(db),
                    referencedColumn:
                        $$EntriesTableReferences._categoryIdTable(db).id,
                  ) as T;
                }
                if (currencyCode) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.currencyCode,
                    referencedTable:
                        $$EntriesTableReferences._currencyCodeTable(db),
                    referencedColumn:
                        $$EntriesTableReferences._currencyCodeTable(db).code,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$EntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $EntriesTable,
    Entry,
    $$EntriesTableFilterComposer,
    $$EntriesTableOrderingComposer,
    $$EntriesTableAnnotationComposer,
    $$EntriesTableCreateCompanionBuilder,
    $$EntriesTableUpdateCompanionBuilder,
    (Entry, $$EntriesTableReferences),
    Entry,
    PrefetchHooks Function(
        {bool transactionId,
        bool accountId,
        bool categoryId,
        bool currencyCode})>;
typedef $$TagsTableCreateCompanionBuilder = TagsCompanion Function({
  required String id,
  required String name,
  required int createdAt,
  Value<int> rowid,
});
typedef $$TagsTableUpdateCompanionBuilder = TagsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int> createdAt,
  Value<int> rowid,
});

final class $$TagsTableReferences
    extends BaseReferences<_$AppDatabase, $TagsTable, Tag> {
  $$TagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TransactionTagsTable, List<TransactionTag>>
      _transactionTagsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.transactionTags,
              aliasName:
                  $_aliasNameGenerator(db.tags.id, db.transactionTags.tagId));

  $$TransactionTagsTableProcessedTableManager get transactionTagsRefs {
    final manager =
        $$TransactionTagsTableTableManager($_db, $_db.transactionTags)
            .filter((f) => f.tagId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_transactionTagsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> transactionTagsRefs(
      Expression<bool> Function($$TransactionTagsTableFilterComposer f) f) {
    final $$TransactionTagsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.transactionTags,
        getReferencedColumn: (t) => t.tagId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionTagsTableFilterComposer(
              $db: $db,
              $table: $db.transactionTags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> transactionTagsRefs<T extends Object>(
      Expression<T> Function($$TransactionTagsTableAnnotationComposer a) f) {
    final $$TransactionTagsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.transactionTags,
        getReferencedColumn: (t) => t.tagId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionTagsTableAnnotationComposer(
              $db: $db,
              $table: $db.transactionTags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TagsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TagsTable,
    Tag,
    $$TagsTableFilterComposer,
    $$TagsTableOrderingComposer,
    $$TagsTableAnnotationComposer,
    $$TagsTableCreateCompanionBuilder,
    $$TagsTableUpdateCompanionBuilder,
    (Tag, $$TagsTableReferences),
    Tag,
    PrefetchHooks Function({bool transactionTagsRefs})> {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TagsCompanion(
            id: id,
            name: name,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required int createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              TagsCompanion.insert(
            id: id,
            name: name,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$TagsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({transactionTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (transactionTagsRefs) db.transactionTags
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (transactionTagsRefs)
                    await $_getPrefetchedData<Tag, $TagsTable, TransactionTag>(
                        currentTable: table,
                        referencedTable:
                            $$TagsTableReferences._transactionTagsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TagsTableReferences(db, table, p0)
                                .transactionTagsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.tagId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TagsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TagsTable,
    Tag,
    $$TagsTableFilterComposer,
    $$TagsTableOrderingComposer,
    $$TagsTableAnnotationComposer,
    $$TagsTableCreateCompanionBuilder,
    $$TagsTableUpdateCompanionBuilder,
    (Tag, $$TagsTableReferences),
    Tag,
    PrefetchHooks Function({bool transactionTagsRefs})>;
typedef $$TransactionTagsTableCreateCompanionBuilder = TransactionTagsCompanion
    Function({
  required String transactionId,
  required String tagId,
  Value<int> rowid,
});
typedef $$TransactionTagsTableUpdateCompanionBuilder = TransactionTagsCompanion
    Function({
  Value<String> transactionId,
  Value<String> tagId,
  Value<int> rowid,
});

final class $$TransactionTagsTableReferences extends BaseReferences<
    _$AppDatabase, $TransactionTagsTable, TransactionTag> {
  $$TransactionTagsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $TransactionsTable _transactionIdTable(_$AppDatabase db) =>
      db.transactions.createAlias($_aliasNameGenerator(
          db.transactionTags.transactionId, db.transactions.id));

  $$TransactionsTableProcessedTableManager get transactionId {
    final $_column = $_itemColumn<String>('transaction_id')!;

    final manager = $$TransactionsTableTableManager($_db, $_db.transactions)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $TagsTable _tagIdTable(_$AppDatabase db) => db.tags
      .createAlias($_aliasNameGenerator(db.transactionTags.tagId, db.tags.id));

  $$TagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<String>('tag_id')!;

    final manager = $$TagsTableTableManager($_db, $_db.tags)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TransactionTagsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionTagsTable> {
  $$TransactionTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$TransactionsTableFilterComposer get transactionId {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.transactionId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableFilterComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tagId,
        referencedTable: $db.tags,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TagsTableFilterComposer(
              $db: $db,
              $table: $db.tags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TransactionTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionTagsTable> {
  $$TransactionTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$TransactionsTableOrderingComposer get transactionId {
    final $$TransactionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.transactionId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableOrderingComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tagId,
        referencedTable: $db.tags,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TagsTableOrderingComposer(
              $db: $db,
              $table: $db.tags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TransactionTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionTagsTable> {
  $$TransactionTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$TransactionsTableAnnotationComposer get transactionId {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.transactionId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableAnnotationComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tagId,
        referencedTable: $db.tags,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TagsTableAnnotationComposer(
              $db: $db,
              $table: $db.tags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TransactionTagsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TransactionTagsTable,
    TransactionTag,
    $$TransactionTagsTableFilterComposer,
    $$TransactionTagsTableOrderingComposer,
    $$TransactionTagsTableAnnotationComposer,
    $$TransactionTagsTableCreateCompanionBuilder,
    $$TransactionTagsTableUpdateCompanionBuilder,
    (TransactionTag, $$TransactionTagsTableReferences),
    TransactionTag,
    PrefetchHooks Function({bool transactionId, bool tagId})> {
  $$TransactionTagsTableTableManager(
      _$AppDatabase db, $TransactionTagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> transactionId = const Value.absent(),
            Value<String> tagId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TransactionTagsCompanion(
            transactionId: transactionId,
            tagId: tagId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String transactionId,
            required String tagId,
            Value<int> rowid = const Value.absent(),
          }) =>
              TransactionTagsCompanion.insert(
            transactionId: transactionId,
            tagId: tagId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TransactionTagsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({transactionId = false, tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (transactionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.transactionId,
                    referencedTable: $$TransactionTagsTableReferences
                        ._transactionIdTable(db),
                    referencedColumn: $$TransactionTagsTableReferences
                        ._transactionIdTable(db)
                        .id,
                  ) as T;
                }
                if (tagId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.tagId,
                    referencedTable:
                        $$TransactionTagsTableReferences._tagIdTable(db),
                    referencedColumn:
                        $$TransactionTagsTableReferences._tagIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$TransactionTagsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TransactionTagsTable,
    TransactionTag,
    $$TransactionTagsTableFilterComposer,
    $$TransactionTagsTableOrderingComposer,
    $$TransactionTagsTableAnnotationComposer,
    $$TransactionTagsTableCreateCompanionBuilder,
    $$TransactionTagsTableUpdateCompanionBuilder,
    (TransactionTag, $$TransactionTagsTableReferences),
    TransactionTag,
    PrefetchHooks Function({bool transactionId, bool tagId})>;
typedef $$ExchangeRatesTableCreateCompanionBuilder = ExchangeRatesCompanion
    Function({
  Value<int> id,
  required String fromCurrency,
  required String toCurrency,
  required int rateMicro,
  required int fetchedAt,
  required String rateDate,
});
typedef $$ExchangeRatesTableUpdateCompanionBuilder = ExchangeRatesCompanion
    Function({
  Value<int> id,
  Value<String> fromCurrency,
  Value<String> toCurrency,
  Value<int> rateMicro,
  Value<int> fetchedAt,
  Value<String> rateDate,
});

final class $$ExchangeRatesTableReferences
    extends BaseReferences<_$AppDatabase, $ExchangeRatesTable, ExchangeRate> {
  $$ExchangeRatesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $CurrenciesTable _fromCurrencyTable(_$AppDatabase db) =>
      db.currencies.createAlias($_aliasNameGenerator(
          db.exchangeRates.fromCurrency, db.currencies.code));

  $$CurrenciesTableProcessedTableManager get fromCurrency {
    final $_column = $_itemColumn<String>('from_currency')!;

    final manager = $$CurrenciesTableTableManager($_db, $_db.currencies)
        .filter((f) => f.code.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fromCurrencyTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $CurrenciesTable _toCurrencyTable(_$AppDatabase db) =>
      db.currencies.createAlias($_aliasNameGenerator(
          db.exchangeRates.toCurrency, db.currencies.code));

  $$CurrenciesTableProcessedTableManager get toCurrency {
    final $_column = $_itemColumn<String>('to_currency')!;

    final manager = $$CurrenciesTableTableManager($_db, $_db.currencies)
        .filter((f) => f.code.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_toCurrencyTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ExchangeRatesTableFilterComposer
    extends Composer<_$AppDatabase, $ExchangeRatesTable> {
  $$ExchangeRatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get rateMicro => $composableBuilder(
      column: $table.rateMicro, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fetchedAt => $composableBuilder(
      column: $table.fetchedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rateDate => $composableBuilder(
      column: $table.rateDate, builder: (column) => ColumnFilters(column));

  $$CurrenciesTableFilterComposer get fromCurrency {
    final $$CurrenciesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.fromCurrency,
        referencedTable: $db.currencies,
        getReferencedColumn: (t) => t.code,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CurrenciesTableFilterComposer(
              $db: $db,
              $table: $db.currencies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CurrenciesTableFilterComposer get toCurrency {
    final $$CurrenciesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.toCurrency,
        referencedTable: $db.currencies,
        getReferencedColumn: (t) => t.code,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CurrenciesTableFilterComposer(
              $db: $db,
              $table: $db.currencies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ExchangeRatesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExchangeRatesTable> {
  $$ExchangeRatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get rateMicro => $composableBuilder(
      column: $table.rateMicro, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fetchedAt => $composableBuilder(
      column: $table.fetchedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rateDate => $composableBuilder(
      column: $table.rateDate, builder: (column) => ColumnOrderings(column));

  $$CurrenciesTableOrderingComposer get fromCurrency {
    final $$CurrenciesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.fromCurrency,
        referencedTable: $db.currencies,
        getReferencedColumn: (t) => t.code,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CurrenciesTableOrderingComposer(
              $db: $db,
              $table: $db.currencies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CurrenciesTableOrderingComposer get toCurrency {
    final $$CurrenciesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.toCurrency,
        referencedTable: $db.currencies,
        getReferencedColumn: (t) => t.code,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CurrenciesTableOrderingComposer(
              $db: $db,
              $table: $db.currencies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ExchangeRatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExchangeRatesTable> {
  $$ExchangeRatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get rateMicro =>
      $composableBuilder(column: $table.rateMicro, builder: (column) => column);

  GeneratedColumn<int> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  GeneratedColumn<String> get rateDate =>
      $composableBuilder(column: $table.rateDate, builder: (column) => column);

  $$CurrenciesTableAnnotationComposer get fromCurrency {
    final $$CurrenciesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.fromCurrency,
        referencedTable: $db.currencies,
        getReferencedColumn: (t) => t.code,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CurrenciesTableAnnotationComposer(
              $db: $db,
              $table: $db.currencies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CurrenciesTableAnnotationComposer get toCurrency {
    final $$CurrenciesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.toCurrency,
        referencedTable: $db.currencies,
        getReferencedColumn: (t) => t.code,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CurrenciesTableAnnotationComposer(
              $db: $db,
              $table: $db.currencies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ExchangeRatesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ExchangeRatesTable,
    ExchangeRate,
    $$ExchangeRatesTableFilterComposer,
    $$ExchangeRatesTableOrderingComposer,
    $$ExchangeRatesTableAnnotationComposer,
    $$ExchangeRatesTableCreateCompanionBuilder,
    $$ExchangeRatesTableUpdateCompanionBuilder,
    (ExchangeRate, $$ExchangeRatesTableReferences),
    ExchangeRate,
    PrefetchHooks Function({bool fromCurrency, bool toCurrency})> {
  $$ExchangeRatesTableTableManager(_$AppDatabase db, $ExchangeRatesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExchangeRatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExchangeRatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExchangeRatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> fromCurrency = const Value.absent(),
            Value<String> toCurrency = const Value.absent(),
            Value<int> rateMicro = const Value.absent(),
            Value<int> fetchedAt = const Value.absent(),
            Value<String> rateDate = const Value.absent(),
          }) =>
              ExchangeRatesCompanion(
            id: id,
            fromCurrency: fromCurrency,
            toCurrency: toCurrency,
            rateMicro: rateMicro,
            fetchedAt: fetchedAt,
            rateDate: rateDate,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String fromCurrency,
            required String toCurrency,
            required int rateMicro,
            required int fetchedAt,
            required String rateDate,
          }) =>
              ExchangeRatesCompanion.insert(
            id: id,
            fromCurrency: fromCurrency,
            toCurrency: toCurrency,
            rateMicro: rateMicro,
            fetchedAt: fetchedAt,
            rateDate: rateDate,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ExchangeRatesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({fromCurrency = false, toCurrency = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (fromCurrency) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.fromCurrency,
                    referencedTable:
                        $$ExchangeRatesTableReferences._fromCurrencyTable(db),
                    referencedColumn: $$ExchangeRatesTableReferences
                        ._fromCurrencyTable(db)
                        .code,
                  ) as T;
                }
                if (toCurrency) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.toCurrency,
                    referencedTable:
                        $$ExchangeRatesTableReferences._toCurrencyTable(db),
                    referencedColumn: $$ExchangeRatesTableReferences
                        ._toCurrencyTable(db)
                        .code,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ExchangeRatesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ExchangeRatesTable,
    ExchangeRate,
    $$ExchangeRatesTableFilterComposer,
    $$ExchangeRatesTableOrderingComposer,
    $$ExchangeRatesTableAnnotationComposer,
    $$ExchangeRatesTableCreateCompanionBuilder,
    $$ExchangeRatesTableUpdateCompanionBuilder,
    (ExchangeRate, $$ExchangeRatesTableReferences),
    ExchangeRate,
    PrefetchHooks Function({bool fromCurrency, bool toCurrency})>;
typedef $$AttachmentsTableCreateCompanionBuilder = AttachmentsCompanion
    Function({
  required String id,
  required String transactionId,
  required String filePath,
  required int fileSizeBytes,
  Value<String> mimeType,
  Value<int?> widthPx,
  Value<int?> heightPx,
  required int createdAt,
  Value<int> rowid,
});
typedef $$AttachmentsTableUpdateCompanionBuilder = AttachmentsCompanion
    Function({
  Value<String> id,
  Value<String> transactionId,
  Value<String> filePath,
  Value<int> fileSizeBytes,
  Value<String> mimeType,
  Value<int?> widthPx,
  Value<int?> heightPx,
  Value<int> createdAt,
  Value<int> rowid,
});

final class $$AttachmentsTableReferences
    extends BaseReferences<_$AppDatabase, $AttachmentsTable, Attachment> {
  $$AttachmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TransactionsTable _transactionIdTable(_$AppDatabase db) =>
      db.transactions.createAlias($_aliasNameGenerator(
          db.attachments.transactionId, db.transactions.id));

  $$TransactionsTableProcessedTableManager get transactionId {
    final $_column = $_itemColumn<String>('transaction_id')!;

    final manager = $$TransactionsTableTableManager($_db, $_db.transactions)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$AttachmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fileSizeBytes => $composableBuilder(
      column: $table.fileSizeBytes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mimeType => $composableBuilder(
      column: $table.mimeType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get widthPx => $composableBuilder(
      column: $table.widthPx, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get heightPx => $composableBuilder(
      column: $table.heightPx, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$TransactionsTableFilterComposer get transactionId {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.transactionId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableFilterComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AttachmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fileSizeBytes => $composableBuilder(
      column: $table.fileSizeBytes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mimeType => $composableBuilder(
      column: $table.mimeType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get widthPx => $composableBuilder(
      column: $table.widthPx, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get heightPx => $composableBuilder(
      column: $table.heightPx, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$TransactionsTableOrderingComposer get transactionId {
    final $$TransactionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.transactionId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableOrderingComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AttachmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<int> get fileSizeBytes => $composableBuilder(
      column: $table.fileSizeBytes, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get widthPx =>
      $composableBuilder(column: $table.widthPx, builder: (column) => column);

  GeneratedColumn<int> get heightPx =>
      $composableBuilder(column: $table.heightPx, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$TransactionsTableAnnotationComposer get transactionId {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.transactionId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableAnnotationComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AttachmentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AttachmentsTable,
    Attachment,
    $$AttachmentsTableFilterComposer,
    $$AttachmentsTableOrderingComposer,
    $$AttachmentsTableAnnotationComposer,
    $$AttachmentsTableCreateCompanionBuilder,
    $$AttachmentsTableUpdateCompanionBuilder,
    (Attachment, $$AttachmentsTableReferences),
    Attachment,
    PrefetchHooks Function({bool transactionId})> {
  $$AttachmentsTableTableManager(_$AppDatabase db, $AttachmentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttachmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> transactionId = const Value.absent(),
            Value<String> filePath = const Value.absent(),
            Value<int> fileSizeBytes = const Value.absent(),
            Value<String> mimeType = const Value.absent(),
            Value<int?> widthPx = const Value.absent(),
            Value<int?> heightPx = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AttachmentsCompanion(
            id: id,
            transactionId: transactionId,
            filePath: filePath,
            fileSizeBytes: fileSizeBytes,
            mimeType: mimeType,
            widthPx: widthPx,
            heightPx: heightPx,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String transactionId,
            required String filePath,
            required int fileSizeBytes,
            Value<String> mimeType = const Value.absent(),
            Value<int?> widthPx = const Value.absent(),
            Value<int?> heightPx = const Value.absent(),
            required int createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              AttachmentsCompanion.insert(
            id: id,
            transactionId: transactionId,
            filePath: filePath,
            fileSizeBytes: fileSizeBytes,
            mimeType: mimeType,
            widthPx: widthPx,
            heightPx: heightPx,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$AttachmentsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({transactionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (transactionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.transactionId,
                    referencedTable:
                        $$AttachmentsTableReferences._transactionIdTable(db),
                    referencedColumn:
                        $$AttachmentsTableReferences._transactionIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$AttachmentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AttachmentsTable,
    Attachment,
    $$AttachmentsTableFilterComposer,
    $$AttachmentsTableOrderingComposer,
    $$AttachmentsTableAnnotationComposer,
    $$AttachmentsTableCreateCompanionBuilder,
    $$AttachmentsTableUpdateCompanionBuilder,
    (Attachment, $$AttachmentsTableReferences),
    Attachment,
    PrefetchHooks Function({bool transactionId})>;
typedef $$BudgetsTableCreateCompanionBuilder = BudgetsCompanion Function({
  required String id,
  required String name,
  Value<String?> categoryId,
  required int amountMinor,
  required String currencyCode,
  required String periodType,
  Value<int> periodN,
  Value<bool> rollover,
  Value<bool> isActive,
  required int createdAt,
  required int updatedAt,
  Value<int> rowid,
});
typedef $$BudgetsTableUpdateCompanionBuilder = BudgetsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> categoryId,
  Value<int> amountMinor,
  Value<String> currencyCode,
  Value<String> periodType,
  Value<int> periodN,
  Value<bool> rollover,
  Value<bool> isActive,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int> rowid,
});

final class $$BudgetsTableReferences
    extends BaseReferences<_$AppDatabase, $BudgetsTable, Budget> {
  $$BudgetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias(
          $_aliasNameGenerator(db.budgets.categoryId, db.categories.id));

  $$CategoriesTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<String>('category_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager($_db, $_db.categories)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $CurrenciesTable _currencyCodeTable(_$AppDatabase db) =>
      db.currencies.createAlias(
          $_aliasNameGenerator(db.budgets.currencyCode, db.currencies.code));

  $$CurrenciesTableProcessedTableManager get currencyCode {
    final $_column = $_itemColumn<String>('currency_code')!;

    final manager = $$CurrenciesTableTableManager($_db, $_db.currencies)
        .filter((f) => f.code.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_currencyCodeTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$BudgetPeriodsTable, List<BudgetPeriod>>
      _budgetPeriodsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.budgetPeriods,
              aliasName: $_aliasNameGenerator(
                  db.budgets.id, db.budgetPeriods.budgetId));

  $$BudgetPeriodsTableProcessedTableManager get budgetPeriodsRefs {
    final manager = $$BudgetPeriodsTableTableManager($_db, $_db.budgetPeriods)
        .filter((f) => f.budgetId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_budgetPeriodsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

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

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amountMinor => $composableBuilder(
      column: $table.amountMinor, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get periodType => $composableBuilder(
      column: $table.periodType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get periodN => $composableBuilder(
      column: $table.periodN, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get rollover => $composableBuilder(
      column: $table.rollover, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableFilterComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CurrenciesTableFilterComposer get currencyCode {
    final $$CurrenciesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.currencyCode,
        referencedTable: $db.currencies,
        getReferencedColumn: (t) => t.code,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CurrenciesTableFilterComposer(
              $db: $db,
              $table: $db.currencies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> budgetPeriodsRefs(
      Expression<bool> Function($$BudgetPeriodsTableFilterComposer f) f) {
    final $$BudgetPeriodsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.budgetPeriods,
        getReferencedColumn: (t) => t.budgetId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BudgetPeriodsTableFilterComposer(
              $db: $db,
              $table: $db.budgetPeriods,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
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

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amountMinor => $composableBuilder(
      column: $table.amountMinor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get periodType => $composableBuilder(
      column: $table.periodType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get periodN => $composableBuilder(
      column: $table.periodN, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get rollover => $composableBuilder(
      column: $table.rollover, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CurrenciesTableOrderingComposer get currencyCode {
    final $$CurrenciesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.currencyCode,
        referencedTable: $db.currencies,
        getReferencedColumn: (t) => t.code,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CurrenciesTableOrderingComposer(
              $db: $db,
              $table: $db.currencies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
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

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
      column: $table.amountMinor, builder: (column) => column);

  GeneratedColumn<String> get periodType => $composableBuilder(
      column: $table.periodType, builder: (column) => column);

  GeneratedColumn<int> get periodN =>
      $composableBuilder(column: $table.periodN, builder: (column) => column);

  GeneratedColumn<bool> get rollover =>
      $composableBuilder(column: $table.rollover, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CurrenciesTableAnnotationComposer get currencyCode {
    final $$CurrenciesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.currencyCode,
        referencedTable: $db.currencies,
        getReferencedColumn: (t) => t.code,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CurrenciesTableAnnotationComposer(
              $db: $db,
              $table: $db.currencies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> budgetPeriodsRefs<T extends Object>(
      Expression<T> Function($$BudgetPeriodsTableAnnotationComposer a) f) {
    final $$BudgetPeriodsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.budgetPeriods,
        getReferencedColumn: (t) => t.budgetId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BudgetPeriodsTableAnnotationComposer(
              $db: $db,
              $table: $db.budgetPeriods,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
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
    (Budget, $$BudgetsTableReferences),
    Budget,
    PrefetchHooks Function(
        {bool categoryId, bool currencyCode, bool budgetPeriodsRefs})> {
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
            Value<String> name = const Value.absent(),
            Value<String?> categoryId = const Value.absent(),
            Value<int> amountMinor = const Value.absent(),
            Value<String> currencyCode = const Value.absent(),
            Value<String> periodType = const Value.absent(),
            Value<int> periodN = const Value.absent(),
            Value<bool> rollover = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BudgetsCompanion(
            id: id,
            name: name,
            categoryId: categoryId,
            amountMinor: amountMinor,
            currencyCode: currencyCode,
            periodType: periodType,
            periodN: periodN,
            rollover: rollover,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> categoryId = const Value.absent(),
            required int amountMinor,
            required String currencyCode,
            required String periodType,
            Value<int> periodN = const Value.absent(),
            Value<bool> rollover = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            required int createdAt,
            required int updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              BudgetsCompanion.insert(
            id: id,
            name: name,
            categoryId: categoryId,
            amountMinor: amountMinor,
            currencyCode: currencyCode,
            periodType: periodType,
            periodN: periodN,
            rollover: rollover,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$BudgetsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {categoryId = false,
              currencyCode = false,
              budgetPeriodsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (budgetPeriodsRefs) db.budgetPeriods
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (categoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoryId,
                    referencedTable:
                        $$BudgetsTableReferences._categoryIdTable(db),
                    referencedColumn:
                        $$BudgetsTableReferences._categoryIdTable(db).id,
                  ) as T;
                }
                if (currencyCode) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.currencyCode,
                    referencedTable:
                        $$BudgetsTableReferences._currencyCodeTable(db),
                    referencedColumn:
                        $$BudgetsTableReferences._currencyCodeTable(db).code,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (budgetPeriodsRefs)
                    await $_getPrefetchedData<Budget, $BudgetsTable,
                            BudgetPeriod>(
                        currentTable: table,
                        referencedTable: $$BudgetsTableReferences
                            ._budgetPeriodsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BudgetsTableReferences(db, table, p0)
                                .budgetPeriodsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.budgetId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
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
    (Budget, $$BudgetsTableReferences),
    Budget,
    PrefetchHooks Function(
        {bool categoryId, bool currencyCode, bool budgetPeriodsRefs})>;
typedef $$BudgetPeriodsTableCreateCompanionBuilder = BudgetPeriodsCompanion
    Function({
  required String id,
  required String budgetId,
  required int periodStart,
  required int periodEnd,
  required int budgetedMinor,
  Value<int> carriedOverMinor,
  required int createdAt,
  Value<int> rowid,
});
typedef $$BudgetPeriodsTableUpdateCompanionBuilder = BudgetPeriodsCompanion
    Function({
  Value<String> id,
  Value<String> budgetId,
  Value<int> periodStart,
  Value<int> periodEnd,
  Value<int> budgetedMinor,
  Value<int> carriedOverMinor,
  Value<int> createdAt,
  Value<int> rowid,
});

final class $$BudgetPeriodsTableReferences
    extends BaseReferences<_$AppDatabase, $BudgetPeriodsTable, BudgetPeriod> {
  $$BudgetPeriodsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $BudgetsTable _budgetIdTable(_$AppDatabase db) =>
      db.budgets.createAlias(
          $_aliasNameGenerator(db.budgetPeriods.budgetId, db.budgets.id));

  $$BudgetsTableProcessedTableManager get budgetId {
    final $_column = $_itemColumn<String>('budget_id')!;

    final manager = $$BudgetsTableTableManager($_db, $_db.budgets)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_budgetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$BudgetPeriodsTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetPeriodsTable> {
  $$BudgetPeriodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get periodStart => $composableBuilder(
      column: $table.periodStart, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get periodEnd => $composableBuilder(
      column: $table.periodEnd, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get budgetedMinor => $composableBuilder(
      column: $table.budgetedMinor, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get carriedOverMinor => $composableBuilder(
      column: $table.carriedOverMinor,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$BudgetsTableFilterComposer get budgetId {
    final $$BudgetsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.budgetId,
        referencedTable: $db.budgets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BudgetsTableFilterComposer(
              $db: $db,
              $table: $db.budgets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BudgetPeriodsTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetPeriodsTable> {
  $$BudgetPeriodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get periodStart => $composableBuilder(
      column: $table.periodStart, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get periodEnd => $composableBuilder(
      column: $table.periodEnd, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get budgetedMinor => $composableBuilder(
      column: $table.budgetedMinor,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get carriedOverMinor => $composableBuilder(
      column: $table.carriedOverMinor,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$BudgetsTableOrderingComposer get budgetId {
    final $$BudgetsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.budgetId,
        referencedTable: $db.budgets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BudgetsTableOrderingComposer(
              $db: $db,
              $table: $db.budgets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BudgetPeriodsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetPeriodsTable> {
  $$BudgetPeriodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get periodStart => $composableBuilder(
      column: $table.periodStart, builder: (column) => column);

  GeneratedColumn<int> get periodEnd =>
      $composableBuilder(column: $table.periodEnd, builder: (column) => column);

  GeneratedColumn<int> get budgetedMinor => $composableBuilder(
      column: $table.budgetedMinor, builder: (column) => column);

  GeneratedColumn<int> get carriedOverMinor => $composableBuilder(
      column: $table.carriedOverMinor, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$BudgetsTableAnnotationComposer get budgetId {
    final $$BudgetsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.budgetId,
        referencedTable: $db.budgets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BudgetsTableAnnotationComposer(
              $db: $db,
              $table: $db.budgets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BudgetPeriodsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BudgetPeriodsTable,
    BudgetPeriod,
    $$BudgetPeriodsTableFilterComposer,
    $$BudgetPeriodsTableOrderingComposer,
    $$BudgetPeriodsTableAnnotationComposer,
    $$BudgetPeriodsTableCreateCompanionBuilder,
    $$BudgetPeriodsTableUpdateCompanionBuilder,
    (BudgetPeriod, $$BudgetPeriodsTableReferences),
    BudgetPeriod,
    PrefetchHooks Function({bool budgetId})> {
  $$BudgetPeriodsTableTableManager(_$AppDatabase db, $BudgetPeriodsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetPeriodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetPeriodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetPeriodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> budgetId = const Value.absent(),
            Value<int> periodStart = const Value.absent(),
            Value<int> periodEnd = const Value.absent(),
            Value<int> budgetedMinor = const Value.absent(),
            Value<int> carriedOverMinor = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BudgetPeriodsCompanion(
            id: id,
            budgetId: budgetId,
            periodStart: periodStart,
            periodEnd: periodEnd,
            budgetedMinor: budgetedMinor,
            carriedOverMinor: carriedOverMinor,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String budgetId,
            required int periodStart,
            required int periodEnd,
            required int budgetedMinor,
            Value<int> carriedOverMinor = const Value.absent(),
            required int createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              BudgetPeriodsCompanion.insert(
            id: id,
            budgetId: budgetId,
            periodStart: periodStart,
            periodEnd: periodEnd,
            budgetedMinor: budgetedMinor,
            carriedOverMinor: carriedOverMinor,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$BudgetPeriodsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({budgetId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (budgetId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.budgetId,
                    referencedTable:
                        $$BudgetPeriodsTableReferences._budgetIdTable(db),
                    referencedColumn:
                        $$BudgetPeriodsTableReferences._budgetIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$BudgetPeriodsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BudgetPeriodsTable,
    BudgetPeriod,
    $$BudgetPeriodsTableFilterComposer,
    $$BudgetPeriodsTableOrderingComposer,
    $$BudgetPeriodsTableAnnotationComposer,
    $$BudgetPeriodsTableCreateCompanionBuilder,
    $$BudgetPeriodsTableUpdateCompanionBuilder,
    (BudgetPeriod, $$BudgetPeriodsTableReferences),
    BudgetPeriod,
    PrefetchHooks Function({bool budgetId})>;
typedef $$ScheduledOccurrencesTableCreateCompanionBuilder
    = ScheduledOccurrencesCompanion Function({
  required String id,
  required String templateId,
  required int scheduledDate,
  Value<String> status,
  Value<String?> childTransactionId,
  required int createdAt,
  required int updatedAt,
  Value<int> rowid,
});
typedef $$ScheduledOccurrencesTableUpdateCompanionBuilder
    = ScheduledOccurrencesCompanion Function({
  Value<String> id,
  Value<String> templateId,
  Value<int> scheduledDate,
  Value<String> status,
  Value<String?> childTransactionId,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int> rowid,
});

final class $$ScheduledOccurrencesTableReferences extends BaseReferences<
    _$AppDatabase, $ScheduledOccurrencesTable, ScheduledOccurrence> {
  $$ScheduledOccurrencesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $RecurringTemplatesTable _templateIdTable(_$AppDatabase db) =>
      db.recurringTemplates.createAlias($_aliasNameGenerator(
          db.scheduledOccurrences.templateId, db.recurringTemplates.id));

  $$RecurringTemplatesTableProcessedTableManager get templateId {
    final $_column = $_itemColumn<String>('template_id')!;

    final manager =
        $$RecurringTemplatesTableTableManager($_db, $_db.recurringTemplates)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_templateIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $TransactionsTable _childTransactionIdTable(_$AppDatabase db) =>
      db.transactions.createAlias($_aliasNameGenerator(
          db.scheduledOccurrences.childTransactionId, db.transactions.id));

  $$TransactionsTableProcessedTableManager? get childTransactionId {
    final $_column = $_itemColumn<String>('child_transaction_id');
    if ($_column == null) return null;
    final manager = $$TransactionsTableTableManager($_db, $_db.transactions)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_childTransactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ScheduledOccurrencesTableFilterComposer
    extends Composer<_$AppDatabase, $ScheduledOccurrencesTable> {
  $$ScheduledOccurrencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get scheduledDate => $composableBuilder(
      column: $table.scheduledDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$RecurringTemplatesTableFilterComposer get templateId {
    final $$RecurringTemplatesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.templateId,
        referencedTable: $db.recurringTemplates,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecurringTemplatesTableFilterComposer(
              $db: $db,
              $table: $db.recurringTemplates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TransactionsTableFilterComposer get childTransactionId {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.childTransactionId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableFilterComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ScheduledOccurrencesTableOrderingComposer
    extends Composer<_$AppDatabase, $ScheduledOccurrencesTable> {
  $$ScheduledOccurrencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get scheduledDate => $composableBuilder(
      column: $table.scheduledDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$RecurringTemplatesTableOrderingComposer get templateId {
    final $$RecurringTemplatesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.templateId,
        referencedTable: $db.recurringTemplates,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecurringTemplatesTableOrderingComposer(
              $db: $db,
              $table: $db.recurringTemplates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TransactionsTableOrderingComposer get childTransactionId {
    final $$TransactionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.childTransactionId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableOrderingComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ScheduledOccurrencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScheduledOccurrencesTable> {
  $$ScheduledOccurrencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get scheduledDate => $composableBuilder(
      column: $table.scheduledDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$RecurringTemplatesTableAnnotationComposer get templateId {
    final $$RecurringTemplatesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.templateId,
            referencedTable: $db.recurringTemplates,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$RecurringTemplatesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.recurringTemplates,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  $$TransactionsTableAnnotationComposer get childTransactionId {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.childTransactionId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableAnnotationComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ScheduledOccurrencesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ScheduledOccurrencesTable,
    ScheduledOccurrence,
    $$ScheduledOccurrencesTableFilterComposer,
    $$ScheduledOccurrencesTableOrderingComposer,
    $$ScheduledOccurrencesTableAnnotationComposer,
    $$ScheduledOccurrencesTableCreateCompanionBuilder,
    $$ScheduledOccurrencesTableUpdateCompanionBuilder,
    (ScheduledOccurrence, $$ScheduledOccurrencesTableReferences),
    ScheduledOccurrence,
    PrefetchHooks Function({bool templateId, bool childTransactionId})> {
  $$ScheduledOccurrencesTableTableManager(
      _$AppDatabase db, $ScheduledOccurrencesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScheduledOccurrencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScheduledOccurrencesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScheduledOccurrencesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> templateId = const Value.absent(),
            Value<int> scheduledDate = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> childTransactionId = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ScheduledOccurrencesCompanion(
            id: id,
            templateId: templateId,
            scheduledDate: scheduledDate,
            status: status,
            childTransactionId: childTransactionId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String templateId,
            required int scheduledDate,
            Value<String> status = const Value.absent(),
            Value<String?> childTransactionId = const Value.absent(),
            required int createdAt,
            required int updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ScheduledOccurrencesCompanion.insert(
            id: id,
            templateId: templateId,
            scheduledDate: scheduledDate,
            status: status,
            childTransactionId: childTransactionId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ScheduledOccurrencesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {templateId = false, childTransactionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (templateId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.templateId,
                    referencedTable: $$ScheduledOccurrencesTableReferences
                        ._templateIdTable(db),
                    referencedColumn: $$ScheduledOccurrencesTableReferences
                        ._templateIdTable(db)
                        .id,
                  ) as T;
                }
                if (childTransactionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.childTransactionId,
                    referencedTable: $$ScheduledOccurrencesTableReferences
                        ._childTransactionIdTable(db),
                    referencedColumn: $$ScheduledOccurrencesTableReferences
                        ._childTransactionIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ScheduledOccurrencesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $ScheduledOccurrencesTable,
        ScheduledOccurrence,
        $$ScheduledOccurrencesTableFilterComposer,
        $$ScheduledOccurrencesTableOrderingComposer,
        $$ScheduledOccurrencesTableAnnotationComposer,
        $$ScheduledOccurrencesTableCreateCompanionBuilder,
        $$ScheduledOccurrencesTableUpdateCompanionBuilder,
        (ScheduledOccurrence, $$ScheduledOccurrencesTableReferences),
        ScheduledOccurrence,
        PrefetchHooks Function({bool templateId, bool childTransactionId})>;
typedef $$InstallmentPlansTableCreateCompanionBuilder
    = InstallmentPlansCompanion Function({
  required String templateId,
  required int totalConfiguredMinor,
  required int numberOfInstallments,
  required int createdAt,
  Value<int> rowid,
});
typedef $$InstallmentPlansTableUpdateCompanionBuilder
    = InstallmentPlansCompanion Function({
  Value<String> templateId,
  Value<int> totalConfiguredMinor,
  Value<int> numberOfInstallments,
  Value<int> createdAt,
  Value<int> rowid,
});

final class $$InstallmentPlansTableReferences extends BaseReferences<
    _$AppDatabase, $InstallmentPlansTable, InstallmentPlan> {
  $$InstallmentPlansTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $RecurringTemplatesTable _templateIdTable(_$AppDatabase db) =>
      db.recurringTemplates.createAlias($_aliasNameGenerator(
          db.installmentPlans.templateId, db.recurringTemplates.id));

  $$RecurringTemplatesTableProcessedTableManager get templateId {
    final $_column = $_itemColumn<String>('template_id')!;

    final manager =
        $$RecurringTemplatesTableTableManager($_db, $_db.recurringTemplates)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_templateIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$InstallmentPlansTableFilterComposer
    extends Composer<_$AppDatabase, $InstallmentPlansTable> {
  $$InstallmentPlansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get totalConfiguredMinor => $composableBuilder(
      column: $table.totalConfiguredMinor,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get numberOfInstallments => $composableBuilder(
      column: $table.numberOfInstallments,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$RecurringTemplatesTableFilterComposer get templateId {
    final $$RecurringTemplatesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.templateId,
        referencedTable: $db.recurringTemplates,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecurringTemplatesTableFilterComposer(
              $db: $db,
              $table: $db.recurringTemplates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InstallmentPlansTableOrderingComposer
    extends Composer<_$AppDatabase, $InstallmentPlansTable> {
  $$InstallmentPlansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get totalConfiguredMinor => $composableBuilder(
      column: $table.totalConfiguredMinor,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get numberOfInstallments => $composableBuilder(
      column: $table.numberOfInstallments,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$RecurringTemplatesTableOrderingComposer get templateId {
    final $$RecurringTemplatesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.templateId,
        referencedTable: $db.recurringTemplates,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecurringTemplatesTableOrderingComposer(
              $db: $db,
              $table: $db.recurringTemplates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InstallmentPlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $InstallmentPlansTable> {
  $$InstallmentPlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get totalConfiguredMinor => $composableBuilder(
      column: $table.totalConfiguredMinor, builder: (column) => column);

  GeneratedColumn<int> get numberOfInstallments => $composableBuilder(
      column: $table.numberOfInstallments, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$RecurringTemplatesTableAnnotationComposer get templateId {
    final $$RecurringTemplatesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.templateId,
            referencedTable: $db.recurringTemplates,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$RecurringTemplatesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.recurringTemplates,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$InstallmentPlansTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InstallmentPlansTable,
    InstallmentPlan,
    $$InstallmentPlansTableFilterComposer,
    $$InstallmentPlansTableOrderingComposer,
    $$InstallmentPlansTableAnnotationComposer,
    $$InstallmentPlansTableCreateCompanionBuilder,
    $$InstallmentPlansTableUpdateCompanionBuilder,
    (InstallmentPlan, $$InstallmentPlansTableReferences),
    InstallmentPlan,
    PrefetchHooks Function({bool templateId})> {
  $$InstallmentPlansTableTableManager(
      _$AppDatabase db, $InstallmentPlansTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InstallmentPlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InstallmentPlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InstallmentPlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> templateId = const Value.absent(),
            Value<int> totalConfiguredMinor = const Value.absent(),
            Value<int> numberOfInstallments = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InstallmentPlansCompanion(
            templateId: templateId,
            totalConfiguredMinor: totalConfiguredMinor,
            numberOfInstallments: numberOfInstallments,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String templateId,
            required int totalConfiguredMinor,
            required int numberOfInstallments,
            required int createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              InstallmentPlansCompanion.insert(
            templateId: templateId,
            totalConfiguredMinor: totalConfiguredMinor,
            numberOfInstallments: numberOfInstallments,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$InstallmentPlansTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({templateId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (templateId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.templateId,
                    referencedTable:
                        $$InstallmentPlansTableReferences._templateIdTable(db),
                    referencedColumn: $$InstallmentPlansTableReferences
                        ._templateIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$InstallmentPlansTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InstallmentPlansTable,
    InstallmentPlan,
    $$InstallmentPlansTableFilterComposer,
    $$InstallmentPlansTableOrderingComposer,
    $$InstallmentPlansTableAnnotationComposer,
    $$InstallmentPlansTableCreateCompanionBuilder,
    $$InstallmentPlansTableUpdateCompanionBuilder,
    (InstallmentPlan, $$InstallmentPlansTableReferences),
    InstallmentPlan,
    PrefetchHooks Function({bool templateId})>;
typedef $$InstallmentOccurrencesTableCreateCompanionBuilder
    = InstallmentOccurrencesCompanion Function({
  required String id,
  required String templateId,
  required int sequenceNumber,
  required int scheduledDate,
  required int amountMinor,
  Value<String> status,
  Value<String?> childTransactionId,
  required int createdAt,
  required int updatedAt,
  Value<int> rowid,
});
typedef $$InstallmentOccurrencesTableUpdateCompanionBuilder
    = InstallmentOccurrencesCompanion Function({
  Value<String> id,
  Value<String> templateId,
  Value<int> sequenceNumber,
  Value<int> scheduledDate,
  Value<int> amountMinor,
  Value<String> status,
  Value<String?> childTransactionId,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int> rowid,
});

final class $$InstallmentOccurrencesTableReferences extends BaseReferences<
    _$AppDatabase, $InstallmentOccurrencesTable, InstallmentOccurrence> {
  $$InstallmentOccurrencesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $RecurringTemplatesTable _templateIdTable(_$AppDatabase db) =>
      db.recurringTemplates.createAlias($_aliasNameGenerator(
          db.installmentOccurrences.templateId, db.recurringTemplates.id));

  $$RecurringTemplatesTableProcessedTableManager get templateId {
    final $_column = $_itemColumn<String>('template_id')!;

    final manager =
        $$RecurringTemplatesTableTableManager($_db, $_db.recurringTemplates)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_templateIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $TransactionsTable _childTransactionIdTable(_$AppDatabase db) =>
      db.transactions.createAlias($_aliasNameGenerator(
          db.installmentOccurrences.childTransactionId, db.transactions.id));

  $$TransactionsTableProcessedTableManager? get childTransactionId {
    final $_column = $_itemColumn<String>('child_transaction_id');
    if ($_column == null) return null;
    final manager = $$TransactionsTableTableManager($_db, $_db.transactions)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_childTransactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$InstallmentOccurrencesTableFilterComposer
    extends Composer<_$AppDatabase, $InstallmentOccurrencesTable> {
  $$InstallmentOccurrencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sequenceNumber => $composableBuilder(
      column: $table.sequenceNumber,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get scheduledDate => $composableBuilder(
      column: $table.scheduledDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amountMinor => $composableBuilder(
      column: $table.amountMinor, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$RecurringTemplatesTableFilterComposer get templateId {
    final $$RecurringTemplatesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.templateId,
        referencedTable: $db.recurringTemplates,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecurringTemplatesTableFilterComposer(
              $db: $db,
              $table: $db.recurringTemplates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TransactionsTableFilterComposer get childTransactionId {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.childTransactionId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableFilterComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InstallmentOccurrencesTableOrderingComposer
    extends Composer<_$AppDatabase, $InstallmentOccurrencesTable> {
  $$InstallmentOccurrencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sequenceNumber => $composableBuilder(
      column: $table.sequenceNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get scheduledDate => $composableBuilder(
      column: $table.scheduledDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amountMinor => $composableBuilder(
      column: $table.amountMinor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$RecurringTemplatesTableOrderingComposer get templateId {
    final $$RecurringTemplatesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.templateId,
        referencedTable: $db.recurringTemplates,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecurringTemplatesTableOrderingComposer(
              $db: $db,
              $table: $db.recurringTemplates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TransactionsTableOrderingComposer get childTransactionId {
    final $$TransactionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.childTransactionId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableOrderingComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InstallmentOccurrencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InstallmentOccurrencesTable> {
  $$InstallmentOccurrencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sequenceNumber => $composableBuilder(
      column: $table.sequenceNumber, builder: (column) => column);

  GeneratedColumn<int> get scheduledDate => $composableBuilder(
      column: $table.scheduledDate, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
      column: $table.amountMinor, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$RecurringTemplatesTableAnnotationComposer get templateId {
    final $$RecurringTemplatesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.templateId,
            referencedTable: $db.recurringTemplates,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$RecurringTemplatesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.recurringTemplates,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  $$TransactionsTableAnnotationComposer get childTransactionId {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.childTransactionId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableAnnotationComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InstallmentOccurrencesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InstallmentOccurrencesTable,
    InstallmentOccurrence,
    $$InstallmentOccurrencesTableFilterComposer,
    $$InstallmentOccurrencesTableOrderingComposer,
    $$InstallmentOccurrencesTableAnnotationComposer,
    $$InstallmentOccurrencesTableCreateCompanionBuilder,
    $$InstallmentOccurrencesTableUpdateCompanionBuilder,
    (InstallmentOccurrence, $$InstallmentOccurrencesTableReferences),
    InstallmentOccurrence,
    PrefetchHooks Function({bool templateId, bool childTransactionId})> {
  $$InstallmentOccurrencesTableTableManager(
      _$AppDatabase db, $InstallmentOccurrencesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InstallmentOccurrencesTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$InstallmentOccurrencesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InstallmentOccurrencesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> templateId = const Value.absent(),
            Value<int> sequenceNumber = const Value.absent(),
            Value<int> scheduledDate = const Value.absent(),
            Value<int> amountMinor = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> childTransactionId = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InstallmentOccurrencesCompanion(
            id: id,
            templateId: templateId,
            sequenceNumber: sequenceNumber,
            scheduledDate: scheduledDate,
            amountMinor: amountMinor,
            status: status,
            childTransactionId: childTransactionId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String templateId,
            required int sequenceNumber,
            required int scheduledDate,
            required int amountMinor,
            Value<String> status = const Value.absent(),
            Value<String?> childTransactionId = const Value.absent(),
            required int createdAt,
            required int updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              InstallmentOccurrencesCompanion.insert(
            id: id,
            templateId: templateId,
            sequenceNumber: sequenceNumber,
            scheduledDate: scheduledDate,
            amountMinor: amountMinor,
            status: status,
            childTransactionId: childTransactionId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$InstallmentOccurrencesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {templateId = false, childTransactionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (templateId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.templateId,
                    referencedTable: $$InstallmentOccurrencesTableReferences
                        ._templateIdTable(db),
                    referencedColumn: $$InstallmentOccurrencesTableReferences
                        ._templateIdTable(db)
                        .id,
                  ) as T;
                }
                if (childTransactionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.childTransactionId,
                    referencedTable: $$InstallmentOccurrencesTableReferences
                        ._childTransactionIdTable(db),
                    referencedColumn: $$InstallmentOccurrencesTableReferences
                        ._childTransactionIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$InstallmentOccurrencesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $InstallmentOccurrencesTable,
        InstallmentOccurrence,
        $$InstallmentOccurrencesTableFilterComposer,
        $$InstallmentOccurrencesTableOrderingComposer,
        $$InstallmentOccurrencesTableAnnotationComposer,
        $$InstallmentOccurrencesTableCreateCompanionBuilder,
        $$InstallmentOccurrencesTableUpdateCompanionBuilder,
        (InstallmentOccurrence, $$InstallmentOccurrencesTableReferences),
        InstallmentOccurrence,
        PrefetchHooks Function({bool templateId, bool childTransactionId})>;
typedef $$AppSettingsTableCreateCompanionBuilder = AppSettingsCompanion
    Function({
  required String key,
  Value<String?> value,
  required int updatedAt,
  Value<int> rowid,
});
typedef $$AppSettingsTableUpdateCompanionBuilder = AppSettingsCompanion
    Function({
  Value<String> key,
  Value<String?> value,
  Value<int> updatedAt,
  Value<int> rowid,
});

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AppSettingsTable,
    AppSetting,
    $$AppSettingsTableFilterComposer,
    $$AppSettingsTableOrderingComposer,
    $$AppSettingsTableAnnotationComposer,
    $$AppSettingsTableCreateCompanionBuilder,
    $$AppSettingsTableUpdateCompanionBuilder,
    (AppSetting, BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>),
    AppSetting,
    PrefetchHooks Function()> {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String?> value = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppSettingsCompanion(
            key: key,
            value: value,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            Value<String?> value = const Value.absent(),
            required int updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              AppSettingsCompanion.insert(
            key: key,
            value: value,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AppSettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AppSettingsTable,
    AppSetting,
    $$AppSettingsTableFilterComposer,
    $$AppSettingsTableOrderingComposer,
    $$AppSettingsTableAnnotationComposer,
    $$AppSettingsTableCreateCompanionBuilder,
    $$AppSettingsTableUpdateCompanionBuilder,
    (AppSetting, BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>),
    AppSetting,
    PrefetchHooks Function()>;
typedef $$DraftsTableCreateCompanionBuilder = DraftsCompanion Function({
  required String id,
  required String payloadJson,
  required int createdAt,
  required int updatedAt,
  Value<int> rowid,
});
typedef $$DraftsTableUpdateCompanionBuilder = DraftsCompanion Function({
  Value<String> id,
  Value<String> payloadJson,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int> rowid,
});

class $$DraftsTableFilterComposer
    extends Composer<_$AppDatabase, $DraftsTable> {
  $$DraftsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$DraftsTableOrderingComposer
    extends Composer<_$AppDatabase, $DraftsTable> {
  $$DraftsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$DraftsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DraftsTable> {
  $$DraftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DraftsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DraftsTable,
    Draft,
    $$DraftsTableFilterComposer,
    $$DraftsTableOrderingComposer,
    $$DraftsTableAnnotationComposer,
    $$DraftsTableCreateCompanionBuilder,
    $$DraftsTableUpdateCompanionBuilder,
    (Draft, BaseReferences<_$AppDatabase, $DraftsTable, Draft>),
    Draft,
    PrefetchHooks Function()> {
  $$DraftsTableTableManager(_$AppDatabase db, $DraftsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DraftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DraftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DraftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DraftsCompanion(
            id: id,
            payloadJson: payloadJson,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String payloadJson,
            required int createdAt,
            required int updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              DraftsCompanion.insert(
            id: id,
            payloadJson: payloadJson,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DraftsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DraftsTable,
    Draft,
    $$DraftsTableFilterComposer,
    $$DraftsTableOrderingComposer,
    $$DraftsTableAnnotationComposer,
    $$DraftsTableCreateCompanionBuilder,
    $$DraftsTableUpdateCompanionBuilder,
    (Draft, BaseReferences<_$AppDatabase, $DraftsTable, Draft>),
    Draft,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$AccountDetailsTableTableManager get accountDetails =>
      $$AccountDetailsTableTableManager(_db, _db.accountDetails);
  $$CurrenciesTableTableManager get currencies =>
      $$CurrenciesTableTableManager(_db, _db.currencies);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$PayeesTableTableManager get payees =>
      $$PayeesTableTableManager(_db, _db.payees);
  $$RecurringTemplatesTableTableManager get recurringTemplates =>
      $$RecurringTemplatesTableTableManager(_db, _db.recurringTemplates);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$EntriesTableTableManager get entries =>
      $$EntriesTableTableManager(_db, _db.entries);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$TransactionTagsTableTableManager get transactionTags =>
      $$TransactionTagsTableTableManager(_db, _db.transactionTags);
  $$ExchangeRatesTableTableManager get exchangeRates =>
      $$ExchangeRatesTableTableManager(_db, _db.exchangeRates);
  $$AttachmentsTableTableManager get attachments =>
      $$AttachmentsTableTableManager(_db, _db.attachments);
  $$BudgetsTableTableManager get budgets =>
      $$BudgetsTableTableManager(_db, _db.budgets);
  $$BudgetPeriodsTableTableManager get budgetPeriods =>
      $$BudgetPeriodsTableTableManager(_db, _db.budgetPeriods);
  $$ScheduledOccurrencesTableTableManager get scheduledOccurrences =>
      $$ScheduledOccurrencesTableTableManager(_db, _db.scheduledOccurrences);
  $$InstallmentPlansTableTableManager get installmentPlans =>
      $$InstallmentPlansTableTableManager(_db, _db.installmentPlans);
  $$InstallmentOccurrencesTableTableManager get installmentOccurrences =>
      $$InstallmentOccurrencesTableTableManager(
          _db, _db.installmentOccurrences);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$DraftsTableTableManager get drafts =>
      $$DraftsTableTableManager(_db, _db.drafts);
}
