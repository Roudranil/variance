// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'use_case_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides a [CreateTransactionUseCase] bound to the transaction repository
/// and [LedgerEngine] (T-49, T-50).

@ProviderFor(createTransactionUseCase)
final createTransactionUseCaseProvider = CreateTransactionUseCaseProvider._();

/// Provides a [CreateTransactionUseCase] bound to the transaction repository
/// and [LedgerEngine] (T-49, T-50).

final class CreateTransactionUseCaseProvider extends $FunctionalProvider<
        AsyncValue<CreateTransactionUseCase>,
        CreateTransactionUseCase,
        FutureOr<CreateTransactionUseCase>>
    with
        $FutureModifier<CreateTransactionUseCase>,
        $FutureProvider<CreateTransactionUseCase> {
  /// Provides a [CreateTransactionUseCase] bound to the transaction repository
  /// and [LedgerEngine] (T-49, T-50).
  CreateTransactionUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'createTransactionUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$createTransactionUseCaseHash();

  @$internal
  @override
  $FutureProviderElement<CreateTransactionUseCase> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<CreateTransactionUseCase> create(Ref ref) {
    return createTransactionUseCase(ref);
  }
}

String _$createTransactionUseCaseHash() =>
    r'87354daa9fa523281c7a76697c18f4a5fb3935b3';

/// Provides a [WatchMonthlyTransactionsUseCase] bound to the transaction
/// repository.

@ProviderFor(watchMonthlyTransactionsUseCase)
final watchMonthlyTransactionsUseCaseProvider =
    WatchMonthlyTransactionsUseCaseProvider._();

/// Provides a [WatchMonthlyTransactionsUseCase] bound to the transaction
/// repository.

final class WatchMonthlyTransactionsUseCaseProvider extends $FunctionalProvider<
        AsyncValue<WatchMonthlyTransactionsUseCase>,
        WatchMonthlyTransactionsUseCase,
        FutureOr<WatchMonthlyTransactionsUseCase>>
    with
        $FutureModifier<WatchMonthlyTransactionsUseCase>,
        $FutureProvider<WatchMonthlyTransactionsUseCase> {
  /// Provides a [WatchMonthlyTransactionsUseCase] bound to the transaction
  /// repository.
  WatchMonthlyTransactionsUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'watchMonthlyTransactionsUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$watchMonthlyTransactionsUseCaseHash();

  @$internal
  @override
  $FutureProviderElement<WatchMonthlyTransactionsUseCase> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<WatchMonthlyTransactionsUseCase> create(Ref ref) {
    return watchMonthlyTransactionsUseCase(ref);
  }
}

String _$watchMonthlyTransactionsUseCaseHash() =>
    r'27384f99ede86cf00e18f28ce20c952072c9e30f';

/// Provides a [SearchTransactionsUseCase] bound to the transaction repository.

@ProviderFor(searchTransactionsUseCase)
final searchTransactionsUseCaseProvider = SearchTransactionsUseCaseProvider._();

/// Provides a [SearchTransactionsUseCase] bound to the transaction repository.

final class SearchTransactionsUseCaseProvider extends $FunctionalProvider<
        AsyncValue<SearchTransactionsUseCase>,
        SearchTransactionsUseCase,
        FutureOr<SearchTransactionsUseCase>>
    with
        $FutureModifier<SearchTransactionsUseCase>,
        $FutureProvider<SearchTransactionsUseCase> {
  /// Provides a [SearchTransactionsUseCase] bound to the transaction repository.
  SearchTransactionsUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'searchTransactionsUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$searchTransactionsUseCaseHash();

  @$internal
  @override
  $FutureProviderElement<SearchTransactionsUseCase> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<SearchTransactionsUseCase> create(Ref ref) {
    return searchTransactionsUseCase(ref);
  }
}

String _$searchTransactionsUseCaseHash() =>
    r'aa237e5c651646fbc36e56aba7ac5b72f38c98af';

/// Provides a [WatchAccountsUseCase] bound to the account repository.

@ProviderFor(watchAccountsUseCase)
final watchAccountsUseCaseProvider = WatchAccountsUseCaseProvider._();

/// Provides a [WatchAccountsUseCase] bound to the account repository.

final class WatchAccountsUseCaseProvider extends $FunctionalProvider<
        AsyncValue<WatchAccountsUseCase>,
        WatchAccountsUseCase,
        FutureOr<WatchAccountsUseCase>>
    with
        $FutureModifier<WatchAccountsUseCase>,
        $FutureProvider<WatchAccountsUseCase> {
  /// Provides a [WatchAccountsUseCase] bound to the account repository.
  WatchAccountsUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'watchAccountsUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$watchAccountsUseCaseHash();

  @$internal
  @override
  $FutureProviderElement<WatchAccountsUseCase> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<WatchAccountsUseCase> create(Ref ref) {
    return watchAccountsUseCase(ref);
  }
}

String _$watchAccountsUseCaseHash() =>
    r'329f26421282b1da8a0bae22c41a998ead1aea08';

/// Provides a [LedgerEngine] wired to the Drift-backed ledger repository.
///
/// The ledger repository requires both [AccountDao] and [TransactionDao]
/// to handle EQ account creation and entry inserts.

@ProviderFor(ledgerEngine)
final ledgerEngineProvider = LedgerEngineProvider._();

/// Provides a [LedgerEngine] wired to the Drift-backed ledger repository.
///
/// The ledger repository requires both [AccountDao] and [TransactionDao]
/// to handle EQ account creation and entry inserts.

final class LedgerEngineProvider extends $FunctionalProvider<
        AsyncValue<LedgerEngine>, LedgerEngine, FutureOr<LedgerEngine>>
    with $FutureModifier<LedgerEngine>, $FutureProvider<LedgerEngine> {
  /// Provides a [LedgerEngine] wired to the Drift-backed ledger repository.
  ///
  /// The ledger repository requires both [AccountDao] and [TransactionDao]
  /// to handle EQ account creation and entry inserts.
  LedgerEngineProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'ledgerEngineProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$ledgerEngineHash();

  @$internal
  @override
  $FutureProviderElement<LedgerEngine> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<LedgerEngine> create(Ref ref) {
    return ledgerEngine(ref);
  }
}

String _$ledgerEngineHash() => r'267ca0acb6f86693c72e2b10f854dc44b9fe9787';

/// Provides a [CreateAccountUseCase] bound to the account repository and
/// [LedgerEngine].

@ProviderFor(createAccountUseCase)
final createAccountUseCaseProvider = CreateAccountUseCaseProvider._();

/// Provides a [CreateAccountUseCase] bound to the account repository and
/// [LedgerEngine].

final class CreateAccountUseCaseProvider extends $FunctionalProvider<
        AsyncValue<CreateAccountUseCase>,
        CreateAccountUseCase,
        FutureOr<CreateAccountUseCase>>
    with
        $FutureModifier<CreateAccountUseCase>,
        $FutureProvider<CreateAccountUseCase> {
  /// Provides a [CreateAccountUseCase] bound to the account repository and
  /// [LedgerEngine].
  CreateAccountUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'createAccountUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$createAccountUseCaseHash();

  @$internal
  @override
  $FutureProviderElement<CreateAccountUseCase> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<CreateAccountUseCase> create(Ref ref) {
    return createAccountUseCase(ref);
  }
}

String _$createAccountUseCaseHash() =>
    r'88cc63ce358204e7d2a503e424349d3d5de2ec68';

/// Provides an [UpdateAccountUseCase] bound to the account repository.

@ProviderFor(updateAccountUseCase)
final updateAccountUseCaseProvider = UpdateAccountUseCaseProvider._();

/// Provides an [UpdateAccountUseCase] bound to the account repository.

final class UpdateAccountUseCaseProvider extends $FunctionalProvider<
        AsyncValue<UpdateAccountUseCase>,
        UpdateAccountUseCase,
        FutureOr<UpdateAccountUseCase>>
    with
        $FutureModifier<UpdateAccountUseCase>,
        $FutureProvider<UpdateAccountUseCase> {
  /// Provides an [UpdateAccountUseCase] bound to the account repository.
  UpdateAccountUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'updateAccountUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$updateAccountUseCaseHash();

  @$internal
  @override
  $FutureProviderElement<UpdateAccountUseCase> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<UpdateAccountUseCase> create(Ref ref) {
    return updateAccountUseCase(ref);
  }
}

String _$updateAccountUseCaseHash() =>
    r'ed54040bb1c1393b76cf12b64c4f1dcbea91a798';

/// Provides a [DeleteAccountUseCase] bound to the account repository.

@ProviderFor(deleteAccountUseCase)
final deleteAccountUseCaseProvider = DeleteAccountUseCaseProvider._();

/// Provides a [DeleteAccountUseCase] bound to the account repository.

final class DeleteAccountUseCaseProvider extends $FunctionalProvider<
        AsyncValue<DeleteAccountUseCase>,
        DeleteAccountUseCase,
        FutureOr<DeleteAccountUseCase>>
    with
        $FutureModifier<DeleteAccountUseCase>,
        $FutureProvider<DeleteAccountUseCase> {
  /// Provides a [DeleteAccountUseCase] bound to the account repository.
  DeleteAccountUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'deleteAccountUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$deleteAccountUseCaseHash();

  @$internal
  @override
  $FutureProviderElement<DeleteAccountUseCase> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<DeleteAccountUseCase> create(Ref ref) {
    return deleteAccountUseCase(ref);
  }
}

String _$deleteAccountUseCaseHash() =>
    r'0b55f0c490b1875cc2a650788883ec7e900fd33a';

/// Provides a [GetAccountBalanceUseCase] bound to the account repository.

@ProviderFor(getAccountBalanceUseCase)
final getAccountBalanceUseCaseProvider = GetAccountBalanceUseCaseProvider._();

/// Provides a [GetAccountBalanceUseCase] bound to the account repository.

final class GetAccountBalanceUseCaseProvider extends $FunctionalProvider<
        AsyncValue<GetAccountBalanceUseCase>,
        GetAccountBalanceUseCase,
        FutureOr<GetAccountBalanceUseCase>>
    with
        $FutureModifier<GetAccountBalanceUseCase>,
        $FutureProvider<GetAccountBalanceUseCase> {
  /// Provides a [GetAccountBalanceUseCase] bound to the account repository.
  GetAccountBalanceUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'getAccountBalanceUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$getAccountBalanceUseCaseHash();

  @$internal
  @override
  $FutureProviderElement<GetAccountBalanceUseCase> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<GetAccountBalanceUseCase> create(Ref ref) {
    return getAccountBalanceUseCase(ref);
  }
}

String _$getAccountBalanceUseCaseHash() =>
    r'7a8642a2991c9d27bd6be5a3fd709d5583e06ea0';

/// Provides a [CreateCategoryUseCase] bound to the category repository.

@ProviderFor(createCategoryUseCase)
final createCategoryUseCaseProvider = CreateCategoryUseCaseProvider._();

/// Provides a [CreateCategoryUseCase] bound to the category repository.

final class CreateCategoryUseCaseProvider extends $FunctionalProvider<
        AsyncValue<CreateCategoryUseCase>,
        CreateCategoryUseCase,
        FutureOr<CreateCategoryUseCase>>
    with
        $FutureModifier<CreateCategoryUseCase>,
        $FutureProvider<CreateCategoryUseCase> {
  /// Provides a [CreateCategoryUseCase] bound to the category repository.
  CreateCategoryUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'createCategoryUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$createCategoryUseCaseHash();

  @$internal
  @override
  $FutureProviderElement<CreateCategoryUseCase> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<CreateCategoryUseCase> create(Ref ref) {
    return createCategoryUseCase(ref);
  }
}

String _$createCategoryUseCaseHash() =>
    r'0806089ef884d00ec077462f07081dfe4df96775';

/// Provides an [UpdateCategoryUseCase] bound to the category repository.

@ProviderFor(updateCategoryUseCase)
final updateCategoryUseCaseProvider = UpdateCategoryUseCaseProvider._();

/// Provides an [UpdateCategoryUseCase] bound to the category repository.

final class UpdateCategoryUseCaseProvider extends $FunctionalProvider<
        AsyncValue<UpdateCategoryUseCase>,
        UpdateCategoryUseCase,
        FutureOr<UpdateCategoryUseCase>>
    with
        $FutureModifier<UpdateCategoryUseCase>,
        $FutureProvider<UpdateCategoryUseCase> {
  /// Provides an [UpdateCategoryUseCase] bound to the category repository.
  UpdateCategoryUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'updateCategoryUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$updateCategoryUseCaseHash();

  @$internal
  @override
  $FutureProviderElement<UpdateCategoryUseCase> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<UpdateCategoryUseCase> create(Ref ref) {
    return updateCategoryUseCase(ref);
  }
}

String _$updateCategoryUseCaseHash() =>
    r'7211f65d483b2ade6bc1f116c3b2f1bb9f60ffa0';

/// Provides a [DeleteCategoryUseCase] bound to the category repository.

@ProviderFor(deleteCategoryUseCase)
final deleteCategoryUseCaseProvider = DeleteCategoryUseCaseProvider._();

/// Provides a [DeleteCategoryUseCase] bound to the category repository.

final class DeleteCategoryUseCaseProvider extends $FunctionalProvider<
        AsyncValue<DeleteCategoryUseCase>,
        DeleteCategoryUseCase,
        FutureOr<DeleteCategoryUseCase>>
    with
        $FutureModifier<DeleteCategoryUseCase>,
        $FutureProvider<DeleteCategoryUseCase> {
  /// Provides a [DeleteCategoryUseCase] bound to the category repository.
  DeleteCategoryUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'deleteCategoryUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$deleteCategoryUseCaseHash();

  @$internal
  @override
  $FutureProviderElement<DeleteCategoryUseCase> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<DeleteCategoryUseCase> create(Ref ref) {
    return deleteCategoryUseCase(ref);
  }
}

String _$deleteCategoryUseCaseHash() =>
    r'0c81dc0b385b23806019075fd973d9116b2f4369';

/// Provides a [CreateInstallmentPlanUseCase] bound to the installment plan
/// repository and [PeriodCalculator].

@ProviderFor(createInstallmentPlanUseCase)
final createInstallmentPlanUseCaseProvider =
    CreateInstallmentPlanUseCaseProvider._();

/// Provides a [CreateInstallmentPlanUseCase] bound to the installment plan
/// repository and [PeriodCalculator].

final class CreateInstallmentPlanUseCaseProvider extends $FunctionalProvider<
        AsyncValue<CreateInstallmentPlanUseCase>,
        CreateInstallmentPlanUseCase,
        FutureOr<CreateInstallmentPlanUseCase>>
    with
        $FutureModifier<CreateInstallmentPlanUseCase>,
        $FutureProvider<CreateInstallmentPlanUseCase> {
  /// Provides a [CreateInstallmentPlanUseCase] bound to the installment plan
  /// repository and [PeriodCalculator].
  CreateInstallmentPlanUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'createInstallmentPlanUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$createInstallmentPlanUseCaseHash();

  @$internal
  @override
  $FutureProviderElement<CreateInstallmentPlanUseCase> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<CreateInstallmentPlanUseCase> create(Ref ref) {
    return createInstallmentPlanUseCase(ref);
  }
}

String _$createInstallmentPlanUseCaseHash() =>
    r'0111b06c782503936e02c4e469f6b9eafdbdcbee';

/// Provides a [CreateRecurringTemplateUseCase] bound to the template
/// repository.

@ProviderFor(createRecurringTemplateUseCase)
final createRecurringTemplateUseCaseProvider =
    CreateRecurringTemplateUseCaseProvider._();

/// Provides a [CreateRecurringTemplateUseCase] bound to the template
/// repository.

final class CreateRecurringTemplateUseCaseProvider extends $FunctionalProvider<
        AsyncValue<CreateRecurringTemplateUseCase>,
        CreateRecurringTemplateUseCase,
        FutureOr<CreateRecurringTemplateUseCase>>
    with
        $FutureModifier<CreateRecurringTemplateUseCase>,
        $FutureProvider<CreateRecurringTemplateUseCase> {
  /// Provides a [CreateRecurringTemplateUseCase] bound to the template
  /// repository.
  CreateRecurringTemplateUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'createRecurringTemplateUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$createRecurringTemplateUseCaseHash();

  @$internal
  @override
  $FutureProviderElement<CreateRecurringTemplateUseCase> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<CreateRecurringTemplateUseCase> create(Ref ref) {
    return createRecurringTemplateUseCase(ref);
  }
}

String _$createRecurringTemplateUseCaseHash() =>
    r'd7332c9ff6f8d677a7e46a65f46f165a7b281671';

/// Provides an [UpdateRecurringTemplateUseCase] bound to the template
/// repository.

@ProviderFor(updateRecurringTemplateUseCase)
final updateRecurringTemplateUseCaseProvider =
    UpdateRecurringTemplateUseCaseProvider._();

/// Provides an [UpdateRecurringTemplateUseCase] bound to the template
/// repository.

final class UpdateRecurringTemplateUseCaseProvider extends $FunctionalProvider<
        AsyncValue<UpdateRecurringTemplateUseCase>,
        UpdateRecurringTemplateUseCase,
        FutureOr<UpdateRecurringTemplateUseCase>>
    with
        $FutureModifier<UpdateRecurringTemplateUseCase>,
        $FutureProvider<UpdateRecurringTemplateUseCase> {
  /// Provides an [UpdateRecurringTemplateUseCase] bound to the template
  /// repository.
  UpdateRecurringTemplateUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'updateRecurringTemplateUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$updateRecurringTemplateUseCaseHash();

  @$internal
  @override
  $FutureProviderElement<UpdateRecurringTemplateUseCase> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<UpdateRecurringTemplateUseCase> create(Ref ref) {
    return updateRecurringTemplateUseCase(ref);
  }
}

String _$updateRecurringTemplateUseCaseHash() =>
    r'744edf7e144992b9149d4c2df54099356d01f8f7';

/// Provides a [SkipOccurrenceUseCase] bound to the scheduled occurrence
/// repository.

@ProviderFor(skipOccurrenceUseCase)
final skipOccurrenceUseCaseProvider = SkipOccurrenceUseCaseProvider._();

/// Provides a [SkipOccurrenceUseCase] bound to the scheduled occurrence
/// repository.

final class SkipOccurrenceUseCaseProvider extends $FunctionalProvider<
        AsyncValue<SkipOccurrenceUseCase>,
        SkipOccurrenceUseCase,
        FutureOr<SkipOccurrenceUseCase>>
    with
        $FutureModifier<SkipOccurrenceUseCase>,
        $FutureProvider<SkipOccurrenceUseCase> {
  /// Provides a [SkipOccurrenceUseCase] bound to the scheduled occurrence
  /// repository.
  SkipOccurrenceUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'skipOccurrenceUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$skipOccurrenceUseCaseHash();

  @$internal
  @override
  $FutureProviderElement<SkipOccurrenceUseCase> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<SkipOccurrenceUseCase> create(Ref ref) {
    return skipOccurrenceUseCase(ref);
  }
}

String _$skipOccurrenceUseCaseHash() =>
    r'2ad0d6449191eaa9dc2fe6487d283002067c1953';

/// Provides a [PauseRecurringTemplateUseCase] bound to both the template
/// and scheduled occurrence repositories.

@ProviderFor(pauseRecurringTemplateUseCase)
final pauseRecurringTemplateUseCaseProvider =
    PauseRecurringTemplateUseCaseProvider._();

/// Provides a [PauseRecurringTemplateUseCase] bound to both the template
/// and scheduled occurrence repositories.

final class PauseRecurringTemplateUseCaseProvider extends $FunctionalProvider<
        AsyncValue<PauseRecurringTemplateUseCase>,
        PauseRecurringTemplateUseCase,
        FutureOr<PauseRecurringTemplateUseCase>>
    with
        $FutureModifier<PauseRecurringTemplateUseCase>,
        $FutureProvider<PauseRecurringTemplateUseCase> {
  /// Provides a [PauseRecurringTemplateUseCase] bound to both the template
  /// and scheduled occurrence repositories.
  PauseRecurringTemplateUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'pauseRecurringTemplateUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$pauseRecurringTemplateUseCaseHash();

  @$internal
  @override
  $FutureProviderElement<PauseRecurringTemplateUseCase> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<PauseRecurringTemplateUseCase> create(Ref ref) {
    return pauseRecurringTemplateUseCase(ref);
  }
}

String _$pauseRecurringTemplateUseCaseHash() =>
    r'781aa312a7c23220298566635ab1dba63e3e949c';

/// Provides a [GetExchangeRateUseCase] bound to the exchange rate repository.

@ProviderFor(getExchangeRateUseCase)
final getExchangeRateUseCaseProvider = GetExchangeRateUseCaseProvider._();

/// Provides a [GetExchangeRateUseCase] bound to the exchange rate repository.

final class GetExchangeRateUseCaseProvider extends $FunctionalProvider<
        AsyncValue<GetExchangeRateUseCase>,
        GetExchangeRateUseCase,
        FutureOr<GetExchangeRateUseCase>>
    with
        $FutureModifier<GetExchangeRateUseCase>,
        $FutureProvider<GetExchangeRateUseCase> {
  /// Provides a [GetExchangeRateUseCase] bound to the exchange rate repository.
  GetExchangeRateUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'getExchangeRateUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$getExchangeRateUseCaseHash();

  @$internal
  @override
  $FutureProviderElement<GetExchangeRateUseCase> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<GetExchangeRateUseCase> create(Ref ref) {
    return getExchangeRateUseCase(ref);
  }
}

String _$getExchangeRateUseCaseHash() =>
    r'a7a98e609a3d3d6bc464edffe5ca7e6cf43ff22f';

/// Provides a [RefreshExchangeRatesUseCase] wired with account repository,
/// exchange rate upsert sink, HTTP service, and home currency from settings.

@ProviderFor(refreshExchangeRatesUseCase)
final refreshExchangeRatesUseCaseProvider =
    RefreshExchangeRatesUseCaseProvider._();

/// Provides a [RefreshExchangeRatesUseCase] wired with account repository,
/// exchange rate upsert sink, HTTP service, and home currency from settings.

final class RefreshExchangeRatesUseCaseProvider extends $FunctionalProvider<
        AsyncValue<RefreshExchangeRatesUseCase>,
        RefreshExchangeRatesUseCase,
        FutureOr<RefreshExchangeRatesUseCase>>
    with
        $FutureModifier<RefreshExchangeRatesUseCase>,
        $FutureProvider<RefreshExchangeRatesUseCase> {
  /// Provides a [RefreshExchangeRatesUseCase] wired with account repository,
  /// exchange rate upsert sink, HTTP service, and home currency from settings.
  RefreshExchangeRatesUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'refreshExchangeRatesUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$refreshExchangeRatesUseCaseHash();

  @$internal
  @override
  $FutureProviderElement<RefreshExchangeRatesUseCase> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<RefreshExchangeRatesUseCase> create(Ref ref) {
    return refreshExchangeRatesUseCase(ref);
  }
}

String _$refreshExchangeRatesUseCaseHash() =>
    r'9b017f66b3fc18fd5ed955f9823ee7058adf6f87';
