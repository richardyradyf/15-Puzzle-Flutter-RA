import 'package:flutter/material.dart';

import '../models/game_settings.dart';
import '../utils/formatters.dart';

/// Pantalla estática
class InstructionsScreen extends StatelessWidget {
  const InstructionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cómo jugar')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const _InfoCard(
                icon: Icons.flag_circle_outlined,
                title: 'Objetivo',
                text: 'Ordena las piezas en orden numérico utilizando el '
                    'espacio vacío para deslizar las piezas adyacentes.',
              ),
              const _InfoCard(
                icon: Icons.touch_app_outlined,
                title: 'Cómo mover',
                text: 'Toca (o haz clic en) una pieza que esté justo arriba, '
                    'abajo, a la izquierda o a la derecha del espacio vacío. '
                    'La pieza se deslizará hacia ese espacio. El cronómetro '
                    'empieza con tu primer movimiento.',
              ),
              const _InfoCard(
                icon: Icons.emoji_events_outlined,
                title: 'Cómo ganar',
                text: 'Ganas cuando todas las piezas quedan ordenadas de '
                    'izquierda a derecha y de arriba hacia abajo '
                    '(1, 2, 3, ...), dejando el espacio vacío en la última '
                    'casilla. Si mejoras tu tiempo o tus movimientos, se '
                    'guarda un nuevo récord.',
              ),
              _InfoCard(
                icon: Icons.timer_off_outlined,
                title: 'Cómo perder',
                text: 'Cada dificultad tiene un tiempo límite. Si el '
                    'cronómetro llega al límite sin resolver el tablero, '
                    'pierdes. También pierdes si pulsas "Rendirse".\n\n'
                    '${Difficulty.values.map((d) => '• ${d.fullLabel}: ${formatDuration(d.timeLimit)}').join('\n')}',
              ),
              const _InfoCard(
                icon: Icons.lightbulb_outline,
                title: 'Consejos',
                text: 'Resuelve primero la fila de arriba y luego la columna '
                    'izquierda; así el problema se reduce a un tablero más '
                    'pequeño. Todos los tableros generados tienen solución.',
              ),
              const SizedBox(height: 8),
              FilledButton.tonalIcon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Volver al menú'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.icon, required this.title, required this.text});

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: theme.colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(text, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}