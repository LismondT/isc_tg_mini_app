import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tg_mini_app/core/core.dart';
import 'package:tg_mini_app/features/features.dart';
import 'package:tg_mini_app/game/game.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    Globals.levels = await LevelLoader.loadLevels();
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
