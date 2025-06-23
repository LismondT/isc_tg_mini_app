import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tg_mini_app/core/core.dart';
import 'package:tg_mini_app/features/features.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Globals.load();
  } catch (e) {
    print(e);
  }

  final gameProgress = await GameProgress.create();

  runApp(
    ChangeNotifierProvider.value(value: gameProgress, child: const MainApp()),
  );
}
