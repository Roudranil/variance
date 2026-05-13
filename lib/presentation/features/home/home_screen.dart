// lib/presentation/features/home/home_screen.dart
//
// Placeholder for the Home screen (Tab 0).
//
// This is a minimal scaffold-only widget used to verify that GoRouter routes
// compile and navigation works. Full implementation is in a later sprint.
//
// T-183: The [HomeGreeting] widget reads displayName from AppSettingsNotifier
// and shows "Hi, [name]!" or "Hi!" reactively.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:variance/presentation/providers/app_settings_providers.dart';

/// Placeholder Home screen shown on Tab 0 of the shell navigation.
///
/// Contains the reactive greeting widget ([HomeGreeting]) that updates when
/// [displayName] changes via Profile settings.
class HomeScreen extends ConsumerWidget {
  /// Creates the [HomeScreen] placeholder.
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: Center(
        child: HomeGreeting(),
      ),
    );
  }
}

/// A greeting widget that reactively shows the user's display name.
///
/// Reads [displayName] from [appSettingsProvider]. Shows "Hi, [name]!" when
/// the name is non-empty, "Hi!" otherwise.
class HomeGreeting extends ConsumerWidget {
  /// Creates the [HomeGreeting] widget.
  const HomeGreeting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider).value;
    final name = settings?.displayName;
    final greeting =
        (name != null && name.trim().isNotEmpty) ? 'Hi, $name!' : 'Hi!';

    return Text(
      greeting,
      style: Theme.of(context).textTheme.headlineMedium,
    );
  }
}
