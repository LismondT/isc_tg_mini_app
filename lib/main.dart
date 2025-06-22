import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:telegram_web_app/telegram_web_app.dart';

import 'package:tg_mini_app/core/core.dart';
import 'package:tg_mini_app/features/features.dart';

void main() async {
  TelegramWebApp.instance.ready();
  Globals.tgChatId = TelegramWebApp.instance.initData.chatInstance ?? 0;
  TelegramWebApp.instance.showPopup(
    message: 'Чат id: ${TelegramWebApp.instance.initData.chatInstance}',
    callback: (_) => {},
  );

  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Globals.load();
  } catch (e) {
    print(e);
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => GameProgress(),
      child: const MainApp(),
    ),
  );
}
