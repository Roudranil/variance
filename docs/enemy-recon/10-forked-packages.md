# Forked Packages Analysis

Cashew forked and vendored three open-source Flutter packages (two as local copies, one as a GitHub fork) because the stock versions had bugs and missing features that were unsolvable without source-level modifications. This document catalogs every modification, why it was necessary, and what Variance should learn.

---

## 1. `sliding_sheet` v0.5.2 (Modified)

**Original package:** [`sliding_sheet` v0.5.2](https://pub.dev/packages/sliding_sheet) by BendixMa  
**Location:** `packages/sliding_sheet-0.5.2-modified/`  
**Status of original:** Last published 2021, abandoned (SDK constraint `>=2.12.0 <3.0.0`), incompatible with Dart 3+ without modification  
**Used in:** `lib/widgets/openBottomSheet.dart` -- the single entry point for ALL bottom sheets in the app

### What This Package Does

A drag-and-scroll bottom sheet that supports snapping to multiple extents (e.g., half-screen, full-screen), header/footer builders, backdrop interaction, parallax effects, and showing as both an inline widget and a modal dialog route.

### Modification 1: Impeller Rendering Engine Fix (Backdrop)

**Problem:** When Flutter 3.13 shipped with Impeller as the default rendering backend on iOS, the backdrop overlay stopped fading correctly. The original code used an unconstrained `Container` with `double.infinity` dimensions, which Impeller rendered incorrectly.

**Fix:** Replace infinite dimensions with explicit screen-size dimensions:

```dart
// BEFORE (stock v0.5.2)
child: Container(
  width: double.infinity,
  height: double.infinity,
  color: widget.backdropColor,
),

// AFTER (modified)
// Fixes backdrop not fading correctly when using Impeller (iOS - Flutter v3.13)
width: MediaQuery.sizeOf(context).width,
height: MediaQuery.sizeOf(context).height - 1,
color: widget.backdropColor,
```

The `-1` on height is intentional: it prevents a sub-pixel overlap that triggers rendering artifacts on some devices.

**Lesson for Variance:** Never rely on `double.infinity` for visual overlay dimensions. Always use explicit screen-size constraints, especially for anything that applies opacity or color overlays. Impeller handles unconstrained painting differently from Skia.

### Modification 2: Keyboard Dismiss Flickering Fix (Backdrop Opacity)

**Problem:** When a bottom sheet was dismissed while the keyboard was open, the sequence was: keyboard closes -> available height changes -> backdrop opacity recalculates -> backdrop flickers because the opacity briefly spikes then drops. This produced a visible flash.

**Fix:** Introduce a `maxOpacity` ceiling that locks the backdrop opacity at the moment dismissal begins:

```dart
// Added field
double? maxOpacity;

// In _buildBackdrop(), after calculating opacity:
if(dismissUnderway && maxOpacity==null) maxOpacity = opacity;
opacity = math.min(maxOpacity ?? 1, opacity);
```

Once dismissal starts, the opacity can only decrease (or stay the same), never spike above the level at the moment of dismiss initiation.

**Lesson for Variance:** Keyboard dismiss is a multi-frame event that changes `MediaQuery` constraints mid-animation. Any sheet/overlay that calculates visual properties from available height must guard against transient spikes during this transition.

### Modification 3: Accidental Auto-Dismiss on Keyboard Close

**Problem:** When a keyboard was dismissed (e.g., user taps outside a text field), the available height changed so rapidly that `_adjustSnapForIncomingConstraints` would calculate a new extent below `minExtent`, causing the sheet to auto-dismiss entirely instead of just re-snapping.

**Fix:** Two changes:
1. Guard the constraint adjustment with `dismissUnderway == false`:
```dart
if (previousHeight > 0.0 &&
        previousHeight != availableHeight &&
        state.isShown &&
        dismissUnderway == false // <-- ADDED: prevents unexpected behaviour when keyboard shrinks
    ) {
```
2. After recalculating, force a snap to at least `minExtent`:
```dart
// Fix accidental auto dismiss when keyboard dismissed/height changes too fast
snapToExtent(math.max(minExtent, currentExtent),
    velocity: 0, duration: const Duration(milliseconds: 100));
scrollTo(controller.offset,
    duration: const Duration(milliseconds: 100), curve: Curves.ease);
```

**Lesson for Variance:** Any bottom sheet that supports keyboard interaction MUST handle the height-change cascade when keyboards open/close. The sheet extent calculation and the keyboard dismiss are asynchronous -- you need explicit guards.

### Modification 4: Keyboard-Aware Dismiss Dialog

**Problem:** When dismissing a dialog while the keyboard was open, the sheet would pop the route before the keyboard finished closing, resulting in janky animations and sometimes a stuck overlay.

**Fix:** Modified `popDialog` to explicitly close the keyboard first and wait for it to fully retract:

```dart
Future<bool> popDialog(double velocity) async {
  dismissUnderway = true;
  final FocusScopeNode currentFocus = FocusScope.of(context);
  if (!currentFocus.hasPrimaryFocus ||
      MediaQuery.viewInsetsOf(context).bottom > 0) {
    currentFocus.unfocus();
    while (MediaQuery.viewInsetsOf(context).bottom > 0) {
      await Future.delayed(const Duration(milliseconds: 1), () {});
    }
  }
  snapToExtent(0.0, velocity: velocity);
  Navigator.pop(context);
  return true;
}
```

**Lesson for Variance:** Dismissing a route while a keyboard is open is a race condition. The keyboard close and the route pop compete for frame time. Always sequence them: close keyboard first, wait for `viewInsets.bottom == 0`, then pop.

### Modification 5: Deprecated API Migration to Flutter 3.x

**Problem:** The original package used deprecated `MediaQuery.of(context)` accessors that were removed or deprecated in Flutter 3.x.

**Fix:** Migrated throughout:
- `MediaQuery.of(context).viewPadding.top` -> `MediaQuery.viewPaddingOf(context).top`
- `MediaQuery.of(context).viewInsets.bottom` -> `MediaQuery.viewInsetsOf(context).bottom`
- `MediaQuery.of(context).size` -> `MediaQuery.sizeOf(context)`

These are more efficient too, as the specific variants only rebuild when that specific property changes, not when any MediaQuery property changes.

### Modification 6: Custom Scrollbar Support

**Problem:** The stock `ScrollSpec` had a `showScrollbar` boolean but hardcoded the scrollbar widget. Cashew needed to provide its own `ScrollbarWrap` widget.

**Fix:** Added a `scrollbar` callback to `ScrollSpec`:

```dart
// Added to ScrollSpec
final Widget Function(Widget child)? scrollbar;

// In _buildScrollView():
if (scrollSpec.showScrollbar && scrollSpec.scrollbar != null) {
  scrollView = scrollSpec.scrollbar!(scrollView);
}
```

Used in `openBottomSheet.dart`:
```dart
scrollSpec: ScrollSpec(
  overscroll: false,
  showScrollbar: showScrollbar,
  scrollbar: ((child) => ScrollbarWrap(child: child)),
),
```

**Lesson for Variance:** Bottom sheet scrollbar customization is a real need for finance apps with long transaction lists. Stock packages rarely expose this.

### Summary of All sliding_sheet Changes

| # | Change | Category | Original Bug/Limitation |
|---|--------|----------|------------------------|
| 1 | Impeller backdrop rendering | Bug fix | Infinite-dimension Container broken on Impeller |
| 2 | maxOpacity during dismiss | Bug fix | Backdrop flickers when keyboard closes during dismiss |
| 3 | Auto-dismiss guard | Bug fix | Sheet auto-dismisses when keyboard closes too fast |
| 4 | Keyboard-first dismiss | Bug fix | Route pops before keyboard finishes closing |
| 5 | MediaQuery API migration | Maintenance | Deprecated APIs in Flutter 3.x |
| 6 | Custom scrollbar callback | Feature | No way to provide custom scrollbar widget |

---

## 2. `implicitly_animated_reorderable_list` v0.4.2 (Modified)

**Original package:** [`implicitly_animated_reorderable_list` v0.4.2](https://pub.dev/packages/implicitly_animated_reorderable_list) by BendixMa  
**Location:** `packages/implicitly_animated_reorderable_list-0.4.2-modified/`  
**Status of original:** Last published 2021, abandoned (SDK constraint `>=2.12.0 <3.0.0`)  
**Used in:** `lib/widgets/transactionEntries.dart`, `lib/pages/upcomingOverdueTransactionsPage.dart`, `lib/pages/creditDebtTransactionsPage.dart`

### What This Package Does

A `ListView` that implicitly calculates diffs between two lists using the Myers diff algorithm and animates insertions, removals, and reorders. Provides both `ImplicitlyAnimatedList` (basic animated list) and `ImplicitlyAnimatedReorderableList` (with drag-to-reorder support via `Handle` and `Reorderable` widgets).

### Modification 1: Null-Safe Index Access (getOrNull)

**Problem:** The `SliverImplicitlyAnimatedList` accessed `data[index]` directly during the item builder callback. When the diff algorithm was mid-computation and the list length changed asynchronously, this would throw a `RangeError` and crash the app.

**Fix:** Added a `getOrNull` extension method and a cascade fallback:

```dart
// In _SliverImplicitlyAnimatedListState.build():
final E? item = data.getOrNull(index) ??
    newList.getOrNull(index) ??
    oldList.getOrNull(index);

if (item == null) {
  return Container(); // graceful fallback instead of crash
}
```

The `getOrNull` extension in `util.dart`:
```dart
extension ListExtension<E> on List<E> {
  E? getOrNull(int index) {
    try {
      return this[index];
    } on Error {
      return null;
    } on Exception {
      return null;
    }
  }
}
```

**Lesson for Variance:** When using diff-based animated lists, the diff computation is asynchronous (can even run on isolates). The builder callback can be called with stale indices during the transition. Always guard index access.

### Modification 2: Dart 3 / Flutter 3.x Compatibility

**Problem:** SDK constraint `>=2.12.0 <3.0.0` prevented use with Dart 3. Various deprecated APIs needed updating.

**Fix:** Updated SDK constraints (implicitly, by vendoring), migrated deprecated widget APIs, and ensured null-safety patterns were compatible with Dart 3.

### How Cashew Uses This Package

The package is used in three distinct patterns:

1. **`SliverImplicitlyAnimatedList`** -- For transaction lists that animate when transactions are added/removed/filtered. Used in `transactionEntries.dart`, `upcomingOverdueTransactionsPage.dart`, and `creditDebtTransactionsPage.dart`.

2. **`ImplicitlyAnimatedList`** -- For simpler animated lists (non-sliver contexts) in `transactionEntries.dart`.

3. **Reorderable variant is NOT used directly** -- Cashew does NOT use the `ImplicitlyAnimatedReorderableList` from this package for its reorder functionality. Instead, it uses a completely separate modified `SliverReorderableList` (see Package 3 below). The package was forked primarily for the animated diff list, not the reorder part.

---

## 3. Flutter's `SliverReorderableList` (Copied and Modified)

**Original source:** Flutter SDK's `widgets/reorderable_list.dart`  
**Location:** `lib/modified/reorderable_list.dart` (1,446 lines)  
**Used in:** 12+ files across the app (every page that needs reorderable lists)

### What This Is

This is a full copy of Flutter's built-in `SliverReorderableList` and `ReorderableList` widgets, extracted from the framework source code and modified. The app hides Flutter's built-in versions:

```dart
import 'package:flutter/material.dart' hide SliverReorderableList;
import 'package:budget/modified/reorderable_list.dart';
```

This hiding pattern appears in 12+ files throughout the codebase, confirming this is a deliberate, app-wide replacement.

### Modification 1: Async ReorderCallback with Cancellation

**The single most important change.** Flutter's stock `ReorderCallback` is synchronous and void:

```dart
// Flutter stock
typedef ReorderCallback = void Function(int oldIndex, int newIndex);
```

Cashew's modified version makes it async and returns a bool:

```dart
// Modified
typedef ReorderCallback = Future<bool> Function(int oldIndex, int newIndex);
```

The `_dropCompleted` method was changed to await the callback:

```dart
void _dropCompleted() async {
  final int fromIndex = _dragIndex!;
  final int toIndex = _insertIndex!;
  if (fromIndex != toIndex) {
    await widget.onReorder.call(fromIndex, toIndex);
  }
  setState(() {
    _dragReset();
  });
}
```

**Why this matters:** In a finance app, reordering items must persist to the database. The stock callback fires-and-forgets, meaning the UI resets before the database write completes. If the database write fails, the UI has already moved on. With the async version, the UI waits for confirmation before resetting the drag state.

**Lesson for Variance:** Any reorderable list where the order persists to a database needs the reorder callback to be async. Flutter's stock `ReorderCallback` is inadequate for data-driven apps. We will need to either use a package that supports async reorder, or fork/wrap the built-in widget.

### Modification 2: Null-Safe Proxy Animation Guard

**Problem:** When a drag was cancelled quickly (e.g., user taps and releases very fast), `_proxyAnimation` could be null when `createProxy` was called, causing a null dereference crash.

**Fix:**

```dart
Widget createProxy(BuildContext context) {
  return capturedThemes.wrap(
    _proxyAnimation == null
        ? SizedBox.shrink()  // <-- guard: return empty widget if animation was disposed
        : _DragItemProxy(
            listState: listState,
            index: index,
            // ...
          ),
  );
}
```

**Lesson for Variance:** Drag gesture state machines have race conditions between pointer-up events and animation disposal. Always guard animation references with null checks in proxy builders.

### The Bridge Widget: `ImplicitlyAnimatedDeleteSliverReorderableList`

Cashew built an additional wrapper widget at `lib/widgets/util/implicitlyAnimatedDeleteSliverReorderableList.dart` that combines the modified `SliverReorderableList` with animated deletion. This widget:

1. Wraps each item in an `AnimatedExpanded` widget
2. Tracks which index is being deleted
3. Plays a collapse animation before actually removing the item from the data list
4. Coordinates with the parent's stream rebuilds by delaying data updates until the animation completes

This represents a custom solution to a problem neither Flutter's stock widgets nor any package solves: a sliver-compatible list that supports BOTH drag-to-reorder AND animated item deletion with proper animation sequencing.

---

## 4. `reorderable_grid_view` (GitHub Fork)

**Original package:** [`reorderable_grid_view`](https://pub.dev/packages/reorderable_grid_view)  
**Fork:** `https://github.com/jameskokoska/reorderable_grid_view`  
**Used in:** `lib/widgets/selectCategory.dart` -- the category picker grid

### What This Package Does

Provides a grid view where items can be dragged and reordered, used for the category selection grid where users can long-press and rearrange their expense categories.

### Why It Was Forked

The fork is maintained by the Cashew developer (jameskokoska). Given the pattern with the other packages, the fork likely addresses:

1. **Dart 3 compatibility** -- the original package has SDK constraints that may not support Dart 3
2. **Integration with the modified `SliverReorderableList`** -- Cashew hides Flutter's built-in `SliverReorderableList` and `ReorderableDelayedDragStartListener` app-wide in files that use this widget:
```dart
import 'package:flutter/material.dart'
    hide SliverReorderableList, ReorderableDelayedDragStartListener;
```
3. **Async reorder callback** -- consistent with the modified `ReorderCallback` typedef used throughout the app

---

## 5. `flutter_file_picker` (Third-Party Fork)

**Fork:** `https://github.com/melWiss/flutter_file_picker.git`  
**Original issue:** [flutter_file_picker#1404](https://github.com/miguelpruivo/flutter_file_picker/issues/1404)

Referenced in `pubspec.yaml`:
```yaml
file_picker:
  git:
    # This fork implements https://github.com/miguelpruivo/flutter_file_picker/issues/1404
    url: https://github.com/melWiss/flutter_file_picker.git
```

This is a bug-fix fork for a file picker issue, not a UI package fork. Included here for completeness.

---

## Cross-Cutting Themes

### Theme 1: Abandoned Packages Are the Norm

All three UI packages were last published in 2021 with Dart 2 SDK constraints. They are effectively abandoned. Cashew had no choice but to vendor them because:
- No Dart 3 support
- No Impeller support
- No Flutter 3.x MediaQuery API support
- Known bugs will never be fixed upstream

**Variance takeaway:** Never depend on a package with SDK constraints below `>=3.0.0` for core UI. If we must use a community package for critical UI, prefer packages that are actively maintained (published within 6 months) or be prepared to vendor and maintain.

### Theme 2: Keyboard Interaction Is the Hardest Problem

Four of the six `sliding_sheet` modifications are keyboard-related. The interaction between:
- Keyboard open/close changing `MediaQuery.viewInsets`
- Sheet extent recalculation
- Animation state during dismissal
- Route popping timing

...creates a combinatorial explosion of edge cases that no stock package handles correctly.

**Variance takeaway:** Our bottom sheet implementation must be keyboard-aware from day one. This is not a "nice to have" fix -- it is a P0 requirement for any sheet that contains text input fields (which in a finance app means transaction entry, search, notes, etc.).

### Theme 3: Async Reorder Is Essential for Data-Driven Apps

Flutter's built-in `ReorderCallback` is `void Function(int, int)` -- synchronous and fire-and-forget. This is fine for purely UI state but inadequate when the reorder must persist to a database. Cashew copied 1,446 lines of Flutter framework code and modified exactly one typedef to make this work.

**Variance takeaway:** We need async reorder support. Options:
1. Use a package that supports async callbacks natively
2. Wrap Flutter's built-in widget with an async bridge
3. Build our own reorderable sliver (most control, most effort)

### Theme 4: Animated Lists + Reorder + Delete = Unsolved

No single package provides: animated list diffing + drag-to-reorder + animated item deletion + sliver compatibility. Cashew needed all four and ended up combining:
- Modified `implicitly_animated_reorderable_list` (for animated diffing)
- Modified `SliverReorderableList` from Flutter SDK (for reorder)
- Custom `ImplicitlyAnimatedDeleteSliverReorderableList` (bridge widget)

**Variance takeaway:** This is an area where we should evaluate the current Flutter ecosystem carefully before building. If no package solves this cleanly in 2026, we may need to build a custom sliver that handles all three concerns natively rather than layering three separate solutions.

### Theme 5: Impeller Changes Everything

The Impeller rendering engine (default on iOS since Flutter 3.13, coming to Android) handles edge cases differently from Skia:
- Infinite-dimension containers render differently
- Sub-pixel overlaps cause artifacts
- Opacity/color overlay compositing behaves differently

**Variance takeaway:** All visual overlay code (backdrop dimming, sheet shadows, modal barriers) must be tested on Impeller from day one. Do not assume Skia behavior.

---

## Package Status Summary

| Package | Original Version | Last Published | Dart 3 Ready | Actively Maintained | Cashew Action |
|---------|-----------------|----------------|--------------|--------------------|--------------| 
| `sliding_sheet` | 0.5.2 | 2021 | No | No (abandoned) | Vendored + 6 modifications |
| `implicitly_animated_reorderable_list` | 0.4.2 | 2021 | No | No (abandoned) | Vendored + 2 modifications |
| `reorderable_list` (Flutter SDK) | N/A | N/A | Yes | Yes (part of Flutter) | Copied + 2 modifications |
| `reorderable_grid_view` | Unknown | Unknown | Unknown | Fork by app developer | GitHub fork |
| `flutter_file_picker` | Unknown | Active | Yes | Yes | GitHub fork for bug #1404 |

---

## Recommendations for Variance

1. **Bottom sheets:** Evaluate [`wolt_modal_sheet`](https://pub.dev/packages/wolt_modal_sheet) or build a custom solution. Do NOT depend on `sliding_sheet` or any abandoned package. Keyboard interaction must be first-class.

2. **Animated lists:** Evaluate whether Flutter's stock `AnimatedList`/`SliverAnimatedList` (significantly improved since 2021) plus a diff algorithm (or [`diffutil_dart`](https://pub.dev/packages/diffutil_dart)) can replace the vendored package.

3. **Reorderable lists:** Consider wrapping Flutter's built-in `SliverReorderableList` with an async bridge layer rather than copying the full source. The modification surface is small (one typedef change + one null guard).

4. **Combined animated-reorder-delete:** This is the hardest problem. Plan for custom implementation if no package solves it. Budget engineering time accordingly.

5. **Test on Impeller from day one.** Run `flutter run --enable-impeller` on every visual component during development.
