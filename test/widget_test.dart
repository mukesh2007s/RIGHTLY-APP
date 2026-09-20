// Basic smoke test for Rightly app

import 'package:flutter_test/flutter_test.dart';
import 'package:rightly/main.dart';

void main() {
  testWidgets('App launches without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const RightlyApp());
    await tester.pump();
    expect(find.byType(RightlyApp), findsOneWidget);
  });
}
