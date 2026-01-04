import 'package:flutter/material.dart';

/// The Settings screen.
///
/// Allows the user to configure app preferences.
class SettingsScreen extends StatelessWidget {
  /// Creates a new instance of [SettingsScreen].
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('Settings Screen')),
    );
  }
}
