// lib/main.dart
//
// App entry point.
//
// Wraps the root widget in ProviderScope so that all @riverpod providers
// (database, DAOs, repositories, use cases, app settings) are accessible
// throughout the widget tree.
//
// The GoRouter instance is built inside AppRouterWidget (a ConsumerWidget)
// so it can access Riverpod providers for the onboarding redirect guard.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:variance/presentation/navigation/app_router.dart';

void main() {
  runApp(
    // ProviderScope is the Riverpod composition root.
    // All keepAlive providers (AppDatabase, DAOs, repositories, settings) are
    // constructed here on first access and held for the app's lifetime.
    const ProviderScope(child: AppRouterWidget()),
  );
}
