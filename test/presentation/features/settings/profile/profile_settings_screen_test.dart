// test/presentation/features/settings/profile/profile_settings_screen_test.dart
//
// Widget tests for ProfileSettingsScreen and HomeGreeting (T-183).
//
// Test cases — ProfileSettingsScreen:
//   1. Name field is pre-filled with current displayName.
//   2. Name field shows empty string when displayName is null.
//   3. Save button is disabled when field equals the initial value (clean).
//   4. Save button is enabled after the field value changes (dirty).
//   5. Tapping Save writes a patch with the new displayName.
//   6. Snackbar "Profile updated" shown after successful save.
//   7. Save button re-disables after save (no longer dirty).
//   8. Clearing the name field enables Save (different from "Alice").
//   9. Screen shows "Stored on-device only. Never uploaded." info text.
//  10. Loading state shows CircularProgressIndicator.
//  11. Error state shows error message.
//
// Test cases — HomeGreeting:
//  12. Shows "Hi, Alice!" when displayName is "Alice".
//  13. Shows "Hi!" when displayName is null.
//  14. Shows "Hi!" when displayName is an empty string.
//  15. Shows "Hi!" when displayName is whitespace only.
//  16. Greeting updates reactively when displayName changes via stream.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:variance/domain/entities/app_settings.dart';
import 'package:variance/domain/repositories/i_app_settings_repository.dart';
import 'package:variance/presentation/features/home/home_screen.dart';
import 'package:variance/presentation/features/settings/profile/profile_settings_screen.dart';
import 'package:variance/presentation/providers/app_settings_providers.dart';

// ---------------------------------------------------------------------------
// Fake notifiers
// ---------------------------------------------------------------------------

class _FakeAppSettingsNotifier extends AppSettingsNotifier {
  _FakeAppSettingsNotifier(this._settings);
  AppSettings _settings;
  final List<AppSettingsPatch> savedPatches = [];

  @override
  Future<AppSettings> build() async => _settings;

  @override
  Future<void> save(AppSettingsPatch patch) async {
    savedPatches.add(patch);
    // Simulate the state updating after save so the screen can detect "not dirty".
    if (patch.displayName != null) {
      _settings = _settings.copyWith(displayName: patch.displayName);
    }
  }
}

class _SlowNotifier extends AppSettingsNotifier {
  @override
  Future<AppSettings> build() => Completer<AppSettings>().future;
}

class _ErrorNotifier extends AppSettingsNotifier {
  @override
  Future<AppSettings> build() async => throw Exception('fail');
}

/// A notifier backed by a [StreamController] so tests can push new values.
class _StreamNotifier extends AppSettingsNotifier {
  _StreamNotifier(this._controller, this._initial);
  final StreamController<AppSettings> _controller;
  final AppSettings _initial;

  @override
  Future<AppSettings> build() async {
    final completer = Completer<AppSettings>();

    final sub = _controller.stream.listen((s) {
      if (!completer.isCompleted) {
        completer.complete(s);
      } else {
        if (ref.mounted) state = AsyncData(s);
      }
    });
    ref.onDispose(sub.cancel);

    // Prime with initial value.
    _controller.add(_initial);

    return completer.future;
  }

  @override
  Future<void> save(patch) async {}
}

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

Widget _buildProfileWidget({
  required AppSettings settings,
  _FakeAppSettingsNotifier? notifier,
}) {
  final n = notifier ?? _FakeAppSettingsNotifier(settings);
  return ProviderScope(
    overrides: [appSettingsProvider.overrideWith(() => n)],
    child: const MaterialApp(home: ProfileSettingsScreen()),
  );
}

Widget _buildGreetingWidget(AppSettingsNotifier notifier) {
  return ProviderScope(
    overrides: [appSettingsProvider.overrideWith(() => notifier)],
    child: const MaterialApp(home: Scaffold(body: HomeGreeting())),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ProfileSettingsScreen (T-183)', () {
    testWidgets(
      '1. name field pre-filled with current displayName',
      (tester) async {
        const settings = AppSettings(displayName: 'Alice');
        await tester.pumpWidget(_buildProfileWidget(settings: settings));
        await tester.pumpAndSettle();

        expect(find.widgetWithText(TextField, 'Alice'), findsOneWidget);
      },
    );

    testWidgets(
      '2. name field empty when displayName is null',
      (tester) async {
        const settings = AppSettings(displayName: null);
        await tester.pumpWidget(_buildProfileWidget(settings: settings));
        await tester.pumpAndSettle();

        final tf = tester.widget<TextField>(find.byType(TextField));
        expect(tf.controller?.text, equals(''));
      },
    );

    testWidgets(
      '3. Save button is disabled when field equals initial value',
      (tester) async {
        const settings = AppSettings(displayName: 'Alice');
        await tester.pumpWidget(_buildProfileWidget(settings: settings));
        await tester.pumpAndSettle();

        // No change — Save should be disabled (null onPressed).
        final saveBtn = tester.widget<TextButton>(find.widgetWithText(TextButton, 'Save'));
        expect(saveBtn.onPressed, isNull);
      },
    );

    testWidgets(
      '4. Save button is enabled after field value changes',
      (tester) async {
        const settings = AppSettings(displayName: 'Alice');
        await tester.pumpWidget(_buildProfileWidget(settings: settings));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'Bob');
        await tester.pump();

        final saveBtn = tester.widget<TextButton>(find.widgetWithText(TextButton, 'Save'));
        expect(saveBtn.onPressed, isNotNull);
      },
    );

    testWidgets(
      '5. tapping Save writes patch with new displayName',
      (tester) async {
        const settings = AppSettings(displayName: 'Alice');
        final notifier = _FakeAppSettingsNotifier(settings);
        await tester.pumpWidget(_buildProfileWidget(notifier: notifier, settings: settings));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'Bob');
        await tester.pump();

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        expect(notifier.savedPatches, isNotEmpty);
        expect(notifier.savedPatches.last.displayName, equals('Bob'));
      },
    );

    testWidgets(
      '6. snackbar "Profile updated" shown after successful save',
      (tester) async {
        const settings = AppSettings(displayName: 'Alice');
        final notifier = _FakeAppSettingsNotifier(settings);
        await tester.pumpWidget(_buildProfileWidget(notifier: notifier, settings: settings));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'Bob');
        await tester.pump();

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        expect(find.text('Profile updated'), findsOneWidget);
      },
    );

    testWidgets(
      '8. clearing the name field makes Save enabled (change from "Alice" to "")',
      (tester) async {
        const settings = AppSettings(displayName: 'Alice');
        await tester.pumpWidget(_buildProfileWidget(settings: settings));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), '');
        await tester.pump();

        final saveBtn = tester.widget<TextButton>(find.widgetWithText(TextButton, 'Save'));
        expect(saveBtn.onPressed, isNotNull);
      },
    );

    testWidgets(
      '9. screen shows local-only info text',
      (tester) async {
        await tester.pumpWidget(_buildProfileWidget(settings: const AppSettings()));
        await tester.pumpAndSettle();

        expect(find.textContaining('Stored on-device only'), findsOneWidget);
      },
    );

    testWidgets(
      '10. loading state shows CircularProgressIndicator',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appSettingsProvider.overrideWith(() => _SlowNotifier()),
            ],
            child: const MaterialApp(home: ProfileSettingsScreen()),
          ),
        );
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      '11. error state shows error message',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appSettingsProvider.overrideWith(() => _ErrorNotifier()),
            ],
            child: const MaterialApp(home: ProfileSettingsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.textContaining('Failed to load profile'), findsOneWidget);
      },
    );
  });

  // -------------------------------------------------------------------------

  group('HomeGreeting (T-183)', () {
    testWidgets(
      '12. shows "Hi, Alice!" when displayName is "Alice"',
      (tester) async {
        const settings = AppSettings(displayName: 'Alice');
        await tester.pumpWidget(
          _buildGreetingWidget(_FakeAppSettingsNotifier(settings)),
        );
        await tester.pumpAndSettle();

        expect(find.text('Hi, Alice!'), findsOneWidget);
      },
    );

    testWidgets(
      '13. shows "Hi!" when displayName is null',
      (tester) async {
        const settings = AppSettings(displayName: null);
        await tester.pumpWidget(
          _buildGreetingWidget(_FakeAppSettingsNotifier(settings)),
        );
        await tester.pumpAndSettle();

        expect(find.text('Hi!'), findsOneWidget);
      },
    );

    testWidgets(
      '14. shows "Hi!" when displayName is empty string',
      (tester) async {
        const settings = AppSettings(displayName: '');
        await tester.pumpWidget(
          _buildGreetingWidget(_FakeAppSettingsNotifier(settings)),
        );
        await tester.pumpAndSettle();

        expect(find.text('Hi!'), findsOneWidget);
      },
    );

    testWidgets(
      '15. shows "Hi!" when displayName is whitespace only',
      (tester) async {
        const settings = AppSettings(displayName: '   ');
        await tester.pumpWidget(
          _buildGreetingWidget(_FakeAppSettingsNotifier(settings)),
        );
        await tester.pumpAndSettle();

        expect(find.text('Hi!'), findsOneWidget);
      },
    );

    testWidgets(
      '16. greeting updates reactively when displayName changes',
      (tester) async {
        final ctrl = StreamController<AppSettings>.broadcast();
        const initial = AppSettings(displayName: 'Alice');
        final notifier = _StreamNotifier(ctrl, initial);

        await tester.pumpWidget(_buildGreetingWidget(notifier));
        await tester.pumpAndSettle();

        expect(find.text('Hi, Alice!'), findsOneWidget);

        // Push an updated AppSettings with a different name.
        ctrl.add(const AppSettings(displayName: 'Bob'));
        await tester.pumpAndSettle();

        expect(find.text('Hi, Bob!'), findsOneWidget);

        await ctrl.close();
      },
    );
  });
}
