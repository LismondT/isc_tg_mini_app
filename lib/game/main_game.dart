import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import 'package:tg_mini_app/game/components/ui/level_progress_bar.dart';
import 'package:tg_mini_app/game/enemy.dart';
import 'package:tg_mini_app/game/overlays/level_complete_overlay.dart';
import 'package:tg_mini_app/game/player.dart';

class MainGame extends FlameGame with PanDetector, HasCollisionDetection {
  final int level;
  late final Player player;
  late LevelProgressBar progressBar;
  final double levelDuration = 10.0;

  int killedEnemys = 0;

  MainGame(this.level);

  @override
  FutureOr<void> onLoad() async {
    player = Player();
    progressBar = LevelProgressBar(maxTime: levelDuration);

    add(
      SpawnComponent(
        factory: (index) {
          return Enemy();
        },
        period: 1 / level,
        area: Rectangle.fromLTWH(0, 0, size.x, -Enemy.enemySize),
      ),
    );

    final parallax = await loadParallaxComponent(
      [
        ParallaxImageData('stars.png'),
        ParallaxImageData('stars.png'),
        ParallaxImageData('stars.png'),
      ],
      baseVelocity: Vector2(0, -5),
      repeat: ImageRepeat.repeat,
      velocityMultiplierDelta: Vector2(2, 5),
    );

    add(parallax);
    add(player);
    add(progressBar);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (progressBar.isComplete) {
      win();
    }
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    player.move(info.delta.global);
  }

  @override
  void onPanStart(DragStartInfo info) {
    player.startShooting();
  }

  @override
  void onPanEnd(DragEndInfo info) {
    player.stopShooting();
  }

  void win() {
    paused = true;
    overlays.add(LevelCompleteOverlay.id);
  }

  void onEnemyKill() {}
}
