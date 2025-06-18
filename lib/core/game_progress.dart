import 'package:flutter/material.dart';

class GameProgress with ChangeNotifier {
  int _highestLevelCompleted = 0;
  int _currentLevel = 1;
  final int _totalLevels = 35;

  int get highestLevelCompleted => _highestLevelCompleted;
  int get currentLevel => _currentLevel;
  int get totalLevels => _totalLevels;

  void completeLevel(int level) {
    if (level > _highestLevelCompleted) {
      _highestLevelCompleted = level;
    }
    if (_currentLevel < _totalLevels) {
      _currentLevel++;
    }
    notifyListeners();
  }
}
