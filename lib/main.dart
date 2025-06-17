import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

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
    return MaterialApp(
      title: 'Level Selection',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LevelSelectionScreen(),
    );
  }
}

class GameProgress with ChangeNotifier {
  int _highestLevelCompleted = 0;
  int _currentLevel = 1;
  final int _totalLevels = 35;

  int get highestLevelCompleted => _highestLevelCompleted;
  int get currentLevel => _currentLevel;
  int get totalLevels => _totalLevels;

  void completeLevel(int level) {
    if (level > _highestLevelCompleted) {
      _highestLevelCompleted = level;
    }
    if (_currentLevel < _totalLevels) {
      _currentLevel++;
    }
    notifyListeners();
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
  late ScrollController _scrollController;
  final double _itemWidth = 80.0;
  final double _itemSpacing = 20.0;
  int? _animatedLevel;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerCurrentLevel(animate: false);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _centerCurrentLevel({bool animate = true}) {
    final gameProgress = Provider.of<GameProgress>(context, listen: false);
    final currentLevelIndex = gameProgress.currentLevel - 1;

    final viewportWidth = MediaQuery.of(context).size.width;
    final totalContentWidth =
        gameProgress.totalLevels * (_itemWidth + _itemSpacing);

    double targetOffset = currentLevelIndex * (_itemWidth + _itemSpacing);

    // Позволяет проскроллить в обе стороны
    final maxScroll =
        totalContentWidth + _horizontalPadding() * 2 - viewportWidth;
    //targetOffset = targetOffset.clamp(0.0, maxScroll);

    if (animate) {
      setState(() => _isAnimating = true);
      _scrollController
          .animateTo(
            targetOffset,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
          )
          .then((_) {
            if (mounted) {
              setState(() => _isAnimating = false);
            }
          });
    } else {
      _scrollController.jumpTo(targetOffset);
    }
  }

  double _horizontalPadding() {
    return MediaQuery.of(context).size.width / 2 - _itemWidth / 2;
  }

  void _onLevelComplete(int completedLevel) {
    final gameProgress = Provider.of<GameProgress>(context, listen: false);

    setState(() {
      _isAnimating = true;
      _animatedLevel = completedLevel;
    });

    _animationController.reset();

    _animationController.forward().then((_) {
      if (mounted) {
        setState(() {
          _animatedLevel = null;
          _isAnimating = false;
        });

        // ⬇️ ВАЖНО: сначала обновляем прогресс
        gameProgress.completeLevel(completedLevel);

        // ⬇️ А теперь ждём завершения кадра, чтобы currentLevel обновился
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _centerCurrentLevel(); // теперь работает корректно
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameProgress = Provider.of<GameProgress>(context);
    final totalLevels = gameProgress.totalLevels;
    final currentLevel = gameProgress.currentLevel;
    final completedLevels = gameProgress.highestLevelCompleted;
    final horizontalPadding =
        MediaQuery.of(context).size.width / 2 - _itemWidth / 2;
    final totalContentWidth = totalLevels * (_itemWidth + _itemSpacing);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Выбор ревня'),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          SizedBox(
            height: 100,
            child: Stack(
              children: [
                SizedBox(
                  width: totalContentWidth + horizontalPadding * 2, // 👈 важно
                  height: 100,
                  child: CustomPaint(
                    painter: LevelConnectorPainter(
                      completedLevels: completedLevels,
                      animatedLevel: _animatedLevel,
                      animationValue: _animationController.value,
                    ),
                  ),
                ),
                NotificationListener<ScrollNotification>(
                  onNotification: (notification) => true,
                  child: ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: totalLevels,
                    padding: EdgeInsets.symmetric(
                      horizontal:
                          MediaQuery.of(context).size.width / 2 -
                          _itemWidth / 2,
                    ),
                    itemBuilder: (context, index) {
                      final level = index + 1;
                      final isCompleted = level <= completedLevels;
                      final isCurrent = level == currentLevel;
                      final isLocked = level > currentLevel;

                      return _buildLevelCircle(
                        level: level,
                        isCompleted: isCompleted,
                        isCurrent: isCurrent,
                        isLocked: isLocked,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: _isAnimating
                ? const CircularProgressIndicator()
                : FilledButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GameScreen(
                            level: currentLevel,
                            onLevelComplete: _onLevelComplete,
                          ),
                        ),
                      );
                    },
                    child: const Text('да я фембой'),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCircle({
    required int level,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLocked,
  }) {
    return Container(
      width: _itemWidth,
      margin: EdgeInsets.only(right: _itemSpacing),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: isCurrent ? 60 : 50,
            height: isCurrent ? 60 : 50,
            decoration: BoxDecoration(
              color: isCurrent
                  ? Colors.blue[400]
                  : isCompleted
                  ? Colors.green[400]
                  : Colors.grey[300],
              shape: BoxShape.circle,
              border: Border.all(
                color: isCurrent ? Colors.blue[800]! : Colors.transparent,
                width: 2,
              ),
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                '$level',
                style: TextStyle(
                  color: isCurrent ? Colors.white : Colors.black,
                  fontSize: isCurrent ? 24 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (isCurrent)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'я тута',
                style: TextStyle(color: Colors.blue[800], fontSize: 12),
              ),
            ),
          if (isLocked)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Icon(Icons.lock, size: 16, color: Colors.grey[600]),
            ),
        ],
      ),
    );
  }
}

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
      ..color = Colors.green
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

class GameScreen extends StatefulWidget {
  final int level;
  final Function(int) onLevelComplete;

  const GameScreen({
    super.key,
    required this.level,
    required this.onLevelComplete,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _levelCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Level ${widget.level}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Level ${widget.level} Content',
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 20),
                if (!_levelCompleted)
                  ElevatedButton(
                    onPressed: () {
                      setState(() => _levelCompleted = true);
                      widget.onLevelComplete(widget.level);
                      Future.delayed(const Duration(seconds: 1), () {
                        Navigator.pop(context);
                      });
                    },
                    child: const Text('Complete Level'),
                  ),
              ],
            ),
          ),
          if (_levelCompleted)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 80),
                  SizedBox(height: 20),
                  Text(
                    'Level Completed!',
                    style: TextStyle(
                      fontSize: 32,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
