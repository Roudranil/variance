// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'money.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Money {
  /// Amount in the smallest denomination of [currencyCode].
  int get amountMinor;

  /// ISO 4217 three-letter currency code (e.g. 'USD', 'INR', 'JPY').
  String get currencyCode;

  /// Create a copy of Money
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MoneyCopyWith<Money> get copyWith =>
      _$MoneyCopyWithImpl<Money>(this as Money, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Money &&
            (identical(other.amountMinor, amountMinor) ||
                other.amountMinor == amountMinor) &&
            (identical(other.currencyCode, currencyCode) ||
                other.currencyCode == currencyCode));
  }

  @override
  int get hashCode => Object.hash(runtimeType, amountMinor, currencyCode);

  @override
  String toString() {
    return 'Money(amountMinor: $amountMinor, currencyCode: $currencyCode)';
  }
}

/// @nodoc
abstract mixin class $MoneyCopyWith<$Res> {
  factory $MoneyCopyWith(Money value, $Res Function(Money) _then) =
      _$MoneyCopyWithImpl;
  @useResult
  $Res call({int amountMinor, String currencyCode});
}

/// @nodoc
class _$MoneyCopyWithImpl<$Res> implements $MoneyCopyWith<$Res> {
  _$MoneyCopyWithImpl(this._self, this._then);

  final Money _self;
  final $Res Function(Money) _then;

  /// Create a copy of Money
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? amountMinor = null,
    Object? currencyCode = null,
  }) {
    return _then(_self.copyWith(
      amountMinor: null == amountMinor
          ? _self.amountMinor
          : amountMinor // ignore: cast_nullable_to_non_nullable
              as int,
      currencyCode: null == currencyCode
          ? _self.currencyCode
          : currencyCode // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [Money].
extension MoneyPatterns on Money {
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
    TResult Function(_Money value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Money() when $default != null:
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
    TResult Function(_Money value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Money():
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
    TResult? Function(_Money value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Money() when $default != null:
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
    TResult Function(int amountMinor, String currencyCode)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Money() when $default != null:
        return $default(_that.amountMinor, _that.currencyCode);
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
    TResult Function(int amountMinor, String currencyCode) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Money():
        return $default(_that.amountMinor, _that.currencyCode);
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
    TResult? Function(int amountMinor, String currencyCode)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Money() when $default != null:
        return $default(_that.amountMinor, _that.currencyCode);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Money implements Money {
  const _Money({required this.amountMinor, required this.currencyCode});

  /// Amount in the smallest denomination of [currencyCode].
  @override
  final int amountMinor;

  /// ISO 4217 three-letter currency code (e.g. 'USD', 'INR', 'JPY').
  @override
  final String currencyCode;

  /// Create a copy of Money
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MoneyCopyWith<_Money> get copyWith =>
      __$MoneyCopyWithImpl<_Money>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Money &&
            (identical(other.amountMinor, amountMinor) ||
                other.amountMinor == amountMinor) &&
            (identical(other.currencyCode, currencyCode) ||
                other.currencyCode == currencyCode));
  }

  @override
  int get hashCode => Object.hash(runtimeType, amountMinor, currencyCode);

  @override
  String toString() {
    return 'Money(amountMinor: $amountMinor, currencyCode: $currencyCode)';
  }
}

/// @nodoc
abstract mixin class _$MoneyCopyWith<$Res> implements $MoneyCopyWith<$Res> {
  factory _$MoneyCopyWith(_Money value, $Res Function(_Money) _then) =
      __$MoneyCopyWithImpl;
  @override
  @useResult
  $Res call({int amountMinor, String currencyCode});
}

/// @nodoc
class __$MoneyCopyWithImpl<$Res> implements _$MoneyCopyWith<$Res> {
  __$MoneyCopyWithImpl(this._self, this._then);

  final _Money _self;
  final $Res Function(_Money) _then;

  /// Create a copy of Money
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? amountMinor = null,
    Object? currencyCode = null,
  }) {
    return _then(_Money(
      amountMinor: null == amountMinor
          ? _self.amountMinor
          : amountMinor // ignore: cast_nullable_to_non_nullable
              as int,
      currencyCode: null == currencyCode
          ? _self.currencyCode
          : currencyCode // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
