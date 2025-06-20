import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';
import 'package:tg_mini_app/game/game.dart';

class Enemy extends SpriteComponent
    with HasGameReference<MainGame>, CollisionCallbacks {
  Enemy({super.position})
    : super(size: Vector2.all(enemySize * 10), anchor: Anchor.center);

  static const enemySize = 10.0;
  int health = 10;
  bool isHit = false;
  final double knockbackForce = 10.0; // Сила отдачи

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await Sprite.load('enemies/Virus_0003.png');
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Продолжаем движение вниз, если нет активных эффектов
    if (!isHit) {
      position.y += dt * 250;
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

  void onHit(Bullet bullet) {
    bullet.removeFromParent();
    health--;
    isHit = true;

    // Эффект масштабирования
    final hitEffect = SequenceEffect([
      ScaleEffect.by(Vector2.all(0.9), EffectController(duration: 0.05)),
    ]);

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
