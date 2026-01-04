import 'package:flutter/material.dart';

/// The Dashboard screen.
///
/// Displays analytics and summary charts.
class DashboardScreen extends StatelessWidget {
  /// Creates a new instance of [DashboardScreen].
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: const Center(child: Text('Dashboard Screen')),
    );
  }
}
