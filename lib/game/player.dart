import 'dart:async';

import 'package:flame/components.dart';

import 'game.dart';

class Player extends SpriteComponent with HasGameReference<MainGame> {
  Player() : super(size: Vector2(100, 150), anchor: Anchor.center);

  late final SpawnComponent _bulletSpawner;

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();

    sprite = await game.loadSprite('player-sprite.png');

    position = game.size / 2;

    _bulletSpawner = SpawnComponent(
      period: .2,
      selfPositioning: true,
      factory: (index) {
        return Bullet(position: position + Vector2(0, -height / 2));
      },
      autoStart: false,
    );
    game.add(_bulletSpawner);
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
}
