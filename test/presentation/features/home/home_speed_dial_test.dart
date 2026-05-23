// test/presentation/features/home/home_speed_dial_test.dart
//
// Widget tests for HomeSpeedDial (T-165, T-166).
//
// Test cases:
//   T-165.1  Three actions (Expense, Income, Transfer) render when expanded
//   T-165.2  Scrim tap collapses the dial back to single FAB
//   T-165.3  Expense / Income / Transfer actions fire correct callbacks
//   T-165.4  FAB hidden (Visibility.visible=false) while search is active
//   T-166.1  Drafts action present when back_button_behaviour = auto_save_draft
//   T-166.2  Drafts action absent when back_button_behaviour != auto_save_draft

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:variance/domain/entities/app_settings.dart';
import 'package:variance/presentation/features/home/widgets/home_speed_dial.dart';
import 'package:variance/presentation/providers/app_settings_providers.dart';
import 'package:variance/presentation/providers/search_providers.dart';

// ---------------------------------------------------------------------------
// Fake notifiers
// ---------------------------------------------------------------------------

class _FakeSearchNotifier extends SearchNotifier {
  @override
  SearchState build() => const SearchState();

  void setActive(bool active) {
    state = state.copyWith(isActive: active);
  }
}

class _FakeAppSettingsNotifier extends AppSettingsNotifier {
  final BackButtonBehaviour behaviour;

  _FakeAppSettingsNotifier({
    this.behaviour = BackButtonBehaviour.ask,
  });

  @override
  Future<AppSettings> build() async =>
      AppSettings(backButtonBehaviour: behaviour);
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildApp({
  _FakeSearchNotifier? searchNotifier,
  _FakeAppSettingsNotifier? settingsNotifier,
  VoidCallback? onExpense,
  VoidCallback? onIncome,
  VoidCallback? onTransfer,
  VoidCallback? onDrafts,
}) {
  final sn = searchNotifier ?? _FakeSearchNotifier();
  final an = settingsNotifier ?? _FakeAppSettingsNotifier();

  return ProviderScope(
    overrides: [
      searchProvider.overrideWith(() => sn),
      appSettingsProvider.overrideWith(() => an),
    ],
    child: MaterialApp(
      home: Scaffold(
        // Wrap in a Stack so the Positioned scrim has a bounded parent.
        body: Stack(children: [const SizedBox.expand()]),
        floatingActionButton: HomeSpeedDial(
          onExpense: onExpense ?? () {},
          onIncome: onIncome ?? () {},
          onTransfer: onTransfer ?? () {},
          onDrafts: onDrafts ?? () {},
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('HomeSpeedDial T-165', () {
    testWidgets('T-165.1 Three actions render when expanded', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      // Tap the collapsed FAB to expand.
      await tester.tap(find.byKey(const Key('fab_collapsed')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('fab_expense')), findsOneWidget);
      expect(find.byKey(const Key('fab_income')), findsOneWidget);
      expect(find.byKey(const Key('fab_transfer')), findsOneWidget);
    });

    testWidgets('T-165.2 Scrim tap collapses the dial', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      // Expand.
      await tester.tap(find.byKey(const Key('fab_collapsed')));
      await tester.pumpAndSettle();

      // The collapse FAB and scrim should now be visible.
      expect(find.byKey(const Key('speed_dial_scrim')), findsOneWidget);

      // Tap the scrim.
      await tester.tap(find.byKey(const Key('speed_dial_scrim')));
      await tester.pumpAndSettle();

      // Back to collapsed single FAB.
      expect(find.byKey(const Key('fab_collapsed')), findsOneWidget);
      expect(find.byKey(const Key('fab_expense')), findsNothing);
    });

    testWidgets('T-165.3 Expense action fires callback', (tester) async {
      var tapped = '';
      await tester.pumpWidget(_buildApp(
        onExpense: () => tapped = 'expense',
        onIncome: () => tapped = 'income',
        onTransfer: () => tapped = 'transfer',
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('fab_collapsed')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('fab_expense')));
      await tester.pump();

      expect(tapped, 'expense');
    });

    testWidgets('T-165.3 Income action fires callback', (tester) async {
      var tapped = '';
      await tester.pumpWidget(_buildApp(
        onExpense: () => tapped = 'expense',
        onIncome: () => tapped = 'income',
        onTransfer: () => tapped = 'transfer',
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('fab_collapsed')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('fab_income')));
      await tester.pump();

      expect(tapped, 'income');
    });

    testWidgets('T-165.3 Transfer action fires callback', (tester) async {
      var tapped = '';
      await tester.pumpWidget(_buildApp(
        onExpense: () => tapped = 'expense',
        onIncome: () => tapped = 'income',
        onTransfer: () => tapped = 'transfer',
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('fab_collapsed')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('fab_transfer')));
      await tester.pump();

      expect(tapped, 'transfer');
    });

    testWidgets('T-165.4 FAB hidden while search is active', (tester) async {
      final sn = _FakeSearchNotifier();
      await tester.pumpWidget(_buildApp(searchNotifier: sn));
      await tester.pump();

      // FAB visible when search inactive.
      expect(
        tester
            .widget<Visibility>(
              find.ancestor(
                of: find.byKey(const Key('fab_collapsed')),
                matching: find.byType(Visibility),
              ),
            )
            .visible,
        isTrue,
      );

      // Activate search.
      sn.setActive(true);
      await tester.pump();

      // Visibility should be false; the FAB widget subtree not rendered.
      final visibility = tester.widget<Visibility>(
        find.byType(Visibility),
      );
      expect(visibility.visible, isFalse);
    });
  });

  group('HomeSpeedDial T-166', () {
    testWidgets('T-166.1 Drafts action present when auto_save_draft',
        (tester) async {
      final an = _FakeAppSettingsNotifier(
        behaviour: BackButtonBehaviour.autoSaveDraft,
      );
      await tester.pumpWidget(_buildApp(settingsNotifier: an));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('fab_collapsed')));
      await tester.pump();

      expect(find.byKey(const Key('fab_drafts')), findsOneWidget);
    });

    testWidgets('T-166.2 Drafts action absent when not auto_save_draft',
        (tester) async {
      final an = _FakeAppSettingsNotifier(
        behaviour: BackButtonBehaviour.ask,
      );
      await tester.pumpWidget(_buildApp(settingsNotifier: an));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('fab_collapsed')));
      await tester.pump();

      expect(find.byKey(const Key('fab_drafts')), findsNothing);
    });

    testWidgets('T-166.1 Drafts action fires callback', (tester) async {
      var tapped = false;
      final an = _FakeAppSettingsNotifier(
        behaviour: BackButtonBehaviour.autoSaveDraft,
      );
      await tester.pumpWidget(_buildApp(
        settingsNotifier: an,
        onDrafts: () => tapped = true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('fab_collapsed')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('fab_drafts')));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });
  });
}
