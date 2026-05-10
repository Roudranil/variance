// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AccountDetail {
  /// UUID v4 stable identifier for this detail row.
  String get id;

  /// UUID of the parent [Account].
  String get accountId;

  /// Field name (e.g. `bank_name`, `card_number`).
  ///
  /// Valid values are defined in data model §3.2.
  String get detailKey;

  /// Plain-text value for non-sensitive fields.
  ///
  /// Null when [detailValueEncrypted] is populated (sensitive fields).
  String? get detailValue;

  /// AES-encrypted blob for sensitive fields (card_number, account_number).
  ///
  /// Null for non-sensitive fields. Only one of [detailValue] or
  /// [detailValueEncrypted] should be non-null at a time.
  String? get detailValueEncrypted;

  /// Last-modified epoch (Unix seconds).
  int get updatedAt;

  /// Create a copy of AccountDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AccountDetailCopyWith<AccountDetail> get copyWith =>
      _$AccountDetailCopyWithImpl<AccountDetail>(
          this as AccountDetail, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AccountDetail &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.detailKey, detailKey) ||
                other.detailKey == detailKey) &&
            (identical(other.detailValue, detailValue) ||
                other.detailValue == detailValue) &&
            (identical(other.detailValueEncrypted, detailValueEncrypted) ||
                other.detailValueEncrypted == detailValueEncrypted) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, accountId, detailKey,
      detailValue, detailValueEncrypted, updatedAt);

  @override
  String toString() {
    return 'AccountDetail(id: $id, accountId: $accountId, detailKey: $detailKey, detailValue: $detailValue, detailValueEncrypted: $detailValueEncrypted, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $AccountDetailCopyWith<$Res> {
  factory $AccountDetailCopyWith(
          AccountDetail value, $Res Function(AccountDetail) _then) =
      _$AccountDetailCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String accountId,
      String detailKey,
      String? detailValue,
      String? detailValueEncrypted,
      int updatedAt});
}

/// @nodoc
class _$AccountDetailCopyWithImpl<$Res>
    implements $AccountDetailCopyWith<$Res> {
  _$AccountDetailCopyWithImpl(this._self, this._then);

  final AccountDetail _self;
  final $Res Function(AccountDetail) _then;

  /// Create a copy of AccountDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? accountId = null,
    Object? detailKey = null,
    Object? detailValue = freezed,
    Object? detailValueEncrypted = freezed,
    Object? updatedAt = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      accountId: null == accountId
          ? _self.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as String,
      detailKey: null == detailKey
          ? _self.detailKey
          : detailKey // ignore: cast_nullable_to_non_nullable
              as String,
      detailValue: freezed == detailValue
          ? _self.detailValue
          : detailValue // ignore: cast_nullable_to_non_nullable
              as String?,
      detailValueEncrypted: freezed == detailValueEncrypted
          ? _self.detailValueEncrypted
          : detailValueEncrypted // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [AccountDetail].
extension AccountDetailPatterns on AccountDetail {
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
    TResult Function(_AccountDetail value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AccountDetail() when $default != null:
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
    TResult Function(_AccountDetail value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AccountDetail():
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
    TResult? Function(_AccountDetail value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AccountDetail() when $default != null:
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
    TResult Function(String id, String accountId, String detailKey,
            String? detailValue, String? detailValueEncrypted, int updatedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AccountDetail() when $default != null:
        return $default(_that.id, _that.accountId, _that.detailKey,
            _that.detailValue, _that.detailValueEncrypted, _that.updatedAt);
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
    TResult Function(String id, String accountId, String detailKey,
            String? detailValue, String? detailValueEncrypted, int updatedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AccountDetail():
        return $default(_that.id, _that.accountId, _that.detailKey,
            _that.detailValue, _that.detailValueEncrypted, _that.updatedAt);
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
    TResult? Function(String id, String accountId, String detailKey,
            String? detailValue, String? detailValueEncrypted, int updatedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AccountDetail() when $default != null:
        return $default(_that.id, _that.accountId, _that.detailKey,
            _that.detailValue, _that.detailValueEncrypted, _that.updatedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _AccountDetail implements AccountDetail {
  const _AccountDetail(
      {required this.id,
      required this.accountId,
      required this.detailKey,
      this.detailValue,
      this.detailValueEncrypted,
      required this.updatedAt});

  /// UUID v4 stable identifier for this detail row.
  @override
  final String id;

  /// UUID of the parent [Account].
  @override
  final String accountId;

  /// Field name (e.g. `bank_name`, `card_number`).
  ///
  /// Valid values are defined in data model §3.2.
  @override
  final String detailKey;

  /// Plain-text value for non-sensitive fields.
  ///
  /// Null when [detailValueEncrypted] is populated (sensitive fields).
  @override
  final String? detailValue;

  /// AES-encrypted blob for sensitive fields (card_number, account_number).
  ///
  /// Null for non-sensitive fields. Only one of [detailValue] or
  /// [detailValueEncrypted] should be non-null at a time.
  @override
  final String? detailValueEncrypted;

  /// Last-modified epoch (Unix seconds).
  @override
  final int updatedAt;

  /// Create a copy of AccountDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AccountDetailCopyWith<_AccountDetail> get copyWith =>
      __$AccountDetailCopyWithImpl<_AccountDetail>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AccountDetail &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.detailKey, detailKey) ||
                other.detailKey == detailKey) &&
            (identical(other.detailValue, detailValue) ||
                other.detailValue == detailValue) &&
            (identical(other.detailValueEncrypted, detailValueEncrypted) ||
                other.detailValueEncrypted == detailValueEncrypted) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, accountId, detailKey,
      detailValue, detailValueEncrypted, updatedAt);

  @override
  String toString() {
    return 'AccountDetail(id: $id, accountId: $accountId, detailKey: $detailKey, detailValue: $detailValue, detailValueEncrypted: $detailValueEncrypted, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$AccountDetailCopyWith<$Res>
    implements $AccountDetailCopyWith<$Res> {
  factory _$AccountDetailCopyWith(
          _AccountDetail value, $Res Function(_AccountDetail) _then) =
      __$AccountDetailCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String accountId,
      String detailKey,
      String? detailValue,
      String? detailValueEncrypted,
      int updatedAt});
}

/// @nodoc
class __$AccountDetailCopyWithImpl<$Res>
    implements _$AccountDetailCopyWith<$Res> {
  __$AccountDetailCopyWithImpl(this._self, this._then);

  final _AccountDetail _self;
  final $Res Function(_AccountDetail) _then;

  /// Create a copy of AccountDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? accountId = null,
    Object? detailKey = null,
    Object? detailValue = freezed,
    Object? detailValueEncrypted = freezed,
    Object? updatedAt = null,
  }) {
    return _then(_AccountDetail(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      accountId: null == accountId
          ? _self.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as String,
      detailKey: null == detailKey
          ? _self.detailKey
          : detailKey // ignore: cast_nullable_to_non_nullable
              as String,
      detailValue: freezed == detailValue
          ? _self.detailValue
          : detailValue // ignore: cast_nullable_to_non_nullable
              as String?,
      detailValueEncrypted: freezed == detailValueEncrypted
          ? _self.detailValueEncrypted
          : detailValueEncrypted // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
