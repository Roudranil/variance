// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'budget.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Budget {
  /// UUID v4 stable identifier.
  String get id;

  /// User label.
  String get name;

  /// Linked category UUID; null = total (all-categories) budget.
  String? get categoryId;

  /// Budget ceiling in minor units.
  int get amountMinor;

  /// Home currency of this budget.
  String get currencyCode;

  /// Recurrence horizon.
  BudgetPeriodType get periodType;

  /// Number of period units (e.g. periodN=1, periodType=monthly = monthly).
  int get periodN;

  /// Carry unused amount to the next period.
  bool get rollover;

  /// Whether this budget is currently active.
  bool get isActive;

  /// Creation epoch (Unix seconds).
  int get createdAt;

  /// Last-modified epoch (Unix seconds).
  int get updatedAt;

  /// Create a copy of Budget
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $BudgetCopyWith<Budget> get copyWith =>
      _$BudgetCopyWithImpl<Budget>(this as Budget, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Budget &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.amountMinor, amountMinor) ||
                other.amountMinor == amountMinor) &&
            (identical(other.currencyCode, currencyCode) ||
                other.currencyCode == currencyCode) &&
            (identical(other.periodType, periodType) ||
                other.periodType == periodType) &&
            (identical(other.periodN, periodN) || other.periodN == periodN) &&
            (identical(other.rollover, rollover) ||
                other.rollover == rollover) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
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
  String toString() {
    return 'Budget(id: $id, name: $name, categoryId: $categoryId, amountMinor: $amountMinor, currencyCode: $currencyCode, periodType: $periodType, periodN: $periodN, rollover: $rollover, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $BudgetCopyWith<$Res> {
  factory $BudgetCopyWith(Budget value, $Res Function(Budget) _then) =
      _$BudgetCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String name,
      String? categoryId,
      int amountMinor,
      String currencyCode,
      BudgetPeriodType periodType,
      int periodN,
      bool rollover,
      bool isActive,
      int createdAt,
      int updatedAt});
}

/// @nodoc
class _$BudgetCopyWithImpl<$Res> implements $BudgetCopyWith<$Res> {
  _$BudgetCopyWithImpl(this._self, this._then);

  final Budget _self;
  final $Res Function(Budget) _then;

  /// Create a copy of Budget
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? categoryId = freezed,
    Object? amountMinor = null,
    Object? currencyCode = null,
    Object? periodType = null,
    Object? periodN = null,
    Object? rollover = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
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
      categoryId: freezed == categoryId
          ? _self.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      amountMinor: null == amountMinor
          ? _self.amountMinor
          : amountMinor // ignore: cast_nullable_to_non_nullable
              as int,
      currencyCode: null == currencyCode
          ? _self.currencyCode
          : currencyCode // ignore: cast_nullable_to_non_nullable
              as String,
      periodType: null == periodType
          ? _self.periodType
          : periodType // ignore: cast_nullable_to_non_nullable
              as BudgetPeriodType,
      periodN: null == periodN
          ? _self.periodN
          : periodN // ignore: cast_nullable_to_non_nullable
              as int,
      rollover: null == rollover
          ? _self.rollover
          : rollover // ignore: cast_nullable_to_non_nullable
              as bool,
      isActive: null == isActive
          ? _self.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as int,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [Budget].
extension BudgetPatterns on Budget {
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
    TResult Function(_Budget value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Budget() when $default != null:
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
    TResult Function(_Budget value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Budget():
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
    TResult? Function(_Budget value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Budget() when $default != null:
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
            String? categoryId,
            int amountMinor,
            String currencyCode,
            BudgetPeriodType periodType,
            int periodN,
            bool rollover,
            bool isActive,
            int createdAt,
            int updatedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Budget() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.categoryId,
            _that.amountMinor,
            _that.currencyCode,
            _that.periodType,
            _that.periodN,
            _that.rollover,
            _that.isActive,
            _that.createdAt,
            _that.updatedAt);
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
            String? categoryId,
            int amountMinor,
            String currencyCode,
            BudgetPeriodType periodType,
            int periodN,
            bool rollover,
            bool isActive,
            int createdAt,
            int updatedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Budget():
        return $default(
            _that.id,
            _that.name,
            _that.categoryId,
            _that.amountMinor,
            _that.currencyCode,
            _that.periodType,
            _that.periodN,
            _that.rollover,
            _that.isActive,
            _that.createdAt,
            _that.updatedAt);
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
            String? categoryId,
            int amountMinor,
            String currencyCode,
            BudgetPeriodType periodType,
            int periodN,
            bool rollover,
            bool isActive,
            int createdAt,
            int updatedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Budget() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.categoryId,
            _that.amountMinor,
            _that.currencyCode,
            _that.periodType,
            _that.periodN,
            _that.rollover,
            _that.isActive,
            _that.createdAt,
            _that.updatedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Budget implements Budget {
  const _Budget(
      {required this.id,
      required this.name,
      this.categoryId,
      required this.amountMinor,
      required this.currencyCode,
      required this.periodType,
      this.periodN = 1,
      this.rollover = false,
      this.isActive = true,
      required this.createdAt,
      required this.updatedAt});

  /// UUID v4 stable identifier.
  @override
  final String id;

  /// User label.
  @override
  final String name;

  /// Linked category UUID; null = total (all-categories) budget.
  @override
  final String? categoryId;

  /// Budget ceiling in minor units.
  @override
  final int amountMinor;

  /// Home currency of this budget.
  @override
  final String currencyCode;

  /// Recurrence horizon.
  @override
  final BudgetPeriodType periodType;

  /// Number of period units (e.g. periodN=1, periodType=monthly = monthly).
  @override
  @JsonKey()
  final int periodN;

  /// Carry unused amount to the next period.
  @override
  @JsonKey()
  final bool rollover;

  /// Whether this budget is currently active.
  @override
  @JsonKey()
  final bool isActive;

  /// Creation epoch (Unix seconds).
  @override
  final int createdAt;

  /// Last-modified epoch (Unix seconds).
  @override
  final int updatedAt;

  /// Create a copy of Budget
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$BudgetCopyWith<_Budget> get copyWith =>
      __$BudgetCopyWithImpl<_Budget>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Budget &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.amountMinor, amountMinor) ||
                other.amountMinor == amountMinor) &&
            (identical(other.currencyCode, currencyCode) ||
                other.currencyCode == currencyCode) &&
            (identical(other.periodType, periodType) ||
                other.periodType == periodType) &&
            (identical(other.periodN, periodN) || other.periodN == periodN) &&
            (identical(other.rollover, rollover) ||
                other.rollover == rollover) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
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
  String toString() {
    return 'Budget(id: $id, name: $name, categoryId: $categoryId, amountMinor: $amountMinor, currencyCode: $currencyCode, periodType: $periodType, periodN: $periodN, rollover: $rollover, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$BudgetCopyWith<$Res> implements $BudgetCopyWith<$Res> {
  factory _$BudgetCopyWith(_Budget value, $Res Function(_Budget) _then) =
      __$BudgetCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? categoryId,
      int amountMinor,
      String currencyCode,
      BudgetPeriodType periodType,
      int periodN,
      bool rollover,
      bool isActive,
      int createdAt,
      int updatedAt});
}

/// @nodoc
class __$BudgetCopyWithImpl<$Res> implements _$BudgetCopyWith<$Res> {
  __$BudgetCopyWithImpl(this._self, this._then);

  final _Budget _self;
  final $Res Function(_Budget) _then;

  /// Create a copy of Budget
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? categoryId = freezed,
    Object? amountMinor = null,
    Object? currencyCode = null,
    Object? periodType = null,
    Object? periodN = null,
    Object? rollover = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_Budget(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      categoryId: freezed == categoryId
          ? _self.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      amountMinor: null == amountMinor
          ? _self.amountMinor
          : amountMinor // ignore: cast_nullable_to_non_nullable
              as int,
      currencyCode: null == currencyCode
          ? _self.currencyCode
          : currencyCode // ignore: cast_nullable_to_non_nullable
              as String,
      periodType: null == periodType
          ? _self.periodType
          : periodType // ignore: cast_nullable_to_non_nullable
              as BudgetPeriodType,
      periodN: null == periodN
          ? _self.periodN
          : periodN // ignore: cast_nullable_to_non_nullable
              as int,
      rollover: null == rollover
          ? _self.rollover
          : rollover // ignore: cast_nullable_to_non_nullable
              as bool,
      isActive: null == isActive
          ? _self.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as int,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
