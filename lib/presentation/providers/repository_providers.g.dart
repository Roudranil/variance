// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repository_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the [ITransactionRepository] implementation for the lifetime of
/// the app.
///
/// Depends on [transactionDaoProvider].

@ProviderFor(transactionRepository)
final transactionRepositoryProvider = TransactionRepositoryProvider._();

/// Provides the [ITransactionRepository] implementation for the lifetime of
/// the app.
///
/// Depends on [transactionDaoProvider].

final class TransactionRepositoryProvider extends $FunctionalProvider<
        AsyncValue<ITransactionRepository>,
        ITransactionRepository,
        FutureOr<ITransactionRepository>>
    with
        $FutureModifier<ITransactionRepository>,
        $FutureProvider<ITransactionRepository> {
  /// Provides the [ITransactionRepository] implementation for the lifetime of
  /// the app.
  ///
  /// Depends on [transactionDaoProvider].
  TransactionRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'transactionRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$transactionRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<ITransactionRepository> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<ITransactionRepository> create(Ref ref) {
    return transactionRepository(ref);
  }
}

String _$transactionRepositoryHash() =>
    r'a5c7f5f1435577657000a20139823d5a8cb3d217';

/// Provides the [IAccountRepository] implementation for the lifetime of the
/// app.
///
/// Depends on [accountDaoProvider].

@ProviderFor(accountRepository)
final accountRepositoryProvider = AccountRepositoryProvider._();

/// Provides the [IAccountRepository] implementation for the lifetime of the
/// app.
///
/// Depends on [accountDaoProvider].

final class AccountRepositoryProvider extends $FunctionalProvider<
        AsyncValue<IAccountRepository>,
        IAccountRepository,
        FutureOr<IAccountRepository>>
    with
        $FutureModifier<IAccountRepository>,
        $FutureProvider<IAccountRepository> {
  /// Provides the [IAccountRepository] implementation for the lifetime of the
  /// app.
  ///
  /// Depends on [accountDaoProvider].
  AccountRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'accountRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$accountRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<IAccountRepository> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<IAccountRepository> create(Ref ref) {
    return accountRepository(ref);
  }
}

String _$accountRepositoryHash() => r'4adffbfdbe03ce46739623083fcb810249b96c30';

/// Provides the [ICategoryRepository] implementation for the lifetime of the
/// app.
///
/// Depends on [categoryDaoProvider].

@ProviderFor(categoryRepository)
final categoryRepositoryProvider = CategoryRepositoryProvider._();

/// Provides the [ICategoryRepository] implementation for the lifetime of the
/// app.
///
/// Depends on [categoryDaoProvider].

final class CategoryRepositoryProvider extends $FunctionalProvider<
        AsyncValue<ICategoryRepository>,
        ICategoryRepository,
        FutureOr<ICategoryRepository>>
    with
        $FutureModifier<ICategoryRepository>,
        $FutureProvider<ICategoryRepository> {
  /// Provides the [ICategoryRepository] implementation for the lifetime of the
  /// app.
  ///
  /// Depends on [categoryDaoProvider].
  CategoryRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'categoryRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$categoryRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<ICategoryRepository> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<ICategoryRepository> create(Ref ref) {
    return categoryRepository(ref);
  }
}

String _$categoryRepositoryHash() =>
    r'e227a65b3d65e4184f22d8914efd65b38050d719';

/// Provides the [IRecurringTemplateRepository] implementation for the lifetime
/// of the app.
///
/// Depends on [templateDaoProvider].

@ProviderFor(recurringTemplateRepository)
final recurringTemplateRepositoryProvider =
    RecurringTemplateRepositoryProvider._();

/// Provides the [IRecurringTemplateRepository] implementation for the lifetime
/// of the app.
///
/// Depends on [templateDaoProvider].

final class RecurringTemplateRepositoryProvider extends $FunctionalProvider<
        AsyncValue<IRecurringTemplateRepository>,
        IRecurringTemplateRepository,
        FutureOr<IRecurringTemplateRepository>>
    with
        $FutureModifier<IRecurringTemplateRepository>,
        $FutureProvider<IRecurringTemplateRepository> {
  /// Provides the [IRecurringTemplateRepository] implementation for the lifetime
  /// of the app.
  ///
  /// Depends on [templateDaoProvider].
  RecurringTemplateRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'recurringTemplateRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$recurringTemplateRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<IRecurringTemplateRepository> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<IRecurringTemplateRepository> create(Ref ref) {
    return recurringTemplateRepository(ref);
  }
}

String _$recurringTemplateRepositoryHash() =>
    r'1822175bc52f447020143fc5cf869dc9b143b700';

/// Provides the [IScheduledOccurrenceRepository] implementation for the
/// lifetime of the app.
///
/// Depends on [scheduledOccurrenceDaoProvider].

@ProviderFor(scheduledOccurrenceRepository)
final scheduledOccurrenceRepositoryProvider =
    ScheduledOccurrenceRepositoryProvider._();

/// Provides the [IScheduledOccurrenceRepository] implementation for the
/// lifetime of the app.
///
/// Depends on [scheduledOccurrenceDaoProvider].

final class ScheduledOccurrenceRepositoryProvider extends $FunctionalProvider<
        AsyncValue<IScheduledOccurrenceRepository>,
        IScheduledOccurrenceRepository,
        FutureOr<IScheduledOccurrenceRepository>>
    with
        $FutureModifier<IScheduledOccurrenceRepository>,
        $FutureProvider<IScheduledOccurrenceRepository> {
  /// Provides the [IScheduledOccurrenceRepository] implementation for the
  /// lifetime of the app.
  ///
  /// Depends on [scheduledOccurrenceDaoProvider].
  ScheduledOccurrenceRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'scheduledOccurrenceRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$scheduledOccurrenceRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<IScheduledOccurrenceRepository> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<IScheduledOccurrenceRepository> create(Ref ref) {
    return scheduledOccurrenceRepository(ref);
  }
}

String _$scheduledOccurrenceRepositoryHash() =>
    r'215cb231e2aaa851d3ae17b6691833786b634a98';

/// Provides the [IExchangeRateRepository] implementation for the lifetime of
/// the app.
///
/// Depends on [exchangeRateDaoProvider].

@ProviderFor(exchangeRateRepository)
final exchangeRateRepositoryProvider = ExchangeRateRepositoryProvider._();

/// Provides the [IExchangeRateRepository] implementation for the lifetime of
/// the app.
///
/// Depends on [exchangeRateDaoProvider].

final class ExchangeRateRepositoryProvider extends $FunctionalProvider<
        AsyncValue<IExchangeRateRepository>,
        IExchangeRateRepository,
        FutureOr<IExchangeRateRepository>>
    with
        $FutureModifier<IExchangeRateRepository>,
        $FutureProvider<IExchangeRateRepository> {
  /// Provides the [IExchangeRateRepository] implementation for the lifetime of
  /// the app.
  ///
  /// Depends on [exchangeRateDaoProvider].
  ExchangeRateRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'exchangeRateRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$exchangeRateRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<IExchangeRateRepository> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<IExchangeRateRepository> create(Ref ref) {
    return exchangeRateRepository(ref);
  }
}

String _$exchangeRateRepositoryHash() =>
    r'3d51876bd5fd79ba97d934f0078549f0d0085d5f';

/// Provides the [ICurrencyRepository] implementation for the lifetime of the
/// app.
///
/// Depends on [currencyDaoProvider].

@ProviderFor(currencyRepository)
final currencyRepositoryProvider = CurrencyRepositoryProvider._();

/// Provides the [ICurrencyRepository] implementation for the lifetime of the
/// app.
///
/// Depends on [currencyDaoProvider].

final class CurrencyRepositoryProvider extends $FunctionalProvider<
        AsyncValue<ICurrencyRepository>,
        ICurrencyRepository,
        FutureOr<ICurrencyRepository>>
    with
        $FutureModifier<ICurrencyRepository>,
        $FutureProvider<ICurrencyRepository> {
  /// Provides the [ICurrencyRepository] implementation for the lifetime of the
  /// app.
  ///
  /// Depends on [currencyDaoProvider].
  CurrencyRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'currencyRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$currencyRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<ICurrencyRepository> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<ICurrencyRepository> create(Ref ref) {
    return currencyRepository(ref);
  }
}

String _$currencyRepositoryHash() =>
    r'c4d4ff63366c657e3cd9ab65203924185a270972';

/// Provides the [IAppSettingsRepository] implementation for the lifetime of
/// the app.
///
/// Backed by [AppSettingsDao]. Used by the GoRouter redirect guard, the
/// AppSettingsNotifier, and the theme provider.

@ProviderFor(appSettingsRepository)
final appSettingsRepositoryProvider = AppSettingsRepositoryProvider._();

/// Provides the [IAppSettingsRepository] implementation for the lifetime of
/// the app.
///
/// Backed by [AppSettingsDao]. Used by the GoRouter redirect guard, the
/// AppSettingsNotifier, and the theme provider.

final class AppSettingsRepositoryProvider extends $FunctionalProvider<
        AsyncValue<IAppSettingsRepository>,
        IAppSettingsRepository,
        FutureOr<IAppSettingsRepository>>
    with
        $FutureModifier<IAppSettingsRepository>,
        $FutureProvider<IAppSettingsRepository> {
  /// Provides the [IAppSettingsRepository] implementation for the lifetime of
  /// the app.
  ///
  /// Backed by [AppSettingsDao]. Used by the GoRouter redirect guard, the
  /// AppSettingsNotifier, and the theme provider.
  AppSettingsRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'appSettingsRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$appSettingsRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<IAppSettingsRepository> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<IAppSettingsRepository> create(Ref ref) {
    return appSettingsRepository(ref);
  }
}

String _$appSettingsRepositoryHash() =>
    r'98bbfb8d69b31d2b885a3dcdc27e6cb978b94332';

/// Provides the [IInstallmentPlanRepository] implementation for the lifetime
/// of the app.
///
/// Depends on [installmentPlanDaoProvider], [installmentOccurrenceDaoProvider],
/// [templateDaoProvider], and [appDatabaseProvider] — the latter two are
/// needed for the atomic create operation (createAtomic).

@ProviderFor(installmentPlanRepository)
final installmentPlanRepositoryProvider = InstallmentPlanRepositoryProvider._();

/// Provides the [IInstallmentPlanRepository] implementation for the lifetime
/// of the app.
///
/// Depends on [installmentPlanDaoProvider], [installmentOccurrenceDaoProvider],
/// [templateDaoProvider], and [appDatabaseProvider] — the latter two are
/// needed for the atomic create operation (createAtomic).

final class InstallmentPlanRepositoryProvider extends $FunctionalProvider<
        AsyncValue<IInstallmentPlanRepository>,
        IInstallmentPlanRepository,
        FutureOr<IInstallmentPlanRepository>>
    with
        $FutureModifier<IInstallmentPlanRepository>,
        $FutureProvider<IInstallmentPlanRepository> {
  /// Provides the [IInstallmentPlanRepository] implementation for the lifetime
  /// of the app.
  ///
  /// Depends on [installmentPlanDaoProvider], [installmentOccurrenceDaoProvider],
  /// [templateDaoProvider], and [appDatabaseProvider] — the latter two are
  /// needed for the atomic create operation (createAtomic).
  InstallmentPlanRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'installmentPlanRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$installmentPlanRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<IInstallmentPlanRepository> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<IInstallmentPlanRepository> create(Ref ref) {
    return installmentPlanRepository(ref);
  }
}

String _$installmentPlanRepositoryHash() =>
    r'a2907fa32a10981b07bbb19ef2dad04e508222ae';

/// Provides the [IInstallmentOccurrenceRepository] implementation for the
/// lifetime of the app.
///
/// Depends on [installmentOccurrenceDaoProvider].

@ProviderFor(installmentOccurrenceRepository)
final installmentOccurrenceRepositoryProvider =
    InstallmentOccurrenceRepositoryProvider._();

/// Provides the [IInstallmentOccurrenceRepository] implementation for the
/// lifetime of the app.
///
/// Depends on [installmentOccurrenceDaoProvider].

final class InstallmentOccurrenceRepositoryProvider extends $FunctionalProvider<
        AsyncValue<IInstallmentOccurrenceRepository>,
        IInstallmentOccurrenceRepository,
        FutureOr<IInstallmentOccurrenceRepository>>
    with
        $FutureModifier<IInstallmentOccurrenceRepository>,
        $FutureProvider<IInstallmentOccurrenceRepository> {
  /// Provides the [IInstallmentOccurrenceRepository] implementation for the
  /// lifetime of the app.
  ///
  /// Depends on [installmentOccurrenceDaoProvider].
  InstallmentOccurrenceRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'installmentOccurrenceRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$installmentOccurrenceRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<IInstallmentOccurrenceRepository> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<IInstallmentOccurrenceRepository> create(Ref ref) {
    return installmentOccurrenceRepository(ref);
  }
}

String _$installmentOccurrenceRepositoryHash() =>
    r'd0f1fb408c608de611667e70ad96fd156238f7b8';

/// Loads all active [Currency] entities from the local database once on app
/// startup and keeps the result alive for the entire session.
///
/// The currency list is populated from the bundled `assets/data/currencies.json`
/// asset during the Drift `onCreate` migration (T-22). No runtime network
/// fetch is ever performed (SDS §2.16.1).
///
/// Consumers should prefer this provider over calling the repository directly
/// to avoid repeated DAO round-trips for a static list.

@ProviderFor(currencies)
final currenciesProvider = CurrenciesProvider._();

/// Loads all active [Currency] entities from the local database once on app
/// startup and keeps the result alive for the entire session.
///
/// The currency list is populated from the bundled `assets/data/currencies.json`
/// asset during the Drift `onCreate` migration (T-22). No runtime network
/// fetch is ever performed (SDS §2.16.1).
///
/// Consumers should prefer this provider over calling the repository directly
/// to avoid repeated DAO round-trips for a static list.

final class CurrenciesProvider extends $FunctionalProvider<
        AsyncValue<List<Currency>>, List<Currency>, FutureOr<List<Currency>>>
    with $FutureModifier<List<Currency>>, $FutureProvider<List<Currency>> {
  /// Loads all active [Currency] entities from the local database once on app
  /// startup and keeps the result alive for the entire session.
  ///
  /// The currency list is populated from the bundled `assets/data/currencies.json`
  /// asset during the Drift `onCreate` migration (T-22). No runtime network
  /// fetch is ever performed (SDS §2.16.1).
  ///
  /// Consumers should prefer this provider over calling the repository directly
  /// to avoid repeated DAO round-trips for a static list.
  CurrenciesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'currenciesProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$currenciesHash();

  @$internal
  @override
  $FutureProviderElement<List<Currency>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Currency>> create(Ref ref) {
    return currencies(ref);
  }
}

String _$currenciesHash() => r'e5741b5bfddfa51a425cddfa74aa4f0fb3fbf164';
