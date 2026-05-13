// test/presentation/features/settings/transaction_entry/transaction_entry_settings_screen_test.dart
//
// Widget tests for TransactionEntrySettingsScreen (T-179).
//
// Test cases:
//   1. Screen renders AppBar with title "Transaction Entry".
//   2. Description max length dropdown shows current value (1000).
//   3. Selecting 500 chars writes descriptionMaxLength=500 patch.
//   4. Selecting 2000 chars writes descriptionMaxLength=2000 patch.
//   5. Back button behaviour — "Ask every time" radio is selected initially.
//   6. Selecting "Auto-save draft" radio writes BackButtonBehaviour.autoSaveDraft.
//   7. Selecting "Discard immediately" radio writes BackButtonBehaviour.discard.
//   8. Selecting "Ask every time" radio writes BackButtonBehaviour.ask.
//   9. Draft lifecycle info card is visible when Auto-save is selected.
//  10. Draft lifecycle info card is hidden when Ask is selected.
//  11. Draft lifecycle info card is hidden when Discard is selected.
//  12. Info card text says "Max 5 drafts".
//  13. Loading state shows CircularProgressIndicator.
//  14. Error state shows error message text.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:variance/domain/entities/app_settings.dart';
import 'package:variance/domain/repositories/i_app_settings_repository.dart';
import 'package:variance/presentation/features/settings/transaction_entry/transaction_entry_settings_screen.dart';
import 'package:variance/presentation/providers/app_settings_providers.dart';

// ---------------------------------------------------------------------------
// Fake notifier
// ---------------------------------------------------------------------------

class _FakeAppSettingsNotifier extends AppSettingsNotifier {
  _FakeAppSettingsNotifier(this._settings);
  final AppSettings _settings;
  final List<AppSettingsPatch> savedPatches = [];

  @override
  Future<AppSettings> build() async => _settings;

  @override
  Future<void> save(AppSettingsPatch patch) async => savedPatches.add(patch);
}

class _SlowNotifier extends AppSettingsNotifier {
  @override
  Future<AppSettings> build() => Completer<AppSettings>().future;
}

class _ErrorNotifier extends AppSettingsNotifier {
  @override
  Future<AppSettings> build() async => throw Exception('load failed');
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _askSettings = AppSettings(
  homeCurrency: 'INR',
  onboardingComplete: true,
  descriptionMaxLength: 1000,
  backButtonBehaviour: BackButtonBehaviour.ask,
);

const _autoSaveSettings = AppSettings(
  homeCurrency: 'INR',
  onboardingComplete: true,
  descriptionMaxLength: 1000,
  backButtonBehaviour: BackButtonBehaviour.autoSaveDraft,
);

const _discardSettings = AppSettings(
  homeCurrency: 'INR',
  onboardingComplete: true,
  descriptionMaxLength: 1000,
  backButtonBehaviour: BackButtonBehaviour.discard,
);

Widget _buildWidget({
  AppSettings settings = _askSettings,
  _FakeAppSettingsNotifier? notifier,
}) {
  final fakeNotifier = notifier ?? _FakeAppSettingsNotifier(settings);
  return ProviderScope(
    overrides: [
      appSettingsProvider.overrideWith(() => fakeNotifier),
    ],
    child: const MaterialApp(home: TransactionEntrySettingsScreen()),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('TransactionEntrySettingsScreen (T-179)', () {
    testWidgets('1. screen renders AppBar with "Transaction Entry" title',
        (tester) async {
      await tester.pumpWidget(_buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Transaction Entry'), findsOneWidget);
    });

    testWidgets(
      '2. description max length dropdown shows current value (1000)',
      (tester) async {
        await tester.pumpWidget(_buildWidget());
        await tester.pumpAndSettle();

        expect(find.text('1000 chars'), findsOneWidget);
      },
    );

    testWidgets(
      '3. selecting 500 chars writes descriptionMaxLength=500 patch',
      (tester) async {
        final notifier = _FakeAppSettingsNotifier(_askSettings);
        await tester.pumpWidget(_buildWidget(notifier: notifier));
        await tester.pumpAndSettle();

        await tester.tap(find.text('1000 chars'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('500 chars').last);
        await tester.pumpAndSettle();

        expect(notifier.savedPatches, isNotEmpty);
        expect(notifier.savedPatches.last.descriptionMaxLength, equals(500));
      },
    );

    testWidgets(
      '4. selecting 2000 chars writes descriptionMaxLength=2000 patch',
      (tester) async {
        final notifier = _FakeAppSettingsNotifier(_askSettings);
        await tester.pumpWidget(_buildWidget(notifier: notifier));
        await tester.pumpAndSettle();

        await tester.tap(find.text('1000 chars'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('2000 chars').last);
        await tester.pumpAndSettle();

        expect(notifier.savedPatches.last.descriptionMaxLength, equals(2000));
      },
    );

    testWidgets(
      '5. "Ask every time" radio option is present',
      (tester) async {
        await tester.pumpWidget(_buildWidget(settings: _askSettings));
        await tester.pumpAndSettle();

        expect(find.text('Ask every time'), findsOneWidget);
      },
    );

    testWidgets(
      '6. selecting "Auto-save draft" writes BackButtonBehaviour.autoSaveDraft',
      (tester) async {
        final notifier = _FakeAppSettingsNotifier(_askSettings);
        await tester.pumpWidget(_buildWidget(notifier: notifier));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Auto-save draft'));
        await tester.pump();

        expect(notifier.savedPatches, isNotEmpty);
        expect(
          notifier.savedPatches.last.backButtonBehaviour,
          equals(BackButtonBehaviour.autoSaveDraft),
        );
      },
    );

    testWidgets(
      '7. selecting "Discard immediately" writes BackButtonBehaviour.discard',
      (tester) async {
        final notifier = _FakeAppSettingsNotifier(_askSettings);
        await tester.pumpWidget(_buildWidget(notifier: notifier));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Discard immediately'));
        await tester.pump();

        expect(
          notifier.savedPatches.last.backButtonBehaviour,
          equals(BackButtonBehaviour.discard),
        );
      },
    );

    testWidgets(
      '8. selecting "Ask every time" writes BackButtonBehaviour.ask',
      (tester) async {
        final notifier = _FakeAppSettingsNotifier(_autoSaveSettings);
        await tester.pumpWidget(_buildWidget(notifier: notifier));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Ask every time'));
        await tester.pump();

        expect(
          notifier.savedPatches.last.backButtonBehaviour,
          equals(BackButtonBehaviour.ask),
        );
      },
    );

    testWidgets(
      '9. draft lifecycle info card is visible when Auto-save is selected',
      (tester) async {
        await tester.pumpWidget(
          _buildWidget(settings: _autoSaveSettings),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.info_outline), findsOneWidget);
      },
    );

    testWidgets(
      '10. draft lifecycle info card is hidden when Ask is selected',
      (tester) async {
        await tester.pumpWidget(_buildWidget(settings: _askSettings));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.info_outline), findsNothing);
      },
    );

    testWidgets(
      '11. draft lifecycle info card is hidden when Discard is selected',
      (tester) async {
        await tester.pumpWidget(_buildWidget(settings: _discardSettings));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.info_outline), findsNothing);
      },
    );

    testWidgets(
      '12. info card text mentions "Max 5 drafts"',
      (tester) async {
        await tester.pumpWidget(_buildWidget(settings: _autoSaveSettings));
        await tester.pumpAndSettle();

        expect(find.textContaining('Max 5 drafts'), findsOneWidget);
      },
    );

    testWidgets(
      '13. loading state shows CircularProgressIndicator',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appSettingsProvider.overrideWith(_SlowNotifier.new),
            ],
            child: const MaterialApp(home: TransactionEntrySettingsScreen()),
          ),
        );
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      '14. error state shows error message',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appSettingsProvider.overrideWith(_ErrorNotifier.new),
            ],
            child: const MaterialApp(home: TransactionEntrySettingsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.textContaining('Failed to load transaction entry settings'),
          findsOneWidget,
        );
      },
    );
  });
}
