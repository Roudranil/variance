// lib/presentation/features/home/home_screen.dart
//
// Placeholder for the Home screen (Tab 0).
//
// This is a minimal scaffold-only widget used to verify that GoRouter routes
// compile and navigation works. Full implementation is in a later sprint.

import 'package:flutter/material.dart';

/// Placeholder Home screen shown on Tab 0 of the shell navigation.
///
/// Replaced by the full home dashboard widget in a later sprint.
class HomeScreen extends StatelessWidget {
  /// Creates the [HomeScreen] placeholder.
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Home'),
      ),
    );
  }
}
