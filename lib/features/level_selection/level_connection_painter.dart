import 'package:flutter/material.dart';

class LevelConnectorPainter extends CustomPainter {
  final int completedLevels;
  final int? animatedLevel;
  final double animationValue;

  LevelConnectorPainter({
    required this.completedLevels,
    this.animatedLevel,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final completedPaint = Paint()
      ..color = Color(0xFF7AC6D4)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final centerY = size.height / 2;

    canvas.drawLine(
      Offset(size.width / 2, centerY),
      Offset(size.width, centerY),
      paint,
    );

    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width / 2, centerY),
      completedPaint,
    );
  }

  @override
  bool shouldRepaint(covariant LevelConnectorPainter oldDelegate) {
    return oldDelegate.completedLevels != completedLevels ||
        oldDelegate.animatedLevel != animatedLevel ||
        oldDelegate.animationValue != animationValue;
  }
}
