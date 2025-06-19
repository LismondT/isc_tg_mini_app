import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:tg_mini_app/core/globals.dart';
import 'package:tg_mini_app/game/game.dart';
import 'package:tg_mini_app/game/overlays/level_complete_overlay.dart';

class GameScreen extends StatefulWidget {
  final int level;

  const GameScreen({super.key, required this.level});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: MainGame(widget.level),
        overlayBuilderMap: {
          LevelCompleteOverlay.id: (_, MainGame game) => LevelCompleteOverlay(
            currentLevel: game.level,
            totalLevels: Globals.levelsCount,
            obtainedLetter: Globals.cleanPhrase[game.level - 1],
          ),
        },
      ),
    );
  }
}
