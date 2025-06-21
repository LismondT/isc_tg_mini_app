import 'package:flutter/material.dart';
import 'package:tg_mini_app/router.dart';

class LevelCompleteOverlay extends StatelessWidget {
  static String id = 'level_complete_overlay';
  final String obtainedLetter;
  final int currentLevel;
  final int totalLevels;

  const LevelCompleteOverlay({
    super.key,
    required this.obtainedLetter,
    required this.currentLevel,
    required this.totalLevels,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.black.withAlpha(125),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.primary, width: 3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Уровень пройден!',
                style: TextStyle(
                  color: theme.onPrimaryContainer,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Уровень $currentLevel/$totalLevels',
                style: TextStyle(color: theme.onPrimaryContainer, fontSize: 18),
              ),
              const SizedBox(height: 30),
              Text(
                'Вы получили букву:',
                style: TextStyle(color: theme.onPrimaryContainer, fontSize: 20),
              ),
              const SizedBox(height: 15),
              // Анимированное отображение полученной буквы
              AnimatedLetterBox(letter: obtainedLetter),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => router.pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Далее',
                  style: TextStyle(fontSize: 20, color: theme.onPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedLetterBox extends StatefulWidget {
  final String letter;

  const AnimatedLetterBox({super.key, required this.letter});

  @override
  State<AnimatedLetterBox> createState() => _AnimatedLetterBoxState();
}

class _AnimatedLetterBoxState extends State<AnimatedLetterBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.2,
    ).chain(CurveTween(curve: Curves.elasticOut)).animate(_controller);

    _rotateAnimation = Tween<double>(
      begin: -0.2,
      end: 0,
    ).chain(CurveTween(curve: Curves.easeOutBack)).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotateAnimation.value,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.primary,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: theme.primary.withAlpha(100),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  widget.letter,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: theme.onPrimary,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
