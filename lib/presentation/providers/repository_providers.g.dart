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
/// This provider reads from the AppDatabase directly (no dedicated DAO).
/// Used by the GoRouter redirect guard to check onboarding completion.

@ProviderFor(appSettingsRepository)
final appSettingsRepositoryProvider = AppSettingsRepositoryProvider._();

/// Provides the [IAppSettingsRepository] implementation for the lifetime of
/// the app.
///
/// This provider reads from the AppDatabase directly (no dedicated DAO).
/// Used by the GoRouter redirect guard to check onboarding completion.

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
  /// This provider reads from the AppDatabase directly (no dedicated DAO).
  /// Used by the GoRouter redirect guard to check onboarding completion.
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
    r'4124c57fdc28b88d9ac5d6f29c7cbe23cde5e8ab';
