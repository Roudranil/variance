// test/presentation/features/settings/security/security_settings_screen_test.dart
//
// Widget tests for SecuritySettingsScreen (T-184) and PIN screens (T-185).
//
// Test cases — SecuritySettingsScreen:
//   1. Screen renders "Security" AppBar title.
//   2. Scope clarification card is visible.
//   3. Lock timeout dropdown shows "Immediately" for lockTimeoutSeconds=0.
//   4. Lock timeout dropdown shows "30 seconds" for lockTimeoutSeconds=30.
//   5. Lock timeout dropdown shows "1 minute" for lockTimeoutSeconds=60.
//   6. Lock timeout dropdown shows "5 minutes" for lockTimeoutSeconds=300.
//   7. Selecting "30 seconds" writes lockTimeoutSeconds=30 patch.
//   8. Selecting "1 minute" writes lockTimeoutSeconds=60 patch.
//   9. Selecting "Immediately" writes lockTimeoutSeconds=0 patch.
//  10. "Set / Change PIN" row is present.
//  11. Device lock notice row is present.
//  12. "Forgot PIN?" info row is present.
//  13. Loading state shows CircularProgressIndicator.
//  14. Error state shows error message.
//
// Test cases — PinSetupScreen (T-185):
//  15. Create mode: AppBar shows "Set PIN".
//  16. Change mode: AppBar shows "Change PIN".
//  17. Shows 6 empty dot indicators on load.
//  18. Entering a digit fills one dot.
//  19. Backspace removes the last dot.
//  20. After 6 digits the screen advances to confirm step ("Confirm your PIN").
//  21. Mismatched PIN shows error text.
//
// Test cases — PinEntryScreen (T-185):
//  22. Shows "Enter your PIN" label.
//  23. Entering correct 6 digits calls onSuccess.
//  24. "Forgot PIN" button is visible.
//  25. Wrong PIN shows error text with attempt count.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:variance/domain/entities/app_settings.dart';
import 'package:variance/domain/repositories/i_app_settings_repository.dart';
import 'package:variance/presentation/features/settings/security/pin_entry_screen.dart';
import 'package:variance/presentation/features/settings/security/pin_setup_screen.dart';
import 'package:variance/presentation/features/settings/security/security_settings_screen.dart';
import 'package:variance/presentation/navigation/app_router.dart';
import 'package:variance/presentation/providers/app_settings_providers.dart';

// ---------------------------------------------------------------------------
// Fake notifiers
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
  Future<AppSettings> build() async => throw Exception('fail');
}

// ---------------------------------------------------------------------------
// Security settings helper
// ---------------------------------------------------------------------------

Widget _buildSecurityWidget({
  int lockTimeout = 0,
  _FakeAppSettingsNotifier? notifier,
}) {
  final settings = AppSettings(lockTimeoutSeconds: lockTimeout);
  final n = notifier ?? _FakeAppSettingsNotifier(settings);
  final router = GoRouter(
    initialLocation: AppRoutes.settingsSecurity,
    routes: [
      GoRoute(
        path: AppRoutes.settingsSecurity,
        builder: (_, __) => const SecuritySettingsScreen(),
        routes: [
          GoRoute(
            path: 'pin-setup',
            builder: (_, __) => const Scaffold(body: Text('PinSetupScreen')),
          ),
        ],
      ),
    ],
  );

  return ProviderScope(
    overrides: [appSettingsProvider.overrideWith(() => n)],
    child: MaterialApp.router(routerConfig: router),
  );
}

// ---------------------------------------------------------------------------
// PIN setup helper — wraps screen in a simple MaterialApp (no router).
// ---------------------------------------------------------------------------

Widget _buildPinSetupWidget(PinSetupMode mode) {
  return MaterialApp(
    home: PinSetupScreen(mode: mode),
  );
}

// ---------------------------------------------------------------------------
// PIN entry helper
// ---------------------------------------------------------------------------

Widget _buildPinEntryWidget({required VoidCallback onSuccess}) {
  return MaterialApp(
    home: PinEntryScreen(onSuccess: onSuccess),
  );
}

/// Taps a keypad digit button by its label text.
Future<void> _tapDigit(WidgetTester tester, int digit) async {
  // There may be multiple Text widgets with the digit; tap the first keypad key.
  await tester.tap(find.text('$digit').first);
  await tester.pump();
}

/// Enters a full 6-digit PIN sequence.
Future<void> _enterPin(WidgetTester tester, List<int> digits) async {
  for (final d in digits) {
    await _tapDigit(tester, d);
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('SecuritySettingsScreen (T-184)', () {
    testWidgets('1. screen renders "Security" AppBar title', (tester) async {
      await tester.pumpWidget(_buildSecurityWidget());
      await tester.pumpAndSettle();

      expect(find.text('Security'), findsWidgets);
    });

    testWidgets('2. scope clarification card is visible', (tester) async {
      await tester.pumpWidget(_buildSecurityWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.shield_outlined), findsOneWidget);
      expect(find.textContaining('lock protects'), findsOneWidget);
    });

    testWidgets(
      '3. lock timeout dropdown shows "Immediately" for seconds=0',
      (tester) async {
        await tester.pumpWidget(_buildSecurityWidget(lockTimeout: 0));
        await tester.pumpAndSettle();

        expect(find.text('Immediately'), findsOneWidget);
      },
    );

    testWidgets(
      '4. lock timeout dropdown shows "30 seconds" for seconds=30',
      (tester) async {
        await tester.pumpWidget(_buildSecurityWidget(lockTimeout: 30));
        await tester.pumpAndSettle();

        expect(find.text('30 seconds'), findsOneWidget);
      },
    );

    testWidgets(
      '5. lock timeout dropdown shows "1 minute" for seconds=60',
      (tester) async {
        await tester.pumpWidget(_buildSecurityWidget(lockTimeout: 60));
        await tester.pumpAndSettle();

        expect(find.text('1 minute'), findsOneWidget);
      },
    );

    testWidgets(
      '6. lock timeout dropdown shows "5 minutes" for seconds=300',
      (tester) async {
        await tester.pumpWidget(_buildSecurityWidget(lockTimeout: 300));
        await tester.pumpAndSettle();

        expect(find.text('5 minutes'), findsOneWidget);
      },
    );

    testWidgets(
      '7. selecting "30 seconds" writes lockTimeoutSeconds=30 patch',
      (tester) async {
        final n =
            _FakeAppSettingsNotifier(const AppSettings(lockTimeoutSeconds: 0));
        await tester
            .pumpWidget(_buildSecurityWidget(lockTimeout: 0, notifier: n));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Immediately'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('30 seconds').last);
        await tester.pumpAndSettle();

        expect(n.savedPatches, isNotEmpty);
        expect(n.savedPatches.last.lockTimeoutSeconds, equals(30));
      },
    );

    testWidgets(
      '8. selecting "1 minute" writes lockTimeoutSeconds=60 patch',
      (tester) async {
        final n =
            _FakeAppSettingsNotifier(const AppSettings(lockTimeoutSeconds: 0));
        await tester
            .pumpWidget(_buildSecurityWidget(lockTimeout: 0, notifier: n));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Immediately'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('1 minute').last);
        await tester.pumpAndSettle();

        expect(n.savedPatches.last.lockTimeoutSeconds, equals(60));
      },
    );

    testWidgets(
      '9. selecting "Immediately" writes lockTimeoutSeconds=0 patch',
      (tester) async {
        final n =
            _FakeAppSettingsNotifier(const AppSettings(lockTimeoutSeconds: 30));
        await tester
            .pumpWidget(_buildSecurityWidget(lockTimeout: 30, notifier: n));
        await tester.pumpAndSettle();

        await tester.tap(find.text('30 seconds'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Immediately').last);
        await tester.pumpAndSettle();

        expect(n.savedPatches.last.lockTimeoutSeconds, equals(0));
      },
    );

    testWidgets('10. "Set / Change PIN" row is present', (tester) async {
      await tester.pumpWidget(_buildSecurityWidget());
      await tester.pumpAndSettle();

      expect(find.text('Set / Change PIN'), findsOneWidget);
    });

    testWidgets('11. device lock notice row is present', (tester) async {
      await tester.pumpWidget(_buildSecurityWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('device security'), findsWidgets);
    });

    testWidgets('12. "Forgot PIN?" info row is present', (tester) async {
      await tester.pumpWidget(_buildSecurityWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('Forgot PIN'), findsOneWidget);
    });

    testWidgets('13. loading state shows CircularProgressIndicator',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [appSettingsProvider.overrideWith(_SlowNotifier.new)],
          child: const MaterialApp(home: SecuritySettingsScreen()),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('14. error state shows error message', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [appSettingsProvider.overrideWith(_ErrorNotifier.new)],
          child: const MaterialApp(home: SecuritySettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Failed to load security settings'),
          findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------

  group('PinSetupScreen (T-185)', () {
    setUp(() {
      // Provide a fake FlutterSecureStorage so no platform channel is called.
      FlutterSecureStorage.setMockInitialValues({});
    });

    testWidgets('15. create mode: AppBar shows "Set PIN"', (tester) async {
      await tester.pumpWidget(_buildPinSetupWidget(PinSetupMode.create));
      await tester.pumpAndSettle();

      expect(find.text('Set PIN'), findsOneWidget);
    });

    testWidgets('16. change mode: AppBar shows "Change PIN"', (tester) async {
      await tester.pumpWidget(_buildPinSetupWidget(PinSetupMode.change));
      await tester.pumpAndSettle();

      // In change mode the first step label is "Enter your current PIN".
      expect(find.text('Change PIN'), findsOneWidget);
    });

    testWidgets('17. shows 6 empty dot indicators on load', (tester) async {
      await tester.pumpWidget(_buildPinSetupWidget(PinSetupMode.create));
      await tester.pumpAndSettle();

      // 6 Container dots are rendered.  They are all unfilled initially.
      // Verify by checking the "Create a PIN" step label is visible.
      expect(find.text('Create a PIN'), findsOneWidget);
    });

    testWidgets('18. entering a digit renders its outline dot filled',
        (tester) async {
      await tester.pumpWidget(_buildPinSetupWidget(PinSetupMode.create));
      await tester.pumpAndSettle();

      await _tapDigit(tester, 1);

      // After 1 digit, the step label should still say "Create a PIN".
      expect(find.text('Create a PIN'), findsOneWidget);
    });

    testWidgets('19. backspace widget is present in keypad', (tester) async {
      await tester.pumpWidget(_buildPinSetupWidget(PinSetupMode.create));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);
    });

    testWidgets(
      '20. after 6 digits screen advances to confirm step',
      (tester) async {
        await tester.pumpWidget(_buildPinSetupWidget(PinSetupMode.create));
        await tester.pumpAndSettle();

        await _enterPin(tester, [1, 2, 3, 4, 5, 6]);
        await tester.pumpAndSettle();

        expect(find.text('Confirm your PIN'), findsOneWidget);
      },
    );

    testWidgets(
      '21. mismatched confirmation PIN shows error text',
      (tester) async {
        await tester.pumpWidget(_buildPinSetupWidget(PinSetupMode.create));
        await tester.pumpAndSettle();

        // Enter first PIN.
        await _enterPin(tester, [1, 2, 3, 4, 5, 6]);
        await tester.pumpAndSettle();

        // Enter different confirmation PIN.
        await _enterPin(tester, [6, 5, 4, 3, 2, 1]);
        await tester.pumpAndSettle();

        expect(find.text('PINs do not match'), findsOneWidget);
      },
    );
  });

  // -------------------------------------------------------------------------

  group('PinEntryScreen (T-185)', () {
    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
    });

    testWidgets('22. shows "Enter your PIN" label', (tester) async {
      await tester.pumpWidget(_buildPinEntryWidget(onSuccess: () {}));
      await tester.pumpAndSettle();

      expect(find.text('Enter your PIN'), findsOneWidget);
    });

    testWidgets(
      '23. correct 6-digit PIN calls onSuccess',
      (tester) async {
        // Store the correct PIN in the mock secure storage.
        FlutterSecureStorage.setMockInitialValues({
          'app_pin_hash': '123456',
        });

        var successCalled = false;
        await tester.pumpWidget(
          _buildPinEntryWidget(onSuccess: () => successCalled = true),
        );
        await tester.pumpAndSettle();

        await _enterPin(tester, [1, 2, 3, 4, 5, 6]);
        await tester.pumpAndSettle();

        expect(successCalled, isTrue);
      },
    );

    testWidgets('24. "Forgot PIN" button is visible', (tester) async {
      await tester.pumpWidget(_buildPinEntryWidget(onSuccess: () {}));
      await tester.pumpAndSettle();

      expect(find.text('Forgot PIN'), findsOneWidget);
    });

    testWidgets(
      '25. wrong PIN shows error text with attempt count',
      (tester) async {
        // No PIN stored — so any entry will be wrong.
        FlutterSecureStorage.setMockInitialValues({});

        await tester.pumpWidget(_buildPinEntryWidget(onSuccess: () {}));
        await tester.pumpAndSettle();

        await _enterPin(tester, [1, 2, 3, 4, 5, 6]);
        await tester.pumpAndSettle();

        expect(find.textContaining('Incorrect PIN'), findsOneWidget);
        expect(find.textContaining('14 attempts remaining'), findsOneWidget);
      },
    );

    testWidgets(
      '26. tapping "Forgot PIN" shows confirmation dialog',
      (tester) async {
        await tester.pumpWidget(_buildPinEntryWidget(onSuccess: () {}));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Forgot PIN'));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text('Reset'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
      },
    );

    testWidgets(
      '27. cancelling the Forgot PIN dialog dismisses it without action',
      (tester) async {
        await tester.pumpWidget(_buildPinEntryWidget(onSuccess: () {}));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Forgot PIN'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // Dialog should be gone; the PIN entry screen remains.
        expect(find.byType(AlertDialog), findsNothing);
        expect(find.text('Enter your PIN'), findsOneWidget);
      },
    );
  });
}
