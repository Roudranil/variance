// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Reactive stream of all non-system, non-deleted accounts.
///
/// Emits a new list whenever the underlying accounts table changes.
/// Consumers should prefer this provider over calling the repository directly.

@ProviderFor(accounts)
final accountsProvider = AccountsProvider._();

/// Reactive stream of all non-system, non-deleted accounts.
///
/// Emits a new list whenever the underlying accounts table changes.
/// Consumers should prefer this provider over calling the repository directly.

final class AccountsProvider extends $FunctionalProvider<
        AsyncValue<List<Account>>, List<Account>, Stream<List<Account>>>
    with $FutureModifier<List<Account>>, $StreamProvider<List<Account>> {
  /// Reactive stream of all non-system, non-deleted accounts.
  ///
  /// Emits a new list whenever the underlying accounts table changes.
  /// Consumers should prefer this provider over calling the repository directly.
  AccountsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'accountsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$accountsHash();

  @$internal
  @override
  $StreamProviderElement<List<Account>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Account>> create(Ref ref) {
    return accounts(ref);
  }
}

String _$accountsHash() => r'311475de79c6beac4fe9e6f5ceed5cf527cd5eda';

/// Reactive stream of the computed balance for account [accountId].
///
/// The balance is expressed in the account's own currency (minor units).
/// Emits a new value whenever the underlying entries change.
///
/// Parameters:
/// - [accountId]: UUID of the account to watch.
/// - [currencyCode]: ISO 4217 code used to denominate the balance stream.

@ProviderFor(accountBalance)
final accountBalanceProvider = AccountBalanceFamily._();

/// Reactive stream of the computed balance for account [accountId].
///
/// The balance is expressed in the account's own currency (minor units).
/// Emits a new value whenever the underlying entries change.
///
/// Parameters:
/// - [accountId]: UUID of the account to watch.
/// - [currencyCode]: ISO 4217 code used to denominate the balance stream.

final class AccountBalanceProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  /// Reactive stream of the computed balance for account [accountId].
  ///
  /// The balance is expressed in the account's own currency (minor units).
  /// Emits a new value whenever the underlying entries change.
  ///
  /// Parameters:
  /// - [accountId]: UUID of the account to watch.
  /// - [currencyCode]: ISO 4217 code used to denominate the balance stream.
  AccountBalanceProvider._(
      {required AccountBalanceFamily super.from,
      required (
        String,
        String,
      )
          super.argument})
      : super(
          retry: null,
          name: r'accountBalanceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$accountBalanceHash();

  @override
  String toString() {
    return r'accountBalanceProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    final argument = this.argument as (
      String,
      String,
    );
    return accountBalance(
      ref,
      argument.$1,
      argument.$2,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AccountBalanceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$accountBalanceHash() => r'905f757d74c53484273a6a214920fb9d8331e23a';

/// Reactive stream of the computed balance for account [accountId].
///
/// The balance is expressed in the account's own currency (minor units).
/// Emits a new value whenever the underlying entries change.
///
/// Parameters:
/// - [accountId]: UUID of the account to watch.
/// - [currencyCode]: ISO 4217 code used to denominate the balance stream.

final class AccountBalanceFamily extends $Family
    with
        $FunctionalFamilyOverride<
            Stream<int>,
            (
              String,
              String,
            )> {
  AccountBalanceFamily._()
      : super(
          retry: null,
          name: r'accountBalanceProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Reactive stream of the computed balance for account [accountId].
  ///
  /// The balance is expressed in the account's own currency (minor units).
  /// Emits a new value whenever the underlying entries change.
  ///
  /// Parameters:
  /// - [accountId]: UUID of the account to watch.
  /// - [currencyCode]: ISO 4217 code used to denominate the balance stream.

  AccountBalanceProvider call(
    String accountId,
    String currencyCode,
  ) =>
      AccountBalanceProvider._(argument: (
        accountId,
        currencyCode,
      ), from: this);

  @override
  String toString() => r'accountBalanceProvider';
}

/// Reactive stream of the aggregate net worth in the home currency.
///
/// Emits a [NetWorthResult] whenever the account list or any account balance
/// changes. The staleness flag in [NetWorthResult.hasStaleRates] drives the
/// "Rate may be outdated" indicator in the UI.

@ProviderFor(netWorth)
final netWorthProvider = NetWorthProvider._();

/// Reactive stream of the aggregate net worth in the home currency.
///
/// Emits a [NetWorthResult] whenever the account list or any account balance
/// changes. The staleness flag in [NetWorthResult.hasStaleRates] drives the
/// "Rate may be outdated" indicator in the UI.

final class NetWorthProvider extends $FunctionalProvider<
        AsyncValue<NetWorthResult>, NetWorthResult, Stream<NetWorthResult>>
    with $FutureModifier<NetWorthResult>, $StreamProvider<NetWorthResult> {
  /// Reactive stream of the aggregate net worth in the home currency.
  ///
  /// Emits a [NetWorthResult] whenever the account list or any account balance
  /// changes. The staleness flag in [NetWorthResult.hasStaleRates] drives the
  /// "Rate may be outdated" indicator in the UI.
  NetWorthProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'netWorthProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$netWorthHash();

  @$internal
  @override
  $StreamProviderElement<NetWorthResult> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<NetWorthResult> create(Ref ref) {
    return netWorth(ref);
  }
}

String _$netWorthHash() => r'16a00f3c8b3b92f3b9c0cd713237267de99451eb';

/// Watches a single account by [accountId].
///
/// Emits null if the account does not exist or has been soft-deleted.
/// Used by [AccountDetailScreen] and anywhere a single-account stream
/// is needed outside the list view.
///
/// Parameters:
/// - [accountId]: UUID of the account to watch.

@ProviderFor(accountById)
final accountByIdProvider = AccountByIdFamily._();

/// Watches a single account by [accountId].
///
/// Emits null if the account does not exist or has been soft-deleted.
/// Used by [AccountDetailScreen] and anywhere a single-account stream
/// is needed outside the list view.
///
/// Parameters:
/// - [accountId]: UUID of the account to watch.

final class AccountByIdProvider extends $FunctionalProvider<
        AsyncValue<Account?>, Account?, Stream<Account?>>
    with $FutureModifier<Account?>, $StreamProvider<Account?> {
  /// Watches a single account by [accountId].
  ///
  /// Emits null if the account does not exist or has been soft-deleted.
  /// Used by [AccountDetailScreen] and anywhere a single-account stream
  /// is needed outside the list view.
  ///
  /// Parameters:
  /// - [accountId]: UUID of the account to watch.
  AccountByIdProvider._(
      {required AccountByIdFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'accountByIdProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$accountByIdHash();

  @override
  String toString() {
    return r'accountByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Account?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Account?> create(Ref ref) {
    final argument = this.argument as String;
    return accountById(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AccountByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$accountByIdHash() => r'fb7b1d51d47ccdec81bfb751b773af9fa71de755';

/// Watches a single account by [accountId].
///
/// Emits null if the account does not exist or has been soft-deleted.
/// Used by [AccountDetailScreen] and anywhere a single-account stream
/// is needed outside the list view.
///
/// Parameters:
/// - [accountId]: UUID of the account to watch.

final class AccountByIdFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Account?>, String> {
  AccountByIdFamily._()
      : super(
          retry: null,
          name: r'accountByIdProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Watches a single account by [accountId].
  ///
  /// Emits null if the account does not exist or has been soft-deleted.
  /// Used by [AccountDetailScreen] and anywhere a single-account stream
  /// is needed outside the list view.
  ///
  /// Parameters:
  /// - [accountId]: UUID of the account to watch.

  AccountByIdProvider call(
    String accountId,
  ) =>
      AccountByIdProvider._(argument: accountId, from: this);

  @override
  String toString() => r'accountByIdProvider';
}

/// Derives display labels for all active-account currencies.
///
/// Uses [CurrencySymbolResolver] to detect symbol collisions among the
/// currencies that actually appear on active accounts. When two or more
/// accounts share a currency symbol (e.g. '$' for USD and CAD), each
/// conflicting currency gets an ISO-code suffix: '$USD', '$CAD'.
///
/// Returns a [Map] of currency code → display label. Consumers should read
/// this map and look up the account's [Account.currencyCode] to get the
/// correct label to show in the row.
///
/// Depends on [accountsProvider] (reactive) and [currenciesProvider]
/// (keepAlive static list from seed data).

@ProviderFor(currencySymbolLabels)
final currencySymbolLabelsProvider = CurrencySymbolLabelsProvider._();

/// Derives display labels for all active-account currencies.
///
/// Uses [CurrencySymbolResolver] to detect symbol collisions among the
/// currencies that actually appear on active accounts. When two or more
/// accounts share a currency symbol (e.g. '$' for USD and CAD), each
/// conflicting currency gets an ISO-code suffix: '$USD', '$CAD'.
///
/// Returns a [Map] of currency code → display label. Consumers should read
/// this map and look up the account's [Account.currencyCode] to get the
/// correct label to show in the row.
///
/// Depends on [accountsProvider] (reactive) and [currenciesProvider]
/// (keepAlive static list from seed data).

final class CurrencySymbolLabelsProvider extends $FunctionalProvider<
        AsyncValue<Map<String, String>>,
        Map<String, String>,
        Stream<Map<String, String>>>
    with
        $FutureModifier<Map<String, String>>,
        $StreamProvider<Map<String, String>> {
  /// Derives display labels for all active-account currencies.
  ///
  /// Uses [CurrencySymbolResolver] to detect symbol collisions among the
  /// currencies that actually appear on active accounts. When two or more
  /// accounts share a currency symbol (e.g. '$' for USD and CAD), each
  /// conflicting currency gets an ISO-code suffix: '$USD', '$CAD'.
  ///
  /// Returns a [Map] of currency code → display label. Consumers should read
  /// this map and look up the account's [Account.currencyCode] to get the
  /// correct label to show in the row.
  ///
  /// Depends on [accountsProvider] (reactive) and [currenciesProvider]
  /// (keepAlive static list from seed data).
  CurrencySymbolLabelsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'currencySymbolLabelsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$currencySymbolLabelsHash();

  @$internal
  @override
  $StreamProviderElement<Map<String, String>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Map<String, String>> create(Ref ref) {
    return currencySymbolLabels(ref);
  }
}

String _$currencySymbolLabelsHash() =>
    r'c23a986bd5cbea7fbad9d5652d6c21a3217aad54';
