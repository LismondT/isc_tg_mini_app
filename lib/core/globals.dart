import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_telegram_miniapp/flutter_telegram_miniapp.dart';
import 'package:tg_mini_app/game/game.dart';

import 'dart:js_interop' as js;

import 'package:tg_mini_app/router.dart';

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
    WebApp().init();
    tgChatId = WebApp().initDataUnsafe.user?.id ?? 0;
  }

  static Future<void> sendPromoCode() async {
    if (tgChatId == 0) {
      router.push('/level/1');
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
