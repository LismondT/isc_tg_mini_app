import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:tg_mini_app/game/game.dart';

class Enemy extends SpriteComponent
    with HasGameReference<MainGame>, CollisionCallbacks {
  Enemy({super.position, this.movement = 'zigzag', this.speed = 200})
    : super(size: Vector2.all(enemySize * 10), anchor: Anchor.center);

  final String movement;
  final double speed;
  bool isRight = false;

  static const enemySize = 10.0;
  int health = 10;
  bool isHit = false;
  final double knockbackForce = 10.0;

  late final double _pulseSpeed;
  late final double _rotationSpeed;
  late final double _baseScale;
  double _pulsePhase = 0.0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _pulseSpeed = 1 + Random().nextDouble() * 0.5; // 1.0 - 1.5
    _rotationSpeed = (Random().nextDouble() - 0.5) * 0.5; // -0.25 - 0.25
    _baseScale = 0.9 + Random().nextDouble() * 0.2; // 0.9 - 1.1

    sprite = await Sprite.load('enemies/Virus_0003.png');
    isRight = Random.secure().nextBool();
    angle = Random().nextDouble() * 2 * pi;

    sprite!.paint = Paint.from(sprite!.paint)..color = Colors.green;

    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!isHit) {
      _updateAnimation(dt);
      _move(dt);
    }

    if (position.y > game.size.y) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Bullet && !isHit) {
      onHit(other);
    }
  }

  void _updateAnimation(double dt) {
    _pulsePhase += dt * _pulseSpeed;
    final pulseScale = _baseScale + sin(_pulsePhase) * 0.1;
    scale.setValues(pulseScale, pulseScale);

    angle += _rotationSpeed * dt;
  }

  void _move(double dt) {
    switch (movement) {
      case 'zigzag':
        final moveValue = dt * speed;
        final wallHitEffect = ScaleEffect.by(
          Vector2.all(1.3),
          EffectController(
            duration: 0.07,
            curve: Curves.linear,
            alternate: true,
          ),
        );

        if (isRight) {
          position.x += moveValue;
          if (position.x + size.x / 2 >= game.size.x) {
            isRight = false;
            add(wallHitEffect);
          }
        } else {
          position.x -= moveValue;
          if (position.x - size.x / 2 <= 0) {
            isRight = true;
            add(wallHitEffect);
          }
        }

        position.y += moveValue / 2;
        break;
      case 'line':
      default:
        position.y += dt * speed;
    }
  }

  void onHit(Bullet bullet) {
    bullet.removeFromParent();
    health--;
    isHit = true;

    // Эффект масштабирования
    final hitEffect = ScaleEffect.by(
      Vector2.all(0.8),
      EffectController(duration: 0.07, curve: Curves.decelerate),
    );

    // Эффект изменения цвета
    final flashEffect = ColorEffect(
      const Color(0xFFFFFFFF),
      EffectController(duration: 0.1, alternate: true),
    );

    // Эффект отдачи (отталкивание вверх)
    final knockbackEffect = MoveByEffect(
      Vector2(0, -knockbackForce), // Двигаем вверх
      EffectController(duration: 0.1, curve: Curves.easeOut),
      onComplete: () {
        // После отдачи продолжаем движение вниз
        isHit = false;
      },
    );

    // Добавляем все эффекты
    add(hitEffect);
    add(flashEffect);
    add(knockbackEffect);

    if (health <= 0) {
      onDie();
    }
  }

  void onDie() {
    removeFromParent();
    game.add(Explosion(position: position));
  }
}
