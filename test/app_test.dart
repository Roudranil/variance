import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:variance/app.dart';
import 'package:variance/core/preferences/settings_provider.dart';
import 'package:variance/features/home/screens/home_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('VarianceApp launches and displays HomeScreen', (tester) async {
    final settingsProvider = SettingsProvider();
    await settingsProvider.loadFromPrefs();

    await tester.pumpWidget(VarianceApp(settingsProvider: settingsProvider));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
