import 'package:flutter/material.dart';
import 'package:tg_mini_app/core/globals.dart';

class GameProgress with ChangeNotifier {
  int _highestLevelCompleted = 0;
  int _currentLevel = 1;
  final int _totalLevels = Globals.levelsCount;
  int get highestLevelCompleted => _highestLevelCompleted;
  int get currentLevel => _currentLevel;
  int get totalLevels => _totalLevels;
  bool get isWin => _currentLevel > _totalLevels;

  void completeLevel(int level) {
    if (level > _highestLevelCompleted) {
      _highestLevelCompleted = level;
    }
    if (_currentLevel <= _totalLevels) {
      _currentLevel++;
    }

    notifyListeners();

    if (isWin) {
      Globals.isWin = true;
    }
  }
}
