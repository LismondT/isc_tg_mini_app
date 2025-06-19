import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tg_mini_app/core/game_progress.dart';
import 'package:tg_mini_app/core/globals.dart';
import 'package:tg_mini_app/features/main_app.dart';
import 'package:tg_mini_app/game/level_loader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Globals.levels = await LevelLoader.loadLevels();
  runApp(
    ChangeNotifierProvider(
      create: (context) => GameProgress(),
      child: const MainApp(),
    ),
  );
}
