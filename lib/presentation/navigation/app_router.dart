// lib/presentation/navigation/app_router.dart
//
// GoRouter route tree for the entire Variance app.
//
// Structure:
//   StatefulShellRoute.indexedStack — 3-tab shell (Home / Accounts / Settings)
//     Branch 0: / → HomeScreen
//       /transaction/new      → CreateTransactionScreen (modal, not in shell)
//       /transaction/:id      → TransactionDetailScreen (in-tab push)
//       /transaction/:id/edit → EditTransactionScreen (in-tab push)
//     Branch 1: /accounts → AccountListScreen
//       /accounts/:id  → AccountDetailScreen (in-tab push)
//       /accounts/new  → CreateAccountScreen (in-tab push)
//     Branch 2: /settings → SettingsScreen
//       /settings/currency          → CurrencySettingsScreen
//       /settings/categories        → CategoryManagementScreen
//       /settings/categories/:id    → CategoryDetailScreen
//       /settings/backup            → BackupRestoreScreen
//       /settings/about             → AboutScreen
//
//   Modal routes (outside shell — full-screen):
//     /onboarding         → OnboardingScreen
//     /filter             → FilterSheet (bottom sheet modal)
//     /exchange-rate-detail → ExchangeRateDetailScreen
//
// Navigation rules (SDS §2.4.3):
//   - context.go(...)   for tab-root transitions (replaces tab stack)
//   - context.push(...) for within-tab stack pushes
//
// Onboarding guard (T-16):
//   - If onboarding_complete == false in app_settings, all routes redirect
//     to /onboarding.
//   - /onboarding itself bypasses the guard to prevent redirect loops.
//
// Route parameter validation (SDS §2.4.3):
//   - All :id parameters are validated at the builder.
//   - Invalid parameters navigate to RouteErrorScreen instead of crashing.
//
// Test cases (see test/navigation/app_router_test.dart):
//   - Fresh install (onboardingComplete=false) redirects all routes to /onboarding
//   - Returning user (onboardingComplete=true) routes to home shell normally
//   - Each tab tap navigates to the correct placeholder screen
//   - No GoException on any defined path parameter

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:variance/domain/entities/account.dart';
import 'package:variance/domain/entities/app_settings.dart';
import 'package:variance/presentation/features/accounts/account_detail_screen.dart';
import 'package:variance/presentation/features/accounts/account_form_screen.dart';
import 'package:variance/presentation/features/accounts/account_list_screen.dart';
import 'package:variance/presentation/features/accounts/reconcile_screen.dart';
import 'package:variance/presentation/features/home/home_screen.dart';
import 'package:variance/presentation/features/installments/installment_plan_detail_screen.dart';
import 'package:variance/presentation/features/onboarding/onboarding_screen.dart';
import 'package:variance/presentation/features/settings/appearance/appearance_settings_screen.dart';
import 'package:variance/presentation/features/settings/appearance/color_scheme_preview_screen.dart';
import 'package:variance/presentation/features/settings/backup/backup_data_screen.dart';
import 'package:variance/presentation/features/settings/categories/category_detail_screen.dart';
import 'package:variance/presentation/features/settings/categories/category_management_screen.dart';
import 'package:variance/presentation/features/settings/currency/currency_picker_screen.dart';
import 'package:variance/presentation/features/settings/currency/currency_settings_screen.dart';
import 'package:variance/presentation/features/settings/hub/settings_hub_screen.dart';
import 'package:variance/presentation/features/settings/locale/locale_format_settings_screen.dart';
import 'package:variance/presentation/features/settings/profile/profile_settings_screen.dart';
import 'package:variance/presentation/features/settings/recurring/create_recurring_template_screen.dart';
import 'package:variance/presentation/features/settings/recurring/recurring_template_detail_screen.dart';
import 'package:variance/presentation/features/settings/recurring/recurring_templates_list_screen.dart';
import 'package:variance/presentation/features/settings/security/pin_setup_screen.dart';
import 'package:variance/presentation/features/settings/security/security_settings_screen.dart';
import 'package:variance/presentation/features/settings/transaction_entry/transaction_entry_settings_screen.dart';
import 'package:variance/presentation/features/settings/warnings/account_limits_screen.dart';
import 'package:variance/presentation/features/settings/warnings/category_limits_screen.dart';
import 'package:variance/presentation/features/settings/warnings/warnings_settings_screen.dart';
import 'package:variance/presentation/features/shared/route_error_screen.dart';
import 'package:variance/presentation/features/transactions/exchange_rate_detail_screen.dart';
import 'package:variance/presentation/features/transactions/transaction_detail_screen.dart';
import 'package:variance/presentation/features/transactions/transaction_form_screen.dart';
import 'package:variance/presentation/providers/app_settings_providers.dart';
import 'package:variance/presentation/theme/app_theme.dart';

// ---------------------------------------------------------------------------
// Route path constants
// ---------------------------------------------------------------------------

/// Named route path constants.
///
/// Use these instead of raw string literals in push/go calls to prevent
/// typos and make refactoring safe.
// ignore: avoid_classes_with_only_static_members — intentional namespace
abstract final class AppRoutes {
  /// Tab 0 root.
  static const home = '/';

  /// New transaction modal.
  static const transactionNew = '/transaction/new';

  /// Transaction detail (in-tab push on Tab 0).
  static const transactionDetail = '/transaction/:id';

  /// Transaction edit (in-tab push on Tab 0).
  static const transactionEdit = '/transaction/:id/edit';

  /// Tab 1 root.
  static const accounts = '/accounts';

  /// Account detail (in-tab push on Tab 1).
  static const accountDetail = '/accounts/:id';

  /// New account form (in-tab push on Tab 1).
  static const accountNew = '/accounts/new';

  /// Tab 2 root.
  static const settings = '/settings';

  /// Currency settings (in-tab push on Tab 2).
  static const settingsCurrency = '/settings/currency';

  /// Category management (in-tab push on Tab 2).
  static const settingsCategories = '/settings/categories';

  /// New category form (in-tab push on Tab 2).
  static const settingsCategoryNew = '/settings/categories/new';

  /// Category detail (in-tab push on Tab 2).
  static const settingsCategoryDetail = '/settings/categories/:id';

  /// Appearance settings (in-tab push on Tab 2).
  static const settingsAppearance = '/settings/appearance';

  /// Color scheme preview (in-tab push on Tab 2).
  static const settingsAppearancePreview = '/settings/appearance/preview';

  /// Locale & format settings (in-tab push on Tab 2).
  static const settingsLocale = '/settings/locale';

  /// Transaction entry settings (in-tab push on Tab 2).
  static const settingsTransactionEntry = '/settings/transaction-entry';

  /// Warnings & limits settings (in-tab push on Tab 2).
  static const settingsWarnings = '/settings/warnings';

  /// Per-account limits sub-screen (in-tab push on Tab 2).
  static const settingsWarningsAccounts = '/settings/warnings/accounts';

  /// Per-category limits sub-screen (in-tab push on Tab 2).
  static const settingsWarningsCategories = '/settings/warnings/categories';

  /// Profile settings (in-tab push on Tab 2).
  static const settingsProfile = '/settings/profile';

  /// Security settings (in-tab push on Tab 2).
  static const settingsSecurity = '/settings/security';

  /// PIN setup screen (push from security settings).
  static const settingsSecurityPinSetup = '/settings/security/pin-setup';

  /// Tags settings (in-tab push on Tab 2).
  static const settingsTags = '/settings/tags';

  /// Payees settings (in-tab push on Tab 2).
  static const settingsPayees = '/settings/payees';

  /// Recurring & installments settings (in-tab push on Tab 2).
  static const settingsRecurring = '/settings/recurring';

  /// Create recurring template form (in-tab push on Tab 2).
  static const settingsRecurringNew = '/settings/recurring/new';

  /// Recurring template detail / edit (in-tab push on Tab 2).
  static const settingsRecurringDetail = '/settings/recurring/:id';

  /// Builds the recurring template detail path for [id].
  static String settingsRecurringDetailPath(String id) =>
      '/settings/recurring/$id';

  /// Installment plan detail / edit (in-tab push on Tab 2).
  static const settingsInstallmentDetail = '/settings/installments/:id';

  /// Builds the installment plan detail path for [id].
  static String settingsInstallmentDetailPath(String id) =>
      '/settings/installments/$id';

  /// Drafts settings (in-tab push on Tab 2).
  static const settingsDrafts = '/settings/drafts';

  /// Backup & restore (in-tab push on Tab 2).
  static const settingsBackup = '/settings/backup';

  /// About screen (in-tab push on Tab 2).
  static const settingsAbout = '/settings/about';

  /// Onboarding wizard (full-screen modal, outside shell).
  static const onboarding = '/onboarding';

  /// Transaction filter bottom sheet (full-screen modal, outside shell).
  static const filter = '/filter';

  /// Exchange rate detail (full-screen modal, outside shell).
  static const exchangeRateDetail = '/exchange-rate-detail';

  /// Currency picker (full-screen modal, outside shell).
  static const currencyPicker = '/currency-picker';

  // -----------------------------------------------------------------------
  // Path builders — replaces :id parameter at call sites.
  // -----------------------------------------------------------------------

  /// Builds the account detail path for [id].
  static String accountDetailPath(String id) => '/accounts/$id';

  /// Builds the account edit path for [id].
  static String accountEdit(String id) => '/accounts/$id/edit';

  /// Builds the reconcile path for account [id].
  static String accountReconcile(String id) => '/accounts/$id/reconcile';

  /// Builds the transaction detail path for [id].
  static String transactionDetailPath(String id) => '/transaction/$id';

  /// Builds the transaction edit path for [id].
  static String transactionEditPath(String id) => '/transaction/$id/edit';
}

// ---------------------------------------------------------------------------
// Settings listenable — drives GoRouter redirect re-evaluation
// ---------------------------------------------------------------------------

/// A [ChangeNotifier] that notifies listeners whenever [AppSettings] emits
/// a new value from the Riverpod provider.
///
/// Passed to [GoRouter.refreshListenable] so that the `redirect` callback is
/// re-evaluated every time the settings stream emits (e.g. when onboarding
/// completes).
class _SettingsListenable extends ChangeNotifier {
  /// Creates a [_SettingsListenable] that listens to [appSettingsProvider].
  ///
  /// Parameters:
  /// - [ref]: The Riverpod [WidgetRef] used to subscribe to the provider.
  _SettingsListenable(WidgetRef ref) {
    // Listen for any change in app settings and notify GoRouter to re-run
    // the redirect callback.
    ref.listen<AsyncValue<AppSettings>>(
      appSettingsProvider,
      (_, __) => notifyListeners(),
    );
  }
}

// ---------------------------------------------------------------------------
// Router factory
// ---------------------------------------------------------------------------

/// Creates a [GoRouter] backed by a [WidgetRef] so the onboarding redirect
/// guard can watch the live [AppSettings] stream.
///
/// The [_SettingsListenable] is wired to [GoRouter.refreshListenable] so that
/// GoRouter re-runs the `redirect` callback whenever [appSettingsProvider]
/// emits a new value.
///
/// Prefer [AppRouterWidget] for production. Call [makeAppRouter] directly in
/// widget tests that need a custom [WidgetRef].
GoRouter makeAppRouter(WidgetRef ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    // Re-evaluate the redirect callback whenever AppSettings changes.
    refreshListenable: _SettingsListenable(ref),
    // ---------------------------------------------------------------------------
    // Onboarding redirect guard (T-16)
    //
    // Reads onboardingComplete from the live AppSettings stream.
    // If false, every route redirects to /onboarding.
    // The /onboarding route itself is whitelisted to prevent redirect loops.
    // ---------------------------------------------------------------------------
    redirect: (BuildContext context, GoRouterState state) {
      final settingsValue = ref.read(appSettingsProvider);

      // While the settings stream is loading, do not redirect — let the user
      // see the shell. Once settings load, a rebuild will re-evaluate.
      // AsyncValue<AppSettings>.value returns T? (null when loading or error).
      final AppSettings? settings = settingsValue.value;
      if (settings == null) return null;

      final isOnboarding = state.matchedLocation == AppRoutes.onboarding;
      final onboardingComplete = settings.onboardingComplete;

      // Not onboarded → redirect everything to /onboarding.
      if (!onboardingComplete && !isOnboarding) return AppRoutes.onboarding;

      // Onboarded and already at /onboarding → go home.
      if (onboardingComplete && isOnboarding) return AppRoutes.home;

      return null;
    },

    routes: [
      // -----------------------------------------------------------------------
      // Shell route — 3-tab bottom navigation
      // -----------------------------------------------------------------------
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _AppShell(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
                routes: [
                  // /transaction/:id — in-tab push (context.push)
                  GoRoute(
                    path: 'transaction/:id',
                    builder: (context, state) {
                      final id = state.pathParameters['id'];
                      if (id == null || id.isEmpty) {
                        return const RouteErrorScreen(
                          errorMessage: 'Transaction ID is missing.',
                        );
                      }
                      return TransactionDetailScreen(transactionId: id);
                    },
                    routes: [
                      // /transaction/:id/edit — in-tab push (context.push)
                      GoRoute(
                        path: 'edit',
                        builder: (context, state) {
                          final id = state.pathParameters['id'];
                          if (id == null || id.isEmpty) {
                            return const RouteErrorScreen(
                              errorMessage: 'Transaction ID is missing.',
                            );
                          }
                          // TODO(dev): return EditTransactionScreen(id: id);
                          return const RouteErrorScreen(
                            errorMessage:
                                'Transaction edit not yet implemented.',
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // Branch 1: Accounts
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.accounts,
                builder: (context, state) => const AccountListScreen(),
                routes: [
                  // /accounts/new — in-tab push (context.push)
                  GoRoute(
                    path: 'new',
                    builder: (context, state) =>
                        const AccountFormScreen(existingAccount: null),
                  ),
                  // /accounts/:id — in-tab push (context.push)
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = state.pathParameters['id'];
                      if (id == null || id.isEmpty) {
                        return const RouteErrorScreen(
                          errorMessage: 'Account ID is missing.',
                        );
                      }
                      return AccountDetailScreen(accountId: id);
                    },
                    routes: [
                      // /accounts/:id/edit
                      GoRoute(
                        path: 'edit',
                        builder: (context, state) {
                          // Account passed via extra (set by AccountListScreen).
                          final account = state.extra;
                          if (account is! Account) {
                            return const RouteErrorScreen(
                              errorMessage: 'Account data missing for edit.',
                            );
                          }
                          return AccountFormScreen(existingAccount: account);
                        },
                      ),
                      // /accounts/:id/reconcile — T-43
                      GoRoute(
                        path: 'reconcile',
                        builder: (context, state) {
                          final id = state.pathParameters['id'];
                          if (id == null || id.isEmpty) {
                            return const RouteErrorScreen(
                              errorMessage: 'Account ID is missing.',
                            );
                          }
                          return ReconcileScreen(accountId: id);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // Branch 2: Settings
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const SettingsHubScreen(),
                routes: [
                  // /settings/appearance — Appearance settings (T-175)
                  GoRoute(
                    path: 'appearance',
                    builder: (context, state) =>
                        const AppearanceSettingsScreen(),
                    routes: [
                      // /settings/appearance/preview — Color preview (T-176)
                      GoRoute(
                        path: 'preview',
                        builder: (context, state) =>
                            const ColorSchemePreviewScreen(),
                      ),
                    ],
                  ),
                  // /settings/locale — Locale & Format settings (T-177)
                  GoRoute(
                    path: 'locale',
                    builder: (context, state) =>
                        const LocaleFormatSettingsScreen(),
                  ),
                  // /settings/transaction-entry — Transaction Entry settings (T-179)
                  GoRoute(
                    path: 'transaction-entry',
                    builder: (context, state) =>
                        const TransactionEntrySettingsScreen(),
                  ),
                  // /settings/warnings — Warnings & Limits hub (T-181, T-182)
                  GoRoute(
                    path: 'warnings',
                    builder: (context, state) => const WarningsSettingsScreen(),
                    routes: [
                      // /settings/warnings/accounts — Per-Account Limits (T-181)
                      GoRoute(
                        path: 'accounts',
                        builder: (context, state) =>
                            const AccountLimitsScreen(),
                      ),
                      // /settings/warnings/categories — Per-Category Limits (T-182)
                      GoRoute(
                        path: 'categories',
                        builder: (context, state) =>
                            const CategoryLimitsScreen(),
                      ),
                    ],
                  ),
                  // /settings/profile — Profile settings (T-183)
                  GoRoute(
                    path: 'profile',
                    builder: (context, state) => const ProfileSettingsScreen(),
                  ),
                  // /settings/security — Security settings (T-184)
                  GoRoute(
                    path: 'security',
                    builder: (context, state) => const SecuritySettingsScreen(),
                    routes: [
                      // /settings/security/pin-setup — PIN setup (T-185)
                      GoRoute(
                        path: 'pin-setup',
                        builder: (context, state) {
                          final modeStr =
                              state.uri.queryParameters['mode'] ?? 'create';
                          final mode = modeStr == 'change'
                              ? PinSetupMode.change
                              : PinSetupMode.create;
                          return PinSetupScreen(mode: mode);
                        },
                      ),
                    ],
                  ),
                  // /settings/currency — currency settings (T-96)
                  GoRoute(
                    path: 'currency',
                    builder: (context, state) => const CurrencySettingsScreen(),
                  ),
                  // /settings/categories — category management
                  GoRoute(
                    path: 'categories',
                    builder: (context, state) =>
                        const CategoryManagementScreen(),
                    routes: [
                      // /settings/categories/new — create form
                      GoRoute(
                        path: 'new',
                        builder: (context, state) {
                          // Query params: ?tree=expense|income, ?parent=:id
                          final tree = state.uri.queryParameters['tree'];
                          final parentId = state.uri.queryParameters['parent'];
                          return CategoryDetailScreen(
                            categoryId: null,
                            initialTree: tree,
                            initialParentId: parentId,
                          );
                        },
                      ),
                      // /settings/categories/:id — edit form
                      GoRoute(
                        path: ':id',
                        builder: (context, state) {
                          final id = state.pathParameters['id'];
                          if (id == null || id.isEmpty) {
                            return const RouteErrorScreen(
                              errorMessage: 'Category ID is missing.',
                            );
                          }
                          return CategoryDetailScreen(
                            categoryId: id,
                            initialTree: null,
                            initialParentId: null,
                          );
                        },
                      ),
                    ],
                  ),
                  // /settings/tags — placeholder
                  GoRoute(
                    path: 'tags',
                    builder: (context, state) => const RouteErrorScreen(
                      errorMessage: 'Tags settings not yet implemented.',
                    ),
                  ),
                  // /settings/payees — placeholder
                  GoRoute(
                    path: 'payees',
                    builder: (context, state) => const RouteErrorScreen(
                      errorMessage: 'Payees settings not yet implemented.',
                    ),
                  ),
                  // /settings/recurring — Recurring & Installments list (T-108)
                  GoRoute(
                    path: 'recurring',
                    builder: (context, state) =>
                        const RecurringTemplatesListScreen(),
                    routes: [
                      // /settings/recurring/new — Create template (T-106)
                      GoRoute(
                        path: 'new',
                        builder: (context, state) =>
                            const CreateRecurringTemplateScreen(),
                      ),
                      // /settings/recurring/:id — Detail / edit (T-109)
                      GoRoute(
                        path: ':id',
                        builder: (context, state) {
                          final id = state.pathParameters['id'];
                          if (id == null || id.isEmpty) {
                            return const RouteErrorScreen(
                              errorMessage: 'Template ID is missing.',
                            );
                          }
                          return RecurringTemplateDetailScreen(templateId: id);
                        },
                      ),
                    ],
                  ),
                  // /settings/installments/:id — Installment Plan Detail (T-137)
                  GoRoute(
                    path: 'installments/:id',
                    builder: (context, state) {
                      final id = state.pathParameters['id'];
                      if (id == null || id.isEmpty) {
                        return const RouteErrorScreen(
                          errorMessage: 'Installment plan ID is missing.',
                        );
                      }
                      return InstallmentPlanDetailScreen(templateId: id);
                    },
                  ),
                  // /settings/drafts — placeholder
                  GoRoute(
                    path: 'drafts',
                    builder: (context, state) => const RouteErrorScreen(
                      errorMessage: 'Drafts settings not yet implemented.',
                    ),
                  ),
                  // /settings/backup — BackupDataScreen (T-187)
                  GoRoute(
                    path: 'backup',
                    builder: (context, state) => const BackupDataScreen(),
                  ),
                  // /settings/about — placeholder
                  GoRoute(
                    path: 'about',
                    builder: (context, state) {
                      // TODO(dev): return AboutScreen();
                      return const RouteErrorScreen(
                        errorMessage: 'About screen not yet implemented.',
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // -----------------------------------------------------------------------
      // Modal routes — outside shell (no bottom navigation bar)
      // -----------------------------------------------------------------------

      // /onboarding — full-screen modal, shown on fresh install.
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // /transaction/new — full-screen slide-up modal.
      GoRoute(
        path: AppRoutes.transactionNew,
        builder: (context, state) {
          // Optional pre-fill for destination account (credit card Pay FAB).
          final extra = state.extra;
          final prefillDestId = extra is Map<String, dynamic>
              ? extra['prefillDestinationId'] as String?
              : null;
          return TransactionFormScreen(
            prefillDestinationAccountId: prefillDestId,
          );
        },
      ),

      // /filter — bottom sheet modal for transaction filtering.
      GoRoute(
        path: AppRoutes.filter,
        builder: (context, state) {
          // TODO(dev): return FilterSheet();
          return const RouteErrorScreen(
            errorMessage: 'Filter sheet not yet implemented.',
          );
        },
      ),

      // /exchange-rate-detail — exchange rate detail modal (T-98).
      GoRoute(
        path: AppRoutes.exchangeRateDetail,
        builder: (context, state) => ExchangeRateDetailScreen(
          fromCurrency: state.uri.queryParameters['from'] ?? '',
          toCurrency: state.uri.queryParameters['to'] ?? '',
        ),
      ),

      // /currency-picker — ISO 4217 currency picker modal (T-97).
      GoRoute(
        path: AppRoutes.currencyPicker,
        builder: (context, state) => CurrencyPickerScreen(
          currentCode: state.uri.queryParameters['current'],
        ),
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// Provider-aware router widget (production entry point)
// ---------------------------------------------------------------------------

/// A [ConsumerWidget] that builds a [GoRouter] with access to [WidgetRef].
///
/// The onboarding redirect guard calls [ref.read(appSettingsProvider)], which
/// requires a Riverpod context. Using a [ConsumerWidget] as the top-level
/// router host gives us that context without storing [BuildContext] in
/// long-lived objects.
///
/// [VarianceApp] should use [AppRouterWidget] as the root of [MaterialApp]:
/// ```dart
/// MaterialApp(home: AppRouterWidget())
/// // or simply:
/// AppRouterWidget()  // renders MaterialApp.router internally
/// ```
class AppRouterWidget extends ConsumerWidget {
  /// Creates the [AppRouterWidget].
  const AppRouterWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Router is created once and stored in a local variable. It is not
    // memoized here because GoRouter is already kept alive by the widget tree.
    final router = makeAppRouter(ref);

    // Read color scheme mode preference from settings (null while loading).
    final AppSettings? settings = ref.watch(appSettingsProvider).value;
    final colorSchemeMode =
        settings?.colorSchemeMode ?? ColorSchemeMode.dynamic;

    // Resolve custom seed color from settings (fallback to default purple).
    final Color seedColor = _resolveSeedColor(settings?.colorSeed);

    // DynamicColorBuilder attempts OEM wallpaper extraction (Android 12+).
    // When the device supports it AND the user prefers dynamic mode, the OEM
    // schemes are used. Otherwise we fall back to a seed-based or catppuccin
    // scheme.
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        final ThemePair themes = _resolveThemes(
          colorSchemeMode: colorSchemeMode,
          lightDynamic: lightDynamic,
          darkDynamic: darkDynamic,
          seedColor: seedColor,
        );

        // dynamicAvailable: OEM extraction succeeded (non-null schemes) when
        // the user prefers dynamic mode. Passed down via DynamicColorAvailability
        // so AppearanceSettingsScreen can show the "unavailable" note.
        final dynamicAvailable = lightDynamic != null && darkDynamic != null;

        return DynamicColorAvailability(
          available: dynamicAvailable,
          child: MaterialApp.router(
            title: 'Variance',
            theme: themes.light,
            darkTheme: themes.dark,
            themeMode: _resolveThemeMode(settings?.theme),
            routerConfig: router,
          ),
        );
      },
    );
  }

  /// Parses [hexColorSeed] (e.g. '#6750A4') to a [Color].
  ///
  /// Returns [kDefaultSeedColor] when [hexColorSeed] is null or unparseable.
  static Color _resolveSeedColor(String? hexColorSeed) {
    if (hexColorSeed == null) return kDefaultSeedColor;
    final cleaned = hexColorSeed.replaceFirst('#', '');
    final value = int.tryParse('FF$cleaned', radix: 16);
    return value != null ? Color(value) : kDefaultSeedColor;
  }

  /// Selects between dynamic OEM, catppuccin, and seed-based schemes.
  ///
  /// When [colorSchemeMode] is [ColorSchemeMode.dynamic] and the OEM schemes
  /// are non-null (Android 12+), the OEM schemes are applied. When
  /// [colorSchemeMode] is [ColorSchemeMode.catppuccin], the Catppuccin palette
  /// is applied. Otherwise the seed-based fallback is used.
  static ThemePair _resolveThemes({
    required ColorSchemeMode colorSchemeMode,
    required ColorScheme? lightDynamic,
    required ColorScheme? darkDynamic,
    required Color seedColor,
  }) {
    if (colorSchemeMode == ColorSchemeMode.dynamic &&
        lightDynamic != null &&
        darkDynamic != null) {
      return AppThemeData.fromColorSchemes(lightDynamic, darkDynamic);
    }
    if (colorSchemeMode == ColorSchemeMode.catppuccin) {
      return AppThemeData.fromCatppuccin();
    }
    return AppThemeData.fromSeed(seedColor);
  }

  /// Maps [AppTheme] preference to Flutter [ThemeMode].
  ///
  /// Returns [ThemeMode.system] when [theme] is null (settings not yet loaded).
  static ThemeMode _resolveThemeMode(AppTheme? theme) {
    return switch (theme) {
      AppTheme.light => ThemeMode.light,
      AppTheme.dark => ThemeMode.dark,
      AppTheme.system || null => ThemeMode.system,
    };
  }
}

// ---------------------------------------------------------------------------
// Legacy appRouter (used only in tests that do not need the redirect guard)
// ---------------------------------------------------------------------------

/// A minimal [GoRouter] that does not include the onboarding redirect guard.
///
/// Used in widget tests that only need to verify navigation structure without
/// a live Riverpod container. Tests requiring the redirect guard should call
/// [makeAppRouter] directly with a [WidgetRef].
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          _AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.accounts,
              builder: (context, state) => const AccountListScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.settings,
              builder: (context, state) => const SettingsHubScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
  ],
);

// ---------------------------------------------------------------------------
// Shell scaffold widget
// ---------------------------------------------------------------------------

/// The 3-tab shell scaffold with an M3 [NavigationBar].
///
/// This widget is the builder for [StatefulShellRoute] and renders the
/// bottom navigation bar. It is never used standalone — it is provided by
/// GoRouter's shell route infrastructure.
///
/// Navigation rules:
///   - Tapping a tab destination uses `navigationShell.goBranch()` which
///     internally calls context.go() — this replaces the root of that
///     tab's stack (correct per SDS §2.4.3).
///   - Within-tab pushes use context.push(...) from child screens.
class _AppShell extends StatelessWidget {
  const _AppShell({required this.navigationShell});

  /// Provided by [StatefulShellRoute]; drives tab index and branch navigation.
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The individual tab screens render their own AppBar.
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        // Use goBranch to switch tabs, preserving each tab's own back-stack
        // per StatefulShellRoute.indexedStack semantics.
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          // initialLocation=true resets the branch stack to root on re-tap.
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Accounts',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
