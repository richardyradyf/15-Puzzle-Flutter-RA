import 'package:flutter/material.dart';

import '../models/game_settings.dart';
import '../models/puzzle.dart';
import 'puzzle_tile.dart';

class PuzzleBoard extends StatelessWidget {
  const PuzzleBoard({
    super.key,
    required this.puzzle,
    required this.boardSize,
    required this.style,
    required this.animate,
    required this.onTileTap,
  });

  final Puzzle puzzle;
  final double boardSize;
  final TileStyle style;
  final bool animate;
  final ValueChanged<int> onTileTap;

  static const double _padding = 8;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tileSize = (boardSize - _padding * 2) / puzzle.size;
    final total = puzzle.size * puzzle.size - 1;

    return Container(
      width: boardSize,
      height: boardSize,
      padding: const EdgeInsets.all(_padding),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          for (var value = 1; value <= total; value++)
            _buildTile(value, tileSize, total),
        ],
      ),
    );
  }

  Widget _buildTile(int value, double tileSize, int total) {
    final index = puzzle.tiles.indexOf(value);
    final row = index ~/ puzzle.size;
    final col = index % puzzle.size;

    return AnimatedPositioned(
      key: ValueKey(value),
      duration: animate ? const Duration(milliseconds: 180) : Duration.zero,
      curve: Curves.easeOutCubic,
      left: col * tileSize,
      top: row * tileSize,
      width: tileSize,
      height: tileSize,
      child: Padding(
        padding: EdgeInsets.all(tileSize * 0.04),
        child: PuzzleTile(
          value: value,
          total: total,
          style: style,
          isCorrect: index == value - 1,
          onTap: () => onTileTap(index),
        ),
      ),
    );
  }
}