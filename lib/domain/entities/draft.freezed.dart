// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'draft.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Draft {
  /// UUID v4 stable identifier.
  String get id;

  /// Serialized form state (JSON string).
  String get payloadJson;

  /// Creation epoch used for FIFO eviction (Unix seconds).
  int get createdAt;

  /// Last auto-save epoch (Unix seconds).
  int get updatedAt;

  /// Create a copy of Draft
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DraftCopyWith<Draft> get copyWith =>
      _$DraftCopyWithImpl<Draft>(this as Draft, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Draft &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.payloadJson, payloadJson) ||
                other.payloadJson == payloadJson) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, payloadJson, createdAt, updatedAt);

  @override
  String toString() {
    return 'Draft(id: $id, payloadJson: $payloadJson, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $DraftCopyWith<$Res> {
  factory $DraftCopyWith(Draft value, $Res Function(Draft) _then) =
      _$DraftCopyWithImpl;
  @useResult
  $Res call({String id, String payloadJson, int createdAt, int updatedAt});
}

/// @nodoc
class _$DraftCopyWithImpl<$Res> implements $DraftCopyWith<$Res> {
  _$DraftCopyWithImpl(this._self, this._then);

  final Draft _self;
  final $Res Function(Draft) _then;

  /// Create a copy of Draft
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? payloadJson = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      payloadJson: null == payloadJson
          ? _self.payloadJson
          : payloadJson // ignore: cast_nullable_to_non_nullable
              as String,
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

/// Adds pattern-matching-related methods to [Draft].
extension DraftPatterns on Draft {
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
    TResult Function(_Draft value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Draft() when $default != null:
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
    TResult Function(_Draft value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Draft():
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
    TResult? Function(_Draft value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Draft() when $default != null:
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
            String id, String payloadJson, int createdAt, int updatedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Draft() when $default != null:
        return $default(
            _that.id, _that.payloadJson, _that.createdAt, _that.updatedAt);
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
            String id, String payloadJson, int createdAt, int updatedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Draft():
        return $default(
            _that.id, _that.payloadJson, _that.createdAt, _that.updatedAt);
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
            String id, String payloadJson, int createdAt, int updatedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Draft() when $default != null:
        return $default(
            _that.id, _that.payloadJson, _that.createdAt, _that.updatedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Draft implements Draft {
  const _Draft(
      {required this.id,
      required this.payloadJson,
      required this.createdAt,
      required this.updatedAt});

  /// UUID v4 stable identifier.
  @override
  final String id;

  /// Serialized form state (JSON string).
  @override
  final String payloadJson;

  /// Creation epoch used for FIFO eviction (Unix seconds).
  @override
  final int createdAt;

  /// Last auto-save epoch (Unix seconds).
  @override
  final int updatedAt;

  /// Create a copy of Draft
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DraftCopyWith<_Draft> get copyWith =>
      __$DraftCopyWithImpl<_Draft>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Draft &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.payloadJson, payloadJson) ||
                other.payloadJson == payloadJson) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, payloadJson, createdAt, updatedAt);

  @override
  String toString() {
    return 'Draft(id: $id, payloadJson: $payloadJson, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$DraftCopyWith<$Res> implements $DraftCopyWith<$Res> {
  factory _$DraftCopyWith(_Draft value, $Res Function(_Draft) _then) =
      __$DraftCopyWithImpl;
  @override
  @useResult
  $Res call({String id, String payloadJson, int createdAt, int updatedAt});
}

/// @nodoc
class __$DraftCopyWithImpl<$Res> implements _$DraftCopyWith<$Res> {
  __$DraftCopyWithImpl(this._self, this._then);

  final _Draft _self;
  final $Res Function(_Draft) _then;

  /// Create a copy of Draft
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? payloadJson = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_Draft(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      payloadJson: null == payloadJson
          ? _self.payloadJson
          : payloadJson // ignore: cast_nullable_to_non_nullable
              as String,
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
