import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tg_mini_app/core/game_progress.dart';
import 'package:tg_mini_app/features/main_app.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => GameProgress(),
      child: const MainApp(),
    ),
  );
}
