import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/widgets.dart';

import 'package:tg_mini_app/game/game.dart';

class Player extends SpriteComponent
    with HasGameReference<MainGame>, CollisionCallbacks {
  Player() : super(size: Vector2(50, 50), anchor: Anchor.center);

  late final SpawnComponent _bulletSpawner;

  int health = 3;
  bool isInvulnerable = false;
  Timer? _invulnerabilityTimer;
  final double invulnerabilityDuration = 2.0; // 2 секунды неуязвимости
  final double blinkInterval = 0.2; // Интервал м

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();

    sprite = await game.loadSprite('player/player1.png');

    position = game.size / 2;
    position.y = game.size.y + 100;

    add(
      MoveEffect.to(
        Vector2(game.size.x / 2, game.size.y * 2 / 3),
        EffectController(duration: 0.5, curve: Curves.decelerate),
      ),
    );

    _bulletSpawner = SpawnComponent(
      period: 0.25,
      selfPositioning: true,
      factory: (index) {
        return Bullet(position: position + Vector2(0, -height / 2));
      },
      autoStart: false,
    );
    game.add(_bulletSpawner);
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
      onHit();
    }
  }

  void move(Vector2 delta) {
    position.add(delta);
    _checkBorders();
  }

  void _checkBorders() {
    position.x = position.x.clamp(size.x / 2, game.size.x - size.x / 2);
    position.y = position.y.clamp(0, game.size.y);
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

  void onHit() {
    if (isInvulnerable) return;

    health--;

    game.shakeScreen();

    if (health <= 0) {
      onDie();
    }

    _activateInvulnerability();
  }

  void onDie() {
    _endInvulnerability();
    game.gameOver();
  }

  void _activateInvulnerability() {
    isInvulnerable = true;

    // Эффект мерцания
    final blinkEffect = SequenceEffect(
      [
        OpacityEffect.to(0.5, EffectController(duration: blinkInterval / 2)),
        OpacityEffect.to(1.0, EffectController(duration: blinkInterval / 2)),
      ],
      repeatCount: (invulnerabilityDuration / blinkInterval).round(),
      onComplete: () => _endInvulnerability(),
    );

    add(blinkEffect);
  }

  void _endInvulnerability() {
    isInvulnerable = false;
    _invulnerabilityTimer?.reset();
    _invulnerabilityTimer?.stop();

    // Восстанавливаем полную видимость
    if (sprite != null) {
      sprite!.paint.color = sprite!.paint.color.withOpacity(1.0);
    }
  }
}
