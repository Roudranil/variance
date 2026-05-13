// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Account {
  /// UUID v4 stable identifier.
  String get id;

  /// User-visible display name.
  String get name;

  /// Account type discriminator.
  AccountCategory get accountCategory;

  /// Opening balance in minor units of [currencyCode].
  ///
  /// Applied once at account creation; never changed.
  int get initialBalanceMinor;

  /// ISO 4217 code; immutable after creation.
  String get currencyCode;

  /// Whether to include this account in net worth calculations.
  bool get includeInNetWorth;

  /// Optional free-form note.
  String? get notes;

  /// Soft-delete flag.
  bool get isDeleted;

  /// Unix epoch seconds; set when [isDeleted] becomes true.
  int? get deletedAt;

  /// True for EQ and BAI/BAE accounts; blocks user deletion.
  bool get isProtected;

  /// True for system-generated accounts (EQ per currency); hidden from views.
  bool get isSystem;

  /// User-defined sort position; null = alphabetical.
  int? get displayOrder;

  /// Creation epoch (Unix seconds).
  int get createdAt;

  /// Last-modified epoch (Unix seconds).
  int get updatedAt;

  /// JSON escape hatch for forward-compatible extensions.
  String? get metadata;

  /// Per-account large-transaction warning threshold in the account's native
  /// currency (minor units). Null means no threshold is set.
  ///
  /// When a transaction amount exceeds this value, the app shows a warning
  /// before posting (TC-047, SDS §5.4.4).
  int? get largeTxnThresholdMinor;

  /// Create a copy of Account
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AccountCopyWith<Account> get copyWith =>
      _$AccountCopyWithImpl<Account>(this as Account, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Account &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.accountCategory, accountCategory) ||
                other.accountCategory == accountCategory) &&
            (identical(other.initialBalanceMinor, initialBalanceMinor) ||
                other.initialBalanceMinor == initialBalanceMinor) &&
            (identical(other.currencyCode, currencyCode) ||
                other.currencyCode == currencyCode) &&
            (identical(other.includeInNetWorth, includeInNetWorth) ||
                other.includeInNetWorth == includeInNetWorth) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.isDeleted, isDeleted) ||
                other.isDeleted == isDeleted) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.isProtected, isProtected) ||
                other.isProtected == isProtected) &&
            (identical(other.isSystem, isSystem) ||
                other.isSystem == isSystem) &&
            (identical(other.displayOrder, displayOrder) ||
                other.displayOrder == displayOrder) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.metadata, metadata) ||
                other.metadata == metadata) &&
            (identical(other.largeTxnThresholdMinor, largeTxnThresholdMinor) ||
                other.largeTxnThresholdMinor == largeTxnThresholdMinor));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
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
  String toString() {
    return 'Account(id: $id, name: $name, accountCategory: $accountCategory, initialBalanceMinor: $initialBalanceMinor, currencyCode: $currencyCode, includeInNetWorth: $includeInNetWorth, notes: $notes, isDeleted: $isDeleted, deletedAt: $deletedAt, isProtected: $isProtected, isSystem: $isSystem, displayOrder: $displayOrder, createdAt: $createdAt, updatedAt: $updatedAt, metadata: $metadata, largeTxnThresholdMinor: $largeTxnThresholdMinor)';
  }
}

/// @nodoc
abstract mixin class $AccountCopyWith<$Res> {
  factory $AccountCopyWith(Account value, $Res Function(Account) _then) =
      _$AccountCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String name,
      AccountCategory accountCategory,
      int initialBalanceMinor,
      String currencyCode,
      bool includeInNetWorth,
      String? notes,
      bool isDeleted,
      int? deletedAt,
      bool isProtected,
      bool isSystem,
      int? displayOrder,
      int createdAt,
      int updatedAt,
      String? metadata,
      int? largeTxnThresholdMinor});
}

/// @nodoc
class _$AccountCopyWithImpl<$Res> implements $AccountCopyWith<$Res> {
  _$AccountCopyWithImpl(this._self, this._then);

  final Account _self;
  final $Res Function(Account) _then;

  /// Create a copy of Account
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? accountCategory = null,
    Object? initialBalanceMinor = null,
    Object? currencyCode = null,
    Object? includeInNetWorth = null,
    Object? notes = freezed,
    Object? isDeleted = null,
    Object? deletedAt = freezed,
    Object? isProtected = null,
    Object? isSystem = null,
    Object? displayOrder = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? metadata = freezed,
    Object? largeTxnThresholdMinor = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      accountCategory: null == accountCategory
          ? _self.accountCategory
          : accountCategory // ignore: cast_nullable_to_non_nullable
              as AccountCategory,
      initialBalanceMinor: null == initialBalanceMinor
          ? _self.initialBalanceMinor
          : initialBalanceMinor // ignore: cast_nullable_to_non_nullable
              as int,
      currencyCode: null == currencyCode
          ? _self.currencyCode
          : currencyCode // ignore: cast_nullable_to_non_nullable
              as String,
      includeInNetWorth: null == includeInNetWorth
          ? _self.includeInNetWorth
          : includeInNetWorth // ignore: cast_nullable_to_non_nullable
              as bool,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      isDeleted: null == isDeleted
          ? _self.isDeleted
          : isDeleted // ignore: cast_nullable_to_non_nullable
              as bool,
      deletedAt: freezed == deletedAt
          ? _self.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as int?,
      isProtected: null == isProtected
          ? _self.isProtected
          : isProtected // ignore: cast_nullable_to_non_nullable
              as bool,
      isSystem: null == isSystem
          ? _self.isSystem
          : isSystem // ignore: cast_nullable_to_non_nullable
              as bool,
      displayOrder: freezed == displayOrder
          ? _self.displayOrder
          : displayOrder // ignore: cast_nullable_to_non_nullable
              as int?,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as int,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as int,
      metadata: freezed == metadata
          ? _self.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as String?,
      largeTxnThresholdMinor: freezed == largeTxnThresholdMinor
          ? _self.largeTxnThresholdMinor
          : largeTxnThresholdMinor // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// Adds pattern-matching-related methods to [Account].
extension AccountPatterns on Account {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Account value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Account() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_Account value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Account():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Account value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Account() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
            String name,
            AccountCategory accountCategory,
            int initialBalanceMinor,
            String currencyCode,
            bool includeInNetWorth,
            String? notes,
            bool isDeleted,
            int? deletedAt,
            bool isProtected,
            bool isSystem,
            int? displayOrder,
            int createdAt,
            int updatedAt,
            String? metadata,
            int? largeTxnThresholdMinor)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Account() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.accountCategory,
            _that.initialBalanceMinor,
            _that.currencyCode,
            _that.includeInNetWorth,
            _that.notes,
            _that.isDeleted,
            _that.deletedAt,
            _that.isProtected,
            _that.isSystem,
            _that.displayOrder,
            _that.createdAt,
            _that.updatedAt,
            _that.metadata,
            _that.largeTxnThresholdMinor);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            String name,
            AccountCategory accountCategory,
            int initialBalanceMinor,
            String currencyCode,
            bool includeInNetWorth,
            String? notes,
            bool isDeleted,
            int? deletedAt,
            bool isProtected,
            bool isSystem,
            int? displayOrder,
            int createdAt,
            int updatedAt,
            String? metadata,
            int? largeTxnThresholdMinor)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Account():
        return $default(
            _that.id,
            _that.name,
            _that.accountCategory,
            _that.initialBalanceMinor,
            _that.currencyCode,
            _that.includeInNetWorth,
            _that.notes,
            _that.isDeleted,
            _that.deletedAt,
            _that.isProtected,
            _that.isSystem,
            _that.displayOrder,
            _that.createdAt,
            _that.updatedAt,
            _that.metadata,
            _that.largeTxnThresholdMinor);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
            String name,
            AccountCategory accountCategory,
            int initialBalanceMinor,
            String currencyCode,
            bool includeInNetWorth,
            String? notes,
            bool isDeleted,
            int? deletedAt,
            bool isProtected,
            bool isSystem,
            int? displayOrder,
            int createdAt,
            int updatedAt,
            String? metadata,
            int? largeTxnThresholdMinor)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Account() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.accountCategory,
            _that.initialBalanceMinor,
            _that.currencyCode,
            _that.includeInNetWorth,
            _that.notes,
            _that.isDeleted,
            _that.deletedAt,
            _that.isProtected,
            _that.isSystem,
            _that.displayOrder,
            _that.createdAt,
            _that.updatedAt,
            _that.metadata,
            _that.largeTxnThresholdMinor);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Account implements Account {
  const _Account(
      {required this.id,
      required this.name,
      required this.accountCategory,
      this.initialBalanceMinor = 0,
      required this.currencyCode,
      this.includeInNetWorth = true,
      this.notes,
      this.isDeleted = false,
      this.deletedAt,
      this.isProtected = false,
      this.isSystem = false,
      this.displayOrder,
      required this.createdAt,
      required this.updatedAt,
      this.metadata,
      this.largeTxnThresholdMinor});

  /// UUID v4 stable identifier.
  @override
  final String id;

  /// User-visible display name.
  @override
  final String name;

  /// Account type discriminator.
  @override
  final AccountCategory accountCategory;

  /// Opening balance in minor units of [currencyCode].
  ///
  /// Applied once at account creation; never changed.
  @override
  @JsonKey()
  final int initialBalanceMinor;

  /// ISO 4217 code; immutable after creation.
  @override
  final String currencyCode;

  /// Whether to include this account in net worth calculations.
  @override
  @JsonKey()
  final bool includeInNetWorth;

  /// Optional free-form note.
  @override
  final String? notes;

  /// Soft-delete flag.
  @override
  @JsonKey()
  final bool isDeleted;

  /// Unix epoch seconds; set when [isDeleted] becomes true.
  @override
  final int? deletedAt;

  /// True for EQ and BAI/BAE accounts; blocks user deletion.
  @override
  @JsonKey()
  final bool isProtected;

  /// True for system-generated accounts (EQ per currency); hidden from views.
  @override
  @JsonKey()
  final bool isSystem;

  /// User-defined sort position; null = alphabetical.
  @override
  final int? displayOrder;

  /// Creation epoch (Unix seconds).
  @override
  final int createdAt;

  /// Last-modified epoch (Unix seconds).
  @override
  final int updatedAt;

  /// JSON escape hatch for forward-compatible extensions.
  @override
  final String? metadata;

  /// Per-account large-transaction warning threshold in the account's native
  /// currency (minor units). Null means no threshold is set.
  ///
  /// When a transaction amount exceeds this value, the app shows a warning
  /// before posting (TC-047, SDS §5.4.4).
  @override
  final int? largeTxnThresholdMinor;

  /// Create a copy of Account
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AccountCopyWith<_Account> get copyWith =>
      __$AccountCopyWithImpl<_Account>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Account &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.accountCategory, accountCategory) ||
                other.accountCategory == accountCategory) &&
            (identical(other.initialBalanceMinor, initialBalanceMinor) ||
                other.initialBalanceMinor == initialBalanceMinor) &&
            (identical(other.currencyCode, currencyCode) ||
                other.currencyCode == currencyCode) &&
            (identical(other.includeInNetWorth, includeInNetWorth) ||
                other.includeInNetWorth == includeInNetWorth) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.isDeleted, isDeleted) ||
                other.isDeleted == isDeleted) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.isProtected, isProtected) ||
                other.isProtected == isProtected) &&
            (identical(other.isSystem, isSystem) ||
                other.isSystem == isSystem) &&
            (identical(other.displayOrder, displayOrder) ||
                other.displayOrder == displayOrder) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.metadata, metadata) ||
                other.metadata == metadata) &&
            (identical(other.largeTxnThresholdMinor, largeTxnThresholdMinor) ||
                other.largeTxnThresholdMinor == largeTxnThresholdMinor));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
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
  String toString() {
    return 'Account(id: $id, name: $name, accountCategory: $accountCategory, initialBalanceMinor: $initialBalanceMinor, currencyCode: $currencyCode, includeInNetWorth: $includeInNetWorth, notes: $notes, isDeleted: $isDeleted, deletedAt: $deletedAt, isProtected: $isProtected, isSystem: $isSystem, displayOrder: $displayOrder, createdAt: $createdAt, updatedAt: $updatedAt, metadata: $metadata, largeTxnThresholdMinor: $largeTxnThresholdMinor)';
  }
}

/// @nodoc
abstract mixin class _$AccountCopyWith<$Res> implements $AccountCopyWith<$Res> {
  factory _$AccountCopyWith(_Account value, $Res Function(_Account) _then) =
      __$AccountCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      AccountCategory accountCategory,
      int initialBalanceMinor,
      String currencyCode,
      bool includeInNetWorth,
      String? notes,
      bool isDeleted,
      int? deletedAt,
      bool isProtected,
      bool isSystem,
      int? displayOrder,
      int createdAt,
      int updatedAt,
      String? metadata,
      int? largeTxnThresholdMinor});
}

/// @nodoc
class __$AccountCopyWithImpl<$Res> implements _$AccountCopyWith<$Res> {
  __$AccountCopyWithImpl(this._self, this._then);

  final _Account _self;
  final $Res Function(_Account) _then;

  /// Create a copy of Account
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? accountCategory = null,
    Object? initialBalanceMinor = null,
    Object? currencyCode = null,
    Object? includeInNetWorth = null,
    Object? notes = freezed,
    Object? isDeleted = null,
    Object? deletedAt = freezed,
    Object? isProtected = null,
    Object? isSystem = null,
    Object? displayOrder = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? metadata = freezed,
    Object? largeTxnThresholdMinor = freezed,
  }) {
    return _then(_Account(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      accountCategory: null == accountCategory
          ? _self.accountCategory
          : accountCategory // ignore: cast_nullable_to_non_nullable
              as AccountCategory,
      initialBalanceMinor: null == initialBalanceMinor
          ? _self.initialBalanceMinor
          : initialBalanceMinor // ignore: cast_nullable_to_non_nullable
              as int,
      currencyCode: null == currencyCode
          ? _self.currencyCode
          : currencyCode // ignore: cast_nullable_to_non_nullable
              as String,
      includeInNetWorth: null == includeInNetWorth
          ? _self.includeInNetWorth
          : includeInNetWorth // ignore: cast_nullable_to_non_nullable
              as bool,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      isDeleted: null == isDeleted
          ? _self.isDeleted
          : isDeleted // ignore: cast_nullable_to_non_nullable
              as bool,
      deletedAt: freezed == deletedAt
          ? _self.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as int?,
      isProtected: null == isProtected
          ? _self.isProtected
          : isProtected // ignore: cast_nullable_to_non_nullable
              as bool,
      isSystem: null == isSystem
          ? _self.isSystem
          : isSystem // ignore: cast_nullable_to_non_nullable
              as bool,
      displayOrder: freezed == displayOrder
          ? _self.displayOrder
          : displayOrder // ignore: cast_nullable_to_non_nullable
              as int?,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as int,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as int,
      metadata: freezed == metadata
          ? _self.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as String?,
      largeTxnThresholdMinor: freezed == largeTxnThresholdMinor
          ? _self.largeTxnThresholdMinor
          : largeTxnThresholdMinor // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

// dart format on
