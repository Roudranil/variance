// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payee.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Payee {
  /// UUID v4 stable identifier.
  String get id;

  /// Payee name; unique (case-insensitive enforced at app layer).
  String get name;

  /// Soft-delete flag.
  bool get isDeleted;

  /// Soft-delete epoch (Unix seconds).
  int? get deletedAt;

  /// Creation epoch (Unix seconds).
  int get createdAt;

  /// Last-modified epoch (Unix seconds).
  int get updatedAt;

  /// Create a copy of Payee
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PayeeCopyWith<Payee> get copyWith =>
      _$PayeeCopyWithImpl<Payee>(this as Payee, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Payee &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.isDeleted, isDeleted) ||
                other.isDeleted == isDeleted) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, id, name, isDeleted, deletedAt, createdAt, updatedAt);

  @override
  String toString() {
    return 'Payee(id: $id, name: $name, isDeleted: $isDeleted, deletedAt: $deletedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $PayeeCopyWith<$Res> {
  factory $PayeeCopyWith(Payee value, $Res Function(Payee) _then) =
      _$PayeeCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String name,
      bool isDeleted,
      int? deletedAt,
      int createdAt,
      int updatedAt});
}

/// @nodoc
class _$PayeeCopyWithImpl<$Res> implements $PayeeCopyWith<$Res> {
  _$PayeeCopyWithImpl(this._self, this._then);

  final Payee _self;
  final $Res Function(Payee) _then;

  /// Create a copy of Payee
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? isDeleted = null,
    Object? deletedAt = freezed,
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
      isDeleted: null == isDeleted
          ? _self.isDeleted
          : isDeleted // ignore: cast_nullable_to_non_nullable
              as bool,
      deletedAt: freezed == deletedAt
          ? _self.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as int?,
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

/// Adds pattern-matching-related methods to [Payee].
extension PayeePatterns on Payee {
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
    TResult Function(_Payee value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Payee() when $default != null:
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
    TResult Function(_Payee value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Payee():
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
    TResult? Function(_Payee value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Payee() when $default != null:
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
    TResult Function(String id, String name, bool isDeleted, int? deletedAt,
            int createdAt, int updatedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Payee() when $default != null:
        return $default(_that.id, _that.name, _that.isDeleted, _that.deletedAt,
            _that.createdAt, _that.updatedAt);
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
    TResult Function(String id, String name, bool isDeleted, int? deletedAt,
            int createdAt, int updatedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Payee():
        return $default(_that.id, _that.name, _that.isDeleted, _that.deletedAt,
            _that.createdAt, _that.updatedAt);
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
    TResult? Function(String id, String name, bool isDeleted, int? deletedAt,
            int createdAt, int updatedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Payee() when $default != null:
        return $default(_that.id, _that.name, _that.isDeleted, _that.deletedAt,
            _that.createdAt, _that.updatedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Payee implements Payee {
  const _Payee(
      {required this.id,
      required this.name,
      this.isDeleted = false,
      this.deletedAt,
      required this.createdAt,
      required this.updatedAt});

  /// UUID v4 stable identifier.
  @override
  final String id;

  /// Payee name; unique (case-insensitive enforced at app layer).
  @override
  final String name;

  /// Soft-delete flag.
  @override
  @JsonKey()
  final bool isDeleted;

  /// Soft-delete epoch (Unix seconds).
  @override
  final int? deletedAt;

  /// Creation epoch (Unix seconds).
  @override
  final int createdAt;

  /// Last-modified epoch (Unix seconds).
  @override
  final int updatedAt;

  /// Create a copy of Payee
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PayeeCopyWith<_Payee> get copyWith =>
      __$PayeeCopyWithImpl<_Payee>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Payee &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.isDeleted, isDeleted) ||
                other.isDeleted == isDeleted) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, id, name, isDeleted, deletedAt, createdAt, updatedAt);

  @override
  String toString() {
    return 'Payee(id: $id, name: $name, isDeleted: $isDeleted, deletedAt: $deletedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$PayeeCopyWith<$Res> implements $PayeeCopyWith<$Res> {
  factory _$PayeeCopyWith(_Payee value, $Res Function(_Payee) _then) =
      __$PayeeCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      bool isDeleted,
      int? deletedAt,
      int createdAt,
      int updatedAt});
}

/// @nodoc
class __$PayeeCopyWithImpl<$Res> implements _$PayeeCopyWith<$Res> {
  __$PayeeCopyWithImpl(this._self, this._then);

  final _Payee _self;
  final $Res Function(_Payee) _then;

  /// Create a copy of Payee
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? isDeleted = null,
    Object? deletedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_Payee(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      isDeleted: null == isDeleted
          ? _self.isDeleted
          : isDeleted // ignore: cast_nullable_to_non_nullable
              as bool,
      deletedAt: freezed == deletedAt
          ? _self.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as int?,
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
