import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:tg_mini_app/game/game.dart';

class LevelProgressBar extends PositionComponent
    with HasGameReference<MainGame> {
  final double maxTime;
  double currentTime = 0;
  @override
  final double height = 20;
  @override
  late double width;

  LevelProgressBar({required this.maxTime}) {
    priority = 10; // Высокий приоритет для отображения поверх других элементов
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    width = game.size.x - 40; // Ширина с отступами по 20 с каждой стороны
    position = Vector2(20, 20); // Позиция в верхней части экрана
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Фон полоски прогресса
    final bgRect = Rect.fromLTWH(0, 0, width, height);
    final bgPaint = Paint()..color = const Color.fromARGB(255, 47, 82, 63);
    canvas.drawRect(bgRect, bgPaint);

    // Заполненная часть
    final progress = currentTime / maxTime;
    final filledWidth = width * progress.clamp(0, 1);
    final filledRect = Rect.fromLTWH(0, 0, filledWidth, height);

    final gradient = LinearGradient(
      colors: [Colors.blue.shade400, Colors.green.shade400],
    );
    final filledPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, filledWidth, height),
      );

    canvas.drawRect(filledRect, filledPaint);

    // Обводка
    final borderPaint = Paint()
      ..color = Color.fromARGB(255, 116, 189, 202)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(bgRect, borderPaint);

    // Текст с оставшимся временем
    final textSpan = TextSpan(
      text: '${(maxTime - currentTime).toStringAsFixed(1)}s',
      style: const TextStyle(color: Colors.white, fontSize: 16),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        width / 2 - textPainter.width / 2,
        height / 2 - textPainter.height / 2,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    currentTime += dt;
    currentTime = currentTime.clamp(0, maxTime);
  }

  bool get isComplete => currentTime >= maxTime;
}
