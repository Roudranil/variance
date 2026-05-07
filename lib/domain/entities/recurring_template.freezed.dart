// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recurring_template.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RecurringTemplate {
  /// UUID v4 stable identifier.
  String get id;

  /// Financial direction; immutable after creation.
  String get transactionType;

  /// Lifecycle state.
  RecurringTemplateStatus get status;

  /// Per-occurrence amount in minor units; in-place editable.
  int get amountMinor;

  /// ISO 4217 code; derived from source account.
  String get currencyCode;

  /// Source account UUID; null for income.
  String? get accountSourceId;

  /// Destination account UUID; null for expense.
  String? get accountDestinationId;

  /// Category UUID; null for transfer; editable.
  String? get categoryId;

  /// Subcategory UUID; editable.
  String? get subcategoryId;

  /// Payee UUID; optional.
  String? get payeeId;

  /// Template title; editable.
  String? get title;

  /// Description; editable.
  String? get description;

  /// Cadence multiplier (e.g. 2 in "every 2 weeks"); immutable.
  int get recurrenceN;

  /// Cadence time unit; immutable.
  RecurrenceUnit get recurrenceUnit;

  /// Optional scheduling constraints (JSON array of [RecurrenceConstraint]);
  /// immutable.
  List<RecurrenceConstraint>? get recurrenceConstraints;

  /// First occurrence date (Unix epoch days); immutable.
  int get startDate;

  /// Last valid occurrence date; immutable for recurring; computed for
  /// installments.
  int? get endDate;

  /// Auto-posting behaviour; editable.
  PostingBehaviour get postingBehaviour;

  /// Transfer fee mode; null = no fee.
  FeeMode? get feeMode;

  /// Flat fee in minor units.
  int? get feeAmountMinor;

  /// Percentage fee × 1,000,000.
  int? get feePercentageMicro;

  /// Fee expense category UUID.
  String? get feeCategoryId;

  /// Resume-after epoch; null = not paused.
  int? get pauseUntil;

  /// Archival epoch; null = not archived.
  int? get archivedAt;

  /// Archival trigger; null = not archived.
  ArchivedReason? get archivedReason;

  /// Discriminator: false = recurring, true = installment.
  bool get isInstallment;

  /// Soft-delete flag.
  bool get isDeleted;

  /// Soft-delete epoch.
  int? get deletedAt;

  /// Creation epoch (Unix seconds).
  int get createdAt;

  /// Last-modified epoch (Unix seconds).
  int get updatedAt;

  /// JSON escape hatch.
  String? get metadata;

  /// Create a copy of RecurringTemplate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RecurringTemplateCopyWith<RecurringTemplate> get copyWith =>
      _$RecurringTemplateCopyWithImpl<RecurringTemplate>(
          this as RecurringTemplate, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RecurringTemplate &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.transactionType, transactionType) ||
                other.transactionType == transactionType) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.amountMinor, amountMinor) ||
                other.amountMinor == amountMinor) &&
            (identical(other.currencyCode, currencyCode) ||
                other.currencyCode == currencyCode) &&
            (identical(other.accountSourceId, accountSourceId) ||
                other.accountSourceId == accountSourceId) &&
            (identical(other.accountDestinationId, accountDestinationId) ||
                other.accountDestinationId == accountDestinationId) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.subcategoryId, subcategoryId) ||
                other.subcategoryId == subcategoryId) &&
            (identical(other.payeeId, payeeId) || other.payeeId == payeeId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.recurrenceN, recurrenceN) ||
                other.recurrenceN == recurrenceN) &&
            (identical(other.recurrenceUnit, recurrenceUnit) ||
                other.recurrenceUnit == recurrenceUnit) &&
            const DeepCollectionEquality()
                .equals(other.recurrenceConstraints, recurrenceConstraints) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.postingBehaviour, postingBehaviour) ||
                other.postingBehaviour == postingBehaviour) &&
            (identical(other.feeMode, feeMode) || other.feeMode == feeMode) &&
            (identical(other.feeAmountMinor, feeAmountMinor) ||
                other.feeAmountMinor == feeAmountMinor) &&
            (identical(other.feePercentageMicro, feePercentageMicro) ||
                other.feePercentageMicro == feePercentageMicro) &&
            (identical(other.feeCategoryId, feeCategoryId) ||
                other.feeCategoryId == feeCategoryId) &&
            (identical(other.pauseUntil, pauseUntil) ||
                other.pauseUntil == pauseUntil) &&
            (identical(other.archivedAt, archivedAt) ||
                other.archivedAt == archivedAt) &&
            (identical(other.archivedReason, archivedReason) ||
                other.archivedReason == archivedReason) &&
            (identical(other.isInstallment, isInstallment) ||
                other.isInstallment == isInstallment) &&
            (identical(other.isDeleted, isDeleted) ||
                other.isDeleted == isDeleted) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.metadata, metadata) ||
                other.metadata == metadata));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        transactionType,
        status,
        amountMinor,
        currencyCode,
        accountSourceId,
        accountDestinationId,
        categoryId,
        subcategoryId,
        payeeId,
        title,
        description,
        recurrenceN,
        recurrenceUnit,
        const DeepCollectionEquality().hash(recurrenceConstraints),
        startDate,
        endDate,
        postingBehaviour,
        feeMode,
        feeAmountMinor,
        feePercentageMicro,
        feeCategoryId,
        pauseUntil,
        archivedAt,
        archivedReason,
        isInstallment,
        isDeleted,
        deletedAt,
        createdAt,
        updatedAt,
        metadata
      ]);

  @override
  String toString() {
    return 'RecurringTemplate(id: $id, transactionType: $transactionType, status: $status, amountMinor: $amountMinor, currencyCode: $currencyCode, accountSourceId: $accountSourceId, accountDestinationId: $accountDestinationId, categoryId: $categoryId, subcategoryId: $subcategoryId, payeeId: $payeeId, title: $title, description: $description, recurrenceN: $recurrenceN, recurrenceUnit: $recurrenceUnit, recurrenceConstraints: $recurrenceConstraints, startDate: $startDate, endDate: $endDate, postingBehaviour: $postingBehaviour, feeMode: $feeMode, feeAmountMinor: $feeAmountMinor, feePercentageMicro: $feePercentageMicro, feeCategoryId: $feeCategoryId, pauseUntil: $pauseUntil, archivedAt: $archivedAt, archivedReason: $archivedReason, isInstallment: $isInstallment, isDeleted: $isDeleted, deletedAt: $deletedAt, createdAt: $createdAt, updatedAt: $updatedAt, metadata: $metadata)';
  }
}

/// @nodoc
abstract mixin class $RecurringTemplateCopyWith<$Res> {
  factory $RecurringTemplateCopyWith(
          RecurringTemplate value, $Res Function(RecurringTemplate) _then) =
      _$RecurringTemplateCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String transactionType,
      RecurringTemplateStatus status,
      int amountMinor,
      String currencyCode,
      String? accountSourceId,
      String? accountDestinationId,
      String? categoryId,
      String? subcategoryId,
      String? payeeId,
      String? title,
      String? description,
      int recurrenceN,
      RecurrenceUnit recurrenceUnit,
      List<RecurrenceConstraint>? recurrenceConstraints,
      int startDate,
      int? endDate,
      PostingBehaviour postingBehaviour,
      FeeMode? feeMode,
      int? feeAmountMinor,
      int? feePercentageMicro,
      String? feeCategoryId,
      int? pauseUntil,
      int? archivedAt,
      ArchivedReason? archivedReason,
      bool isInstallment,
      bool isDeleted,
      int? deletedAt,
      int createdAt,
      int updatedAt,
      String? metadata});
}

/// @nodoc
class _$RecurringTemplateCopyWithImpl<$Res>
    implements $RecurringTemplateCopyWith<$Res> {
  _$RecurringTemplateCopyWithImpl(this._self, this._then);

  final RecurringTemplate _self;
  final $Res Function(RecurringTemplate) _then;

  /// Create a copy of RecurringTemplate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? transactionType = null,
    Object? status = null,
    Object? amountMinor = null,
    Object? currencyCode = null,
    Object? accountSourceId = freezed,
    Object? accountDestinationId = freezed,
    Object? categoryId = freezed,
    Object? subcategoryId = freezed,
    Object? payeeId = freezed,
    Object? title = freezed,
    Object? description = freezed,
    Object? recurrenceN = null,
    Object? recurrenceUnit = null,
    Object? recurrenceConstraints = freezed,
    Object? startDate = null,
    Object? endDate = freezed,
    Object? postingBehaviour = null,
    Object? feeMode = freezed,
    Object? feeAmountMinor = freezed,
    Object? feePercentageMicro = freezed,
    Object? feeCategoryId = freezed,
    Object? pauseUntil = freezed,
    Object? archivedAt = freezed,
    Object? archivedReason = freezed,
    Object? isInstallment = null,
    Object? isDeleted = null,
    Object? deletedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? metadata = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      transactionType: null == transactionType
          ? _self.transactionType
          : transactionType // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as RecurringTemplateStatus,
      amountMinor: null == amountMinor
          ? _self.amountMinor
          : amountMinor // ignore: cast_nullable_to_non_nullable
              as int,
      currencyCode: null == currencyCode
          ? _self.currencyCode
          : currencyCode // ignore: cast_nullable_to_non_nullable
              as String,
      accountSourceId: freezed == accountSourceId
          ? _self.accountSourceId
          : accountSourceId // ignore: cast_nullable_to_non_nullable
              as String?,
      accountDestinationId: freezed == accountDestinationId
          ? _self.accountDestinationId
          : accountDestinationId // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryId: freezed == categoryId
          ? _self.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      subcategoryId: freezed == subcategoryId
          ? _self.subcategoryId
          : subcategoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      payeeId: freezed == payeeId
          ? _self.payeeId
          : payeeId // ignore: cast_nullable_to_non_nullable
              as String?,
      title: freezed == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      recurrenceN: null == recurrenceN
          ? _self.recurrenceN
          : recurrenceN // ignore: cast_nullable_to_non_nullable
              as int,
      recurrenceUnit: null == recurrenceUnit
          ? _self.recurrenceUnit
          : recurrenceUnit // ignore: cast_nullable_to_non_nullable
              as RecurrenceUnit,
      recurrenceConstraints: freezed == recurrenceConstraints
          ? _self.recurrenceConstraints
          : recurrenceConstraints // ignore: cast_nullable_to_non_nullable
              as List<RecurrenceConstraint>?,
      startDate: null == startDate
          ? _self.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as int,
      endDate: freezed == endDate
          ? _self.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as int?,
      postingBehaviour: null == postingBehaviour
          ? _self.postingBehaviour
          : postingBehaviour // ignore: cast_nullable_to_non_nullable
              as PostingBehaviour,
      feeMode: freezed == feeMode
          ? _self.feeMode
          : feeMode // ignore: cast_nullable_to_non_nullable
              as FeeMode?,
      feeAmountMinor: freezed == feeAmountMinor
          ? _self.feeAmountMinor
          : feeAmountMinor // ignore: cast_nullable_to_non_nullable
              as int?,
      feePercentageMicro: freezed == feePercentageMicro
          ? _self.feePercentageMicro
          : feePercentageMicro // ignore: cast_nullable_to_non_nullable
              as int?,
      feeCategoryId: freezed == feeCategoryId
          ? _self.feeCategoryId
          : feeCategoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      pauseUntil: freezed == pauseUntil
          ? _self.pauseUntil
          : pauseUntil // ignore: cast_nullable_to_non_nullable
              as int?,
      archivedAt: freezed == archivedAt
          ? _self.archivedAt
          : archivedAt // ignore: cast_nullable_to_non_nullable
              as int?,
      archivedReason: freezed == archivedReason
          ? _self.archivedReason
          : archivedReason // ignore: cast_nullable_to_non_nullable
              as ArchivedReason?,
      isInstallment: null == isInstallment
          ? _self.isInstallment
          : isInstallment // ignore: cast_nullable_to_non_nullable
              as bool,
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
      metadata: freezed == metadata
          ? _self.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [RecurringTemplate].
extension RecurringTemplatePatterns on RecurringTemplate {
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
    TResult Function(_RecurringTemplate value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RecurringTemplate() when $default != null:
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
    TResult Function(_RecurringTemplate value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecurringTemplate():
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
    TResult? Function(_RecurringTemplate value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecurringTemplate() when $default != null:
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
            String transactionType,
            RecurringTemplateStatus status,
            int amountMinor,
            String currencyCode,
            String? accountSourceId,
            String? accountDestinationId,
            String? categoryId,
            String? subcategoryId,
            String? payeeId,
            String? title,
            String? description,
            int recurrenceN,
            RecurrenceUnit recurrenceUnit,
            List<RecurrenceConstraint>? recurrenceConstraints,
            int startDate,
            int? endDate,
            PostingBehaviour postingBehaviour,
            FeeMode? feeMode,
            int? feeAmountMinor,
            int? feePercentageMicro,
            String? feeCategoryId,
            int? pauseUntil,
            int? archivedAt,
            ArchivedReason? archivedReason,
            bool isInstallment,
            bool isDeleted,
            int? deletedAt,
            int createdAt,
            int updatedAt,
            String? metadata)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RecurringTemplate() when $default != null:
        return $default(
            _that.id,
            _that.transactionType,
            _that.status,
            _that.amountMinor,
            _that.currencyCode,
            _that.accountSourceId,
            _that.accountDestinationId,
            _that.categoryId,
            _that.subcategoryId,
            _that.payeeId,
            _that.title,
            _that.description,
            _that.recurrenceN,
            _that.recurrenceUnit,
            _that.recurrenceConstraints,
            _that.startDate,
            _that.endDate,
            _that.postingBehaviour,
            _that.feeMode,
            _that.feeAmountMinor,
            _that.feePercentageMicro,
            _that.feeCategoryId,
            _that.pauseUntil,
            _that.archivedAt,
            _that.archivedReason,
            _that.isInstallment,
            _that.isDeleted,
            _that.deletedAt,
            _that.createdAt,
            _that.updatedAt,
            _that.metadata);
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
            String transactionType,
            RecurringTemplateStatus status,
            int amountMinor,
            String currencyCode,
            String? accountSourceId,
            String? accountDestinationId,
            String? categoryId,
            String? subcategoryId,
            String? payeeId,
            String? title,
            String? description,
            int recurrenceN,
            RecurrenceUnit recurrenceUnit,
            List<RecurrenceConstraint>? recurrenceConstraints,
            int startDate,
            int? endDate,
            PostingBehaviour postingBehaviour,
            FeeMode? feeMode,
            int? feeAmountMinor,
            int? feePercentageMicro,
            String? feeCategoryId,
            int? pauseUntil,
            int? archivedAt,
            ArchivedReason? archivedReason,
            bool isInstallment,
            bool isDeleted,
            int? deletedAt,
            int createdAt,
            int updatedAt,
            String? metadata)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecurringTemplate():
        return $default(
            _that.id,
            _that.transactionType,
            _that.status,
            _that.amountMinor,
            _that.currencyCode,
            _that.accountSourceId,
            _that.accountDestinationId,
            _that.categoryId,
            _that.subcategoryId,
            _that.payeeId,
            _that.title,
            _that.description,
            _that.recurrenceN,
            _that.recurrenceUnit,
            _that.recurrenceConstraints,
            _that.startDate,
            _that.endDate,
            _that.postingBehaviour,
            _that.feeMode,
            _that.feeAmountMinor,
            _that.feePercentageMicro,
            _that.feeCategoryId,
            _that.pauseUntil,
            _that.archivedAt,
            _that.archivedReason,
            _that.isInstallment,
            _that.isDeleted,
            _that.deletedAt,
            _that.createdAt,
            _that.updatedAt,
            _that.metadata);
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
            String transactionType,
            RecurringTemplateStatus status,
            int amountMinor,
            String currencyCode,
            String? accountSourceId,
            String? accountDestinationId,
            String? categoryId,
            String? subcategoryId,
            String? payeeId,
            String? title,
            String? description,
            int recurrenceN,
            RecurrenceUnit recurrenceUnit,
            List<RecurrenceConstraint>? recurrenceConstraints,
            int startDate,
            int? endDate,
            PostingBehaviour postingBehaviour,
            FeeMode? feeMode,
            int? feeAmountMinor,
            int? feePercentageMicro,
            String? feeCategoryId,
            int? pauseUntil,
            int? archivedAt,
            ArchivedReason? archivedReason,
            bool isInstallment,
            bool isDeleted,
            int? deletedAt,
            int createdAt,
            int updatedAt,
            String? metadata)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecurringTemplate() when $default != null:
        return $default(
            _that.id,
            _that.transactionType,
            _that.status,
            _that.amountMinor,
            _that.currencyCode,
            _that.accountSourceId,
            _that.accountDestinationId,
            _that.categoryId,
            _that.subcategoryId,
            _that.payeeId,
            _that.title,
            _that.description,
            _that.recurrenceN,
            _that.recurrenceUnit,
            _that.recurrenceConstraints,
            _that.startDate,
            _that.endDate,
            _that.postingBehaviour,
            _that.feeMode,
            _that.feeAmountMinor,
            _that.feePercentageMicro,
            _that.feeCategoryId,
            _that.pauseUntil,
            _that.archivedAt,
            _that.archivedReason,
            _that.isInstallment,
            _that.isDeleted,
            _that.deletedAt,
            _that.createdAt,
            _that.updatedAt,
            _that.metadata);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _RecurringTemplate implements RecurringTemplate {
  const _RecurringTemplate(
      {required this.id,
      required this.transactionType,
      this.status = RecurringTemplateStatus.active,
      required this.amountMinor,
      required this.currencyCode,
      this.accountSourceId,
      this.accountDestinationId,
      this.categoryId,
      this.subcategoryId,
      this.payeeId,
      this.title,
      this.description,
      required this.recurrenceN,
      required this.recurrenceUnit,
      final List<RecurrenceConstraint>? recurrenceConstraints,
      required this.startDate,
      this.endDate,
      this.postingBehaviour = PostingBehaviour.autoPost,
      this.feeMode,
      this.feeAmountMinor,
      this.feePercentageMicro,
      this.feeCategoryId,
      this.pauseUntil,
      this.archivedAt,
      this.archivedReason,
      this.isInstallment = false,
      this.isDeleted = false,
      this.deletedAt,
      required this.createdAt,
      required this.updatedAt,
      this.metadata})
      : _recurrenceConstraints = recurrenceConstraints;

  /// UUID v4 stable identifier.
  @override
  final String id;

  /// Financial direction; immutable after creation.
  @override
  final String transactionType;

  /// Lifecycle state.
  @override
  @JsonKey()
  final RecurringTemplateStatus status;

  /// Per-occurrence amount in minor units; in-place editable.
  @override
  final int amountMinor;

  /// ISO 4217 code; derived from source account.
  @override
  final String currencyCode;

  /// Source account UUID; null for income.
  @override
  final String? accountSourceId;

  /// Destination account UUID; null for expense.
  @override
  final String? accountDestinationId;

  /// Category UUID; null for transfer; editable.
  @override
  final String? categoryId;

  /// Subcategory UUID; editable.
  @override
  final String? subcategoryId;

  /// Payee UUID; optional.
  @override
  final String? payeeId;

  /// Template title; editable.
  @override
  final String? title;

  /// Description; editable.
  @override
  final String? description;

  /// Cadence multiplier (e.g. 2 in "every 2 weeks"); immutable.
  @override
  final int recurrenceN;

  /// Cadence time unit; immutable.
  @override
  final RecurrenceUnit recurrenceUnit;

  /// Optional scheduling constraints (JSON array of [RecurrenceConstraint]);
  /// immutable.
  final List<RecurrenceConstraint>? _recurrenceConstraints;

  /// Optional scheduling constraints (JSON array of [RecurrenceConstraint]);
  /// immutable.
  @override
  List<RecurrenceConstraint>? get recurrenceConstraints {
    final value = _recurrenceConstraints;
    if (value == null) return null;
    if (_recurrenceConstraints is EqualUnmodifiableListView)
      return _recurrenceConstraints;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// First occurrence date (Unix epoch days); immutable.
  @override
  final int startDate;

  /// Last valid occurrence date; immutable for recurring; computed for
  /// installments.
  @override
  final int? endDate;

  /// Auto-posting behaviour; editable.
  @override
  @JsonKey()
  final PostingBehaviour postingBehaviour;

  /// Transfer fee mode; null = no fee.
  @override
  final FeeMode? feeMode;

  /// Flat fee in minor units.
  @override
  final int? feeAmountMinor;

  /// Percentage fee × 1,000,000.
  @override
  final int? feePercentageMicro;

  /// Fee expense category UUID.
  @override
  final String? feeCategoryId;

  /// Resume-after epoch; null = not paused.
  @override
  final int? pauseUntil;

  /// Archival epoch; null = not archived.
  @override
  final int? archivedAt;

  /// Archival trigger; null = not archived.
  @override
  final ArchivedReason? archivedReason;

  /// Discriminator: false = recurring, true = installment.
  @override
  @JsonKey()
  final bool isInstallment;

  /// Soft-delete flag.
  @override
  @JsonKey()
  final bool isDeleted;

  /// Soft-delete epoch.
  @override
  final int? deletedAt;

  /// Creation epoch (Unix seconds).
  @override
  final int createdAt;

  /// Last-modified epoch (Unix seconds).
  @override
  final int updatedAt;

  /// JSON escape hatch.
  @override
  final String? metadata;

  /// Create a copy of RecurringTemplate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$RecurringTemplateCopyWith<_RecurringTemplate> get copyWith =>
      __$RecurringTemplateCopyWithImpl<_RecurringTemplate>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _RecurringTemplate &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.transactionType, transactionType) ||
                other.transactionType == transactionType) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.amountMinor, amountMinor) ||
                other.amountMinor == amountMinor) &&
            (identical(other.currencyCode, currencyCode) ||
                other.currencyCode == currencyCode) &&
            (identical(other.accountSourceId, accountSourceId) ||
                other.accountSourceId == accountSourceId) &&
            (identical(other.accountDestinationId, accountDestinationId) ||
                other.accountDestinationId == accountDestinationId) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.subcategoryId, subcategoryId) ||
                other.subcategoryId == subcategoryId) &&
            (identical(other.payeeId, payeeId) || other.payeeId == payeeId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.recurrenceN, recurrenceN) ||
                other.recurrenceN == recurrenceN) &&
            (identical(other.recurrenceUnit, recurrenceUnit) ||
                other.recurrenceUnit == recurrenceUnit) &&
            const DeepCollectionEquality()
                .equals(other._recurrenceConstraints, _recurrenceConstraints) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.postingBehaviour, postingBehaviour) ||
                other.postingBehaviour == postingBehaviour) &&
            (identical(other.feeMode, feeMode) || other.feeMode == feeMode) &&
            (identical(other.feeAmountMinor, feeAmountMinor) ||
                other.feeAmountMinor == feeAmountMinor) &&
            (identical(other.feePercentageMicro, feePercentageMicro) ||
                other.feePercentageMicro == feePercentageMicro) &&
            (identical(other.feeCategoryId, feeCategoryId) ||
                other.feeCategoryId == feeCategoryId) &&
            (identical(other.pauseUntil, pauseUntil) ||
                other.pauseUntil == pauseUntil) &&
            (identical(other.archivedAt, archivedAt) ||
                other.archivedAt == archivedAt) &&
            (identical(other.archivedReason, archivedReason) ||
                other.archivedReason == archivedReason) &&
            (identical(other.isInstallment, isInstallment) ||
                other.isInstallment == isInstallment) &&
            (identical(other.isDeleted, isDeleted) ||
                other.isDeleted == isDeleted) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.metadata, metadata) ||
                other.metadata == metadata));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        transactionType,
        status,
        amountMinor,
        currencyCode,
        accountSourceId,
        accountDestinationId,
        categoryId,
        subcategoryId,
        payeeId,
        title,
        description,
        recurrenceN,
        recurrenceUnit,
        const DeepCollectionEquality().hash(_recurrenceConstraints),
        startDate,
        endDate,
        postingBehaviour,
        feeMode,
        feeAmountMinor,
        feePercentageMicro,
        feeCategoryId,
        pauseUntil,
        archivedAt,
        archivedReason,
        isInstallment,
        isDeleted,
        deletedAt,
        createdAt,
        updatedAt,
        metadata
      ]);

  @override
  String toString() {
    return 'RecurringTemplate(id: $id, transactionType: $transactionType, status: $status, amountMinor: $amountMinor, currencyCode: $currencyCode, accountSourceId: $accountSourceId, accountDestinationId: $accountDestinationId, categoryId: $categoryId, subcategoryId: $subcategoryId, payeeId: $payeeId, title: $title, description: $description, recurrenceN: $recurrenceN, recurrenceUnit: $recurrenceUnit, recurrenceConstraints: $recurrenceConstraints, startDate: $startDate, endDate: $endDate, postingBehaviour: $postingBehaviour, feeMode: $feeMode, feeAmountMinor: $feeAmountMinor, feePercentageMicro: $feePercentageMicro, feeCategoryId: $feeCategoryId, pauseUntil: $pauseUntil, archivedAt: $archivedAt, archivedReason: $archivedReason, isInstallment: $isInstallment, isDeleted: $isDeleted, deletedAt: $deletedAt, createdAt: $createdAt, updatedAt: $updatedAt, metadata: $metadata)';
  }
}

/// @nodoc
abstract mixin class _$RecurringTemplateCopyWith<$Res>
    implements $RecurringTemplateCopyWith<$Res> {
  factory _$RecurringTemplateCopyWith(
          _RecurringTemplate value, $Res Function(_RecurringTemplate) _then) =
      __$RecurringTemplateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String transactionType,
      RecurringTemplateStatus status,
      int amountMinor,
      String currencyCode,
      String? accountSourceId,
      String? accountDestinationId,
      String? categoryId,
      String? subcategoryId,
      String? payeeId,
      String? title,
      String? description,
      int recurrenceN,
      RecurrenceUnit recurrenceUnit,
      List<RecurrenceConstraint>? recurrenceConstraints,
      int startDate,
      int? endDate,
      PostingBehaviour postingBehaviour,
      FeeMode? feeMode,
      int? feeAmountMinor,
      int? feePercentageMicro,
      String? feeCategoryId,
      int? pauseUntil,
      int? archivedAt,
      ArchivedReason? archivedReason,
      bool isInstallment,
      bool isDeleted,
      int? deletedAt,
      int createdAt,
      int updatedAt,
      String? metadata});
}

/// @nodoc
class __$RecurringTemplateCopyWithImpl<$Res>
    implements _$RecurringTemplateCopyWith<$Res> {
  __$RecurringTemplateCopyWithImpl(this._self, this._then);

  final _RecurringTemplate _self;
  final $Res Function(_RecurringTemplate) _then;

  /// Create a copy of RecurringTemplate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? transactionType = null,
    Object? status = null,
    Object? amountMinor = null,
    Object? currencyCode = null,
    Object? accountSourceId = freezed,
    Object? accountDestinationId = freezed,
    Object? categoryId = freezed,
    Object? subcategoryId = freezed,
    Object? payeeId = freezed,
    Object? title = freezed,
    Object? description = freezed,
    Object? recurrenceN = null,
    Object? recurrenceUnit = null,
    Object? recurrenceConstraints = freezed,
    Object? startDate = null,
    Object? endDate = freezed,
    Object? postingBehaviour = null,
    Object? feeMode = freezed,
    Object? feeAmountMinor = freezed,
    Object? feePercentageMicro = freezed,
    Object? feeCategoryId = freezed,
    Object? pauseUntil = freezed,
    Object? archivedAt = freezed,
    Object? archivedReason = freezed,
    Object? isInstallment = null,
    Object? isDeleted = null,
    Object? deletedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? metadata = freezed,
  }) {
    return _then(_RecurringTemplate(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      transactionType: null == transactionType
          ? _self.transactionType
          : transactionType // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as RecurringTemplateStatus,
      amountMinor: null == amountMinor
          ? _self.amountMinor
          : amountMinor // ignore: cast_nullable_to_non_nullable
              as int,
      currencyCode: null == currencyCode
          ? _self.currencyCode
          : currencyCode // ignore: cast_nullable_to_non_nullable
              as String,
      accountSourceId: freezed == accountSourceId
          ? _self.accountSourceId
          : accountSourceId // ignore: cast_nullable_to_non_nullable
              as String?,
      accountDestinationId: freezed == accountDestinationId
          ? _self.accountDestinationId
          : accountDestinationId // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryId: freezed == categoryId
          ? _self.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      subcategoryId: freezed == subcategoryId
          ? _self.subcategoryId
          : subcategoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      payeeId: freezed == payeeId
          ? _self.payeeId
          : payeeId // ignore: cast_nullable_to_non_nullable
              as String?,
      title: freezed == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      recurrenceN: null == recurrenceN
          ? _self.recurrenceN
          : recurrenceN // ignore: cast_nullable_to_non_nullable
              as int,
      recurrenceUnit: null == recurrenceUnit
          ? _self.recurrenceUnit
          : recurrenceUnit // ignore: cast_nullable_to_non_nullable
              as RecurrenceUnit,
      recurrenceConstraints: freezed == recurrenceConstraints
          ? _self._recurrenceConstraints
          : recurrenceConstraints // ignore: cast_nullable_to_non_nullable
              as List<RecurrenceConstraint>?,
      startDate: null == startDate
          ? _self.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as int,
      endDate: freezed == endDate
          ? _self.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as int?,
      postingBehaviour: null == postingBehaviour
          ? _self.postingBehaviour
          : postingBehaviour // ignore: cast_nullable_to_non_nullable
              as PostingBehaviour,
      feeMode: freezed == feeMode
          ? _self.feeMode
          : feeMode // ignore: cast_nullable_to_non_nullable
              as FeeMode?,
      feeAmountMinor: freezed == feeAmountMinor
          ? _self.feeAmountMinor
          : feeAmountMinor // ignore: cast_nullable_to_non_nullable
              as int?,
      feePercentageMicro: freezed == feePercentageMicro
          ? _self.feePercentageMicro
          : feePercentageMicro // ignore: cast_nullable_to_non_nullable
              as int?,
      feeCategoryId: freezed == feeCategoryId
          ? _self.feeCategoryId
          : feeCategoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      pauseUntil: freezed == pauseUntil
          ? _self.pauseUntil
          : pauseUntil // ignore: cast_nullable_to_non_nullable
              as int?,
      archivedAt: freezed == archivedAt
          ? _self.archivedAt
          : archivedAt // ignore: cast_nullable_to_non_nullable
              as int?,
      archivedReason: freezed == archivedReason
          ? _self.archivedReason
          : archivedReason // ignore: cast_nullable_to_non_nullable
              as ArchivedReason?,
      isInstallment: null == isInstallment
          ? _self.isInstallment
          : isInstallment // ignore: cast_nullable_to_non_nullable
              as bool,
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
      metadata: freezed == metadata
          ? _self.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
