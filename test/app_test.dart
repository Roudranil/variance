import 'package:variance/app.dart';
import 'package:variance/features/home/screens/home_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('VarianceApp launches and displays HomeScreen', (tester) async {
    await tester.pumpWidget(const VarianceApp());
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
