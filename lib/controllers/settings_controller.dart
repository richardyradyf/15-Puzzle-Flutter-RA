import 'package:flutter/material.dart';

import '../models/game_settings.dart';
import '../services/storage_service.dart';

/// Guarda en memoria las preferencias y avisa a la UI cuando cambian.

class SettingsController extends ChangeNotifier {
  SettingsController(this.storage)
    : _difficulty = storage.loadDifficulty(),
      _themeMode = storage.loadThemeMode(),
      _tileStyle = storage.loadTileStyle(),
      _animationsEnabled = storage.loadAnimations();

  final StorageService storage;

  Difficulty _difficulty;
  ThemeMode _themeMode;
  TileStyle _tileStyle;
  bool _animationsEnabled;

  Difficulty get difficulty => _difficulty;
  ThemeMode get themeMode => _themeMode;
  TileStyle get tileStyle => _tileStyle;
  bool get animationsEnabled => _animationsEnabled;
  bool get hasChosenDifficulty => storage.hasDifficulty;

  Duration animDuration(int milliseconds) =>
      _animationsEnabled ? Duration(milliseconds: milliseconds) : Duration.zero;

  Future<void> setDifficulty(Difficulty value) async {
    _difficulty = value;
    notifyListeners();
    await storage.saveDifficulty(value);
  }

  Future<void> setThemeMode(ThemeMode value) async {
    _themeMode = value;
    notifyListeners();
    await storage.saveThemeMode(value);
  }

  Future<void> setTileStyle(TileStyle value) async {
    _tileStyle = value;
    notifyListeners();
    await storage.saveTileStyle(value);
  }

  Future<void> setAnimationsEnabled(bool value) async {
    _animationsEnabled = value;
    notifyListeners();
    await storage.saveAnimations(value);
  }
}
