/// Contains constant keys used for storing user preferences in SharedPreferences.
///
/// These keys provide a single source of truth for preference storage,
/// ensuring consistency across retrieval and persistence operations.
library;

/// Key for storing the user's selected theme mode (system, light, dark).
const String kThemeModeKey = 'theme_mode';

/// Key for storing the user's custom accent color as an integer value.
const String kAccentColorKey = 'accent_color';

/// Key for storing whether dynamic (Material You) colors are enabled.
const String kUseDynamicColorKey = 'use_dynamic_color';

/// Key for storing the user's preferred currency code (ISO 4217).
const String kCurrencyCodeKey = 'currency_code';

/// Key for storing the user's preferred locale string.
const String kLocaleKey = 'locale';
