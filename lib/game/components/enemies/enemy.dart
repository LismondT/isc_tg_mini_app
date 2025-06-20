import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:tg_mini_app/game/game.dart';

class Enemy extends SpriteComponent
    with HasGameReference<MainGame>, CollisionCallbacks {
  Enemy({super.position})
    : super(size: Vector2.all(enemySize), anchor: Anchor.center);

  static const enemySize = 50.0;
  int health = 10;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    sprite = await Sprite.load('enemies/Virus_0003.png');

    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    position.y += dt * 250;

    if (position.y > game.size.y) {
      //removeFromParent();
      position.y = -enemySize;
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Bullet) {
      onHit(other);
    }
  }

  void onHit(Bullet bullet) {
    bullet.removeFromParent();
    onDie();
  }

  void onDie() {
    removeFromParent();
    game.add(Explosion(position: position));
  }
}
