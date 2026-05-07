// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'installment_occurrence.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InstallmentOccurrence {
  /// UUID v4 stable identifier.
  String get id;

  /// Parent installment template UUID.
  String get templateId;

  /// 1-based position in the installment series; unique per template.
  int get sequenceNumber;

  /// Unix epoch date when this installment should be posted.
  int get scheduledDate;

  /// Per-installment amount in minor units; user-adjustable for future
  /// unposted installments.
  int get amountMinor;

  /// Lifecycle status.
  InstallmentOccurrenceStatus get status;

  /// Transaction UUID once the installment is posted.
  String? get childTransactionId;

  /// Creation epoch (Unix seconds).
  int get createdAt;

  /// Last-modified epoch (Unix seconds).
  int get updatedAt;

  /// Create a copy of InstallmentOccurrence
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $InstallmentOccurrenceCopyWith<InstallmentOccurrence> get copyWith =>
      _$InstallmentOccurrenceCopyWithImpl<InstallmentOccurrence>(
          this as InstallmentOccurrence, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is InstallmentOccurrence &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.templateId, templateId) ||
                other.templateId == templateId) &&
            (identical(other.sequenceNumber, sequenceNumber) ||
                other.sequenceNumber == sequenceNumber) &&
            (identical(other.scheduledDate, scheduledDate) ||
                other.scheduledDate == scheduledDate) &&
            (identical(other.amountMinor, amountMinor) ||
                other.amountMinor == amountMinor) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.childTransactionId, childTransactionId) ||
                other.childTransactionId == childTransactionId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      templateId,
      sequenceNumber,
      scheduledDate,
      amountMinor,
      status,
      childTransactionId,
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'InstallmentOccurrence(id: $id, templateId: $templateId, sequenceNumber: $sequenceNumber, scheduledDate: $scheduledDate, amountMinor: $amountMinor, status: $status, childTransactionId: $childTransactionId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $InstallmentOccurrenceCopyWith<$Res> {
  factory $InstallmentOccurrenceCopyWith(InstallmentOccurrence value,
          $Res Function(InstallmentOccurrence) _then) =
      _$InstallmentOccurrenceCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String templateId,
      int sequenceNumber,
      int scheduledDate,
      int amountMinor,
      InstallmentOccurrenceStatus status,
      String? childTransactionId,
      int createdAt,
      int updatedAt});
}

/// @nodoc
class _$InstallmentOccurrenceCopyWithImpl<$Res>
    implements $InstallmentOccurrenceCopyWith<$Res> {
  _$InstallmentOccurrenceCopyWithImpl(this._self, this._then);

  final InstallmentOccurrence _self;
  final $Res Function(InstallmentOccurrence) _then;

  /// Create a copy of InstallmentOccurrence
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? templateId = null,
    Object? sequenceNumber = null,
    Object? scheduledDate = null,
    Object? amountMinor = null,
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
      sequenceNumber: null == sequenceNumber
          ? _self.sequenceNumber
          : sequenceNumber // ignore: cast_nullable_to_non_nullable
              as int,
      scheduledDate: null == scheduledDate
          ? _self.scheduledDate
          : scheduledDate // ignore: cast_nullable_to_non_nullable
              as int,
      amountMinor: null == amountMinor
          ? _self.amountMinor
          : amountMinor // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as InstallmentOccurrenceStatus,
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

/// Adds pattern-matching-related methods to [InstallmentOccurrence].
extension InstallmentOccurrencePatterns on InstallmentOccurrence {
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
    TResult Function(_InstallmentOccurrence value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _InstallmentOccurrence() when $default != null:
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
    TResult Function(_InstallmentOccurrence value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _InstallmentOccurrence():
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
    TResult? Function(_InstallmentOccurrence value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _InstallmentOccurrence() when $default != null:
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
            int sequenceNumber,
            int scheduledDate,
            int amountMinor,
            InstallmentOccurrenceStatus status,
            String? childTransactionId,
            int createdAt,
            int updatedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _InstallmentOccurrence() when $default != null:
        return $default(
            _that.id,
            _that.templateId,
            _that.sequenceNumber,
            _that.scheduledDate,
            _that.amountMinor,
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
            int sequenceNumber,
            int scheduledDate,
            int amountMinor,
            InstallmentOccurrenceStatus status,
            String? childTransactionId,
            int createdAt,
            int updatedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _InstallmentOccurrence():
        return $default(
            _that.id,
            _that.templateId,
            _that.sequenceNumber,
            _that.scheduledDate,
            _that.amountMinor,
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
            int sequenceNumber,
            int scheduledDate,
            int amountMinor,
            InstallmentOccurrenceStatus status,
            String? childTransactionId,
            int createdAt,
            int updatedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _InstallmentOccurrence() when $default != null:
        return $default(
            _that.id,
            _that.templateId,
            _that.sequenceNumber,
            _that.scheduledDate,
            _that.amountMinor,
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

class _InstallmentOccurrence implements InstallmentOccurrence {
  const _InstallmentOccurrence(
      {required this.id,
      required this.templateId,
      required this.sequenceNumber,
      required this.scheduledDate,
      required this.amountMinor,
      this.status = InstallmentOccurrenceStatus.pending,
      this.childTransactionId,
      required this.createdAt,
      required this.updatedAt});

  /// UUID v4 stable identifier.
  @override
  final String id;

  /// Parent installment template UUID.
  @override
  final String templateId;

  /// 1-based position in the installment series; unique per template.
  @override
  final int sequenceNumber;

  /// Unix epoch date when this installment should be posted.
  @override
  final int scheduledDate;

  /// Per-installment amount in minor units; user-adjustable for future
  /// unposted installments.
  @override
  final int amountMinor;

  /// Lifecycle status.
  @override
  @JsonKey()
  final InstallmentOccurrenceStatus status;

  /// Transaction UUID once the installment is posted.
  @override
  final String? childTransactionId;

  /// Creation epoch (Unix seconds).
  @override
  final int createdAt;

  /// Last-modified epoch (Unix seconds).
  @override
  final int updatedAt;

  /// Create a copy of InstallmentOccurrence
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$InstallmentOccurrenceCopyWith<_InstallmentOccurrence> get copyWith =>
      __$InstallmentOccurrenceCopyWithImpl<_InstallmentOccurrence>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _InstallmentOccurrence &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.templateId, templateId) ||
                other.templateId == templateId) &&
            (identical(other.sequenceNumber, sequenceNumber) ||
                other.sequenceNumber == sequenceNumber) &&
            (identical(other.scheduledDate, scheduledDate) ||
                other.scheduledDate == scheduledDate) &&
            (identical(other.amountMinor, amountMinor) ||
                other.amountMinor == amountMinor) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.childTransactionId, childTransactionId) ||
                other.childTransactionId == childTransactionId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      templateId,
      sequenceNumber,
      scheduledDate,
      amountMinor,
      status,
      childTransactionId,
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'InstallmentOccurrence(id: $id, templateId: $templateId, sequenceNumber: $sequenceNumber, scheduledDate: $scheduledDate, amountMinor: $amountMinor, status: $status, childTransactionId: $childTransactionId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$InstallmentOccurrenceCopyWith<$Res>
    implements $InstallmentOccurrenceCopyWith<$Res> {
  factory _$InstallmentOccurrenceCopyWith(_InstallmentOccurrence value,
          $Res Function(_InstallmentOccurrence) _then) =
      __$InstallmentOccurrenceCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String templateId,
      int sequenceNumber,
      int scheduledDate,
      int amountMinor,
      InstallmentOccurrenceStatus status,
      String? childTransactionId,
      int createdAt,
      int updatedAt});
}

/// @nodoc
class __$InstallmentOccurrenceCopyWithImpl<$Res>
    implements _$InstallmentOccurrenceCopyWith<$Res> {
  __$InstallmentOccurrenceCopyWithImpl(this._self, this._then);

  final _InstallmentOccurrence _self;
  final $Res Function(_InstallmentOccurrence) _then;

  /// Create a copy of InstallmentOccurrence
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? templateId = null,
    Object? sequenceNumber = null,
    Object? scheduledDate = null,
    Object? amountMinor = null,
    Object? status = null,
    Object? childTransactionId = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_InstallmentOccurrence(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      templateId: null == templateId
          ? _self.templateId
          : templateId // ignore: cast_nullable_to_non_nullable
              as String,
      sequenceNumber: null == sequenceNumber
          ? _self.sequenceNumber
          : sequenceNumber // ignore: cast_nullable_to_non_nullable
              as int,
      scheduledDate: null == scheduledDate
          ? _self.scheduledDate
          : scheduledDate // ignore: cast_nullable_to_non_nullable
              as int,
      amountMinor: null == amountMinor
          ? _self.amountMinor
          : amountMinor // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as InstallmentOccurrenceStatus,
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
