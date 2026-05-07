// lib/presentation/features/onboarding/onboarding_screen.dart
//
// Placeholder for the Onboarding Wizard screen.
//
// Shown on first launch when onboarding_complete == false in app_settings.
// This is a minimal scaffold-only widget. Full multi-step wizard is in a
// later sprint.

import 'package:flutter/material.dart';

/// Placeholder Onboarding Wizard screen shown on fresh install.
///
/// Replaced by the full onboarding wizard in a later sprint.
class OnboardingScreen extends StatelessWidget {
  /// Creates the [OnboardingScreen] placeholder.
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Onboarding'),
      ),
    );
  }
}
