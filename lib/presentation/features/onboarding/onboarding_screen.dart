// lib/presentation/features/onboarding/onboarding_screen.dart
//
// Placeholder for the Onboarding Wizard screen.
//
// Shown on first launch when onboarding_complete == false in app_settings.
// This is a minimal scaffold-only widget. Full multi-step wizard is in a
// later sprint (UX Flows §4).
//
// DEV AID: A temporary "Skip" button is shown that marks onboarding as
// complete so the app can navigate past this screen during development.
// This button MUST be replaced by the real multi-step wizard per spec
// (UX Flows §4 / UI Spec §3) before release.

import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:variance/domain/entities/app_settings.dart';
import 'package:variance/domain/repositories/i_app_settings_repository.dart';
import 'package:variance/presentation/providers/app_settings_providers.dart';

/// Placeholder Onboarding Wizard screen shown on fresh install.
///
/// Replaced by the full onboarding wizard in a later sprint.
///
/// NOTE: The "Skip" button is a temporary development aid. It marks
/// [AppSettings.onboardingComplete] = true so the app can navigate to the
/// home shell without completing the real wizard.
/// It MUST be removed and replaced per the spec before production release.
class OnboardingScreen extends ConsumerWidget {
  /// Creates the [OnboardingScreen] placeholder.
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Onboarding',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 32),
            // TODO(dev): Replace this button with the real onboarding wizard
            // per UX Flows §4 (steps: Welcome → Currency → First Account →
            // Highlights → Done). This "Skip" button is a temporary dev aid
            // that should NOT appear in the production release.
            FilledButton(
              onPressed: () => _skipOnboarding(context, ref),
              child: const Text('Skip (Dev)'),
            ),
          ],
        ),
      ),
    );
  }

  /// Marks onboarding as complete and navigates to the home shell.
  ///
  /// Saves [AppSettings.onboardingComplete] = true via the
  /// [AppSettingsNotifier.save] method. GoRouter's redirect guard then
  /// automatically navigates away from /onboarding to /.
  Future<void> _skipOnboarding(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(appSettingsProvider.notifier).save(
            const AppSettingsPatch(onboardingComplete: true),
          );
    } on Exception catch (e, st) {
      dev.log(
        'OnboardingScreen: failed to save onboarding complete: $e',
        name: 'OnboardingScreen',
        stackTrace: st,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to complete onboarding.')),
        );
      }
    }
  }
}
