// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scheduled_occurrence.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ScheduledOccurrence {
  /// UUID v4 stable identifier.
  String get id;

  /// Parent template UUID.
  String get templateId;

  /// Unix epoch date when this occurrence should fire.
  int get scheduledDate;

  /// Lifecycle status.
  ScheduledOccurrenceStatus get status;

  /// Transaction UUID once the occurrence is posted.
  String? get childTransactionId;

  /// Creation epoch (Unix seconds).
  int get createdAt;

  /// Last-modified epoch (Unix seconds).
  int get updatedAt;

  /// Create a copy of ScheduledOccurrence
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ScheduledOccurrenceCopyWith<ScheduledOccurrence> get copyWith =>
      _$ScheduledOccurrenceCopyWithImpl<ScheduledOccurrence>(
          this as ScheduledOccurrence, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ScheduledOccurrence &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.templateId, templateId) ||
                other.templateId == templateId) &&
            (identical(other.scheduledDate, scheduledDate) ||
                other.scheduledDate == scheduledDate) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.childTransactionId, childTransactionId) ||
                other.childTransactionId == childTransactionId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, templateId, scheduledDate,
      status, childTransactionId, createdAt, updatedAt);

  @override
  String toString() {
    return 'ScheduledOccurrence(id: $id, templateId: $templateId, scheduledDate: $scheduledDate, status: $status, childTransactionId: $childTransactionId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $ScheduledOccurrenceCopyWith<$Res> {
  factory $ScheduledOccurrenceCopyWith(
          ScheduledOccurrence value, $Res Function(ScheduledOccurrence) _then) =
      _$ScheduledOccurrenceCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String templateId,
      int scheduledDate,
      ScheduledOccurrenceStatus status,
      String? childTransactionId,
      int createdAt,
      int updatedAt});
}

/// @nodoc
class _$ScheduledOccurrenceCopyWithImpl<$Res>
    implements $ScheduledOccurrenceCopyWith<$Res> {
  _$ScheduledOccurrenceCopyWithImpl(this._self, this._then);

  final ScheduledOccurrence _self;
  final $Res Function(ScheduledOccurrence) _then;

  /// Create a copy of ScheduledOccurrence
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? templateId = null,
    Object? scheduledDate = null,
    Object? status = null,
    Object? childTransactionId = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      templateId: null == templateId
          ? _self.templateId
          : templateId // ignore: cast_nullable_to_non_nullable
              as String,
      scheduledDate: null == scheduledDate
          ? _self.scheduledDate
          : scheduledDate // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as ScheduledOccurrenceStatus,
      childTransactionId: freezed == childTransactionId
          ? _self.childTransactionId
          : childTransactionId // ignore: cast_nullable_to_non_nullable
              as String?,
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

/// Adds pattern-matching-related methods to [ScheduledOccurrence].
extension ScheduledOccurrencePatterns on ScheduledOccurrence {
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
    TResult Function(_ScheduledOccurrence value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ScheduledOccurrence() when $default != null:
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
    TResult Function(_ScheduledOccurrence value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScheduledOccurrence():
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
    TResult? Function(_ScheduledOccurrence value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScheduledOccurrence() when $default != null:
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
            String templateId,
            int scheduledDate,
            ScheduledOccurrenceStatus status,
            String? childTransactionId,
            int createdAt,
            int updatedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ScheduledOccurrence() when $default != null:
        return $default(
            _that.id,
            _that.templateId,
            _that.scheduledDate,
            _that.status,
            _that.childTransactionId,
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
            String templateId,
            int scheduledDate,
            ScheduledOccurrenceStatus status,
            String? childTransactionId,
            int createdAt,
            int updatedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScheduledOccurrence():
        return $default(
            _that.id,
            _that.templateId,
            _that.scheduledDate,
            _that.status,
            _that.childTransactionId,
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
            String templateId,
            int scheduledDate,
            ScheduledOccurrenceStatus status,
            String? childTransactionId,
            int createdAt,
            int updatedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScheduledOccurrence() when $default != null:
        return $default(
            _that.id,
            _that.templateId,
            _that.scheduledDate,
            _that.status,
            _that.childTransactionId,
            _that.createdAt,
            _that.updatedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ScheduledOccurrence implements ScheduledOccurrence {
  const _ScheduledOccurrence(
      {required this.id,
      required this.templateId,
      required this.scheduledDate,
      this.status = ScheduledOccurrenceStatus.pending,
      this.childTransactionId,
      required this.createdAt,
      required this.updatedAt});

  /// UUID v4 stable identifier.
  @override
  final String id;

  /// Parent template UUID.
  @override
  final String templateId;

  /// Unix epoch date when this occurrence should fire.
  @override
  final int scheduledDate;

  /// Lifecycle status.
  @override
  @JsonKey()
  final ScheduledOccurrenceStatus status;

  /// Transaction UUID once the occurrence is posted.
  @override
  final String? childTransactionId;

  /// Creation epoch (Unix seconds).
  @override
  final int createdAt;

  /// Last-modified epoch (Unix seconds).
  @override
  final int updatedAt;

  /// Create a copy of ScheduledOccurrence
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ScheduledOccurrenceCopyWith<_ScheduledOccurrence> get copyWith =>
      __$ScheduledOccurrenceCopyWithImpl<_ScheduledOccurrence>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ScheduledOccurrence &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.templateId, templateId) ||
                other.templateId == templateId) &&
            (identical(other.scheduledDate, scheduledDate) ||
                other.scheduledDate == scheduledDate) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.childTransactionId, childTransactionId) ||
                other.childTransactionId == childTransactionId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, templateId, scheduledDate,
      status, childTransactionId, createdAt, updatedAt);

  @override
  String toString() {
    return 'ScheduledOccurrence(id: $id, templateId: $templateId, scheduledDate: $scheduledDate, status: $status, childTransactionId: $childTransactionId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$ScheduledOccurrenceCopyWith<$Res>
    implements $ScheduledOccurrenceCopyWith<$Res> {
  factory _$ScheduledOccurrenceCopyWith(_ScheduledOccurrence value,
          $Res Function(_ScheduledOccurrence) _then) =
      __$ScheduledOccurrenceCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String templateId,
      int scheduledDate,
      ScheduledOccurrenceStatus status,
      String? childTransactionId,
      int createdAt,
      int updatedAt});
}

/// @nodoc
class __$ScheduledOccurrenceCopyWithImpl<$Res>
    implements _$ScheduledOccurrenceCopyWith<$Res> {
  __$ScheduledOccurrenceCopyWithImpl(this._self, this._then);

  final _ScheduledOccurrence _self;
  final $Res Function(_ScheduledOccurrence) _then;

  /// Create a copy of ScheduledOccurrence
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? templateId = null,
    Object? scheduledDate = null,
    Object? status = null,
    Object? childTransactionId = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_ScheduledOccurrence(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      templateId: null == templateId
          ? _self.templateId
          : templateId // ignore: cast_nullable_to_non_nullable
              as String,
      scheduledDate: null == scheduledDate
          ? _self.scheduledDate
          : scheduledDate // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as ScheduledOccurrenceStatus,
      childTransactionId: freezed == childTransactionId
          ? _self.childTransactionId
          : childTransactionId // ignore: cast_nullable_to_non_nullable
              as String?,
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
