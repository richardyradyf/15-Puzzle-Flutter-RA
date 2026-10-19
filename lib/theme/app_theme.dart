import 'package:flutter/material.dart';

/// (naranja Unimet). Material 3 deriva todos los demás colores.
abstract final class AppTheme {
  static const Color seed = Color(0xFFF57C00);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
      );

  static BoxDecoration background(ColorScheme scheme) => BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primaryContainer,
            scheme.surface,
            scheme.tertiaryContainer,
          ],
        ),
      );
}