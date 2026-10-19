import 'package:flutter/material.dart';

import '../controllers/settings_controller.dart';
import '../models/game_settings.dart';
import '../theme/app_theme.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/menu_button.dart';
import 'game_screen.dart';
import 'instructions_screen.dart';
import 'scores_screen.dart';
import 'settings_screen.dart';


class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key, required this.settings});

  final SettingsController settings;

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _play(BuildContext context) async {
    if (!settings.hasChosenDifficulty) {
      final chosen = await _pickDifficulty(context);
      if (chosen == null) return;
      await settings.setDifficulty(chosen);
    }
    if (!context.mounted) return;
    _open(context, GameScreen(settings: settings));
  }

  Future<Difficulty?> _pickDifficulty(BuildContext context) {
    return showModalBottomSheet<Difficulty>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Elige la dificultad',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            for (final d in Difficulty.values)
              ListTile(
                leading: CircleAvatar(child: Text('${d.size}')),
                title: Text(d.fullLabel),
                subtitle: Text('${d.pieces} piezas'),
                onTap: () => Navigator.of(context).pop(d),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final animate = settings.animationsEnabled;

    final buttons = [
      MenuButton(
        label: 'Jugar',
        icon: Icons.play_arrow_rounded,
        primary: true,
        onPressed: () => _play(context),
      ),
      MenuButton(
        label: 'Marcadores',
        icon: Icons.emoji_events_outlined,
        onPressed: () =>
            _open(context, ScoresScreen(storage: settings.storage)),
      ),
      MenuButton(
        label: 'Configuración',
        icon: Icons.settings_outlined,
        onPressed: () => _open(context, SettingsScreen(settings: settings)),
      ),
      MenuButton(
        label: 'Cómo jugar',
        icon: Icons.help_outline,
        onPressed: () => _open(context, const InstructionsScreen()),
      ),
    ];

    return Scaffold(
      body: Container(
        decoration: AppTheme.background(theme.colorScheme),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FadeSlideIn(
                      enabled: animate,
                      child: Column(
                        children: [
                          Icon(Icons.grid_view_rounded,
                              size: 72, color: theme.colorScheme.primary),
                          const SizedBox(height: 8),
                          Text(
                            '15-Puzzle Flutter',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          ListenableBuilder(
                            listenable: settings,
                            builder: (context, _) => Text(
                              'Dificultad: ${settings.difficulty.fullLabel}',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    for (var i = 0; i < buttons.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: FadeSlideIn(
                          enabled: animate,
                          delayIndex: i + 1,
                          child: buttons[i],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}