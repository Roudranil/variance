// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The production [AppDatabase] singleton.
///
/// Opens the encrypted SQLite database on first access and keeps it alive for
/// the lifetime of the app (keepAlive: true).
///
/// Override in tests with [AppDatabase.forTesting]:
/// ```dart
/// ProviderScope(
///   overrides: [appDatabaseProvider.overrideWith((_) => AppDatabase.forTesting())],
///   ...
/// )
/// ```

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

/// The production [AppDatabase] singleton.
///
/// Opens the encrypted SQLite database on first access and keeps it alive for
/// the lifetime of the app (keepAlive: true).
///
/// Override in tests with [AppDatabase.forTesting]:
/// ```dart
/// ProviderScope(
///   overrides: [appDatabaseProvider.overrideWith((_) => AppDatabase.forTesting())],
///   ...
/// )
/// ```

final class AppDatabaseProvider extends $FunctionalProvider<
        AsyncValue<AppDatabase>, AppDatabase, FutureOr<AppDatabase>>
    with $FutureModifier<AppDatabase>, $FutureProvider<AppDatabase> {
  /// The production [AppDatabase] singleton.
  ///
  /// Opens the encrypted SQLite database on first access and keeps it alive for
  /// the lifetime of the app (keepAlive: true).
  ///
  /// Override in tests with [AppDatabase.forTesting]:
  /// ```dart
  /// ProviderScope(
  ///   overrides: [appDatabaseProvider.overrideWith((_) => AppDatabase.forTesting())],
  ///   ...
  /// )
  /// ```
  AppDatabaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'appDatabaseProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $FutureProviderElement<AppDatabase> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<AppDatabase> create(Ref ref) {
    return appDatabase(ref);
  }
}

String _$appDatabaseHash() => r'f719034f463fa358c5fe3955fb6f290d0d58a348';

/// Provides the [TransactionDao] for the open [AppDatabase].
///
/// Depends on [appDatabaseProvider] and is kept alive for the app's lifetime.

@ProviderFor(transactionDao)
final transactionDaoProvider = TransactionDaoProvider._();

/// Provides the [TransactionDao] for the open [AppDatabase].
///
/// Depends on [appDatabaseProvider] and is kept alive for the app's lifetime.

final class TransactionDaoProvider extends $FunctionalProvider<
        AsyncValue<TransactionDao>, TransactionDao, FutureOr<TransactionDao>>
    with $FutureModifier<TransactionDao>, $FutureProvider<TransactionDao> {
  /// Provides the [TransactionDao] for the open [AppDatabase].
  ///
  /// Depends on [appDatabaseProvider] and is kept alive for the app's lifetime.
  TransactionDaoProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'transactionDaoProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$transactionDaoHash();

  @$internal
  @override
  $FutureProviderElement<TransactionDao> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<TransactionDao> create(Ref ref) {
    return transactionDao(ref);
  }
}

String _$transactionDaoHash() => r'4e17b6104d494350c6e52fa8a4a94c20b534933d';

/// Provides the [AccountDao] for the open [AppDatabase].
///
/// Depends on [appDatabaseProvider] and is kept alive for the app's lifetime.

@ProviderFor(accountDao)
final accountDaoProvider = AccountDaoProvider._();

/// Provides the [AccountDao] for the open [AppDatabase].
///
/// Depends on [appDatabaseProvider] and is kept alive for the app's lifetime.

final class AccountDaoProvider extends $FunctionalProvider<
        AsyncValue<AccountDao>, AccountDao, FutureOr<AccountDao>>
    with $FutureModifier<AccountDao>, $FutureProvider<AccountDao> {
  /// Provides the [AccountDao] for the open [AppDatabase].
  ///
  /// Depends on [appDatabaseProvider] and is kept alive for the app's lifetime.
  AccountDaoProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'accountDaoProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$accountDaoHash();

  @$internal
  @override
  $FutureProviderElement<AccountDao> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<AccountDao> create(Ref ref) {
    return accountDao(ref);
  }
}

String _$accountDaoHash() => r'4e18863ccafa889b408445b7fa25dda526e06e03';

/// Provides the [CategoryDao] for the open [AppDatabase].
///
/// Depends on [appDatabaseProvider] and is kept alive for the app's lifetime.

@ProviderFor(categoryDao)
final categoryDaoProvider = CategoryDaoProvider._();

/// Provides the [CategoryDao] for the open [AppDatabase].
///
/// Depends on [appDatabaseProvider] and is kept alive for the app's lifetime.

final class CategoryDaoProvider extends $FunctionalProvider<
        AsyncValue<CategoryDao>, CategoryDao, FutureOr<CategoryDao>>
    with $FutureModifier<CategoryDao>, $FutureProvider<CategoryDao> {
  /// Provides the [CategoryDao] for the open [AppDatabase].
  ///
  /// Depends on [appDatabaseProvider] and is kept alive for the app's lifetime.
  CategoryDaoProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'categoryDaoProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$categoryDaoHash();

  @$internal
  @override
  $FutureProviderElement<CategoryDao> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<CategoryDao> create(Ref ref) {
    return categoryDao(ref);
  }
}

String _$categoryDaoHash() => r'18c9b62dadb4a9af5ad846b788511aa16767e17a';

/// Provides the [TemplateDao] for the open [AppDatabase].
///
/// Depends on [appDatabaseProvider] and is kept alive for the app's lifetime.

@ProviderFor(templateDao)
final templateDaoProvider = TemplateDaoProvider._();

/// Provides the [TemplateDao] for the open [AppDatabase].
///
/// Depends on [appDatabaseProvider] and is kept alive for the app's lifetime.

final class TemplateDaoProvider extends $FunctionalProvider<
        AsyncValue<TemplateDao>, TemplateDao, FutureOr<TemplateDao>>
    with $FutureModifier<TemplateDao>, $FutureProvider<TemplateDao> {
  /// Provides the [TemplateDao] for the open [AppDatabase].
  ///
  /// Depends on [appDatabaseProvider] and is kept alive for the app's lifetime.
  TemplateDaoProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'templateDaoProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$templateDaoHash();

  @$internal
  @override
  $FutureProviderElement<TemplateDao> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<TemplateDao> create(Ref ref) {
    return templateDao(ref);
  }
}

String _$templateDaoHash() => r'9cea3f84afa6326fc2aa047871bbbbbd56dc9c34';

/// Provides the [ExchangeRateDao] for the open [AppDatabase].
///
/// Depends on [appDatabaseProvider] and is kept alive for the app's lifetime.

@ProviderFor(exchangeRateDao)
final exchangeRateDaoProvider = ExchangeRateDaoProvider._();

/// Provides the [ExchangeRateDao] for the open [AppDatabase].
///
/// Depends on [appDatabaseProvider] and is kept alive for the app's lifetime.

final class ExchangeRateDaoProvider extends $FunctionalProvider<
        AsyncValue<ExchangeRateDao>, ExchangeRateDao, FutureOr<ExchangeRateDao>>
    with $FutureModifier<ExchangeRateDao>, $FutureProvider<ExchangeRateDao> {
  /// Provides the [ExchangeRateDao] for the open [AppDatabase].
  ///
  /// Depends on [appDatabaseProvider] and is kept alive for the app's lifetime.
  ExchangeRateDaoProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'exchangeRateDaoProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$exchangeRateDaoHash();

  @$internal
  @override
  $FutureProviderElement<ExchangeRateDao> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<ExchangeRateDao> create(Ref ref) {
    return exchangeRateDao(ref);
  }
}

String _$exchangeRateDaoHash() => r'c1412b136634f0f4040de1da41884198999b5879';

/// Provides the [CurrencyDao] for the open [AppDatabase].
///
/// Depends on [appDatabaseProvider] and is kept alive for the app's lifetime.

@ProviderFor(currencyDao)
final currencyDaoProvider = CurrencyDaoProvider._();

/// Provides the [CurrencyDao] for the open [AppDatabase].
///
/// Depends on [appDatabaseProvider] and is kept alive for the app's lifetime.

final class CurrencyDaoProvider extends $FunctionalProvider<
        AsyncValue<CurrencyDao>, CurrencyDao, FutureOr<CurrencyDao>>
    with $FutureModifier<CurrencyDao>, $FutureProvider<CurrencyDao> {
  /// Provides the [CurrencyDao] for the open [AppDatabase].
  ///
  /// Depends on [appDatabaseProvider] and is kept alive for the app's lifetime.
  CurrencyDaoProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'currencyDaoProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$currencyDaoHash();

  @$internal
  @override
  $FutureProviderElement<CurrencyDao> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<CurrencyDao> create(Ref ref) {
    return currencyDao(ref);
  }
}

String _$currencyDaoHash() => r'b2a85ce77065410021d8e6a9b884a04f19814ee7';

/// Provides the [AppSettingsDao] for the open [AppDatabase].
///
/// Depends on [appDatabaseProvider] and is kept alive for the app's lifetime.

@ProviderFor(appSettingsDao)
final appSettingsDaoProvider = AppSettingsDaoProvider._();

/// Provides the [AppSettingsDao] for the open [AppDatabase].
///
/// Depends on [appDatabaseProvider] and is kept alive for the app's lifetime.

final class AppSettingsDaoProvider extends $FunctionalProvider<
        AsyncValue<AppSettingsDao>, AppSettingsDao, FutureOr<AppSettingsDao>>
    with $FutureModifier<AppSettingsDao>, $FutureProvider<AppSettingsDao> {
  /// Provides the [AppSettingsDao] for the open [AppDatabase].
  ///
  /// Depends on [appDatabaseProvider] and is kept alive for the app's lifetime.
  AppSettingsDaoProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'appSettingsDaoProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$appSettingsDaoHash();

  @$internal
  @override
  $FutureProviderElement<AppSettingsDao> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<AppSettingsDao> create(Ref ref) {
    return appSettingsDao(ref);
  }
}

String _$appSettingsDaoHash() => r'73d5063a45bad708bcf496b636715c8d6d4d3f8c';
