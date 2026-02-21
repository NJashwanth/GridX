import 'package:flutter_test/flutter_test.dart';

import 'package:gridx/main.dart';

void main() {
  testWidgets('shows clean initial page', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('GridX'), findsOneWidget);
    expect(find.text('Welcome to GridX'), findsOneWidget);
    expect(find.text('Your clean starting page is ready.'), findsOneWidget);
  });
}
