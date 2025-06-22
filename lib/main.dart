import 'package:flutter/material.dart';
import 'package:flutter_telegram_miniapp/flutter_telegram_miniapp.dart';
import 'package:provider/provider.dart';
import 'package:tg_mini_app/core/core.dart';
import 'package:tg_mini_app/features/features.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WebApp().init();
  Globals.tgChatId = WebApp().initDataUnsafe.chat!.id;

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
