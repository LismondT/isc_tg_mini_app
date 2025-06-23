import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:tg_mini_app/game/game.dart';

class Globals {
  static late final String phrase;
  static late final String promoCode;
  static final String cleanPhrase = phrase.replaceAll(' ', '');
  static final levelsCount = cleanPhrase.length;

  static List<Level> levels = [];

  static Future<void> load() async {
    levels = await LevelLoader.loadLevels();
    await _loadGlobals();
  }

  static Future<void> _loadGlobals() async {
    final rawJson = await rootBundle.loadString('assets/config/config.json');
    final Map<String, dynamic> json = jsonDecode(rawJson);
    final data = _Data.fromJson(json);

    phrase = data.phrase!;
    promoCode = data.promoCode!;
  }
}

class _Data {
  final String? phrase;
  final String? promoCode;

  _Data({required this.phrase, required this.promoCode});

  factory _Data.fromJson(Map<String, dynamic> json) {
    return _Data(phrase: json['phrase'], promoCode: json['promo_code']);
  }
}
