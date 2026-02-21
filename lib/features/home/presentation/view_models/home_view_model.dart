import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:math';

import '../../../../app/providers/app_providers.dart';
import '../../domain/models/home_game_state.dart';

final homeViewModelProvider = Provider<HomeViewModel>((ref) {
  return HomeViewModel(ref);
});

final homeGameProvider = StateNotifierProvider<HomeGameNotifier, HomeGameState>(
  (ref) {
    return HomeGameNotifier();
  },
);

class HomeViewModel {
  HomeViewModel(this.ref);

  final Ref ref;

  ThemeMode get currentThemeMode => ref.read(themeModeProvider);

  void toggleTheme() {
    final current = ref.read(themeModeProvider);
    ref.read(themeModeProvider.notifier).state = current == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
  }

  void resetGame() {
    ref.read(homeGameProvider.notifier).resetGame();
  }

  void move(MoveDirection direction) {
    ref.read(homeGameProvider.notifier).move(direction);
  }
}

class HomeGameNotifier extends StateNotifier<HomeGameState> {
  HomeGameNotifier() : super(HomeGameState.initial()) {
    resetGame();
  }

  final Random _random = Random();

  void resetGame() {
    var board = List<int>.filled(16, 0);
    board = _addRandomTile(board);
    board = _addRandomTile(board);

    state = state.copyWith(
      board: board,
      score: 0,
      hasWon: false,
      isGameOver: false,
      moveCount: state.moveCount + 1,
      clearLastMoveDirection: true,
    );
  }

  void move(MoveDirection direction) {
    if (state.isGameOver) {
      return;
    }

    final original = List<int>.from(state.board);
    final next = List<int>.from(state.board);
    var moveScore = 0;

    for (var i = 0; i < 4; i++) {
      final line = _readLine(next, direction, i);
      final merged = _mergeLine(line);
      moveScore += merged.$2;
      _writeLine(next, direction, i, merged.$1);
    }

    final changed = !_listEquals(original, next);
    if (!changed) {
      return;
    }

    final withSpawn = _addRandomTile(next);
    final score = state.score + moveScore;
    final hasWon = state.hasWon || withSpawn.any((value) => value >= 2048);
    final isGameOver = !_canMove(withSpawn);

    state = state.copyWith(
      board: withSpawn,
      score: score,
      bestScore: max(state.bestScore, score),
      hasWon: hasWon,
      isGameOver: isGameOver,
      moveCount: state.moveCount + 1,
      lastMoveDirection: direction,
    );
  }

  List<int> _addRandomTile(List<int> board) {
    final empties = <int>[];
    for (var i = 0; i < board.length; i++) {
      if (board[i] == 0) {
        empties.add(i);
      }
    }
    if (empties.isEmpty) {
      return board;
    }

    final index = empties[_random.nextInt(empties.length)];
    final value = _random.nextDouble() < 0.9 ? 2 : 4;
    final next = List<int>.from(board);
    next[index] = value;
    return next;
  }

  (List<int>, int) _mergeLine(List<int> line) {
    final compact = line.where((value) => value != 0).toList();
    final merged = <int>[];
    var scoreGain = 0;

    for (var i = 0; i < compact.length; i++) {
      if (i + 1 < compact.length && compact[i] == compact[i + 1]) {
        final value = compact[i] * 2;
        merged.add(value);
        scoreGain += value;
        i++;
      } else {
        merged.add(compact[i]);
      }
    }

    while (merged.length < 4) {
      merged.add(0);
    }

    return (merged, scoreGain);
  }

  List<int> _readLine(List<int> board, MoveDirection direction, int lineIndex) {
    switch (direction) {
      case MoveDirection.left:
        return List<int>.generate(4, (i) => board[lineIndex * 4 + i]);
      case MoveDirection.right:
        return List<int>.generate(4, (i) => board[lineIndex * 4 + (3 - i)]);
      case MoveDirection.up:
        return List<int>.generate(4, (i) => board[i * 4 + lineIndex]);
      case MoveDirection.down:
        return List<int>.generate(4, (i) => board[(3 - i) * 4 + lineIndex]);
    }
  }

  void _writeLine(
    List<int> board,
    MoveDirection direction,
    int lineIndex,
    List<int> line,
  ) {
    for (var i = 0; i < 4; i++) {
      switch (direction) {
        case MoveDirection.left:
          board[lineIndex * 4 + i] = line[i];
          break;
        case MoveDirection.right:
          board[lineIndex * 4 + (3 - i)] = line[i];
          break;
        case MoveDirection.up:
          board[i * 4 + lineIndex] = line[i];
          break;
        case MoveDirection.down:
          board[(3 - i) * 4 + lineIndex] = line[i];
          break;
      }
    }
  }

  bool _canMove(List<int> board) {
    if (board.any((value) => value == 0)) {
      return true;
    }

    for (var row = 0; row < 4; row++) {
      for (var col = 0; col < 4; col++) {
        final value = board[row * 4 + col];
        if (col < 3 && value == board[row * 4 + col + 1]) {
          return true;
        }
        if (row < 3 && value == board[(row + 1) * 4 + col]) {
          return true;
        }
      }
    }

    return false;
  }

  bool _listEquals(List<int> a, List<int> b) {
    if (identical(a, b)) {
      return true;
    }
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }
}
