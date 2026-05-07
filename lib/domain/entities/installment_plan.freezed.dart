// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'installment_plan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InstallmentPlan {
  /// UUID v4; also the FK to recurring_templates (same value as templateId).
  String get templateId;

  /// Target total amount in minor units; immutable except on early close.
  int get totalConfiguredMinor;

  /// Total number of planned installments; editable for future installments.
  int get numberOfInstallments;

  /// Creation epoch (Unix seconds).
  int get createdAt;

  /// Create a copy of InstallmentPlan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $InstallmentPlanCopyWith<InstallmentPlan> get copyWith =>
      _$InstallmentPlanCopyWithImpl<InstallmentPlan>(
          this as InstallmentPlan, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is InstallmentPlan &&
            (identical(other.templateId, templateId) ||
                other.templateId == templateId) &&
            (identical(other.totalConfiguredMinor, totalConfiguredMinor) ||
                other.totalConfiguredMinor == totalConfiguredMinor) &&
            (identical(other.numberOfInstallments, numberOfInstallments) ||
                other.numberOfInstallments == numberOfInstallments) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(runtimeType, templateId, totalConfiguredMinor,
      numberOfInstallments, createdAt);

  @override
  String toString() {
    return 'InstallmentPlan(templateId: $templateId, totalConfiguredMinor: $totalConfiguredMinor, numberOfInstallments: $numberOfInstallments, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $InstallmentPlanCopyWith<$Res> {
  factory $InstallmentPlanCopyWith(
          InstallmentPlan value, $Res Function(InstallmentPlan) _then) =
      _$InstallmentPlanCopyWithImpl;
  @useResult
  $Res call(
      {String templateId,
      int totalConfiguredMinor,
      int numberOfInstallments,
      int createdAt});
}

/// @nodoc
class _$InstallmentPlanCopyWithImpl<$Res>
    implements $InstallmentPlanCopyWith<$Res> {
  _$InstallmentPlanCopyWithImpl(this._self, this._then);

  final InstallmentPlan _self;
  final $Res Function(InstallmentPlan) _then;

  /// Create a copy of InstallmentPlan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? templateId = null,
    Object? totalConfiguredMinor = null,
    Object? numberOfInstallments = null,
    Object? createdAt = null,
  }) {
    return _then(_self.copyWith(
      templateId: null == templateId
          ? _self.templateId
          : templateId // ignore: cast_nullable_to_non_nullable
              as String,
      totalConfiguredMinor: null == totalConfiguredMinor
          ? _self.totalConfiguredMinor
          : totalConfiguredMinor // ignore: cast_nullable_to_non_nullable
              as int,
      numberOfInstallments: null == numberOfInstallments
          ? _self.numberOfInstallments
          : numberOfInstallments // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [InstallmentPlan].
extension InstallmentPlanPatterns on InstallmentPlan {
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
    TResult Function(_InstallmentPlan value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _InstallmentPlan() when $default != null:
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
    TResult Function(_InstallmentPlan value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _InstallmentPlan():
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
    TResult? Function(_InstallmentPlan value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _InstallmentPlan() when $default != null:
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
    TResult Function(String templateId, int totalConfiguredMinor,
            int numberOfInstallments, int createdAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _InstallmentPlan() when $default != null:
        return $default(_that.templateId, _that.totalConfiguredMinor,
            _that.numberOfInstallments, _that.createdAt);
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
    TResult Function(String templateId, int totalConfiguredMinor,
            int numberOfInstallments, int createdAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _InstallmentPlan():
        return $default(_that.templateId, _that.totalConfiguredMinor,
            _that.numberOfInstallments, _that.createdAt);
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
    TResult? Function(String templateId, int totalConfiguredMinor,
            int numberOfInstallments, int createdAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _InstallmentPlan() when $default != null:
        return $default(_that.templateId, _that.totalConfiguredMinor,
            _that.numberOfInstallments, _that.createdAt);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _InstallmentPlan implements InstallmentPlan {
  const _InstallmentPlan(
      {required this.templateId,
      required this.totalConfiguredMinor,
      required this.numberOfInstallments,
      required this.createdAt});

  /// UUID v4; also the FK to recurring_templates (same value as templateId).
  @override
  final String templateId;

  /// Target total amount in minor units; immutable except on early close.
  @override
  final int totalConfiguredMinor;

  /// Total number of planned installments; editable for future installments.
  @override
  final int numberOfInstallments;

  /// Creation epoch (Unix seconds).
  @override
  final int createdAt;

  /// Create a copy of InstallmentPlan
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$InstallmentPlanCopyWith<_InstallmentPlan> get copyWith =>
      __$InstallmentPlanCopyWithImpl<_InstallmentPlan>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _InstallmentPlan &&
            (identical(other.templateId, templateId) ||
                other.templateId == templateId) &&
            (identical(other.totalConfiguredMinor, totalConfiguredMinor) ||
                other.totalConfiguredMinor == totalConfiguredMinor) &&
            (identical(other.numberOfInstallments, numberOfInstallments) ||
                other.numberOfInstallments == numberOfInstallments) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(runtimeType, templateId, totalConfiguredMinor,
      numberOfInstallments, createdAt);

  @override
  String toString() {
    return 'InstallmentPlan(templateId: $templateId, totalConfiguredMinor: $totalConfiguredMinor, numberOfInstallments: $numberOfInstallments, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$InstallmentPlanCopyWith<$Res>
    implements $InstallmentPlanCopyWith<$Res> {
  factory _$InstallmentPlanCopyWith(
          _InstallmentPlan value, $Res Function(_InstallmentPlan) _then) =
      __$InstallmentPlanCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String templateId,
      int totalConfiguredMinor,
      int numberOfInstallments,
      int createdAt});
}

/// @nodoc
class __$InstallmentPlanCopyWithImpl<$Res>
    implements _$InstallmentPlanCopyWith<$Res> {
  __$InstallmentPlanCopyWithImpl(this._self, this._then);

  final _InstallmentPlan _self;
  final $Res Function(_InstallmentPlan) _then;

  /// Create a copy of InstallmentPlan
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? templateId = null,
    Object? totalConfiguredMinor = null,
    Object? numberOfInstallments = null,
    Object? createdAt = null,
  }) {
    return _then(_InstallmentPlan(
      templateId: null == templateId
          ? _self.templateId
          : templateId // ignore: cast_nullable_to_non_nullable
              as String,
      totalConfiguredMinor: null == totalConfiguredMinor
          ? _self.totalConfiguredMinor
          : totalConfiguredMinor // ignore: cast_nullable_to_non_nullable
              as int,
      numberOfInstallments: null == numberOfInstallments
          ? _self.numberOfInstallments
          : numberOfInstallments // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
