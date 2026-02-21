import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:gridx/main.dart';

void main() {
  testWidgets('shows splash then home page', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    expect(find.text('GridX'), findsOneWidget);
    expect(find.text('2048 inspired game'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Welcome to GridX'), findsOneWidget);
    expect(find.text('Play Game'), findsOneWidget);
  });
}
