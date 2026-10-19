import 'package:flutter/material.dart';

import '../models/game_settings.dart';
import '../utils/formatters.dart';

enum GameOverAction { restart, menu }

Future<GameOverAction> showGameOverDialog(
  BuildContext context, {
  required bool won,
  required int seconds,
  required int moves,
  required Difficulty difficulty,
  required bool isNewRecord,
  required bool animate,
  String? reason,
}) async {
  final result = await showGeneralDialog<GameOverAction>(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'Fin de partida',
    barrierColor: Colors.black54,
    transitionDuration:
        animate ? const Duration(milliseconds: 350) : Duration.zero,
    pageBuilder: (context, animation, secondaryAnimation) => GameOverDialog(
      won: won,
      seconds: seconds,
      moves: moves,
      difficulty: difficulty,
      isNewRecord: isNewRecord,
      reason: reason,
    ),
    transitionBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
        child: child,
      ),
    ),
  );
  return result ?? GameOverAction.menu;
}

class GameOverDialog extends StatelessWidget {
  const GameOverDialog({
    super.key,
    required this.won,
    required this.seconds,
    required this.moves,
    required this.difficulty,
    required this.isNewRecord,
    this.reason,
  });

  final bool won;
  final int seconds;
  final int moves;
  final Difficulty difficulty;
  final bool isNewRecord;
  final String? reason;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = won ? scheme.primary : scheme.error;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                won ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                size: 72,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                won ? '¡Ganaste!' : 'Perdiste',
                style: theme.textTheme.headlineMedium?.copyWith(color: color),
              ),
              if (reason != null) ...[
                const SizedBox(height: 4),
                Text(reason!, textAlign: TextAlign.center),
              ],
              if (isNewRecord) ...[
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: scheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '¡Nuevo récord!',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(color: scheme.onTertiaryContainer),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              _SummaryRow('Tiempo', formatDuration(seconds)),
              _SummaryRow('Movimientos', '$moves'),
              _SummaryRow('Dificultad', difficulty.fullLabel),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          Navigator.of(context).pop(GameOverAction.menu),
                      child: const Text('Menú principal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () =>
                          Navigator.of(context).pop(GameOverAction.restart),
                      child: const Text('Reiniciar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Text(label),
            const Spacer(),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      );
}