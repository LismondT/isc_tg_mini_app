import 'package:flame/components.dart';
import 'package:tg_mini_app/game/main_game.dart';

class Explosion extends SpriteAnimationComponent
    with HasGameReference<MainGame> {
  Explosion({super.position, super.size})
    : super(anchor: Anchor.center, removeOnFinish: true);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    animation = await game.loadSpriteAnimation(
      'explosion.png',
      SpriteAnimationData.sequenced(
        amount: 6,
        stepTime: .1,
        textureSize: Vector2.all(32),
        loop: false,
      ),
    );
  }
}
