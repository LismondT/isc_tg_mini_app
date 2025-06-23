import 'dart:math';
import 'package:flutter/material.dart';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';

import 'package:tg_mini_app/game/game.dart';

class Enemy extends SpriteComponent
    with HasGameReference<MainGame>, CollisionCallbacks {
  Enemy({
    super.position,
    this.movement = 'line',
    this.speed = 200,
    this.health = 1,
  }) : super(anchor: Anchor.center) {
    id = count;
    count++;
  }

  static int count = 0;
  late final int id;
  final String movement;
  final double speed;
  bool isRight = false;

  static const enemySize = 25.0;
  int health;
  bool isHit = false;
  final double knockbackForce = 10.0;

  late final double _circleRadius;
  late final double _circleSpeed;
  double _circleAngle = 0;
  Vector2 _circleCenter = Vector2.zero();

  late final double _pulseSpeed;
  late final double _rotationSpeed;
  late final double _baseScale;
  late final double _movementOffset;
  double _movementPhase = 0.0;
  double _pulsePhase = 0.0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    size = Vector2.all(enemySize + health * 1.5);

    _pulseSpeed = 1 + Random().nextDouble() * 0.5; // 1.0 - 1.5
    _rotationSpeed = (Random().nextDouble() - 0.5) * 0.5; // -0.25 - 0.25
    _baseScale = 0.9 + Random().nextDouble() * 0.2; // 0.9 - 1.1
    _movementOffset = Random().nextDouble() * 2 * pi;
    _movementPhase = Random().nextDouble() * 2 * pi;

    if (movement == 'circle') {
      _circleRadius = 30 + Random().nextDouble() * 40; // Радиус 30-70 пикселей
      _circleSpeed = 1 + Random().nextDouble() * 1.5; // Скорость 1-2.5 рад/сек
      _circleCenter = position.clone();
      _circleAngle = Random().nextDouble() * 2 * pi; // Случайный начальный угол
    }

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

    if (position.y - size.y > game.size.y) {
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

    final verticalBob = sin(_pulsePhase + _movementOffset) * 2;
    position.y += verticalBob * dt;
  }

  void _move(double dt) {
    switch (movement) {
      case 'circle':
        // Обновляем угол для движения по кругу
        _circleAngle += dt * _circleSpeed;

        // Вычисляем новую позицию на окружности
        final newX = _circleCenter.x + _circleRadius * cos(_circleAngle);
        final newY = _circleCenter.y + _circleRadius * sin(_circleAngle);

        // Применяем новую позицию
        position.setValues(newX, newY);

        // Центр круга медленно движется вниз
        _circleCenter.y += dt * speed / 3;
        break;
      case 'sine':
        final amplitude =
            game.size.x * 0.3; // Размах колебаний (30% ширины экрана)
        final frequency = 0.5; // Частота колебаний

        _movementPhase += dt * frequency;

        final centerX = game.size.x / 2; // Центр экрана по горизонтали
        position.x = centerX + sin(_movementPhase) * amplitude;

        // Продолжаем движение вниз с половинной скоростью
        position.y += dt * speed / 2;

        // Добавляем небольшие случайные колебания для натуральности
        final wiggle = sin(_pulsePhase * 3) * 1.5;
        position.x += wiggle * dt;
        break;
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
          position.x += moveValue / 2;
          if (position.x + size.x / 2 >= game.size.x) {
            isRight = false;
            add(wallHitEffect);
          }
        } else {
          position.x -= moveValue / 2;
          if (position.x - size.x / 2 <= 0) {
            isRight = true;
            add(wallHitEffect);
          }
        }

        position.y += moveValue / 2;
        break;
      case 'line':
      default:
        position.y += dt * speed / 2;
    }

    final wiggle = sin(_pulsePhase * 2) * 2;
    position.x += wiggle * dt;
  }

  void onHit(Bullet bullet) {
    bullet.removeFromParent();
    health--;
    isHit = true;

    final hitEffect = ScaleEffect.by(
      Vector2.all(0.7),
      EffectController(duration: 0.07),
    );

    final flashEffect = ColorEffect(
      const Color(0xFFFFFFFF),
      EffectController(duration: 0.1, alternate: true),
    );

    final knockbackEffect = MoveByEffect(
      Vector2(0, -knockbackForce), // Двигаем вверх
      EffectController(duration: 0.1, curve: Curves.easeOut),
      onComplete: () {
        isHit = false;
      },
    );

    add(hitEffect);
    add(flashEffect);
    add(knockbackEffect);

    if (health <= 0) {
      onDie();
    }
  }

  void onDie() {
    game.add(Explosion(position: position, size: size));
    //game.activeEnemies.remove(this);
    removeFromParent();
  }

  void onGameOver() {
    game.add(Explosion(position: position, size: size));
    removeFromParent();
  }
}
