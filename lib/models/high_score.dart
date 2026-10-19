/// Récord guardado para una dificultad.
class HighScore {
  const HighScore({
    required this.bestSeconds,
    required this.bestMoves,
    required this.date,
  });

  factory HighScore.fromJson(Map<String, dynamic> json) => HighScore(
    bestSeconds: json['bestSeconds'] as int,
    bestMoves: json['bestMoves'] as int,
    date: DateTime.parse(json['date'] as String),
  );

  final int bestSeconds;
  final int bestMoves;
  final DateTime date;

  Map<String, dynamic> toJson() => {
    'bestSeconds': bestSeconds,
    'bestMoves': bestMoves,
    'date': date.toIso8601String(),
  };
}
