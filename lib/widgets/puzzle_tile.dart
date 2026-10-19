import 'package:flutter/material.dart';

import '../models/game_settings.dart';

class PuzzleTile extends StatelessWidget {
  const PuzzleTile({
    super.key,
    required this.value,
    required this.total,
    required this.style,
    required this.onTap,
    this.isCorrect = false,
  });

  final int value;
  final int total;
  final TileStyle style;
  final bool isCorrect; 
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final (bg, fg, side, radius, weight) = switch (style) {
      TileStyle.classic => (
          isCorrect ? scheme.primary : scheme.primaryContainer,
          isCorrect ? scheme.onPrimary : scheme.onPrimaryContainer,
          BorderSide.none,
          12.0,
          FontWeight.bold,
        ),
      TileStyle.colorful => (
          HSLColor.fromAHSL(1, (value - 1) * 300 / total, 0.7, 0.5).toColor(),
          Colors.white,
          isCorrect
              ? const BorderSide(color: Colors.white, width: 3)
              : BorderSide.none,
          14.0,
          FontWeight.w800,
        ),
      TileStyle.retro => (
          const Color(0xFF0F1F0F),
          const Color(0xFF39FF14),
          BorderSide(
            color: const Color(0xFF39FF14),
            width: isCorrect ? 3 : 1.5,
          ),
          2.0,
          FontWeight.bold,
        ),
      TileStyle.minimal => (
          isCorrect ? scheme.surfaceContainerHigh : scheme.surface,
          scheme.onSurface,
          BorderSide(color: scheme.outlineVariant),
          8.0,
          FontWeight.w300,
        ),
    };

    return Material(
      color: bg,
      elevation: style == TileStyle.minimal ? 0 : 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: side,
      ),
      child: InkWell(
        onTap: onTap,
        child: Center(
          // FittedBox escala el número al tamaño de la pieza (responsive).
          child: FittedBox(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                '$value',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: weight,
                  color: fg,
                  fontFamily: style == TileStyle.retro ? 'monospace' : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
