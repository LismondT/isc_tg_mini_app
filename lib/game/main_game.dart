import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';

import 'package:tg_mini_app/core/core.dart';
import 'package:tg_mini_app/game/game.dart';

class MainGame extends FlameGame with PanDetector, HasCollisionDetection {
  final int levelNum;
  late final Level level;
  late final Player player;
  late LevelProgressBar progressBar;

  double gameTimer = 0;

  List<Enemy> activeEnemies = [];
  List<ScheduledEnemy> scheduledEnemies = [];
  int currentSpawnIndex = 0;

  MainGame(this.levelNum);

  @override
  FutureOr<void> onLoad() async {
    level = Globals.levels[levelNum - 1];

    player = Player();
    progressBar = LevelProgressBar(maxTime: level.duration);
    add(
      SpriteComponent(sprite: await Sprite.load('background.jpg'), size: size),
    );
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
            ),
          );
        }
      }
    }

    scheduledEnemies.sort((a, b) => a.spawnTime.compareTo(b.spawnTime));
  }

  void spawnEnemy(ScheduledEnemy scheduledEnemi) {
    final x = Random.secure().nextInt(size.x as int) as double;
    final enemy = Enemy(position: Vector2(x, -Enemy.enemySize));
    add(enemy);
    activeEnemies.add(enemy);
  }
}
