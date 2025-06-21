import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_telegram_miniapp/flutter_telegram_miniapp.dart';
import 'package:tg_mini_app/game/game.dart';

class Globals {
  static late final String phrase;
  static late final String promoCode;
  static late final String tgToken;
  static late final int tgChatId;
  static final String cleanPhrase = phrase.replaceAll(' ', '');
  static final levelsCount = cleanPhrase.length;

  static List<Level> levels = [];

  static Future<void> load() async {
    levels = await LevelLoader.loadLevels();
    await _loadGlobals();
    final webApp = WebApp();
    webApp.init();
    try {
      tgChatId = webApp.initDataUnsafe.user?.id ?? 0;
    } catch (e) {
      tgChatId = 1491721075;
    }
  }

  static Future<void> _loadGlobals() async {
    final rawJson = await rootBundle.loadString('assets/config/config.json');
    final Map<String, dynamic> json = jsonDecode(rawJson);
    final data = _Data.fromJson(json);

    phrase = data.phrase!;
    promoCode = data.promoCode!;
    tgToken = data.tgToken!;
  }

  static Future<void> sendPromoCode() async {
    if (tgChatId == 0) {
      return;
    }

    final String url = 'https://api.telegram.org/bot$tgToken/sendMessage';
    final dio = Dio();

    await dio.post(
      url,
      data: {
        'chat_id': tgChatId,
        'text':
            '''
🎉 Поздравляем с победой! 🎉

Вы успешно завершили игру и получаете специальный промокод:

<code>$promoCode</code>
(нажмите, чтобы скопировать)

Спасибо за участие!
''',
        'parse_mode': 'HTML',
      },
    );
  }
}

class _Data {
  final String? phrase;
  final String? promoCode;
  final String? tgToken;

  _Data({required this.phrase, required this.promoCode, required this.tgToken});

  factory _Data.fromJson(Map<String, dynamic> json) {
    return _Data(
      phrase: json['phrase'],
      promoCode: json['promo_code'],
      tgToken: json['telegram_bot_token'],
    );
  }
}
