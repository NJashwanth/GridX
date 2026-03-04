import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:integration_test/integration_test.dart';

import 'package:gridx/main.dart';
import 'package:gridx/features/home/domain/models/home_game_state.dart';
import 'package:gridx/features/home/presentation/view_models/home_view_model.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows completed-game banner after reaching 2048', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeGameProvider.overrideWith(
            (ref) => HomeGameNotifier(
              random: Random(7),
              initialState: const HomeGameState(
                board: [1024, 1024, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                score: 0,
                bestScore: 0,
                hasWon: false,
                isGameOver: false,
                moveCount: 1,
                lastMoveDirection: null,
              ),
            ),
          ),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('New Game'), findsOneWidget);

    expect(find.text('You reached 2048. Keep going!'), findsNothing);

    await tester.fling(
      find.byType(GestureDetector).first,
      const Offset(500, 0),
      2200,
    );
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    expect(find.text('You reached 2048. Keep going!'), findsOneWidget);
    expect(find.text('Restart'), findsOneWidget);
  });
}
