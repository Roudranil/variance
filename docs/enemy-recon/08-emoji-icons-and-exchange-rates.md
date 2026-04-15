# 08 -- Emoji/Icon System & Currency Exchange Rates

Detailed reverse-engineering of two Cashew features: the category icon system (including emoji support) and the currency exchange rate pipeline.

---

## Investigation 1: Category Icon System

### Architecture Summary

Cashew uses a **dual-track icon system** for categories. A category can display either:

1. A **curated PNG illustration** selected from a built-in icon picker, OR
2. A **raw emoji character** typed by the user from their keyboard.

These are two **completely separate code paths**. There is NO emoji-to-icon conversion. The "automagically converts" claim is misleading -- the user either picks a PNG icon or enters an emoji, never both simultaneously.

### Database Schema

In `lib/database/tables.dart`, the `Categories` table stores both options as nullable text columns:

```dart
TextColumn get iconName => text().nullable()();       // e.g. "apple.png"
TextColumn get emojiIconName => text().nullable()();   // e.g. "🍎"
```

The same dual-column pattern exists for `Objectives` (goals/savings targets). A category has either `iconName` OR `emojiIconName` set -- never both. When one is set, the other is nulled out.

From `addCategoryPage.dart`:

```dart
void setSelectedImage(String? image) {
  setState(() {
    selectedImage = (image ?? "").replaceFirst("assets/categories/", "");
    selectedEmoji = null;  // <-- clears emoji when icon is selected
  });
}

void setSelectedEmoji(String? emoji) {
  setState(() {
    selectedEmoji = emoji;
    selectedImage = null;  // <-- clears icon when emoji is selected
  });
}
```

### Track 1: Curated PNG Icon Library

**Source file:** `lib/struct/iconObjects.dart` (4,545 lines)

**Data structure:**

```dart
class IconForCategory {
  IconForCategory({required this.icon, required this.tags, this.mostLikelyCategoryName});
  String icon;                    // filename, e.g. "apple.png"
  List<String> tags;              // search keywords, e.g. ["apple", "fruit", "food", ...]
  String? mostLikelyCategoryName; // auto-suggested category name, e.g. "Food"
}
```

**Counts:**

| Metric | Value |
|--------|-------|
| `IconForCategory` entries in code | **278** (includes the class definition line, so 277 icon objects) |
| PNG files in `assets/categories/` | **277** |
| Tags per icon | ~10 keywords each |
| Unique `mostLikelyCategoryName` values | ~170+ (many repeat for broad categories like "Food", "Finance", "Transportation") |

**Icon art style:** Flat-design, colored PNG illustrations with transparent backgrounds. NOT Material Icons, NOT SVGs, NOT emoji renderings. They look like Flaticon/Freepik-style assets -- colorful, rounded, friendly aesthetic. Examples: a red apple with a leaf, a yellow coffee cup with steam, a pink cartoon car.

**How the picker works** (`lib/widgets/selectCategoryImage.dart`):

1. Opens a bottom sheet with a search bar and a grid of all 277 icons.
2. User can type a search term; the picker iterates through every `IconForCategory`'s `tags` list and does a case-insensitive `contains` match.
3. When the user taps an icon, two things happen:
   - `setSelectedImage(image.icon)` sets the PNG filename.
   - `setSelectedTitle(image.mostLikelyCategoryName)` auto-populates the category name (only if the user hasn't manually typed one and the locale is English).
4. The search is English-only. For non-English locales, the search bar is hidden and the "Use Emoji" button is shown more prominently at the top.

**Key code from the picker:**

```dart
children: iconObjects.map((IconForCategory image) {
  bool show = false;
  if (searchTerm != "") {
    for (int i = 0; i < image.tags.length; i++) {
      if (image.tags[i].toLowerCase().contains(searchTerm.toLowerCase())) {
        show = true;
        break;
      }
    }
  } else {
    show = true;
  }
  // ... render ImageIcon with "assets/categories/" + image.icon
}).toList(),
```

### Track 2: Emoji Character Input

**How it works:**

1. User taps "Use Emoji" button in the icon picker.
2. A text input popup opens with a `FilteringTextInputFormatter` that ONLY allows emoji characters:
   ```dart
   FilteringTextInputFormatter.allow(RegExp(
     r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])'))
   ```
3. The user types ANY emoji from their keyboard. The regex covers copyright/registered marks, miscellaneous symbols (U+2000-U+3300), and all three emoji supplementary blocks (U+1F000-U+1FFFF via UTF-16 surrogate pairs).
4. The raw emoji string is stored directly in `emojiIconName` in the database.

**How emojis are rendered** (`lib/widgets/categoryIcon.dart`):

The `CategoryIcon` widget uses a `Stack` with two layers:

```dart
Stack(
  alignment: AlignmentDirectional.center,
  children: [
    AnimatedContainer(
      // Background circle with category color
      child: Tappable(
        child: Center(
          child: (category?.emojiIconName == null && category != null && category.iconName != null
              ? CacheCategoryIcon(iconName: category.iconName ?? "", size: size)  // PNG path
              : Container()),  // empty if emoji is set
        ),
      ),
    ),
    category?.emojiIconName != null
        ? EmojiIcon(emojiIconName: category?.emojiIconName, size: emojiSize ?? size)
        : SizedBox.shrink(),
  ],
)
```

The `EmojiIcon` widget renders the emoji as plain text using Flutter's `TextFont` widget at the icon size, with `MediaQuery` data forcing `textScaleFactor: 1` and `IgnorePointer` to prevent tap interference:

```dart
class EmojiIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQueryData(textScaleFactor: 1),
      child: IgnorePointer(
        child: Padding(
          padding: EdgeInsetsDirectional.only(bottom: size * 0.185 - (correctionPaddingBottom ?? 0)),
          child: Transform.scale(
            scale: emojiScale,
            child: TextFont(
              text: emojiIconName ?? "",
              textAlign: TextAlign.center,
              fontSize: size,
            ),
          ),
        ),
      ),
    );
  }
}
```

So emojis render using the device's native emoji font (e.g., Noto Color Emoji on Android, Apple Color Emoji on iOS). There is no custom styling, no conversion -- the emoji is stored as a raw Unicode string and rendered as text overlaid on the colored background circle.

The PNG icon (`CacheCategoryIcon`) has a tint mode -- when `colorTintCategoryIcon` is enabled in settings, the PNG is desaturated via `greyScale` color filter and then overlaid with the primary theme color. Emojis cannot be tinted this way since they render as text.

### Summary: No Emoji-to-Icon Conversion

There is absolutely NO mapping from emoji to icon. The system provides two independent paths:

1. **Pick a PNG** from 277 curated illustrations, searchable by English tags, with auto-suggested category names.
2. **Type an emoji** from the keyboard, which is stored and rendered as-is using the device's native emoji font.

The "magic" users perceive is simply that the PNG icon library is well-tagged and the auto-name suggestion ("apple.png" -> "Food") makes the experience feel intelligent.

---

## Investigation 2: Currency Exchange Rate System

### API Source

**Primary API:** [fawazahmed0/exchange-api](https://github.com/fawazahmed0/exchange-api) -- a free, open-source currency exchange rate API hosted on GitHub and served via jsDelivr CDN.

**Exact URL fetched:**

```
https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/usd.min.json
```

This endpoint returns ALL currency exchange rates relative to 1 USD as the base currency. The response format is:

```json
{
  "date": "2024-01-15",
  "usd": {
    "eur": 0.912345,
    "gbp": 0.789012,
    "inr": 83.123456,
    ...
  }
}
```

### Static Currency Metadata

A bundled asset file at `assets/static/generated/currencies.json` (2,895 lines, ~537 currency entries) provides metadata for each currency:

```json
{
  "aed": {
    "Currency": "Dirham",
    "Code": "AED",
    "Symbol": "د.إ",
    "CountryName": "United Arab Emirates",
    "CountryCode": "AE"
  },
  "btc": {
    "Currency": "Bitcoin",
    "Code": "BTC",
    "Symbol": "₿"
  },
  "1inch": {
    "Currency": "1inch",
    "Code": "1inch",
    "NotKnown": true
  }
}
```

This was generated by `assets/static/Convert.py`, which merges data from multiple sources:
- [manishtiwari25 gist](https://gist.github.com/manishtiwari25/d3984385b1cb200b98bcde6902671599) -- base currency list
- [crypto-currency-symbols](https://github.com/yonilevy/crypto-currency-symbols/blob/master/symbols.json) -- crypto symbols
- [ksafranski gist](https://gist.githubusercontent.com/ksafranski/2973986/raw/5fda5e87189b066e11c1bf80bbfbecb556cf2cc1/Common-Currency.json) -- common currency info
- [keeguon gist](https://gist.github.com/keeguon/2310008) -- country codes

The 537 entries include both fiat currencies (USD, EUR, INR, etc.) and cryptocurrencies (BTC, ETH, ADA, DOGE, etc.). Currencies without full metadata are marked with `"NotKnown": true`.

### Fetch Timing and Caching Strategy

**When rates are fetched:**

Exchange rates are fetched as part of `runAllCloudFunctions()` in `lib/widgets/navigationFramework.dart`. This runs:

1. On app startup (after `entireAppLoaded = true`).
2. On pull-to-refresh (via `pullDownToRefreshSync.dart`).
3. On manual sync trigger from the debug page.

The call chain is: `runAllCloudFunctions() -> ... -> getExchangeRates()`. It runs sequentially after cloud sync, email parsing, and backup creation.

**Caching strategy:**

Rates are cached in the `appStateSettings` global map under the key `"cachedCurrencyExchange"`. This is a `Map<dynamic, dynamic>` initialized as `{}` in `lib/struct/defaultPreferences.dart`:

```dart
"cachedCurrencyExchange": {},
```

The entire USD-relative rate map from the API response is stored:

```dart
Future<bool> getExchangeRates() async {
  Map<dynamic, dynamic> cachedCurrencyExchange = appStateSettings["cachedCurrencyExchange"];
  try {
    Uri url = Uri.parse(
        "https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/usd.min.json");
    dynamic response = await http.get(url);
    if (response.statusCode == 200) {
      cachedCurrencyExchange = json.decode(response.body)?["usd"];
    }
  } catch (e) {
    print("Error getting currency rates: " + e.toString());
    return false;
  }
  updateSettings("cachedCurrencyExchange", cachedCurrencyExchange,
    updateGlobalState: appStateSettings["cachedCurrencyExchange"].keys.length <= 0,
  );
  return true;
}
```

`appStateSettings` is persisted via SharedPreferences, so cached rates survive app restarts. There is **no TTL or staleness check** -- rates are simply overwritten on each successful fetch.

### Failure Handling

Minimal. The entire fetch is wrapped in a single `try/catch`:

```dart
catch (e) {
  print("Error getting currency rates: " + e.toString());
  return false;
}
```

On failure:
- The error is printed to the console.
- `false` is returned.
- The previously cached rates remain in `appStateSettings` and continue to be used.
- No retry logic. No user-facing error notification for rate fetch failures specifically.
- If the app has never successfully fetched rates (`cachedCurrencyExchange` is empty), the exchange rates page falls back to showing all currencies from the static `currenciesJSON` with a rate of `1`.

### Exchange Rate Conversion Logic

All conversions go through USD as the intermediary currency. From `lib/struct/currencyFunctions.dart`:

```dart
double amountRatioToPrimaryCurrency(AllWallets allWallets, String? walletCurrency, ...) {
  double exchangeRateFromUSDToTarget = getCurrencyExchangeRate(primaryWalletCurrency);
  double exchangeRateFromCurrentToUSD = 1 / getCurrencyExchangeRate(walletCurrency);
  return exchangeRateFromUSDToTarget * exchangeRateFromCurrentToUSD;
}
```

The formula is: `amount_in_target = amount_in_source * (USD_to_target / USD_to_source)`.

Since all rates are stored as "1 USD = X currency", converting from currency A to currency B is:
`rate = (USD_to_B) / (USD_to_A) = (USD_to_B) * (1 / USD_to_A)`

### Custom/Manual Exchange Rates

Yes, Cashew fully supports custom exchange rates alongside the API rates.

**Storage:** `appStateSettings["customCurrencyAmounts"]` -- a `Map<String, double>` initialized as `{}`.

**Priority logic in `getCurrencyExchangeRate()`:**

```dart
double getCurrencyExchangeRate(String? currencyKey, ...) {
  if (currencyKey == null || currencyKey == "") return 1;
  // 1. Custom rate takes priority
  if (appStateSettings["customCurrencyAmounts"]?[currencyKey] != null) {
    return appStateSettings["customCurrencyAmounts"][currencyKey].toDouble();
  }
  // 2. Fall back to cached API rate
  else if (appStateSettings["cachedCurrencyExchange"]?[currencyKey] != null) {
    return appStateSettings["cachedCurrencyExchange"][currencyKey].toDouble();
  }
  // 3. Default to 1 (no conversion)
  else {
    return 1;
  }
}
```

**Custom rate UI** (`lib/pages/exchangeRatesPage.dart`):

- Users can tap any currency in the exchange rates list to open a `SetCustomCurrency` popup.
- Custom rates are entered as "1 USD = X [currency]" -- always relative to USD, not the user's primary wallet currency.
- Setting a custom rate to 0 or empty removes it, reverting to the API rate.
- Users can also add entirely new custom currencies (not in the API) via an "Add Currency" button, stored in `appStateSettings["customCurrencies"]` as a `List<dynamic>`.
- When a custom rate is changed, `appStateKey.currentState?.refreshAppState()` is called to rebuild the entire app state.

**Important design note from the code comments:**

```dart
// This will convert the primary currency to the custom currency
// Issue: the selected currency may change, causing the custom currency to change
// That is why we only allow the user to set the exchange rate of USD! since it is our reference
// E.g. primary currency CAD, set custom currency of EUR to 5, then USD->CAD exchange rate
// changes when it's pulled (the CAD exchange rate entry), the exchange rate for EUR will change,
// since it references USD!
```

Custom rates are always stored as USD-relative to avoid chain-dependency issues when API rates update.

### Exchange Rate Page UI

The `ExchangeRates` page (`lib/pages/exchangeRatesPage.dart`):

- Shows a credit link: `AboutInfoBox(title: "exchange-rates-api", link: "https://github.com/fawazahmed0/exchange-api")`
- Displays "1 [PRIMARY_WALLET_CURRENCY]" as the header.
- Lists all currencies with their calculated rate relative to the primary wallet's currency.
- Custom currencies are visually distinguished with an outlined container and a delete button.
- Currencies with custom rates are highlighted with `secondaryContainer` background color.
- Search bar filters currencies by key, country name, or currency name.

### Full Pipeline Summary

```
App Launch / Pull-to-Refresh
  |
  v
runAllCloudFunctions()
  |
  v
getExchangeRates()
  |
  v
HTTP GET https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/usd.min.json
  |
  +-- Success (200): Parse JSON, extract "usd" map, store in appStateSettings["cachedCurrencyExchange"]
  +-- Failure: Print error, return false, keep stale cached rates
  |
  v
Rate Lookup (getCurrencyExchangeRate):
  1. Check customCurrencyAmounts[key] -> custom rate (highest priority)
  2. Check cachedCurrencyExchange[key] -> API rate
  3. Default to 1.0 (no conversion)
  |
  v
Conversion (amountRatioToPrimaryCurrency):
  USD as intermediary: rate = (USD->target) * (1 / USD->source)
```

---

## Key Takeaways for Variance SDS

### From the Icon System

1. The emoji and PNG icon paths are completely independent -- no conversion magic.
2. The tag-based search with auto-name suggestion is the clever UX that makes icon selection feel intelligent.
3. 277 curated PNG illustrations is a substantial library; each has ~10 search tags and a suggested category name.
4. Emoji rendering depends entirely on the device's native emoji font -- no custom rendering.
5. The tint/colorize feature only works on PNG icons (via `ColorFilter`), not emojis.
6. For non-English locales, the PNG tag search is hidden and emoji input is promoted as the primary path.

### From the Exchange Rate System

1. The fawazahmed0 API is free, requires no API key, and serves via jsDelivr CDN (high availability, global edge caching).
2. All rates are USD-relative. Cross-currency conversion always goes through USD as intermediary.
3. Caching is naive: overwrite on fetch, use stale on failure, no TTL, no freshness indicator.
4. Custom rates override API rates per-currency, stored as USD-relative to avoid chain dependencies.
5. The static `currencies.json` (537 entries including crypto) provides display metadata (symbol, country, name) independent of the exchange rate data.
6. No rate history is stored -- only the latest rates. No offline-first queue for rate requests.
7. Error handling is minimal: silent catch-and-continue with console logging only.
