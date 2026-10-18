import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_settings.dart';
import '../models/high_score.dart';

/// Única clase que habla con shared_preferences.
class StorageService {
  StorageService(this._prefs);

  static Future<StorageService> init() async =>
      StorageService(await SharedPreferences.getInstance());

  final SharedPreferences _prefs;

  static const _kDifficulty = 'difficulty';
  static const _kThemeMode = 'theme_mode';
  static const _kTileStyle = 'tile_style';
  static const _kAnimations = 'animations_enabled';

  static String _scoreKey(Difficulty d) => 'high_score_${d.name}';

  // ---------------------------------------------------------------------
  // Preferencias
  // ---------------------------------------------------------------------

  bool get hasDifficulty => _prefs.containsKey(_kDifficulty);

  Difficulty loadDifficulty() => _byName(
    Difficulty.values,
    _prefs.getString(_kDifficulty),
    Difficulty.medium,
  );

  ThemeMode loadThemeMode() => _byName(
    ThemeMode.values,
    _prefs.getString(_kThemeMode),
    ThemeMode.system,
  );

  TileStyle loadTileStyle() => _byName(
    TileStyle.values,
    _prefs.getString(_kTileStyle),
    TileStyle.classic,
  );

  bool loadAnimations() => _prefs.getBool(_kAnimations) ?? true;

  Future<void> saveDifficulty(Difficulty value) async {
    await _prefs.setString(_kDifficulty, value.name);
  }

  Future<void> saveThemeMode(ThemeMode value) async {
    await _prefs.setString(_kThemeMode, value.name);
  }

  Future<void> saveTileStyle(TileStyle value) async {
    await _prefs.setString(_kTileStyle, value.name);
  }

  Future<void> saveAnimations(bool value) async {
    await _prefs.setBool(_kAnimations, value);
  }

  // ---------------------------------------------------------------------
  // High Scores
  // ---------------------------------------------------------------------

  HighScore? loadHighScore(Difficulty difficulty) {
    final raw = _prefs.getString(_scoreKey(difficulty));
    if (raw == null) return null;
    try {
      return HighScore.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<bool> submitScore(
    Difficulty difficulty, {
    required int seconds,
    required int moves,
  }) async {
    final current = loadHighScore(difficulty);
    final isRecord =
        current == null ||
        seconds < current.bestSeconds ||
        moves < current.bestMoves;
    if (!isRecord) return false;

    final updated = HighScore(
      bestSeconds: current == null
          ? seconds
          : min(seconds, current.bestSeconds),
      bestMoves: current == null ? moves : min(moves, current.bestMoves),
      date: DateTime.now(),
    );
    await _prefs.setString(_scoreKey(difficulty), jsonEncode(updated.toJson()));
    return true;
  }

  Future<void> clearHighScores() async {
    for (final d in Difficulty.values) {
      await _prefs.remove(_scoreKey(d));
    }
  }

  static T _byName<T extends Enum>(List<T> values, String? name, T fallback) {
    for (final value in values) {
      if (value.name == name) return value;
    }
    return fallback;
  }
}
