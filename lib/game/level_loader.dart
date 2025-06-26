import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:tg_mini_app/game/game.dart';

class LevelLoader {
  static Future<List<Level>> loadLevels() async {
    try {
      // Пробуем загрузить из внешнего источника
      final response = await Dio().get('/config/levels.json');
      return (response.data['levels'] as List)
          .map((level) => Level.fromJson(level))
          .toList();
    } catch (e) {
      // Fallback к bundled версии
      print('Failed to load external levels, using bundled version: $e');
      final String data = await rootBundle.loadString(
        'assets/levels/levels.json',
      );
      final Map<String, dynamic> json = jsonDecode(data);
      return (json['levels'] as List)
          .map((level) => Level.fromJson(level))
          .toList();
    }
  }
}
