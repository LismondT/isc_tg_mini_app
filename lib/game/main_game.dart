import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'package:tg_mini_app/core/core.dart';
import 'package:tg_mini_app/game/game.dart';
import 'package:tg_mini_app/router.dart';

class MainGame extends FlameGame with PanDetector, HasCollisionDetection {
  final int levelNum;
  late final Level level;
  late final Player player;
  late final LevelProgressBar progressBar;
  late final SpriteComponent background;

  double gameTimer = 0;
  bool isWin = false;

  List<Enemy> activeEnemies = [];
  List<ScheduledEnemy> scheduledEnemies = [];
  int currentSpawnIndex = 0;

  MainGame(this.levelNum);

  @override
  FutureOr<void> onLoad() async {
    level = Globals.levels[levelNum - 1];

    player = Player();
    progressBar = LevelProgressBar(maxTime: level.duration);
    background = SpriteComponent(
      sprite: await Sprite.load('background.jpg'),
      autoResize: true,
    );
    add(background);
    add(player);
    add(progressBar);

    scheduleEnemies();
  }

  @override
  void update(double dt) {
    super.update(dt);
    gameTimer += dt;

    while (currentSpawnIndex < scheduledEnemies.length &&
        scheduledEnemies[currentSpawnIndex].spawnTime <= gameTimer) {
      spawnEnemy(scheduledEnemies[currentSpawnIndex]);
      currentSpawnIndex++;
    }

    if (progressBar.isComplete) {
      win();
    }
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (!isWin) {
      player.move(info.delta.global);
    }
  }

  @override
  void onPanStart(DragStartInfo info) {
    if (!isWin) {
      player.startShooting();
    }
  }

  @override
  void onPanEnd(DragEndInfo info) {
    player.stopShooting();
  }

  void win() {
    isWin = true;

    for (final enemy in activeEnemies) {
      if (enemy.parent != null) {
        enemy.onGameOver();
      }
    }
    activeEnemies.clear();

    player.add(
      MoveEffect.by(
        Vector2(0, -size.y - player.size.y),
        EffectController(
          duration: 1,
          curve: Curves.easeInCubic,
          alternate: false,
        ),
        onComplete: () {
          player.position.y = -30;
          removeWhere((c) => c is Explosion);
          overlays.add(LevelCompleteOverlay.id);
        },
      ),
    );
  }

  void scheduleEnemies() {
    scheduledEnemies.clear();
    currentSpawnIndex = 0;

    for (final wave in level.waves) {
      for (final group in wave.enemies) {
        final spawnTimes = wave.getSpawnTimes(group);
        for (int i = 0; i < group.count; i++) {
          scheduledEnemies.add(
            ScheduledEnemy(
              spawnTime: spawnTimes[i],
              imagePath: group.img,
              movementPattern: group.movement,
              bulletPattern: group.bulletPattern,
              minHealth: group.minHealth,
              maxHealth: group.maxHealth,
            ),
          );
        }
      }
    }

    scheduledEnemies.sort((a, b) => a.spawnTime.compareTo(b.spawnTime));
  }

  void spawnEnemy(ScheduledEnemy scheduledEnemy) {
    final x = Random.secure().nextInt(size.x.toInt()).toDouble();
    final health =
        Random.secure().nextInt(scheduledEnemy.maxHealth) +
        scheduledEnemy.minHealth;

    final enemy = Enemy(
      position: Vector2(x, -Enemy.enemySize),
      health: health,
      movement: scheduledEnemy.movementPattern,
    );
    add(enemy);
    activeEnemies.add(enemy);
  }

  void resetGame() async {
    final result = await router.push('/level/$levelNum');
    router.pop(result);
  }

  void gameOver() async {
    add(Explosion(position: player.position, size: player.size));
    remove(player);

    await Future.delayed(Duration(seconds: 1));

    pauseEngine();
    overlays.add(GameOverOverlay.id);
  }

  void shakeScreen({double intensity = 10.0, double duration = 0.15}) {
    final shakeEffect = SequenceEffect(
      [
        MoveEffect.by(
          Vector2(intensity, intensity),
          EffectController(duration: duration / 4, alternate: true),
        ),
        MoveEffect.by(
          Vector2(-intensity, -intensity),
          EffectController(duration: duration / 4, alternate: true),
        ),
        MoveEffect.by(
          Vector2(intensity, -intensity),
          EffectController(duration: duration / 4, alternate: true),
        ),
        MoveEffect.by(
          Vector2(-intensity, intensity),
          EffectController(duration: duration / 4, alternate: true),
        ),
      ],
      onComplete: () {
        background.position = Vector2.zero();
      },
    );

    background.add(shakeEffect);
  }
}
