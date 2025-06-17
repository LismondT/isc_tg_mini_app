import 'dart:async';

import 'package:flame/components.dart';
import 'package:tg_mini_app/game/game.dart';

class LevelSelectorPage extends Component with HasGameReference<MainGame> {
  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
  }
}
