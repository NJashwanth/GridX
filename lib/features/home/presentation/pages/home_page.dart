import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:math' as math;

import '../../../../app/providers/app_providers.dart';
import '../../domain/models/home_game_state.dart';
import '../view_models/home_view_model.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final game = ref.watch(homeGameProvider);
    final viewModel = ref.read(homeViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('GridX'),
        actions: [
          IconButton(
            tooltip: 'New game',
            onPressed: viewModel.resetGame,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Toggle theme',
            onPressed: viewModel.toggleTheme,
            icon: Icon(
              mode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.surfaceContainerLowest,
                Theme.of(context).colorScheme.surfaceContainerLow,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Focus(
                  autofocus: true,
                  onKeyEvent: (node, event) {
                    if (event is! KeyDownEvent) {
                      return KeyEventResult.ignored;
                    }

                    switch (event.logicalKey) {
                      case LogicalKeyboardKey.arrowUp:
                        viewModel.move(MoveDirection.up);
                        return KeyEventResult.handled;
                      case LogicalKeyboardKey.arrowDown:
                        viewModel.move(MoveDirection.down);
                        return KeyEventResult.handled;
                      case LogicalKeyboardKey.arrowLeft:
                        viewModel.move(MoveDirection.left);
                        return KeyEventResult.handled;
                      case LogicalKeyboardKey.arrowRight:
                        viewModel.move(MoveDirection.right);
                        return KeyEventResult.handled;
                    }

                    return KeyEventResult.ignored;
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '2048',
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Swipe on the board or use arrow keys',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: _ScoreCard(
                              label: 'Score',
                              value: game.score,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ScoreCard(
                              label: 'Best',
                              value: game.bestScore,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (game.hasWon || game.isGameOver)
                        _StatusBanner(
                          hasWon: game.hasWon,
                          isGameOver: game.isGameOver,
                          onNewGame: viewModel.resetGame,
                        ),
                      if (game.hasWon || game.isGameOver)
                        const SizedBox(height: 14),
                      Expanded(
                        child: GestureDetector(
                          onPanEnd: (details) {
                            final velocity = details.velocity.pixelsPerSecond;
                            final dx = velocity.dx;
                            final dy = velocity.dy;

                            if (dx.abs() > dy.abs()) {
                              viewModel.move(
                                dx > 0
                                    ? MoveDirection.right
                                    : MoveDirection.left,
                              );
                            } else {
                              viewModel.move(
                                dy > 0 ? MoveDirection.down : MoveDirection.up,
                              );
                            }
                          },
                          child: TweenAnimationBuilder<Offset>(
                            key: ValueKey(game.moveCount),
                            tween: Tween<Offset>(
                              begin: _boardAnimationOffset(
                                game.lastMoveDirection,
                              ),
                              end: Offset.zero,
                            ),
                            duration: const Duration(milliseconds: 140),
                            curve: Curves.easeOutCubic,
                            child: _BoardGrid(board: game.board),
                            builder: (context, offset, child) {
                              return Transform.translate(
                                offset: Offset(offset.dx * 18, offset.dy * 18),
                                child: child,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: viewModel.resetGame,
                          icon: const Icon(Icons.autorenew_rounded),
                          label: const Text('New Game'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Offset _boardAnimationOffset(MoveDirection? direction) {
  switch (direction) {
    case MoveDirection.left:
      return const Offset(0.18, 0);
    case MoveDirection.right:
      return const Offset(-0.18, 0);
    case MoveDirection.up:
      return const Offset(0, 0.18);
    case MoveDirection.down:
      return const Offset(0, -0.18);
    case null:
      return Offset.zero;
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        child: Column(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$value',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.hasWon,
    required this.isGameOver,
    required this.onNewGame,
  });

  final bool hasWon;
  final bool isGameOver;
  final VoidCallback onNewGame;

  @override
  Widget build(BuildContext context) {
    final message = isGameOver
        ? 'Game over. Start a new run.'
        : 'You reached 2048. Keep going!';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(width: 8),
            TextButton(onPressed: onNewGame, child: const Text('Restart')),
          ],
        ),
      ),
    );
  }
}

class _BoardGrid extends StatelessWidget {
  const _BoardGrid({required this.board});

  final List<int> board;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        children: List.generate(4, (row) {
          return Expanded(
            child: Row(
              children: List.generate(4, (col) {
                final value = board[row * 4 + col];
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: _Tile(value: value),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background = _tileColor(value, scheme);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 120),
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: Text(
            value == 0 ? '' : '$value',
            key: ValueKey(value),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: value == 0
                  ? scheme.onSurfaceVariant
                  : scheme.onPrimaryContainer,
            ),
          ),
        ),
      ),
    );
  }

  Color _tileColor(int value, ColorScheme scheme) {
    if (value == 0) {
      return scheme.surfaceContainer;
    }

    final level = (math.log(value) / math.ln2).clamp(1, 11).toDouble();
    final ratio = ((level - 1) / 10).clamp(0.0, 1.0);
    return Color.lerp(
      scheme.primaryContainer,
      scheme.tertiaryContainer,
      ratio,
    )!;
  }
}
