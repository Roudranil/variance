// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Entry {
  /// UUID v4 stable identifier.
  String get id;

  /// Parent transaction UUID.
  String get transactionId;

  /// Account leg — mutually exclusive with [categoryId].
  String? get accountId;

  /// Category leg — mutually exclusive with [accountId].
  String? get categoryId;

  /// DEB side of this entry.
  EntrySide get side;

  /// Amount in minor units of [currencyCode].
  int get amountMinor;

  /// ISO 4217 currency code of this entry.
  String get currencyCode;

  /// Rate to home currency × 1,000,000; null if same as home currency.
  int? get exchangeRateMicro;

  /// System write epoch (TC-025).
  int get createdAt;

  /// Create a copy of Entry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $EntryCopyWith<Entry> get copyWith =>
      _$EntryCopyWithImpl<Entry>(this as Entry, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Entry &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.transactionId, transactionId) ||
                other.transactionId == transactionId) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.side, side) || other.side == side) &&
            (identical(other.amountMinor, amountMinor) ||
                other.amountMinor == amountMinor) &&
            (identical(other.currencyCode, currencyCode) ||
                other.currencyCode == currencyCode) &&
            (identical(other.exchangeRateMicro, exchangeRateMicro) ||
                other.exchangeRateMicro == exchangeRateMicro) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      transactionId,
      accountId,
      categoryId,
      side,
      amountMinor,
      currencyCode,
      exchangeRateMicro,
      createdAt);

  @override
  String toString() {
    return 'Entry(id: $id, transactionId: $transactionId, accountId: $accountId, categoryId: $categoryId, side: $side, amountMinor: $amountMinor, currencyCode: $currencyCode, exchangeRateMicro: $exchangeRateMicro, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $EntryCopyWith<$Res> {
  factory $EntryCopyWith(Entry value, $Res Function(Entry) _then) =
      _$EntryCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String transactionId,
      String? accountId,
      String? categoryId,
      EntrySide side,
      int amountMinor,
      String currencyCode,
      int? exchangeRateMicro,
      int createdAt});
}

/// @nodoc
class _$EntryCopyWithImpl<$Res> implements $EntryCopyWith<$Res> {
  _$EntryCopyWithImpl(this._self, this._then);

  final Entry _self;
  final $Res Function(Entry) _then;

  /// Create a copy of Entry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? transactionId = null,
    Object? accountId = freezed,
    Object? categoryId = freezed,
    Object? side = null,
    Object? amountMinor = null,
    Object? currencyCode = null,
    Object? exchangeRateMicro = freezed,
    Object? createdAt = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      transactionId: null == transactionId
          ? _self.transactionId
          : transactionId // ignore: cast_nullable_to_non_nullable
              as String,
      accountId: freezed == accountId
          ? _self.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryId: freezed == categoryId
          ? _self.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      side: null == side
          ? _self.side
          : side // ignore: cast_nullable_to_non_nullable
              as EntrySide,
      amountMinor: null == amountMinor
          ? _self.amountMinor
          : amountMinor // ignore: cast_nullable_to_non_nullable
              as int,
      currencyCode: null == currencyCode
          ? _self.currencyCode
          : currencyCode // ignore: cast_nullable_to_non_nullable
              as String,
      exchangeRateMicro: freezed == exchangeRateMicro
          ? _self.exchangeRateMicro
          : exchangeRateMicro // ignore: cast_nullable_to_non_nullable
              as int?,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [Entry].
extension EntryPatterns on Entry {
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
    TResult Function(_Entry value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Entry() when $default != null:
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
    TResult Function(_Entry value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Entry():
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
    TResult? Function(_Entry value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Entry() when $default != null:
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
            String transactionId,
            String? accountId,
            String? categoryId,
            EntrySide side,
            int amountMinor,
            String currencyCode,
            int? exchangeRateMicro,
            int createdAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Entry() when $default != null:
        return $default(
            _that.id,
            _that.transactionId,
            _that.accountId,
            _that.categoryId,
            _that.side,
            _that.amountMinor,
            _that.currencyCode,
            _that.exchangeRateMicro,
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
    TResult Function(
            String id,
            String transactionId,
            String? accountId,
            String? categoryId,
            EntrySide side,
            int amountMinor,
            String currencyCode,
            int? exchangeRateMicro,
            int createdAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Entry():
        return $default(
            _that.id,
            _that.transactionId,
            _that.accountId,
            _that.categoryId,
            _that.side,
            _that.amountMinor,
            _that.currencyCode,
            _that.exchangeRateMicro,
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
            String transactionId,
            String? accountId,
            String? categoryId,
            EntrySide side,
            int amountMinor,
            String currencyCode,
            int? exchangeRateMicro,
            int createdAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Entry() when $default != null:
        return $default(
            _that.id,
            _that.transactionId,
            _that.accountId,
            _that.categoryId,
            _that.side,
            _that.amountMinor,
            _that.currencyCode,
            _that.exchangeRateMicro,
            _that.createdAt);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Entry implements Entry {
  const _Entry(
      {required this.id,
      required this.transactionId,
      this.accountId,
      this.categoryId,
      required this.side,
      required this.amountMinor,
      required this.currencyCode,
      this.exchangeRateMicro,
      required this.createdAt});

  /// UUID v4 stable identifier.
  @override
  final String id;

  /// Parent transaction UUID.
  @override
  final String transactionId;

  /// Account leg — mutually exclusive with [categoryId].
  @override
  final String? accountId;

  /// Category leg — mutually exclusive with [accountId].
  @override
  final String? categoryId;

  /// DEB side of this entry.
  @override
  final EntrySide side;

  /// Amount in minor units of [currencyCode].
  @override
  final int amountMinor;

  /// ISO 4217 currency code of this entry.
  @override
  final String currencyCode;

  /// Rate to home currency × 1,000,000; null if same as home currency.
  @override
  final int? exchangeRateMicro;

  /// System write epoch (TC-025).
  @override
  final int createdAt;

  /// Create a copy of Entry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$EntryCopyWith<_Entry> get copyWith =>
      __$EntryCopyWithImpl<_Entry>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Entry &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.transactionId, transactionId) ||
                other.transactionId == transactionId) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.side, side) || other.side == side) &&
            (identical(other.amountMinor, amountMinor) ||
                other.amountMinor == amountMinor) &&
            (identical(other.currencyCode, currencyCode) ||
                other.currencyCode == currencyCode) &&
            (identical(other.exchangeRateMicro, exchangeRateMicro) ||
                other.exchangeRateMicro == exchangeRateMicro) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      transactionId,
      accountId,
      categoryId,
      side,
      amountMinor,
      currencyCode,
      exchangeRateMicro,
      createdAt);

  @override
  String toString() {
    return 'Entry(id: $id, transactionId: $transactionId, accountId: $accountId, categoryId: $categoryId, side: $side, amountMinor: $amountMinor, currencyCode: $currencyCode, exchangeRateMicro: $exchangeRateMicro, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$EntryCopyWith<$Res> implements $EntryCopyWith<$Res> {
  factory _$EntryCopyWith(_Entry value, $Res Function(_Entry) _then) =
      __$EntryCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String transactionId,
      String? accountId,
      String? categoryId,
      EntrySide side,
      int amountMinor,
      String currencyCode,
      int? exchangeRateMicro,
      int createdAt});
}

/// @nodoc
class __$EntryCopyWithImpl<$Res> implements _$EntryCopyWith<$Res> {
  __$EntryCopyWithImpl(this._self, this._then);

  final _Entry _self;
  final $Res Function(_Entry) _then;

  /// Create a copy of Entry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? transactionId = null,
    Object? accountId = freezed,
    Object? categoryId = freezed,
    Object? side = null,
    Object? amountMinor = null,
    Object? currencyCode = null,
    Object? exchangeRateMicro = freezed,
    Object? createdAt = null,
  }) {
    return _then(_Entry(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      transactionId: null == transactionId
          ? _self.transactionId
          : transactionId // ignore: cast_nullable_to_non_nullable
              as String,
      accountId: freezed == accountId
          ? _self.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryId: freezed == categoryId
          ? _self.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      side: null == side
          ? _self.side
          : side // ignore: cast_nullable_to_non_nullable
              as EntrySide,
      amountMinor: null == amountMinor
          ? _self.amountMinor
          : amountMinor // ignore: cast_nullable_to_non_nullable
              as int,
      currencyCode: null == currencyCode
          ? _self.currencyCode
          : currencyCode // ignore: cast_nullable_to_non_nullable
              as String,
      exchangeRateMicro: freezed == exchangeRateMicro
          ? _self.exchangeRateMicro
          : exchangeRateMicro // ignore: cast_nullable_to_non_nullable
              as int?,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
