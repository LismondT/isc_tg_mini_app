import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import 'package:tg_mini_app/game/game.dart';

class LevelPage extends World with HasGameReference<MainGame> {
  late Player player;

  @override
  Future<void> onLoad() async {}
}
