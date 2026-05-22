// test/presentation/features/home/recurring_catch_up_banner_test.dart
//
// Widget tests for RecurringCatchUpBanner (T-121).
//
// Test cases:
//   T-121.1  Banner shown when autoApprovedCount >= 1.
//   T-121.2  Banner absent when autoApprovedCount = 0.
//   T-121.3  Banner shows correct count (N=1, N=5).
//   T-121.4  Banner dismiss button makes it disappear.
//   T-121.5  "View details" CTA navigates to filtered transaction list.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:variance/presentation/features/home/widgets/recurring_catch_up_banner.dart';

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

Widget _buildApp({
  required int count,
  VoidCallback? onViewDetails,
}) {
  return MaterialApp(
    home: Scaffold(
      body: RecurringCatchUpBanner(
        autoApprovedCount: count,
        onViewDetails: onViewDetails,
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('RecurringCatchUpBanner', () {
    testWidgets('T-121.1 banner shown when count >= 1', (tester) async {
      await tester.pumpWidget(_buildApp(count: 1));
      await tester.pump();
      expect(find.byType(RecurringCatchUpBanner), findsOneWidget);
      // Banner text should be visible.
      expect(find.textContaining('auto-posted'), findsOneWidget);
    });

    testWidgets('T-121.2 banner absent when count = 0', (tester) async {
      await tester.pumpWidget(_buildApp(count: 0));
      await tester.pump();
      // Banner renders SizedBox.shrink when count = 0.
      expect(find.textContaining('auto-posted'), findsNothing);
    });

    testWidgets('T-121.3 banner shows N=1 message', (tester) async {
      await tester.pumpWidget(_buildApp(count: 1));
      await tester.pump();
      expect(find.textContaining('1 recurring transaction'), findsOneWidget);
    });

    testWidgets('T-121.3 banner shows N=5 message', (tester) async {
      await tester.pumpWidget(_buildApp(count: 5));
      await tester.pump();
      expect(find.textContaining('5 recurring transactions'), findsOneWidget);
    });

    testWidgets('T-121.4 dismiss button hides the banner', (tester) async {
      await tester.pumpWidget(_buildApp(count: 3));
      await tester.pump();

      // Banner should be visible.
      expect(find.textContaining('auto-posted'), findsOneWidget);

      // Tap the dismiss icon.
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      // Banner should be hidden.
      expect(find.textContaining('auto-posted'), findsNothing);
    });

    testWidgets('T-121.5 "View details" CTA calls callback', (tester) async {
      var callbackCalled = false;

      await tester.pumpWidget(
        _buildApp(
          count: 2,
          onViewDetails: () => callbackCalled = true,
        ),
      );
      await tester.pump();

      await tester.tap(find.text('View details'));
      expect(callbackCalled, isTrue);
    });
  });
}
