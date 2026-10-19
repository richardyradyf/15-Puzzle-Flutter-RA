enum Difficulty {
  easy(size: 3, label: 'Fácil', timeLimit: 3 * 60),
  medium(size: 4, label: 'Medio', timeLimit: 10 * 60),
  hard(size: 5, label: 'Difícil', timeLimit: 20 * 60);

  const Difficulty({
    required this.size,
    required this.label,
    required this.timeLimit,
  });

  /// Cantidad de filas/columnas (3 → 3x3).
  final int size;

  /// Nombre visible para el usuario.
  final String label;

  /// Tiempo máximo de la partida en segundos.
  final int timeLimit;

  /// Número de piezas (sin contar el espacio vacío).
  int get pieces => size * size - 1;

  /// Ej: "Medio (4x4)".
  String get fullLabel => '$label (${size}x$size)';
}

/// Estilos visuales disponibles para las piezas.
enum TileStyle {
  classic('Clásico'),
  colorful('Colorido'),
  retro('Retro'),
  minimal('Minimalista');

  const TileStyle(this.label);

  final String label;
}
