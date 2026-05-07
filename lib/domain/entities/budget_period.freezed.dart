// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'budget_period.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BudgetPeriod {
  /// UUID v4 stable identifier.
  String get id;

  /// Parent budget UUID.
  String get budgetId;

  /// Period start epoch (inclusive, Unix seconds).
  int get periodStart;

  /// Period end epoch (exclusive, Unix seconds).
  int get periodEnd;

  /// Effective ceiling including carryover (minor units).
  int get budgetedMinor;

  /// Rolled-over amount from the previous period (minor units).
  int get carriedOverMinor;

  /// Creation epoch (Unix seconds).
  int get createdAt;

  /// Create a copy of BudgetPeriod
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $BudgetPeriodCopyWith<BudgetPeriod> get copyWith =>
      _$BudgetPeriodCopyWithImpl<BudgetPeriod>(
          this as BudgetPeriod, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is BudgetPeriod &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.budgetId, budgetId) ||
                other.budgetId == budgetId) &&
            (identical(other.periodStart, periodStart) ||
                other.periodStart == periodStart) &&
            (identical(other.periodEnd, periodEnd) ||
                other.periodEnd == periodEnd) &&
            (identical(other.budgetedMinor, budgetedMinor) ||
                other.budgetedMinor == budgetedMinor) &&
            (identical(other.carriedOverMinor, carriedOverMinor) ||
                other.carriedOverMinor == carriedOverMinor) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, budgetId, periodStart,
      periodEnd, budgetedMinor, carriedOverMinor, createdAt);

  @override
  String toString() {
    return 'BudgetPeriod(id: $id, budgetId: $budgetId, periodStart: $periodStart, periodEnd: $periodEnd, budgetedMinor: $budgetedMinor, carriedOverMinor: $carriedOverMinor, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $BudgetPeriodCopyWith<$Res> {
  factory $BudgetPeriodCopyWith(
          BudgetPeriod value, $Res Function(BudgetPeriod) _then) =
      _$BudgetPeriodCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String budgetId,
      int periodStart,
      int periodEnd,
      int budgetedMinor,
      int carriedOverMinor,
      int createdAt});
}

/// @nodoc
class _$BudgetPeriodCopyWithImpl<$Res> implements $BudgetPeriodCopyWith<$Res> {
  _$BudgetPeriodCopyWithImpl(this._self, this._then);

  final BudgetPeriod _self;
  final $Res Function(BudgetPeriod) _then;

  /// Create a copy of BudgetPeriod
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? budgetId = null,
    Object? periodStart = null,
    Object? periodEnd = null,
    Object? budgetedMinor = null,
    Object? carriedOverMinor = null,
    Object? createdAt = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      budgetId: null == budgetId
          ? _self.budgetId
          : budgetId // ignore: cast_nullable_to_non_nullable
              as String,
      periodStart: null == periodStart
          ? _self.periodStart
          : periodStart // ignore: cast_nullable_to_non_nullable
              as int,
      periodEnd: null == periodEnd
          ? _self.periodEnd
          : periodEnd // ignore: cast_nullable_to_non_nullable
              as int,
      budgetedMinor: null == budgetedMinor
          ? _self.budgetedMinor
          : budgetedMinor // ignore: cast_nullable_to_non_nullable
              as int,
      carriedOverMinor: null == carriedOverMinor
          ? _self.carriedOverMinor
          : carriedOverMinor // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [BudgetPeriod].
extension BudgetPeriodPatterns on BudgetPeriod {
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
    TResult Function(_BudgetPeriod value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _BudgetPeriod() when $default != null:
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
    TResult Function(_BudgetPeriod value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BudgetPeriod():
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
    TResult? Function(_BudgetPeriod value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BudgetPeriod() when $default != null:
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
    TResult Function(String id, String budgetId, int periodStart, int periodEnd,
            int budgetedMinor, int carriedOverMinor, int createdAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _BudgetPeriod() when $default != null:
        return $default(
            _that.id,
            _that.budgetId,
            _that.periodStart,
            _that.periodEnd,
            _that.budgetedMinor,
            _that.carriedOverMinor,
            _that.createdAt);
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
    TResult Function(String id, String budgetId, int periodStart, int periodEnd,
            int budgetedMinor, int carriedOverMinor, int createdAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BudgetPeriod():
        return $default(
            _that.id,
            _that.budgetId,
            _that.periodStart,
            _that.periodEnd,
            _that.budgetedMinor,
            _that.carriedOverMinor,
            _that.createdAt);
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
            String budgetId,
            int periodStart,
            int periodEnd,
            int budgetedMinor,
            int carriedOverMinor,
            int createdAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BudgetPeriod() when $default != null:
        return $default(
            _that.id,
            _that.budgetId,
            _that.periodStart,
            _that.periodEnd,
            _that.budgetedMinor,
            _that.carriedOverMinor,
            _that.createdAt);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _BudgetPeriod implements BudgetPeriod {
  const _BudgetPeriod(
      {required this.id,
      required this.budgetId,
      required this.periodStart,
      required this.periodEnd,
      required this.budgetedMinor,
      this.carriedOverMinor = 0,
      required this.createdAt});

  /// UUID v4 stable identifier.
  @override
  final String id;

  /// Parent budget UUID.
  @override
  final String budgetId;

  /// Period start epoch (inclusive, Unix seconds).
  @override
  final int periodStart;

  /// Period end epoch (exclusive, Unix seconds).
  @override
  final int periodEnd;

  /// Effective ceiling including carryover (minor units).
  @override
  final int budgetedMinor;

  /// Rolled-over amount from the previous period (minor units).
  @override
  @JsonKey()
  final int carriedOverMinor;

  /// Creation epoch (Unix seconds).
  @override
  final int createdAt;

  /// Create a copy of BudgetPeriod
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$BudgetPeriodCopyWith<_BudgetPeriod> get copyWith =>
      __$BudgetPeriodCopyWithImpl<_BudgetPeriod>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _BudgetPeriod &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.budgetId, budgetId) ||
                other.budgetId == budgetId) &&
            (identical(other.periodStart, periodStart) ||
                other.periodStart == periodStart) &&
            (identical(other.periodEnd, periodEnd) ||
                other.periodEnd == periodEnd) &&
            (identical(other.budgetedMinor, budgetedMinor) ||
                other.budgetedMinor == budgetedMinor) &&
            (identical(other.carriedOverMinor, carriedOverMinor) ||
                other.carriedOverMinor == carriedOverMinor) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, budgetId, periodStart,
      periodEnd, budgetedMinor, carriedOverMinor, createdAt);

  @override
  String toString() {
    return 'BudgetPeriod(id: $id, budgetId: $budgetId, periodStart: $periodStart, periodEnd: $periodEnd, budgetedMinor: $budgetedMinor, carriedOverMinor: $carriedOverMinor, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$BudgetPeriodCopyWith<$Res>
    implements $BudgetPeriodCopyWith<$Res> {
  factory _$BudgetPeriodCopyWith(
          _BudgetPeriod value, $Res Function(_BudgetPeriod) _then) =
      __$BudgetPeriodCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String budgetId,
      int periodStart,
      int periodEnd,
      int budgetedMinor,
      int carriedOverMinor,
      int createdAt});
}

/// @nodoc
class __$BudgetPeriodCopyWithImpl<$Res>
    implements _$BudgetPeriodCopyWith<$Res> {
  __$BudgetPeriodCopyWithImpl(this._self, this._then);

  final _BudgetPeriod _self;
  final $Res Function(_BudgetPeriod) _then;

  /// Create a copy of BudgetPeriod
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? budgetId = null,
    Object? periodStart = null,
    Object? periodEnd = null,
    Object? budgetedMinor = null,
    Object? carriedOverMinor = null,
    Object? createdAt = null,
  }) {
    return _then(_BudgetPeriod(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      budgetId: null == budgetId
          ? _self.budgetId
          : budgetId // ignore: cast_nullable_to_non_nullable
              as String,
      periodStart: null == periodStart
          ? _self.periodStart
          : periodStart // ignore: cast_nullable_to_non_nullable
              as int,
      periodEnd: null == periodEnd
          ? _self.periodEnd
          : periodEnd // ignore: cast_nullable_to_non_nullable
              as int,
      budgetedMinor: null == budgetedMinor
          ? _self.budgetedMinor
          : budgetedMinor // ignore: cast_nullable_to_non_nullable
              as int,
      carriedOverMinor: null == carriedOverMinor
          ? _self.carriedOverMinor
          : carriedOverMinor // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
