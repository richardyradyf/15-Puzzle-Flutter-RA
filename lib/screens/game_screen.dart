import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../controllers/settings_controller.dart';
import '../models/game_settings.dart';
import '../models/puzzle.dart';
import '../utils/formatters.dart';
import '../widgets/game_over_dialog.dart';
import '../widgets/puzzle_board.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.settings});

  final SettingsController settings;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final Difficulty _difficulty;
  late Puzzle _puzzle;
  Timer? _timer;
  int _moves = 0;
  int _seconds = 0;
  bool _started = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _difficulty = widget.settings.difficulty;
    _puzzle = Puzzle.shuffled(_difficulty.size);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool get _inProgress => _started && !_finished;
  int get _remaining => max(0, _difficulty.timeLimit - _seconds);

  // ---------------------------------------------------------------------
  // Flujo de la partida
  // ---------------------------------------------------------------------

  void _newGame() {
    _timer?.cancel();
    setState(() {
      _puzzle = Puzzle.shuffled(_difficulty.size);
      _moves = 0;
      _seconds = 0;
      _started = false;
      _finished = false;
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _finished) return;
      setState(() => _seconds++);
      if (_seconds >= _difficulty.timeLimit) {
        _endGame(won: false, reason: 'Se acabó el tiempo.');
      }
    });
  }

  void _onTileTap(int index) {
    if (_finished || !_puzzle.canMove(index)) return;
    setState(() {
      _puzzle.move(index);
      _moves++;
    });
    if (!_started) {
      _started = true;
      _startTimer();
    }
    if (_puzzle.isSolved) _endGame(won: true);
  }

  Future<void> _endGame({required bool won, String? reason}) async {
    if (_finished) return;
    _timer?.cancel();
    setState(() => _finished = true);

    final isRecord =
        won &&
        await widget.settings.storage.submitScore(
          _difficulty,
          seconds: _seconds,
          moves: _moves,
        );
    if (!mounted) return;

    final action = await showGameOverDialog(
      context,
      won: won,
      seconds: _seconds,
      moves: _moves,
      difficulty: _difficulty,
      isNewRecord: isRecord,
      reason: reason,
      animate: widget.settings.animationsEnabled,
    );
    if (!mounted) return;

    if (action == GameOverAction.restart) {
      _newGame();
    } else {
      Navigator.of(context).pop();
    }
  }

  // ---------------------------------------------------------------------
  // Confirmaciones (UX: nunca perder una partida por accidente)
  // ---------------------------------------------------------------------

  Future<bool> _confirm(String title, String message, String ok) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(ok),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _onRestartPressed() async {
    if (_inProgress &&
        !await _confirm(
          '¿Reiniciar?',
          'Se perderá la partida actual.',
          'Reiniciar',
        )) {
      return;
    }
    _newGame();
  }

  Future<void> _onGiveUpPressed() async {
    if (await _confirm(
      '¿Rendirse?',
      'La partida contará como perdida.',
      'Rendirse',
    )) {
      _endGame(won: false, reason: 'Te rendiste.');
    }
  }

  Future<void> _onBackPressed() async {
    final leave = await _confirm(
      '¿Salir de la partida?',
      'Perderás el progreso actual.',
      'Salir',
    );
    if (!leave || !mounted) return;
    _timer?.cancel();
    _finished = true;
    Navigator.of(context).pop();
  }

  // ---------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_inProgress,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _onBackPressed();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_difficulty.fullLabel),
          actions: [
            IconButton(
              tooltip: 'Reiniciar',
              icon: const Icon(Icons.refresh),
              onPressed: _onRestartPressed,
            ),
            IconButton(
              tooltip: 'Rendirse',
              icon: const Icon(Icons.flag_outlined),
              onPressed: _inProgress ? _onGiveUpPressed : null,
            ),
          ],
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 720;
              final stats = _StatsPanel(
                moves: _moves,
                seconds: _seconds,
                remaining: _remaining,
                started: _started,
                vertical: isWide,
              );
              final board = LayoutBuilder(
                builder: (context, area) {
                  final size = min(
                    min(area.maxWidth, area.maxHeight) - 24,
                    640.0,
                  );
                  return Center(
                    child: PuzzleBoard(
                      puzzle: _puzzle,
                      boardSize: max(size, 160.0),
                      style: widget.settings.tileStyle,
                      animate: widget.settings.animationsEnabled,
                      onTileTap: _onTileTap,
                    ),
                  );
                },
              );

              if (isWide) {
                return Row(
                  children: [
                    SizedBox(
                      width: 260,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: stats,
                      ),
                    ),
                    Expanded(child: board),
                  ],
                );
              }
              return Column(
                children: [
                  Padding(padding: const EdgeInsets.all(16), child: stats),
                  Expanded(child: board),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StatsPanel extends StatelessWidget {
  const _StatsPanel({
    required this.moves,
    required this.seconds,
    required this.remaining,
    required this.started,
    required this.vertical,
  });

  final int moves;
  final int seconds;
  final int remaining;
  final bool started;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final chips = [
      _StatChip(Icons.swipe_outlined, 'Movimientos', '$moves'),
      _StatChip(Icons.timer_outlined, 'Tiempo', formatDuration(seconds)),
      _StatChip(
        Icons.hourglass_bottom,
        'Restante',
        formatDuration(remaining),
        color: remaining <= 30 ? scheme.error : null,
      ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (vertical)
          ...chips.map(
            (c) =>
                Padding(padding: const EdgeInsets.only(bottom: 12), child: c),
          )
        else
          Row(
            children: [
              for (final c in chips)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: c,
                  ),
                ),
            ],
          ),
        if (!started)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Toca una pieza junto al espacio vacío para empezar',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip(this.icon, this.label, this.value, {this.color});

  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fg = color ?? theme.colorScheme.onSecondaryContainer;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: fg, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: fg,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(label, style: theme.textTheme.labelSmall?.copyWith(color: fg)),
        ],
      ),
    );
  }
}
