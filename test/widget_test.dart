import 'package:flutter_test/flutter_test.dart';
import 'package:expense_app/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('每日支出记录'), findsOneWidget);
  });
}
