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
    final highestTile = game.board.fold<int>(0, math.max);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
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
        child: Stack(
          children: [
            const Positioned.fill(child: _AmbientBackground()),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
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
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final boardSize = math.min(
                          constraints.maxWidth,
                          constraints.maxHeight * 0.55,
                        );

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _HeroHeader(highestTile: highestTile, mode: mode),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: _ScoreCard(
                                    label: 'Score',
                                    value: game.score,
                                    icon: Icons.bolt_rounded,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _ScoreCard(
                                    label: 'Best',
                                    value: game.bestScore,
                                    icon: Icons.workspace_premium_rounded,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _ScoreCard(
                                    label: 'Moves',
                                    value: game.moveCount,
                                    icon: Icons.swipe_rounded,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (game.hasWon || game.isGameOver)
                              _StatusBanner(
                                hasWon: game.hasWon,
                                isGameOver: game.isGameOver,
                                onNewGame: viewModel.resetGame,
                              ),
                            if (game.hasWon || game.isGameOver)
                              const SizedBox(height: 12),
                            Expanded(
                              child: Center(
                                child: SizedBox.square(
                                  dimension: boardSize,
                                  child: GestureDetector(
                                    onPanEnd: (details) {
                                      final velocity =
                                          details.velocity.pixelsPerSecond;
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
                                          dy > 0
                                              ? MoveDirection.down
                                              : MoveDirection.up,
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
                                      duration: const Duration(
                                        milliseconds: 140,
                                      ),
                                      curve: Curves.easeOutCubic,
                                      child: _BoardGrid(board: game.board),
                                      builder: (context, offset, child) {
                                        return Transform.translate(
                                          offset: Offset(
                                            offset.dx * 18,
                                            offset.dy * 18,
                                          ),
                                          child: child,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: scheme.surface.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: scheme.outlineVariant.withValues(
                                    alpha: 0.45,
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Swipe or use arrow keys',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: scheme.onSurfaceVariant,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    ElevatedButton.icon(
                                      onPressed: viewModel.resetGame,
                                      icon: const Icon(Icons.autorenew_rounded),
                                      label: const Text('New Game'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.surfaceContainerLowest,
            scheme.surfaceContainerLow,
            scheme.surfaceContainer,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            left: -80,
            child: _GlowOrb(
              size: 300,
              color: scheme.primaryContainer.withValues(alpha: 0.4),
            ),
          ),
          Positioned(
            bottom: -120,
            right: -60,
            child: _GlowOrb(
              size: 260,
              color: scheme.tertiaryContainer.withValues(alpha: 0.34),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0.0)],
          ),
        ),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.highestTile, required this.mode});

  final int highestTile;
  final ThemeMode mode;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primaryContainer.withValues(alpha: 0.92),
            scheme.secondaryContainer.withValues(alpha: 0.9),
          ],
        ),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.14),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Merge. Climb. Repeat.',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
              color: scheme.onPrimaryContainer.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '2048',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1,
              color: scheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _InfoChip(
                icon: Icons.auto_awesome_rounded,
                label: highestTile == 0
                    ? 'Best Tile: -'
                    : 'Best Tile: $highestTile',
              ),
              const SizedBox(width: 8),
              _InfoChip(
                icon: mode == ThemeMode.dark
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                label: mode == ThemeMode.dark ? 'Night' : 'Day',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: scheme.onSurface),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
        ],
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
  const _ScoreCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.surface.withValues(alpha: 0.78),
            scheme.surfaceContainerHigh.withValues(alpha: 0.86),
          ],
        ),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.34),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: scheme.onSurfaceVariant),
          const SizedBox(height: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$value',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
        ],
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
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isGameOver ? scheme.errorContainer : scheme.primaryContainer)
            .withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            isGameOver
                ? Icons.warning_amber_rounded
                : Icons.celebration_rounded,
            color: isGameOver
                ? scheme.onErrorContainer
                : scheme.onPrimaryContainer,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: isGameOver
                    ? scheme.onErrorContainer
                    : scheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(onPressed: onNewGame, child: const Text('Restart')),
        ],
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.surfaceContainerHigh, scheme.surfaceContainerHighest],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.16),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
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
    final gradient = _tileGradient(value, scheme);
    final textColor = value == 0 ? scheme.onSurfaceVariant : gradient.$3;
    final fontSize = switch ('$value'.length) {
      1 || 2 => 28.0,
      3 => 24.0,
      _ => 19.0,
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [gradient.$1, gradient.$2],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: value == 0 ? 0.04 : 0.12),
            blurRadius: value == 0 ? 3 : 10,
            offset: const Offset(0, 4),
          ),
        ],
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
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  (Color, Color, Color) _tileGradient(int value, ColorScheme scheme) {
    if (value == 0) {
      return (
        scheme.surfaceContainer,
        scheme.surfaceContainerHigh,
        scheme.onSurfaceVariant,
      );
    }

    final level = (math.log(value) / math.ln2).clamp(1, 11).toDouble();
    final ratio = ((level - 1) / 10).clamp(0.0, 1.0);
    final start = Color.lerp(
      scheme.primaryContainer,
      scheme.secondaryContainer,
      ratio,
    )!;
    final end = Color.lerp(
      scheme.secondaryContainer,
      scheme.tertiaryContainer,
      (ratio + 0.25).clamp(0.0, 1.0),
    )!;

    final luminance = (start.computeLuminance() + end.computeLuminance()) / 2;
    final textColor = luminance > 0.55 ? Colors.black87 : Colors.white;

    return (start, end, textColor);
  }
}
