import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:variance/features/settings/screens/settings_screen.dart';

void main() {
  testWidgets('SettingsScreen renders correctly', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Settings Screen'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing); // No FAB
  });
}
