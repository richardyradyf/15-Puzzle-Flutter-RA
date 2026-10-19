import 'package:flutter/material.dart';

import '../controllers/settings_controller.dart';
import '../models/game_settings.dart';
import '../utils/formatters.dart';
import '../widgets/puzzle_tile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.settings});

  final SettingsController settings;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  SettingsController get _s => widget.settings;

  @override
  Widget build(BuildContext context) {
    final d = _s.difficulty;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const _SectionTitle('Dificultad'),
              SegmentedButton<Difficulty>(
                segments: [
                  for (final level in Difficulty.values)
                    ButtonSegment(value: level, label: Text(level.label)),
                ],
                selected: {d},
                onSelectionChanged: (selection) {
                  _s.setDifficulty(selection.first);
                  setState(() {});
                },
              ),
              const SizedBox(height: 8),
              Text(
                '${d.size}x${d.size} · ${d.pieces} piezas · '
                'límite ${formatDuration(d.timeLimit)}',
                style: theme.textTheme.bodySmall,
              ),
              const _SectionTitle('Tema'),
              SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.system,
                    icon: Icon(Icons.brightness_auto),
                    label: Text('Auto'),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    icon: Icon(Icons.light_mode),
                    label: Text('Claro'),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    icon: Icon(Icons.dark_mode),
                    label: Text('Oscuro'),
                  ),
                ],
                selected: {_s.themeMode},
                onSelectionChanged: (selection) {
                  _s.setThemeMode(selection.first);
                  setState(() {});
                },
              ),
              const _SectionTitle('Estilo de las piezas'),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final style in TileStyle.values)
                    _StyleOption(
                      style: style,
                      selected: style == _s.tileStyle,
                      onTap: () {
                        _s.setTileStyle(style);
                        setState(() {});
                      },
                    ),
                ],
              ),
              const _SectionTitle('Otros'),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Animaciones'),
                subtitle: const Text('Desactívalas si el equipo es lento'),
                value: _s.animationsEnabled,
                onChanged: (value) {
                  _s.setAnimationsEnabled(value);
                  setState(() {});
                },
              ),
              const SizedBox(height: 16),
              FilledButton.tonalIcon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.check),
                label: const Text('Listo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 12),
        child: Text(text, style: Theme.of(context).textTheme.titleMedium),
      );
}

class _StyleOption extends StatelessWidget {
  const _StyleOption({
    required this.style,
    required this.selected,
    required this.onTap,
  });

  final TileStyle style;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 96,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? scheme.primary : scheme.outlineVariant,
          width: selected ? 3 : 1,
        ),
      ),
      child: Column(
        children: [
          SizedBox.square(
            dimension: 56,
            child: PuzzleTile(
              value: 7,
              total: 15,
              style: style,
              onTap: onTap,
            ),
          ),
          const SizedBox(height: 6),
          Text(style.label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}