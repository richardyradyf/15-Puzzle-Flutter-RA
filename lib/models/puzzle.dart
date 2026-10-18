import 'dart:math';

class Puzzle {
  Puzzle._(this.size, this.tiles);

  /// Crea un tablero ya resuelto
  factory Puzzle.solved(int size) => Puzzle._(size, _solvedTiles(size));

  factory Puzzle.shuffled(int size, {Random? random}) {
    final rng = random ?? Random();
    final tiles = _solvedTiles(size);
    do {
      tiles.shuffle(rng);
    } while (!isSolvable(tiles, size) || _isSorted(tiles));
    return Puzzle._(size, tiles);
  }

  factory Puzzle.fromTiles(int size, List<int> tiles) =>
      Puzzle._(size, List<int>.of(tiles));

  final int size;
  final List<int> tiles;

  int get emptyIndex => tiles.indexOf(0);

  bool get isSolved => _isSorted(tiles);

  bool canMove(int index) {
    if (index < 0 || index >= tiles.length) return false;
    final empty = emptyIndex;
    final rowDiff = (index ~/ size - empty ~/ size).abs();
    final colDiff = (index % size - empty % size).abs();
    return rowDiff + colDiff == 1;
  }

  bool move(int index) {
    if (!canMove(index)) return false;
    final empty = emptyIndex;
    tiles[empty] = tiles[index];
    tiles[index] = 0;
    return true;
  }

  // ---------------------------------------------------------------------
  // Validación matemática de resolubilidad
  // ---------------------------------------------------------------------

  static int countInversions(List<int> tiles) {
    final numbers = tiles.where((t) => t != 0).toList();
    var inversions = 0;
    for (var i = 0; i < numbers.length; i++) {
      for (var j = i + 1; j < numbers.length; j++) {
        if (numbers[i] > numbers[j]) inversions++;
      }
    }
    return inversions;
  }

  static bool isSolvable(List<int> tiles, int size) {
    final inversions = countInversions(tiles);
    if (size.isOdd) return inversions.isEven;
    final emptyRowFromBottom = size - (tiles.indexOf(0) ~/ size);
    return emptyRowFromBottom.isEven ? inversions.isOdd : inversions.isEven;
  }

  static List<int> _solvedTiles(int size) => [
    for (var i = 1; i < size * size; i++) i,
    0,
  ];

  static bool _isSorted(List<int> tiles) {
    for (var i = 0; i < tiles.length - 1; i++) {
      if (tiles[i] != i + 1) return false;
    }
    return tiles.last == 0;
  }
}
