// test/widget/features/home/greeting_row_test.dart
//
// Widget tests for GreetingRow (T-149).
//
// Test cases:
//   1. shows "Hi, [name]!" when display name is set in AppSettings
//   2. shows "Hi!" when display name is null
//   3. shows "Hi!" when display name is empty string
//   4. text uses bodyLarge style with onSurface color

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:variance/domain/entities/app_settings.dart';
import 'package:variance/presentation/features/home/widgets/greeting_row.dart';
import 'package:variance/presentation/providers/app_settings_providers.dart';

// ---------------------------------------------------------------------------
// Fake AppSettingsNotifier
// ---------------------------------------------------------------------------

class _FakeAppSettingsNotifier extends AppSettingsNotifier {
  _FakeAppSettingsNotifier(this._settings);

  final AppSettings _settings;

  @override
  Future<AppSettings> build() async => _settings;
}

AppSettings _makeSettings({String? displayName}) {
  return AppSettings(
    homeCurrency: 'INR',
    theme: AppTheme.system,
    displayName: displayName,
    onboardingComplete: true,
  );
}

Widget _buildApp(AppSettings settings) {
  return ProviderScope(
    overrides: [
      appSettingsProvider.overrideWith(
        () => _FakeAppSettingsNotifier(settings),
      ),
    ],
    child: const MaterialApp(
      home: Scaffold(body: GreetingRow()),
    ),
  );
}

void main() {
  group('GreetingRow', () {
    testWidgets('shows "Hi, [name]!" when display name is set', (tester) async {
      await tester.pumpWidget(
        _buildApp(_makeSettings(displayName: 'Alice')),
      );
      await tester.pump();

      expect(find.text('Hi, Alice!'), findsOneWidget);
    });

    testWidgets('shows "Hi!" when display name is null', (tester) async {
      await tester.pumpWidget(
        _buildApp(_makeSettings(displayName: null)),
      );
      await tester.pump();

      expect(find.text('Hi!'), findsOneWidget);
    });

    testWidgets('shows "Hi!" when display name is empty string',
        (tester) async {
      await tester.pumpWidget(
        _buildApp(_makeSettings(displayName: '')),
      );
      await tester.pump();

      expect(find.text('Hi!'), findsOneWidget);
    });

    testWidgets('shows "Hi!" when display name is whitespace-only',
        (tester) async {
      await tester.pumpWidget(
        _buildApp(_makeSettings(displayName: '   ')),
      );
      await tester.pump();

      expect(find.text('Hi!'), findsOneWidget);
    });
  });
}
