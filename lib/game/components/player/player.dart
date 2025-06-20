import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../../game.dart';

class Player extends SpriteComponent
    with HasGameReference<MainGame>, CollisionCallbacks {
  Player() : super(size: Vector2(50, 100), anchor: Anchor.center);

  late final SpawnComponent _bulletSpawner;

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();

    sprite = await game.loadSprite('player-sprite.png');

    position = game.size / 2;

    _bulletSpawner = SpawnComponent(
      period: 0.25,
      selfPositioning: true,
      factory: (index) {
        return Bullet(position: position + Vector2(0, -height / 2));
      },
      autoStart: false,
    );
    game.add(_bulletSpawner);
    debugMode = true;
    add(
      RectangleHitbox(
        position: size / 2,
        size: size / 4,
        anchor: Anchor.center,
      ),
    );
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Enemy) {
      game.gameOver();
    }
  }

  void move(Vector2 delta) {
    position.add(delta);
  }

  void startShooting() {
    _bulletSpawner.timer.start();
  }

  void stopShooting() {
    _bulletSpawner.timer.stop();
  }

  void resetPosition() {
    position = game.size / 2;
  }
}
