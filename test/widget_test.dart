import 'package:flutter_test/flutter_test.dart';

import 'package:fundflow/main.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const FundFlowApp());
    await tester.pumpAndSettle();
    expect(find.text('Analytics'), findsAny);
  });
}
