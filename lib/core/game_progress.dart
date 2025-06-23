import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tg_mini_app/core/globals.dart';

class GameProgress with ChangeNotifier {
  int _highestLevelCompleted = 0;
  int _currentLevel = 1;
  final int _totalLevels = Globals.levelsCount;

  GameProgress() {
    _load();
  }

  int get highestLevelCompleted => _highestLevelCompleted;
  int get currentLevel => _currentLevel;
  int get totalLevels => _totalLevels;
  bool get isWin => _currentLevel > _totalLevels;

  void completeLevel(int level) async {
    if (level > _highestLevelCompleted) {
      _highestLevelCompleted = level;
    }

    if (_currentLevel <= _totalLevels) {
      _currentLevel++;
    }

    await _save();
    notifyListeners();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _highestLevelCompleted = prefs.getInt('highestLevelCompleted') ?? 0;
    _currentLevel = prefs.getInt('currentLevel') ?? 1;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('highestLevelCompleted', _highestLevelCompleted);
    await prefs.setInt('currentLevel', _currentLevel);
  }
}
