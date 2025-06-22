import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:telegram_web_app/telegram_web_app.dart';

import 'package:tg_mini_app/core/core.dart';
import 'package:tg_mini_app/features/features.dart';

void main() async {
  try {
    if (TelegramWebApp.instance.isSupported) {
      TelegramWebApp.instance.ready();
      Future.delayed(
        const Duration(seconds: 1),
        TelegramWebApp.instance.expand,
      );
    }
  } catch (e) {
    print("Error happened in Flutter while loading Telegram $e");
    // add delay for 'Telegram seldom not loading' bug
    await Future.delayed(const Duration(milliseconds: 200));
    main();
    return;
  }

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
