---
paths:
    - "**/*.dart"
    - "**/pubspec.yaml"
    - "**/analysis_options.yaml"
---

# Dart coding review checklist

When writing dart code, always make sure below items are followed thoroughly.

### Architecture (CRITICAL)

- **Business logic in widgets** — complex logic belongs in state/service layer, not in `build()` or callbacks
- **Cross-layer imports** — inner layers must not depend on outer layers; domain must not import Flutter
- **Circular dependencies** — package A depends on B and B depends on A
- **Private `src/` imports across packages** — breaks Dart package encapsulation
- **Direct API/DB calls from widgets** — must go through repository/service layer
- **Missing abstractions at layer boundaries** — concrete classes imported across layers

### State Management (CRITICAL)

- **Boolean flag soup** — `isLoading`/`isError`/`hasData` as separate fields; use sealed types or enums
- **Non-exhaustive state handling** — all state variants must be handled
- **Subscribing in `build()`** — never call `.listen()` inside build; use `ListenableBuilder`/`ValueListenableBuilder`
- **Stream/subscription leaks** — all subscriptions must be cancelled in `dispose()`
- **Missing error/loading states** — every async operation must model loading, success, and error

### Widget Composition (HIGH)

- **Oversized `build()`** — exceeding ~80 lines; extract subtrees to separate widget classes
- **`_build*()` helper methods** — extract to classes, not private helper methods
- **Missing `const` constructors** — widgets with all-final fields must declare `const`
- **`StatefulWidget` overuse** — prefer `StatelessWidget` when no mutable local state is needed
- **Missing `key` in list items** — `ListView.builder` items without stable `ValueKey` cause state bugs
- **Hardcoded colors/text styles** — use `Theme.of(context).colorScheme`/`textTheme`
- **Hardcoded spacing** — use design tokens or named constants over magic numbers

### Performance (HIGH)

- **Unnecessary rebuilds** — state consumers wrapping too much tree; narrow scope
- **Expensive work in `build()`** — sorting, filtering, I/O in build; compute in state layer
- **`MediaQuery.of(context)` overuse** — use specific accessors (`MediaQuery.sizeOf(context)`)
- **Concrete list constructors for large data** — use `ListView.builder`/`GridView.builder`
- **Missing image optimization** — no caching, no `cacheWidth`/`cacheHeight`
- **`Opacity` in animations** — use `AnimatedOpacity` or `FadeTransition`
- **`IntrinsicHeight`/`IntrinsicWidth` overuse** — cause extra layout passes; avoid in scrollable lists
- **Missing `const` propagation** — `const` widgets stop rebuild propagation; use wherever possible

### Dart Idioms (MEDIUM)

- **Missing type annotations / implicit `dynamic`**
- **`!` bang overuse** — prefer `?.`, `??`, `case var v?`
- **`var` where `final` works** — prefer `final` for locals, `const` for compile-time constants
- **Relative imports** — use `package:` imports only
- **`print()` in production** — use `dart:developer` `log()`
- **`late` overuse** — prefer nullable types or constructor initialization
- **Ignoring `Future` return values** — use `await` or `unawaited()`
- **Unused `async`** — functions marked `async` that never `await`
- **Mutable collections exposed** — public APIs should return unmodifiable views

### Resource Lifecycle (HIGH)

- **Missing `dispose()`** — every resource from `initState()` must be disposed
- **`BuildContext` used after `await`** — check `context.mounted` before navigation/dialogs after async gaps
- **`setState` after `dispose`** — async callbacks must check `mounted`
- **`BuildContext` stored in long-lived objects** — never store in singletons or static fields
- **Unclosed `StreamController` / `Timer` not cancelled** — must be cleaned up in `dispose()`

### Error Handling (HIGH)

- **Missing global error capture** — both `FlutterError.onError` and `PlatformDispatcher.instance.onError` must be set
- **Red screen in production** — `ErrorWidget.builder` not customized for release mode
- **Raw exceptions reaching UI** — map to user-friendly messages before presentation layer

### Testing (HIGH)

- **Missing unit tests** — state manager changes must have tests
- **Missing widget tests** — new/changed widgets must have widget tests
- **Missing golden tests** — design-critical components must have pixel-perfect regression tests
- **Untested state transitions** — all paths (loading→success, loading→error, empty, retry) must be tested
- **Flaky async tests** — use `pumpAndSettle` or explicit `pump(Duration)`, not timing assumptions

### Accessibility (MEDIUM)

- **Missing semantic labels** — images without `semanticLabel`, icons without `tooltip`
- **Small tap targets** — interactive elements below 48×48 pixels
- **Color-only indicators** — color alone conveying meaning without icon/text alternative
- **Text scaling ignored** — hardcoded sizes that don't respect system accessibility settings

### Platform & Navigation (MEDIUM)

- **Missing `SafeArea`** — content obscured by notches/status bars
- **Mixed navigation patterns** — `Navigator.push` mixed with GoRouter; use GoRouter only
- **Hardcoded route paths** — use route constants
- **Missing deep link validation** — URLs not sanitized before navigation
- **Missing auth guards** — protected routes accessible without redirect

### Security (CRITICAL)

- **Hardcoded secrets** — API keys, tokens, or credentials in Dart source
- **Insecure storage** — sensitive data in plaintext instead of Keychain/EncryptedSharedPreferences
- **Sensitive logging** — tokens, PII, or credentials in `print()`/`debugPrint()`
- **Missing input validation** — user input passed to APIs/navigation without sanitization
