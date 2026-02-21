enum MoveDirection { up, down, left, right }

class HomeGameState {
  const HomeGameState({
    required this.board,
    required this.score,
    required this.bestScore,
    required this.hasWon,
    required this.isGameOver,
    required this.moveCount,
    required this.lastMoveDirection,
  });

  final List<int> board;
  final int score;
  final int bestScore;
  final bool hasWon;
  final bool isGameOver;
  final int moveCount;
  final MoveDirection? lastMoveDirection;

  factory HomeGameState.initial() {
    return const HomeGameState(
      board: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      score: 0,
      bestScore: 0,
      hasWon: false,
      isGameOver: false,
      moveCount: 0,
      lastMoveDirection: null,
    );
  }

  HomeGameState copyWith({
    List<int>? board,
    int? score,
    int? bestScore,
    bool? hasWon,
    bool? isGameOver,
    int? moveCount,
    MoveDirection? lastMoveDirection,
    bool clearLastMoveDirection = false,
  }) {
    return HomeGameState(
      board: board ?? this.board,
      score: score ?? this.score,
      bestScore: bestScore ?? this.bestScore,
      hasWon: hasWon ?? this.hasWon,
      isGameOver: isGameOver ?? this.isGameOver,
      moveCount: moveCount ?? this.moveCount,
      lastMoveDirection: clearLastMoveDirection
          ? null
          : (lastMoveDirection ?? this.lastMoveDirection),
    );
  }
}
