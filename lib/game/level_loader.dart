import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:tg_mini_app/game/game.dart';

class LevelLoader {
  static Future<List<Level>> loadLevels() async {
    final String data = await rootBundle.loadString(
      'assets/levels/levels.json',
    );
    final Map<String, dynamic> json = jsonDecode(data);
    return (json['levels'] as List)
        .map((level) => Level.fromJson(level))
        .toList();
  }
}
