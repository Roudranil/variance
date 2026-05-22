// lib/presentation/features/home/widgets/greeting_row.dart
//
// GreetingRow — personalised greeting shown at the top of the Home screen.
//
// Architecture (T-149, UI spec §5.1.1):
//   - Reads displayName from AppSettingsNotifier.
//   - Shows "Hi, [name]!" when name is set; "Hi!" otherwise.
//   - Applies bodyLarge style with onSurface token per §5.1.1.
//   - StatelessWidget (ConsumerWidget) — no local mutable state.
//
// Test cases (see test/widget/features/home/greeting_row_test.dart):
//   1. name set → "Hi, [name]!"
//   2. name null → "Hi!"
//   3. name empty string → "Hi!"
//   4. name whitespace-only → "Hi!"

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:variance/presentation/providers/app_settings_providers.dart';

/// Personalised greeting row displayed at the top of the Home screen.
///
/// Reads the [displayName] from [appSettingsProvider]. Shows "Hi, [name]!"
/// when a name is configured in Profile settings, or "Hi!" when none is set.
///
/// Text style: [TextTheme.bodyLarge] with [ColorScheme.onSurface] color,
/// per UI spec §5.1.1.
class GreetingRow extends ConsumerWidget {
  /// Creates the [GreetingRow] widget.
  const GreetingRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider).value;
    final name = settings?.displayName;
    final hasName = name != null && name.trim().isNotEmpty;
    final greeting = hasName ? 'Hi, $name!' : 'Hi!';

    final textStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        );

    return Text(
      greeting,
      style: textStyle,
    );
  }
}
