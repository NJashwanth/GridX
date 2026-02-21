enum MoveDirection { up, down, left, right }

class HomeGameState {
  const HomeGameState({
    required this.board,
    required this.score,
    required this.bestScore,
    required this.hasWon,
    required this.isGameOver,
  });

  final List<int> board;
  final int score;
  final int bestScore;
  final bool hasWon;
  final bool isGameOver;

  factory HomeGameState.initial() {
    return const HomeGameState(
      board: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      score: 0,
      bestScore: 0,
      hasWon: false,
      isGameOver: false,
    );
  }

  HomeGameState copyWith({
    List<int>? board,
    int? score,
    int? bestScore,
    bool? hasWon,
    bool? isGameOver,
  }) {
    return HomeGameState(
      board: board ?? this.board,
      score: score ?? this.score,
      bestScore: bestScore ?? this.bestScore,
      hasWon: hasWon ?? this.hasWon,
      isGameOver: isGameOver ?? this.isGameOver,
    );
  }
}
