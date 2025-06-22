import 'package:flutter/material.dart';
import 'package:flutter_telegram_miniapp/flutter_telegram_miniapp.dart';
import 'package:provider/provider.dart';
import 'package:tg_mini_app/core/core.dart';
import 'package:tg_mini_app/features/features.dart';

void main() async {
  final webApp = WebApp();
  webApp.init();
  Globals.tgChatId = webApp.initDataUnsafe.chat!.id;

  WidgetsFlutterBinding.ensureInitialized();

  await webApp.showAlertAsync(message: 'aaaaaaaaaaa');

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
