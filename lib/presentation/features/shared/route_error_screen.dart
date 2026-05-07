// lib/presentation/features/shared/route_error_screen.dart
//
// Error screen shown when a route parameter is invalid.
//
// GoRouter's builder callback validates typed path parameters before
// navigating. When a parameter is malformed (e.g. non-UUID :id), the
// builder navigates to this screen instead of crashing.

import 'package:flutter/material.dart';

/// Shown when a route path parameter is invalid or cannot be resolved.
///
/// Displays the [errorMessage] and a back button to exit the dead-end route.
class RouteErrorScreen extends StatelessWidget {
  /// Creates a [RouteErrorScreen] with the given [errorMessage].
  const RouteErrorScreen({super.key, required this.errorMessage});

  /// Human-readable description of the routing error.
  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Navigation Error')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: const Text('Go back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
