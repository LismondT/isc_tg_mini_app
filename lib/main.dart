import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tg_mini_app/game/main_game.dart';

import 'router.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => GameProgress(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Доо',
      routerConfig: router,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}

class GameProgress with ChangeNotifier {
  int _highestLevelCompleted = 0;
  int _currentLevel = 1;

  int get highestLevelCompleted => _highestLevelCompleted;
  int get currentLevel => _currentLevel;

  void completeLevel(int level) {
    if (level > _highestLevelCompleted) {
      _highestLevelCompleted = level;
    }
    _currentLevel = level + 1;
    notifyListeners();
  }

  void setCurrentLevel(int level) {
    if (level <= _highestLevelCompleted + 1) {
      _currentLevel = level;
      notifyListeners();
    }
  }
}

class LevelSelectionScreen extends StatefulWidget {
  const LevelSelectionScreen({super.key});

  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int? _animatedLevel;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 800),
        )..addListener(() {
          setState(() {});
        });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startLevelAnimation(int level) {
    _animatedLevel = level;
    _animationController.forward(from: 0).then((_) {
      _animatedLevel = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameProgress = Provider.of<GameProgress>(context);
    final totalLevels = 10; // Adjust based on your game

    return Scaffold(
      appBar: AppBar(title: const Text('Выбери чёнить')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 150,
              child: CustomPaint(
                painter: LevelConnectorPainter(
                  levelCount: totalLevels,
                  completedLevels: gameProgress.highestLevelCompleted,
                  animatedLevel: _animatedLevel,
                  animationValue: _animationController.value,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(totalLevels, (index) {
                    final level = index + 1;
                    final isCompleted =
                        level <= gameProgress.highestLevelCompleted;
                    final isAvailable =
                        level <= gameProgress.highestLevelCompleted + 1;
                    final isAnimated = _animatedLevel == level;

                    return AnimatedLevelCircle(
                      level: level,
                      isCompleted: isCompleted,
                      isAvailable: isAvailable,
                      isAnimated: isAnimated,
                      animationValue: _animationController.value,
                      onTap: () {
                        if (isAvailable) {
                          gameProgress.setCurrentLevel(level);
                        }
                      },
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                router.go('/level/${gameProgress.currentLevel}');
              },
              child: const Text('Го батрачить'),
            ),
          ],
        ),
      ),
    );
  }
}

class LevelConnectorPainter extends CustomPainter {
  final int levelCount;
  final int completedLevels;
  final int? animatedLevel;
  final double animationValue;

  LevelConnectorPainter({
    required this.levelCount,
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
      ..color = Colors.green
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final itemWidth = size.width / levelCount;
    final centerY = size.height / 2;

    // Draw base line
    canvas.drawLine(Offset(0, centerY), Offset(size.width, centerY), paint);

    // Draw completed line
    if (completedLevels > 0) {
      double endX = (completedLevels * itemWidth)
          .clamp(0.0, size.width)
          .toDouble();

      if (animatedLevel != null && animatedLevel == completedLevels) {
        endX = (completedLevels - 1 + animationValue) * itemWidth;
      }

      canvas.drawLine(
        Offset(0, centerY),
        Offset(endX, centerY),
        completedPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant LevelConnectorPainter oldDelegate) {
    return oldDelegate.completedLevels != completedLevels ||
        oldDelegate.animatedLevel != animatedLevel ||
        oldDelegate.animationValue != animationValue;
  }
}

class AnimatedLevelCircle extends StatelessWidget {
  final int level;
  final bool isCompleted;
  final bool isAvailable;
  final bool isAnimated;
  final double animationValue;
  final VoidCallback onTap;

  const AnimatedLevelCircle({
    super.key,
    required this.level,
    required this.isCompleted,
    required this.isAvailable,
    required this.isAnimated,
    required this.animationValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = isAnimated ? 40 + 10 * animationValue : 40.0;
    final color = isCompleted
        ? Colors.green
        : isAvailable
        ? Colors.blue
        : Colors.grey;

    return GestureDetector(
      onTap: isAvailable ? onTap : null,
      child: Container(
        width: size,
        height: size,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(isAvailable ? 0.3 : 0.1),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        child: Center(
          child: Text(
            '$level',
            style: TextStyle(
              color: isAvailable ? Colors.black : Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: isAnimated ? 16 + 4 * animationValue : 16,
            ),
          ),
        ),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  final int level;

  const GameScreen({super.key, required this.level});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late MainGame game;

  @override
  void initState() {
    super.initState();
    game = MainGame(widget.level);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Уровень ${widget.level}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            router.go('/');
          },
        ),
      ),
      body: GameWidget(
        game: game,
        overlayBuilderMap: {
          'levelComplete': (context, game) {
            return LevelCompleteOverlay(
              level: widget.level,
              onNextLevel: () {
                Provider.of<GameProgress>(
                  context,
                  listen: false,
                ).completeLevel(widget.level);
                router.go('/');
              },
              onMenu: () {
                router.go('/');
              },
            );
          },
        },
      ),
    );
  }
}

class MyGame extends FlameGame {
  final int level;

  MyGame(this.level);

  @override
  Future<void> onLoad() async {
    // Implement your game logic here
    // For demonstration, we'll just show the completion overlay after 3 seconds
    await Future.delayed(const Duration(seconds: 3));
    overlays.add('levelComplete');
  }

  // Add your game implementation here
}

class LevelCompleteOverlay extends StatelessWidget {
  final int level;
  final VoidCallback onNextLevel;
  final VoidCallback onMenu;

  const LevelCompleteOverlay({
    super.key,
    required this.level,
    required this.onNextLevel,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ты прошл позвляю!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Уровень $level завершён с пробоем!',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: onNextLevel,
                  child: const Text('След ревень'),
                ),
                const SizedBox(width: 20),
                TextButton(onPressed: onMenu, child: const Text('Менюшка')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
