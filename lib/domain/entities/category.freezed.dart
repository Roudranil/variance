// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'category.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Category {
  /// UUID v4 stable identifier.
  String get id;

  /// Parent category UUID; null for root categories.
  String? get parentId;

  /// Income or expense tree.
  CategoryTreeType get treeType;

  /// Display name; unique within tree/parent (case-insensitive, incl. soft-deleted).
  String get name;

  /// Material Symbols icon identifier.
  String get iconRef;

  /// Soft-delete flag.
  bool get isDeleted;

  /// Soft-delete epoch (Unix seconds); set when [isDeleted] becomes true.
  int? get deletedAt;

  /// True for BAI/BAE and "Balance Adjustment" parent; blocks deletion.
  bool get isProtected;

  /// Manual sort order; null = alphabetical (v1 default).
  int? get sortOrder;

  /// Creation epoch (Unix seconds).
  int get createdAt;

  /// Last-modified epoch (Unix seconds).
  int get updatedAt;

  /// Create a copy of Category
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CategoryCopyWith<Category> get copyWith =>
      _$CategoryCopyWithImpl<Category>(this as Category, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Category &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.parentId, parentId) ||
                other.parentId == parentId) &&
            (identical(other.treeType, treeType) ||
                other.treeType == treeType) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.iconRef, iconRef) || other.iconRef == iconRef) &&
            (identical(other.isDeleted, isDeleted) ||
                other.isDeleted == isDeleted) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.isProtected, isProtected) ||
                other.isProtected == isProtected) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
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
      updatedAt);

  @override
  String toString() {
    return 'Category(id: $id, parentId: $parentId, treeType: $treeType, name: $name, iconRef: $iconRef, isDeleted: $isDeleted, deletedAt: $deletedAt, isProtected: $isProtected, sortOrder: $sortOrder, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $CategoryCopyWith<$Res> {
  factory $CategoryCopyWith(Category value, $Res Function(Category) _then) =
      _$CategoryCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String? parentId,
      CategoryTreeType treeType,
      String name,
      String iconRef,
      bool isDeleted,
      int? deletedAt,
      bool isProtected,
      int? sortOrder,
      int createdAt,
      int updatedAt});
}

/// @nodoc
class _$CategoryCopyWithImpl<$Res> implements $CategoryCopyWith<$Res> {
  _$CategoryCopyWithImpl(this._self, this._then);

  final Category _self;
  final $Res Function(Category) _then;

  /// Create a copy of Category
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? parentId = freezed,
    Object? treeType = null,
    Object? name = null,
    Object? iconRef = null,
    Object? isDeleted = null,
    Object? deletedAt = freezed,
    Object? isProtected = null,
    Object? sortOrder = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      parentId: freezed == parentId
          ? _self.parentId
          : parentId // ignore: cast_nullable_to_non_nullable
              as String?,
      treeType: null == treeType
          ? _self.treeType
          : treeType // ignore: cast_nullable_to_non_nullable
              as CategoryTreeType,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      iconRef: null == iconRef
          ? _self.iconRef
          : iconRef // ignore: cast_nullable_to_non_nullable
              as String,
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
      sortOrder: freezed == sortOrder
          ? _self.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
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

/// Adds pattern-matching-related methods to [Category].
extension CategoryPatterns on Category {
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
    TResult Function(_Category value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Category() when $default != null:
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
    TResult Function(_Category value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Category():
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
    TResult? Function(_Category value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Category() when $default != null:
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
            String? parentId,
            CategoryTreeType treeType,
            String name,
            String iconRef,
            bool isDeleted,
            int? deletedAt,
            bool isProtected,
            int? sortOrder,
            int createdAt,
            int updatedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Category() when $default != null:
        return $default(
            _that.id,
            _that.parentId,
            _that.treeType,
            _that.name,
            _that.iconRef,
            _that.isDeleted,
            _that.deletedAt,
            _that.isProtected,
            _that.sortOrder,
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
            String? parentId,
            CategoryTreeType treeType,
            String name,
            String iconRef,
            bool isDeleted,
            int? deletedAt,
            bool isProtected,
            int? sortOrder,
            int createdAt,
            int updatedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Category():
        return $default(
            _that.id,
            _that.parentId,
            _that.treeType,
            _that.name,
            _that.iconRef,
            _that.isDeleted,
            _that.deletedAt,
            _that.isProtected,
            _that.sortOrder,
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
            String? parentId,
            CategoryTreeType treeType,
            String name,
            String iconRef,
            bool isDeleted,
            int? deletedAt,
            bool isProtected,
            int? sortOrder,
            int createdAt,
            int updatedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Category() when $default != null:
        return $default(
            _that.id,
            _that.parentId,
            _that.treeType,
            _that.name,
            _that.iconRef,
            _that.isDeleted,
            _that.deletedAt,
            _that.isProtected,
            _that.sortOrder,
            _that.createdAt,
            _that.updatedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Category implements Category {
  const _Category(
      {required this.id,
      this.parentId,
      required this.treeType,
      required this.name,
      required this.iconRef,
      this.isDeleted = false,
      this.deletedAt,
      this.isProtected = false,
      this.sortOrder,
      required this.createdAt,
      required this.updatedAt});

  /// UUID v4 stable identifier.
  @override
  final String id;

  /// Parent category UUID; null for root categories.
  @override
  final String? parentId;

  /// Income or expense tree.
  @override
  final CategoryTreeType treeType;

  /// Display name; unique within tree/parent (case-insensitive, incl. soft-deleted).
  @override
  final String name;

  /// Material Symbols icon identifier.
  @override
  final String iconRef;

  /// Soft-delete flag.
  @override
  @JsonKey()
  final bool isDeleted;

  /// Soft-delete epoch (Unix seconds); set when [isDeleted] becomes true.
  @override
  final int? deletedAt;

  /// True for BAI/BAE and "Balance Adjustment" parent; blocks deletion.
  @override
  @JsonKey()
  final bool isProtected;

  /// Manual sort order; null = alphabetical (v1 default).
  @override
  final int? sortOrder;

  /// Creation epoch (Unix seconds).
  @override
  final int createdAt;

  /// Last-modified epoch (Unix seconds).
  @override
  final int updatedAt;

  /// Create a copy of Category
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CategoryCopyWith<_Category> get copyWith =>
      __$CategoryCopyWithImpl<_Category>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Category &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.parentId, parentId) ||
                other.parentId == parentId) &&
            (identical(other.treeType, treeType) ||
                other.treeType == treeType) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.iconRef, iconRef) || other.iconRef == iconRef) &&
            (identical(other.isDeleted, isDeleted) ||
                other.isDeleted == isDeleted) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.isProtected, isProtected) ||
                other.isProtected == isProtected) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
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
      updatedAt);

  @override
  String toString() {
    return 'Category(id: $id, parentId: $parentId, treeType: $treeType, name: $name, iconRef: $iconRef, isDeleted: $isDeleted, deletedAt: $deletedAt, isProtected: $isProtected, sortOrder: $sortOrder, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$CategoryCopyWith<$Res>
    implements $CategoryCopyWith<$Res> {
  factory _$CategoryCopyWith(_Category value, $Res Function(_Category) _then) =
      __$CategoryCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String? parentId,
      CategoryTreeType treeType,
      String name,
      String iconRef,
      bool isDeleted,
      int? deletedAt,
      bool isProtected,
      int? sortOrder,
      int createdAt,
      int updatedAt});
}

/// @nodoc
class __$CategoryCopyWithImpl<$Res> implements _$CategoryCopyWith<$Res> {
  __$CategoryCopyWithImpl(this._self, this._then);

  final _Category _self;
  final $Res Function(_Category) _then;

  /// Create a copy of Category
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? parentId = freezed,
    Object? treeType = null,
    Object? name = null,
    Object? iconRef = null,
    Object? isDeleted = null,
    Object? deletedAt = freezed,
    Object? isProtected = null,
    Object? sortOrder = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_Category(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      parentId: freezed == parentId
          ? _self.parentId
          : parentId // ignore: cast_nullable_to_non_nullable
              as String?,
      treeType: null == treeType
          ? _self.treeType
          : treeType // ignore: cast_nullable_to_non_nullable
              as CategoryTreeType,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      iconRef: null == iconRef
          ? _self.iconRef
          : iconRef // ignore: cast_nullable_to_non_nullable
              as String,
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
      sortOrder: freezed == sortOrder
          ? _self.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
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
