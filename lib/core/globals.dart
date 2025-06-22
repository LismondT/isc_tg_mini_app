import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:telegram_web_app/telegram_web_app.dart';
import 'package:tg_mini_app/game/game.dart';
import 'package:tg_mini_app/router.dart';

import 'dart:js' as js;

class Globals {
  static late final String phrase;
  static late final String promoCode;
  static late final String tgToken;
  static int tgChatId = 0;
  static final String cleanPhrase = phrase.replaceAll(' ', '');
  static final levelsCount = cleanPhrase.length;

  static bool isWin = false;

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
    tgToken = data.tgToken!;
  }

  static Future<void> sendPromoCode() async {
    int chatId;

    try {
      final tg = js.context['Telegram']['WebApp'];
      final idStr = tg['initDataUnsafe']['user']['id'].toString();
      chatId = int.parse(idStr);
    } catch (e) {
      router.push('/level/1');
      return;
    }

    final String url = 'https://api.telegram.org/bot$tgToken/sendMessage';
    final dio = Dio();

    await dio.post(
      url,
      data: {
        'chat_id': chatId,
        'text':
            '''
🎉 Поздравляем с победой! 🎉

Вы успешно завершили игру и получаете специальный промокод:

<pre><code>$promoCode</code></pre>
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
