// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exchange_rate.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExchangeRate {
  /// Row identifier (auto-increment, not UUID, per data model §4.2).
  int get id;

  /// Base currency ISO 4217 code.
  String get fromCurrency;

  /// Target currency ISO 4217 code.
  String get toCurrency;

  /// Exchange rate × 1,000,000 (6 decimal precision).
  int get rateMicro;

  /// Wall-clock epoch when the rate was fetched from the API.
  int get fetchedAt;

  /// Publication date from the API `date` field (ISO 8601, e.g. '2025-05-07').
  String get rateDate;

  /// Create a copy of ExchangeRate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ExchangeRateCopyWith<ExchangeRate> get copyWith =>
      _$ExchangeRateCopyWithImpl<ExchangeRate>(
          this as ExchangeRate, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ExchangeRate &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.fromCurrency, fromCurrency) ||
                other.fromCurrency == fromCurrency) &&
            (identical(other.toCurrency, toCurrency) ||
                other.toCurrency == toCurrency) &&
            (identical(other.rateMicro, rateMicro) ||
                other.rateMicro == rateMicro) &&
            (identical(other.fetchedAt, fetchedAt) ||
                other.fetchedAt == fetchedAt) &&
            (identical(other.rateDate, rateDate) ||
                other.rateDate == rateDate));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, fromCurrency, toCurrency,
      rateMicro, fetchedAt, rateDate);

  @override
  String toString() {
    return 'ExchangeRate(id: $id, fromCurrency: $fromCurrency, toCurrency: $toCurrency, rateMicro: $rateMicro, fetchedAt: $fetchedAt, rateDate: $rateDate)';
  }
}

/// @nodoc
abstract mixin class $ExchangeRateCopyWith<$Res> {
  factory $ExchangeRateCopyWith(
          ExchangeRate value, $Res Function(ExchangeRate) _then) =
      _$ExchangeRateCopyWithImpl;
  @useResult
  $Res call(
      {int id,
      String fromCurrency,
      String toCurrency,
      int rateMicro,
      int fetchedAt,
      String rateDate});
}

/// @nodoc
class _$ExchangeRateCopyWithImpl<$Res> implements $ExchangeRateCopyWith<$Res> {
  _$ExchangeRateCopyWithImpl(this._self, this._then);

  final ExchangeRate _self;
  final $Res Function(ExchangeRate) _then;

  /// Create a copy of ExchangeRate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fromCurrency = null,
    Object? toCurrency = null,
    Object? rateMicro = null,
    Object? fetchedAt = null,
    Object? rateDate = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      fromCurrency: null == fromCurrency
          ? _self.fromCurrency
          : fromCurrency // ignore: cast_nullable_to_non_nullable
              as String,
      toCurrency: null == toCurrency
          ? _self.toCurrency
          : toCurrency // ignore: cast_nullable_to_non_nullable
              as String,
      rateMicro: null == rateMicro
          ? _self.rateMicro
          : rateMicro // ignore: cast_nullable_to_non_nullable
              as int,
      fetchedAt: null == fetchedAt
          ? _self.fetchedAt
          : fetchedAt // ignore: cast_nullable_to_non_nullable
              as int,
      rateDate: null == rateDate
          ? _self.rateDate
          : rateDate // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [ExchangeRate].
extension ExchangeRatePatterns on ExchangeRate {
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
    TResult Function(_ExchangeRate value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ExchangeRate() when $default != null:
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
    TResult Function(_ExchangeRate value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ExchangeRate():
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
    TResult? Function(_ExchangeRate value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ExchangeRate() when $default != null:
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
    TResult Function(int id, String fromCurrency, String toCurrency,
            int rateMicro, int fetchedAt, String rateDate)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ExchangeRate() when $default != null:
        return $default(_that.id, _that.fromCurrency, _that.toCurrency,
            _that.rateMicro, _that.fetchedAt, _that.rateDate);
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
    TResult Function(int id, String fromCurrency, String toCurrency,
            int rateMicro, int fetchedAt, String rateDate)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ExchangeRate():
        return $default(_that.id, _that.fromCurrency, _that.toCurrency,
            _that.rateMicro, _that.fetchedAt, _that.rateDate);
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
    TResult? Function(int id, String fromCurrency, String toCurrency,
            int rateMicro, int fetchedAt, String rateDate)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ExchangeRate() when $default != null:
        return $default(_that.id, _that.fromCurrency, _that.toCurrency,
            _that.rateMicro, _that.fetchedAt, _that.rateDate);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ExchangeRate extends ExchangeRate {
  const _ExchangeRate(
      {required this.id,
      required this.fromCurrency,
      required this.toCurrency,
      required this.rateMicro,
      required this.fetchedAt,
      required this.rateDate})
      : super._();

  /// Row identifier (auto-increment, not UUID, per data model §4.2).
  @override
  final int id;

  /// Base currency ISO 4217 code.
  @override
  final String fromCurrency;

  /// Target currency ISO 4217 code.
  @override
  final String toCurrency;

  /// Exchange rate × 1,000,000 (6 decimal precision).
  @override
  final int rateMicro;

  /// Wall-clock epoch when the rate was fetched from the API.
  @override
  final int fetchedAt;

  /// Publication date from the API `date` field (ISO 8601, e.g. '2025-05-07').
  @override
  final String rateDate;

  /// Create a copy of ExchangeRate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ExchangeRateCopyWith<_ExchangeRate> get copyWith =>
      __$ExchangeRateCopyWithImpl<_ExchangeRate>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ExchangeRate &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.fromCurrency, fromCurrency) ||
                other.fromCurrency == fromCurrency) &&
            (identical(other.toCurrency, toCurrency) ||
                other.toCurrency == toCurrency) &&
            (identical(other.rateMicro, rateMicro) ||
                other.rateMicro == rateMicro) &&
            (identical(other.fetchedAt, fetchedAt) ||
                other.fetchedAt == fetchedAt) &&
            (identical(other.rateDate, rateDate) ||
                other.rateDate == rateDate));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, fromCurrency, toCurrency,
      rateMicro, fetchedAt, rateDate);

  @override
  String toString() {
    return 'ExchangeRate(id: $id, fromCurrency: $fromCurrency, toCurrency: $toCurrency, rateMicro: $rateMicro, fetchedAt: $fetchedAt, rateDate: $rateDate)';
  }
}

/// @nodoc
abstract mixin class _$ExchangeRateCopyWith<$Res>
    implements $ExchangeRateCopyWith<$Res> {
  factory _$ExchangeRateCopyWith(
          _ExchangeRate value, $Res Function(_ExchangeRate) _then) =
      __$ExchangeRateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int id,
      String fromCurrency,
      String toCurrency,
      int rateMicro,
      int fetchedAt,
      String rateDate});
}

/// @nodoc
class __$ExchangeRateCopyWithImpl<$Res>
    implements _$ExchangeRateCopyWith<$Res> {
  __$ExchangeRateCopyWithImpl(this._self, this._then);

  final _ExchangeRate _self;
  final $Res Function(_ExchangeRate) _then;

  /// Create a copy of ExchangeRate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? fromCurrency = null,
    Object? toCurrency = null,
    Object? rateMicro = null,
    Object? fetchedAt = null,
    Object? rateDate = null,
  }) {
    return _then(_ExchangeRate(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      fromCurrency: null == fromCurrency
          ? _self.fromCurrency
          : fromCurrency // ignore: cast_nullable_to_non_nullable
              as String,
      toCurrency: null == toCurrency
          ? _self.toCurrency
          : toCurrency // ignore: cast_nullable_to_non_nullable
              as String,
      rateMicro: null == rateMicro
          ? _self.rateMicro
          : rateMicro // ignore: cast_nullable_to_non_nullable
              as int,
      fetchedAt: null == fetchedAt
          ? _self.fetchedAt
          : fetchedAt // ignore: cast_nullable_to_non_nullable
              as int,
      rateDate: null == rateDate
          ? _self.rateDate
          : rateDate // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
