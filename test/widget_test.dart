import 'package:flutter_test/flutter_test.dart';
import 'package:torun/main.dart';

void main() {
  testWidgets('App builds', (WidgetTester tester) async {
    await tester.pumpWidget(const TorunApp());
    expect(find.text('torun — Coming Soon'), findsOneWidget);
  });
}