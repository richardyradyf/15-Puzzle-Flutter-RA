import 'package:flutter/material.dart';

import '../models/game_settings.dart';
import '../models/high_score.dart';
import '../services/storage_service.dart';
import '../utils/formatters.dart';

class ScoresScreen extends StatefulWidget {
  const ScoresScreen({super.key, required this.storage});

  final StorageService storage;

  @override
  State<ScoresScreen> createState() => _ScoresScreenState();
}

class _ScoresScreenState extends State<ScoresScreen> {
  late Map<Difficulty, HighScore?> _scores;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _scores = {
      for (final d in Difficulty.values) d: widget.storage.loadHighScore(d),
    };
  }

  bool get _isEmpty => _scores.values.every((s) => s == null);

  Future<void> _confirmClear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.delete_forever_outlined),
        title: const Text('¿Borrar todos los marcadores?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await widget.storage.clearHighScores();
    if (!mounted) return;
    setState(_load); // recarga la lista (ahora vacía)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Marcadores borrados')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marcadores'),
        actions: [
          IconButton(
            tooltip: 'Borrar marcadores',
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: _isEmpty ? null : _confirmClear,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: _isEmpty
              ? const _EmptyState()
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    for (final d in Difficulty.values)
                      _ScoreCard(difficulty: d, score: _scores[d]),
                  ],
                ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.tonalIcon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.home_outlined),
            label: const Text('Volver al menú'),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events_outlined,
              size: 80, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text('Aún no hay récords', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text(
            '¡Resuelve tu primer rompecabezas y tu marca aparecerá aquí!',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.difficulty, required this.score});

  final Difficulty difficulty;
  final HighScore? score;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = score;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(difficulty.fullLabel, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            if (s == null)
              const Text('Sin récords todavía')
            else
              Wrap(
                spacing: 24,
                runSpacing: 12,
                children: [
                  _Stat(Icons.timer_outlined, 'Mejor tiempo',
                      formatDuration(s.bestSeconds)),
                  _Stat(Icons.swipe_outlined, 'Menos movimientos',
                      '${s.bestMoves}'),
                  _Stat(Icons.event_outlined, 'Fecha', formatDate(s.date)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.labelSmall),
            Text(value, style: theme.textTheme.titleMedium),
          ],
        ),
      ],
    );
  }
}