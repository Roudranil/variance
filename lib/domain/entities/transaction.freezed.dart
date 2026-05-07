// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Transaction {
  /// UUID v4 stable identifier.
  String get id;

  /// Financial direction of the event.
  TransactionType get type;

  /// Ledger participation state (TC-001).
  TransactionStatus get status;

  /// Role within the correction/reversal chain (TC-001).
  TransactionPurpose get purpose;

  /// Business date as Unix epoch seconds.
  int get dateTime;

  /// Amount in minor units of [currencyCode].
  int get amountMinor;

  /// ISO 4217 code; derived from source account; immutable after posting.
  String get currencyCode;

  /// Exchange rate × 1,000,000 from [currencyCode] to
  /// [homeCurrencyAtCapture]; null if currencies are equal (TC-029).
  int? get exchangeRateMicro;

  /// Home currency at the time the rate was captured (TC-029).
  String? get homeCurrencyAtCapture;

  /// Source account for expense/transfer; null for income.
  String? get accountSourceId;

  /// Destination account for income/transfer; null for expense.
  String? get accountDestinationId;

  /// Top-level category; null for transfer.
  String? get categoryId;

  /// Optional subcategory; null for transfer.
  String? get subcategoryId;

  /// Optional payee/merchant reference.
  String? get payeeId;

  /// User-provided label; in-place editable.
  String? get title;

  /// Long-form description; in-place editable.
  String? get description;

  /// UUID shared by compound group members (e.g. transfer + fee); null for
  /// non-compound transactions.
  String? get compoundGroupId;

  /// Role within a compound group; null for non-compound.
  String? get compoundRole;

  /// Link to the recurring template that generated this transaction.
  String? get parentTemplateId;

  /// For purpose = correction or reversal: the ID of the transaction being
  /// corrected/reversed.
  String? get correctsTransactionId;

  /// True when a recurring child was edited/deleted outside normal scheduling.
  bool get isManuallyHandled;

  /// System creation epoch.
  int get createdAt;

  /// Last-modified epoch.
  int get updatedAt;

  /// JSON escape hatch.
  String? get metadata;

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TransactionCopyWith<Transaction> get copyWith =>
      _$TransactionCopyWithImpl<Transaction>(this as Transaction, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Transaction &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.purpose, purpose) || other.purpose == purpose) &&
            (identical(other.dateTime, dateTime) ||
                other.dateTime == dateTime) &&
            (identical(other.amountMinor, amountMinor) ||
                other.amountMinor == amountMinor) &&
            (identical(other.currencyCode, currencyCode) ||
                other.currencyCode == currencyCode) &&
            (identical(other.exchangeRateMicro, exchangeRateMicro) ||
                other.exchangeRateMicro == exchangeRateMicro) &&
            (identical(other.homeCurrencyAtCapture, homeCurrencyAtCapture) ||
                other.homeCurrencyAtCapture == homeCurrencyAtCapture) &&
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
            (identical(other.compoundGroupId, compoundGroupId) ||
                other.compoundGroupId == compoundGroupId) &&
            (identical(other.compoundRole, compoundRole) ||
                other.compoundRole == compoundRole) &&
            (identical(other.parentTemplateId, parentTemplateId) ||
                other.parentTemplateId == parentTemplateId) &&
            (identical(other.correctsTransactionId, correctsTransactionId) ||
                other.correctsTransactionId == correctsTransactionId) &&
            (identical(other.isManuallyHandled, isManuallyHandled) ||
                other.isManuallyHandled == isManuallyHandled) &&
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
        type,
        status,
        purpose,
        dateTime,
        amountMinor,
        currencyCode,
        exchangeRateMicro,
        homeCurrencyAtCapture,
        accountSourceId,
        accountDestinationId,
        categoryId,
        subcategoryId,
        payeeId,
        title,
        description,
        compoundGroupId,
        compoundRole,
        parentTemplateId,
        correctsTransactionId,
        isManuallyHandled,
        createdAt,
        updatedAt,
        metadata
      ]);

  @override
  String toString() {
    return 'Transaction(id: $id, type: $type, status: $status, purpose: $purpose, dateTime: $dateTime, amountMinor: $amountMinor, currencyCode: $currencyCode, exchangeRateMicro: $exchangeRateMicro, homeCurrencyAtCapture: $homeCurrencyAtCapture, accountSourceId: $accountSourceId, accountDestinationId: $accountDestinationId, categoryId: $categoryId, subcategoryId: $subcategoryId, payeeId: $payeeId, title: $title, description: $description, compoundGroupId: $compoundGroupId, compoundRole: $compoundRole, parentTemplateId: $parentTemplateId, correctsTransactionId: $correctsTransactionId, isManuallyHandled: $isManuallyHandled, createdAt: $createdAt, updatedAt: $updatedAt, metadata: $metadata)';
  }
}

/// @nodoc
abstract mixin class $TransactionCopyWith<$Res> {
  factory $TransactionCopyWith(
          Transaction value, $Res Function(Transaction) _then) =
      _$TransactionCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      TransactionType type,
      TransactionStatus status,
      TransactionPurpose purpose,
      int dateTime,
      int amountMinor,
      String currencyCode,
      int? exchangeRateMicro,
      String? homeCurrencyAtCapture,
      String? accountSourceId,
      String? accountDestinationId,
      String? categoryId,
      String? subcategoryId,
      String? payeeId,
      String? title,
      String? description,
      String? compoundGroupId,
      String? compoundRole,
      String? parentTemplateId,
      String? correctsTransactionId,
      bool isManuallyHandled,
      int createdAt,
      int updatedAt,
      String? metadata});
}

/// @nodoc
class _$TransactionCopyWithImpl<$Res> implements $TransactionCopyWith<$Res> {
  _$TransactionCopyWithImpl(this._self, this._then);

  final Transaction _self;
  final $Res Function(Transaction) _then;

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? status = null,
    Object? purpose = null,
    Object? dateTime = null,
    Object? amountMinor = null,
    Object? currencyCode = null,
    Object? exchangeRateMicro = freezed,
    Object? homeCurrencyAtCapture = freezed,
    Object? accountSourceId = freezed,
    Object? accountDestinationId = freezed,
    Object? categoryId = freezed,
    Object? subcategoryId = freezed,
    Object? payeeId = freezed,
    Object? title = freezed,
    Object? description = freezed,
    Object? compoundGroupId = freezed,
    Object? compoundRole = freezed,
    Object? parentTemplateId = freezed,
    Object? correctsTransactionId = freezed,
    Object? isManuallyHandled = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? metadata = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as TransactionType,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as TransactionStatus,
      purpose: null == purpose
          ? _self.purpose
          : purpose // ignore: cast_nullable_to_non_nullable
              as TransactionPurpose,
      dateTime: null == dateTime
          ? _self.dateTime
          : dateTime // ignore: cast_nullable_to_non_nullable
              as int,
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
      homeCurrencyAtCapture: freezed == homeCurrencyAtCapture
          ? _self.homeCurrencyAtCapture
          : homeCurrencyAtCapture // ignore: cast_nullable_to_non_nullable
              as String?,
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
      compoundGroupId: freezed == compoundGroupId
          ? _self.compoundGroupId
          : compoundGroupId // ignore: cast_nullable_to_non_nullable
              as String?,
      compoundRole: freezed == compoundRole
          ? _self.compoundRole
          : compoundRole // ignore: cast_nullable_to_non_nullable
              as String?,
      parentTemplateId: freezed == parentTemplateId
          ? _self.parentTemplateId
          : parentTemplateId // ignore: cast_nullable_to_non_nullable
              as String?,
      correctsTransactionId: freezed == correctsTransactionId
          ? _self.correctsTransactionId
          : correctsTransactionId // ignore: cast_nullable_to_non_nullable
              as String?,
      isManuallyHandled: null == isManuallyHandled
          ? _self.isManuallyHandled
          : isManuallyHandled // ignore: cast_nullable_to_non_nullable
              as bool,
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

/// Adds pattern-matching-related methods to [Transaction].
extension TransactionPatterns on Transaction {
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
    TResult Function(_Transaction value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Transaction() when $default != null:
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
    TResult Function(_Transaction value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Transaction():
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
    TResult? Function(_Transaction value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Transaction() when $default != null:
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
            TransactionType type,
            TransactionStatus status,
            TransactionPurpose purpose,
            int dateTime,
            int amountMinor,
            String currencyCode,
            int? exchangeRateMicro,
            String? homeCurrencyAtCapture,
            String? accountSourceId,
            String? accountDestinationId,
            String? categoryId,
            String? subcategoryId,
            String? payeeId,
            String? title,
            String? description,
            String? compoundGroupId,
            String? compoundRole,
            String? parentTemplateId,
            String? correctsTransactionId,
            bool isManuallyHandled,
            int createdAt,
            int updatedAt,
            String? metadata)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Transaction() when $default != null:
        return $default(
            _that.id,
            _that.type,
            _that.status,
            _that.purpose,
            _that.dateTime,
            _that.amountMinor,
            _that.currencyCode,
            _that.exchangeRateMicro,
            _that.homeCurrencyAtCapture,
            _that.accountSourceId,
            _that.accountDestinationId,
            _that.categoryId,
            _that.subcategoryId,
            _that.payeeId,
            _that.title,
            _that.description,
            _that.compoundGroupId,
            _that.compoundRole,
            _that.parentTemplateId,
            _that.correctsTransactionId,
            _that.isManuallyHandled,
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
            TransactionType type,
            TransactionStatus status,
            TransactionPurpose purpose,
            int dateTime,
            int amountMinor,
            String currencyCode,
            int? exchangeRateMicro,
            String? homeCurrencyAtCapture,
            String? accountSourceId,
            String? accountDestinationId,
            String? categoryId,
            String? subcategoryId,
            String? payeeId,
            String? title,
            String? description,
            String? compoundGroupId,
            String? compoundRole,
            String? parentTemplateId,
            String? correctsTransactionId,
            bool isManuallyHandled,
            int createdAt,
            int updatedAt,
            String? metadata)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Transaction():
        return $default(
            _that.id,
            _that.type,
            _that.status,
            _that.purpose,
            _that.dateTime,
            _that.amountMinor,
            _that.currencyCode,
            _that.exchangeRateMicro,
            _that.homeCurrencyAtCapture,
            _that.accountSourceId,
            _that.accountDestinationId,
            _that.categoryId,
            _that.subcategoryId,
            _that.payeeId,
            _that.title,
            _that.description,
            _that.compoundGroupId,
            _that.compoundRole,
            _that.parentTemplateId,
            _that.correctsTransactionId,
            _that.isManuallyHandled,
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
            TransactionType type,
            TransactionStatus status,
            TransactionPurpose purpose,
            int dateTime,
            int amountMinor,
            String currencyCode,
            int? exchangeRateMicro,
            String? homeCurrencyAtCapture,
            String? accountSourceId,
            String? accountDestinationId,
            String? categoryId,
            String? subcategoryId,
            String? payeeId,
            String? title,
            String? description,
            String? compoundGroupId,
            String? compoundRole,
            String? parentTemplateId,
            String? correctsTransactionId,
            bool isManuallyHandled,
            int createdAt,
            int updatedAt,
            String? metadata)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Transaction() when $default != null:
        return $default(
            _that.id,
            _that.type,
            _that.status,
            _that.purpose,
            _that.dateTime,
            _that.amountMinor,
            _that.currencyCode,
            _that.exchangeRateMicro,
            _that.homeCurrencyAtCapture,
            _that.accountSourceId,
            _that.accountDestinationId,
            _that.categoryId,
            _that.subcategoryId,
            _that.payeeId,
            _that.title,
            _that.description,
            _that.compoundGroupId,
            _that.compoundRole,
            _that.parentTemplateId,
            _that.correctsTransactionId,
            _that.isManuallyHandled,
            _that.createdAt,
            _that.updatedAt,
            _that.metadata);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Transaction implements Transaction {
  const _Transaction(
      {required this.id,
      required this.type,
      required this.status,
      this.purpose = TransactionPurpose.user,
      required this.dateTime,
      required this.amountMinor,
      required this.currencyCode,
      this.exchangeRateMicro,
      this.homeCurrencyAtCapture,
      this.accountSourceId,
      this.accountDestinationId,
      this.categoryId,
      this.subcategoryId,
      this.payeeId,
      this.title,
      this.description,
      this.compoundGroupId,
      this.compoundRole,
      this.parentTemplateId,
      this.correctsTransactionId,
      this.isManuallyHandled = false,
      required this.createdAt,
      required this.updatedAt,
      this.metadata});

  /// UUID v4 stable identifier.
  @override
  final String id;

  /// Financial direction of the event.
  @override
  final TransactionType type;

  /// Ledger participation state (TC-001).
  @override
  final TransactionStatus status;

  /// Role within the correction/reversal chain (TC-001).
  @override
  @JsonKey()
  final TransactionPurpose purpose;

  /// Business date as Unix epoch seconds.
  @override
  final int dateTime;

  /// Amount in minor units of [currencyCode].
  @override
  final int amountMinor;

  /// ISO 4217 code; derived from source account; immutable after posting.
  @override
  final String currencyCode;

  /// Exchange rate × 1,000,000 from [currencyCode] to
  /// [homeCurrencyAtCapture]; null if currencies are equal (TC-029).
  @override
  final int? exchangeRateMicro;

  /// Home currency at the time the rate was captured (TC-029).
  @override
  final String? homeCurrencyAtCapture;

  /// Source account for expense/transfer; null for income.
  @override
  final String? accountSourceId;

  /// Destination account for income/transfer; null for expense.
  @override
  final String? accountDestinationId;

  /// Top-level category; null for transfer.
  @override
  final String? categoryId;

  /// Optional subcategory; null for transfer.
  @override
  final String? subcategoryId;

  /// Optional payee/merchant reference.
  @override
  final String? payeeId;

  /// User-provided label; in-place editable.
  @override
  final String? title;

  /// Long-form description; in-place editable.
  @override
  final String? description;

  /// UUID shared by compound group members (e.g. transfer + fee); null for
  /// non-compound transactions.
  @override
  final String? compoundGroupId;

  /// Role within a compound group; null for non-compound.
  @override
  final String? compoundRole;

  /// Link to the recurring template that generated this transaction.
  @override
  final String? parentTemplateId;

  /// For purpose = correction or reversal: the ID of the transaction being
  /// corrected/reversed.
  @override
  final String? correctsTransactionId;

  /// True when a recurring child was edited/deleted outside normal scheduling.
  @override
  @JsonKey()
  final bool isManuallyHandled;

  /// System creation epoch.
  @override
  final int createdAt;

  /// Last-modified epoch.
  @override
  final int updatedAt;

  /// JSON escape hatch.
  @override
  final String? metadata;

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TransactionCopyWith<_Transaction> get copyWith =>
      __$TransactionCopyWithImpl<_Transaction>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Transaction &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.purpose, purpose) || other.purpose == purpose) &&
            (identical(other.dateTime, dateTime) ||
                other.dateTime == dateTime) &&
            (identical(other.amountMinor, amountMinor) ||
                other.amountMinor == amountMinor) &&
            (identical(other.currencyCode, currencyCode) ||
                other.currencyCode == currencyCode) &&
            (identical(other.exchangeRateMicro, exchangeRateMicro) ||
                other.exchangeRateMicro == exchangeRateMicro) &&
            (identical(other.homeCurrencyAtCapture, homeCurrencyAtCapture) ||
                other.homeCurrencyAtCapture == homeCurrencyAtCapture) &&
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
            (identical(other.compoundGroupId, compoundGroupId) ||
                other.compoundGroupId == compoundGroupId) &&
            (identical(other.compoundRole, compoundRole) ||
                other.compoundRole == compoundRole) &&
            (identical(other.parentTemplateId, parentTemplateId) ||
                other.parentTemplateId == parentTemplateId) &&
            (identical(other.correctsTransactionId, correctsTransactionId) ||
                other.correctsTransactionId == correctsTransactionId) &&
            (identical(other.isManuallyHandled, isManuallyHandled) ||
                other.isManuallyHandled == isManuallyHandled) &&
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
        type,
        status,
        purpose,
        dateTime,
        amountMinor,
        currencyCode,
        exchangeRateMicro,
        homeCurrencyAtCapture,
        accountSourceId,
        accountDestinationId,
        categoryId,
        subcategoryId,
        payeeId,
        title,
        description,
        compoundGroupId,
        compoundRole,
        parentTemplateId,
        correctsTransactionId,
        isManuallyHandled,
        createdAt,
        updatedAt,
        metadata
      ]);

  @override
  String toString() {
    return 'Transaction(id: $id, type: $type, status: $status, purpose: $purpose, dateTime: $dateTime, amountMinor: $amountMinor, currencyCode: $currencyCode, exchangeRateMicro: $exchangeRateMicro, homeCurrencyAtCapture: $homeCurrencyAtCapture, accountSourceId: $accountSourceId, accountDestinationId: $accountDestinationId, categoryId: $categoryId, subcategoryId: $subcategoryId, payeeId: $payeeId, title: $title, description: $description, compoundGroupId: $compoundGroupId, compoundRole: $compoundRole, parentTemplateId: $parentTemplateId, correctsTransactionId: $correctsTransactionId, isManuallyHandled: $isManuallyHandled, createdAt: $createdAt, updatedAt: $updatedAt, metadata: $metadata)';
  }
}

/// @nodoc
abstract mixin class _$TransactionCopyWith<$Res>
    implements $TransactionCopyWith<$Res> {
  factory _$TransactionCopyWith(
          _Transaction value, $Res Function(_Transaction) _then) =
      __$TransactionCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      TransactionType type,
      TransactionStatus status,
      TransactionPurpose purpose,
      int dateTime,
      int amountMinor,
      String currencyCode,
      int? exchangeRateMicro,
      String? homeCurrencyAtCapture,
      String? accountSourceId,
      String? accountDestinationId,
      String? categoryId,
      String? subcategoryId,
      String? payeeId,
      String? title,
      String? description,
      String? compoundGroupId,
      String? compoundRole,
      String? parentTemplateId,
      String? correctsTransactionId,
      bool isManuallyHandled,
      int createdAt,
      int updatedAt,
      String? metadata});
}

/// @nodoc
class __$TransactionCopyWithImpl<$Res> implements _$TransactionCopyWith<$Res> {
  __$TransactionCopyWithImpl(this._self, this._then);

  final _Transaction _self;
  final $Res Function(_Transaction) _then;

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? status = null,
    Object? purpose = null,
    Object? dateTime = null,
    Object? amountMinor = null,
    Object? currencyCode = null,
    Object? exchangeRateMicro = freezed,
    Object? homeCurrencyAtCapture = freezed,
    Object? accountSourceId = freezed,
    Object? accountDestinationId = freezed,
    Object? categoryId = freezed,
    Object? subcategoryId = freezed,
    Object? payeeId = freezed,
    Object? title = freezed,
    Object? description = freezed,
    Object? compoundGroupId = freezed,
    Object? compoundRole = freezed,
    Object? parentTemplateId = freezed,
    Object? correctsTransactionId = freezed,
    Object? isManuallyHandled = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? metadata = freezed,
  }) {
    return _then(_Transaction(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as TransactionType,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as TransactionStatus,
      purpose: null == purpose
          ? _self.purpose
          : purpose // ignore: cast_nullable_to_non_nullable
              as TransactionPurpose,
      dateTime: null == dateTime
          ? _self.dateTime
          : dateTime // ignore: cast_nullable_to_non_nullable
              as int,
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
      homeCurrencyAtCapture: freezed == homeCurrencyAtCapture
          ? _self.homeCurrencyAtCapture
          : homeCurrencyAtCapture // ignore: cast_nullable_to_non_nullable
              as String?,
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
      compoundGroupId: freezed == compoundGroupId
          ? _self.compoundGroupId
          : compoundGroupId // ignore: cast_nullable_to_non_nullable
              as String?,
      compoundRole: freezed == compoundRole
          ? _self.compoundRole
          : compoundRole // ignore: cast_nullable_to_non_nullable
              as String?,
      parentTemplateId: freezed == parentTemplateId
          ? _self.parentTemplateId
          : parentTemplateId // ignore: cast_nullable_to_non_nullable
              as String?,
      correctsTransactionId: freezed == correctsTransactionId
          ? _self.correctsTransactionId
          : correctsTransactionId // ignore: cast_nullable_to_non_nullable
              as String?,
      isManuallyHandled: null == isManuallyHandled
          ? _self.isManuallyHandled
          : isManuallyHandled // ignore: cast_nullable_to_non_nullable
              as bool,
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
