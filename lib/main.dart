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
  final int _totalLevels = 10;

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
    final targetOffset =
        currentLevelIndex * (_itemWidth + _itemSpacing) -
        (viewportWidth / 2) +
        (_itemWidth / 2);

    if (animate) {
      _isAnimating = true;
      _scrollController
          .animateTo(
            targetOffset,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
          )
          .then((_) {
            _isAnimating = false;
          });
    } else {
      _scrollController.jumpTo(targetOffset);
    }
  }

  void _onLevelComplete(int completedLevel) {
    final gameProgress = Provider.of<GameProgress>(context, listen: false);
    _animatedLevel = completedLevel;
    _animationController.forward(from: 0).then((_) {
      _animatedLevel = null;
      gameProgress.completeLevel(completedLevel);
      _centerCurrentLevel();
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameProgress = Provider.of<GameProgress>(context);
    final totalLevels = gameProgress.totalLevels;
    final currentLevel = gameProgress.currentLevel;
    final completedLevels = gameProgress.highestLevelCompleted;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Level'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          SizedBox(
            height: 100,
            child: Stack(
              children: [
                // Connector line
                Positioned.fill(
                  child: CustomPaint(
                    painter: LevelConnectorPainter(
                      levelCount: totalLevels,
                      completedLevels: completedLevels,
                      animatedLevel: _animatedLevel,
                      animationValue: _animationController.value,
                    ),
                  ),
                ),
                // Levels list
                NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is UserScrollNotification &&
                        notification.direction != ScrollDirection.idle) {
                      return true;
                    }
                    return false;
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: totalLevels,
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
            child: FilledButton(
              onPressed: _isAnimating
                  ? null
                  : () {
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
              child: const Text('Start Level'),
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
      margin: EdgeInsets.symmetric(horizontal: _itemSpacing / 2),
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
                'Current',
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

// import 'package:flame/game.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:provider/provider.dart';
// import 'package:tg_mini_app/game/main_game.dart';

// import 'router.dart';

// void main() {
//   runApp(
//     ChangeNotifierProvider(
//       create: (context) => GameProgress(),
//       child: const MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp.router(
//       title: 'Доо',
//       routerConfig: router,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//     );
//   }
// }

// class GameProgress with ChangeNotifier {
//   int _highestLevelCompleted = 0;
//   int _currentLevel = 1;
//   final int _totalLevels = 10;

//   int get highestLevelCompleted => _highestLevelCompleted;
//   int get currentLevel => _currentLevel;
//   int get totalLevels => _totalLevels;

//   void completeLevel(int level) {
//     if (level > _highestLevelCompleted) {
//       _highestLevelCompleted = level;
//     }
//     if (_currentLevel < _totalLevels) {
//       _currentLevel++;
//     }
//     notifyListeners();
//   }
// }

// class LevelSelectionScreen extends StatefulWidget {
//   const LevelSelectionScreen({super.key});

//   @override
//   State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
// }

// class _LevelSelectionScreenState extends State<LevelSelectionScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late ScrollController _scrollController;
//   final double _itemWidth = 80.0;
//   final double _itemSpacing = 20.0;
//   int _currentLevelIndex = 0;
//   bool _isAnimating = false;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 600),
//     );
//     _scrollController = ScrollController();

//     // Initialize current level position
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _centerCurrentLevel(animate: false);
//     });
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void _centerCurrentLevel({bool animate = true}) {
//     final gameProgress = Provider.of<GameProgress>(context, listen: false);
//     _currentLevelIndex = gameProgress.currentLevel - 1;

//     final viewportWidth = MediaQuery.of(context).size.width;
//     final targetOffset =
//         _currentLevelIndex * (_itemWidth + _itemSpacing) -
//         (viewportWidth / 2) +
//         (_itemWidth / 2);

//     if (animate) {
//       _isAnimating = true;
//       _animationController.forward(from: 0).then((_) {
//         _isAnimating = false;
//       });

//       _scrollController.animateTo(
//         targetOffset,
//         duration: const Duration(milliseconds: 600),
//         curve: Curves.easeInOut,
//       );
//     } else {
//       _scrollController.jumpTo(targetOffset);
//     }
//   }

//   void _onLevelComplete(int completedLevel) {
//     final gameProgress = Provider.of<GameProgress>(context, listen: false);
//     gameProgress.completeLevel(completedLevel);
//     _centerCurrentLevel();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final gameProgress = Provider.of<GameProgress>(context);
//     final totalLevels = 10;
//     final currentLevel = gameProgress.currentLevel;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Select Level'),
//         automaticallyImplyLeading: false,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: NotificationListener<ScrollNotification>(
//               onNotification: (notification) {
//                 // Prevent manual scrolling
//                 if (notification is UserScrollNotification &&
//                     notification.direction != ScrollDirection.idle) {
//                   return true;
//                 }
//                 return false;
//               },
//               child: ListView.builder(
//                 controller: _scrollController,
//                 scrollDirection: Axis.horizontal,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: totalLevels,
//                 itemBuilder: (context, index) {
//                   final level = index + 1;
//                   final isCompleted = level < currentLevel;
//                   final isCurrent = level == currentLevel;
//                   final isLocked = level > currentLevel;

//                   return _buildLevelCircle(
//                     level: level,
//                     isCompleted: isCompleted,
//                     isCurrent: isCurrent,
//                     isLocked: isLocked,
//                   );
//                 },
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: FilledButton(
//               onPressed: _isAnimating
//                   ? null
//                   : () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => GameScreen(
//                             level: currentLevel,
//                             onLevelComplete: _onLevelComplete,
//                           ),
//                         ),
//                       );
//                     },
//               child: const Text('Start Level'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLevelCircle({
//     required int level,
//     required bool isCompleted,
//     required bool isCurrent,
//     required bool isLocked,
//   }) {
//     return Container(
//       width: _itemWidth,
//       margin: EdgeInsets.symmetric(horizontal: _itemSpacing / 2),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: isCurrent ? 60 : 50,
//             height: isCurrent ? 60 : 50,
//             decoration: BoxDecoration(
//               color: isCurrent
//                   ? Colors.blue[400]
//                   : isCompleted
//                   ? Colors.green[400]
//                   : Colors.grey[300],
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color: isCurrent ? Colors.blue[800]! : Colors.transparent,
//                 width: 2,
//               ),
//               boxShadow: isCurrent
//                   ? [
//                       BoxShadow(
//                         color: Colors.blue.withOpacity(0.5),
//                         blurRadius: 10,
//                         spreadRadius: 2,
//                       ),
//                     ]
//                   : null,
//             ),
//             child: Center(
//               child: Text(
//                 '$level',
//                 style: TextStyle(
//                   color: isCurrent ? Colors.white : Colors.black,
//                   fontSize: isCurrent ? 24 : 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//           if (isCurrent)
//             Padding(
//               padding: const EdgeInsets.only(top: 8.0),
//               child: Text(
//                 'Current',
//                 style: TextStyle(color: Colors.blue[800], fontSize: 12),
//               ),
//             ),
//           if (isLocked)
//             Padding(
//               padding: const EdgeInsets.only(top: 8.0),
//               child: Icon(Icons.lock, size: 16, color: Colors.grey[600]),
//             ),
//         ],
//       ),
//     );
//   }
// }

// class LevelConnectorPainter extends CustomPainter {
//   final int levelCount;
//   final int completedLevels;
//   final int? animatedLevel;
//   final double animationValue;

//   LevelConnectorPainter({
//     required this.levelCount,
//     required this.completedLevels,
//     this.animatedLevel,
//     required this.animationValue,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.grey[300]!
//       ..strokeWidth = 2
//       ..style = PaintingStyle.stroke;

//     final completedPaint = Paint()
//       ..color = Colors.green
//       ..strokeWidth = 3
//       ..style = PaintingStyle.stroke;

//     final itemWidth = size.width / levelCount;
//     final centerY = size.height / 2;

//     // Draw base line
//     canvas.drawLine(Offset(0, centerY), Offset(size.width, centerY), paint);

//     // Draw completed line
//     if (completedLevels > 0) {
//       double endX = (completedLevels * itemWidth)
//           .clamp(0.0, size.width)
//           .toDouble();

//       if (animatedLevel != null && animatedLevel == completedLevels) {
//         endX = (completedLevels - 1 + animationValue) * itemWidth;
//       }

//       canvas.drawLine(
//         Offset(0, centerY),
//         Offset(endX, centerY),
//         completedPaint,
//       );
//     }
//   }

//   @override
//   bool shouldRepaint(covariant LevelConnectorPainter oldDelegate) {
//     return oldDelegate.completedLevels != completedLevels ||
//         oldDelegate.animatedLevel != animatedLevel ||
//         oldDelegate.animationValue != animationValue;
//   }
// }

// class AnimatedLevelCircle extends StatelessWidget {
//   final int level;
//   final bool isCompleted;
//   final bool isAvailable;
//   final bool isAnimated;
//   final double animationValue;
//   final VoidCallback onTap;

//   const AnimatedLevelCircle({
//     super.key,
//     required this.level,
//     required this.isCompleted,
//     required this.isAvailable,
//     required this.isAnimated,
//     required this.animationValue,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final size = isAnimated ? 40 + 10 * animationValue : 40.0;
//     final color = isCompleted
//         ? Colors.green
//         : isAvailable
//         ? Colors.blue
//         : Colors.grey;

//     return GestureDetector(
//       onTap: isAvailable ? onTap : null,
//       child: Container(
//         width: size,
//         height: size,
//         margin: const EdgeInsets.symmetric(horizontal: 10),
//         decoration: BoxDecoration(
//           color: color.withOpacity(isAvailable ? 0.3 : 0.1),
//           shape: BoxShape.circle,
//           border: Border.all(color: color, width: 2),
//         ),
//         child: Center(
//           child: Text(
//             '$level',
//             style: TextStyle(
//               color: isAvailable ? Colors.black : Colors.grey,
//               fontWeight: FontWeight.bold,
//               fontSize: isAnimated ? 16 + 4 * animationValue : 16,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class GameScreen extends StatefulWidget {
//   final int level;
//   final Function(int) onLevelComplete;

//   const GameScreen({
//     super.key,
//     required this.level,
//     required this.onLevelComplete,
//   });

//   @override
//   State<GameScreen> createState() => _GameScreenState();
// }

// class _GameScreenState extends State<GameScreen> {
//   bool _levelCompleted = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Level ${widget.level}'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       body: Stack(
//         children: [
//           // Your game content here
//           Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   'Level ${widget.level} Content',
//                   style: const TextStyle(fontSize: 24),
//                 ),
//                 const SizedBox(height: 20),
//                 if (!_levelCompleted)
//                   ElevatedButton(
//                     onPressed: () {
//                       setState(() => _levelCompleted = true);
//                       widget.onLevelComplete(widget.level);
//                       Future.delayed(const Duration(seconds: 1), () {
//                         Navigator.pop(context);
//                       });
//                     },
//                     child: const Text('Complete Level'),
//                   ),
//               ],
//             ),
//           ),
//           if (_levelCompleted)
//             const Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.check_circle, color: Colors.green, size: 80),
//                   SizedBox(height: 20),
//                   Text(
//                     'Level Completed!',
//                     style: TextStyle(
//                       fontSize: 32,
//                       color: Colors.green,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// class MyGame extends FlameGame {
//   final int level;

//   MyGame(this.level);

//   @override
//   Future<void> onLoad() async {
//     // Implement your game logic here
//     // For demonstration, we'll just show the completion overlay after 3 seconds
//     await Future.delayed(const Duration(seconds: 3));
//     overlays.add('levelComplete');
//   }

//   // Add your game implementation here
// }

// class LevelCompleteOverlay extends StatelessWidget {
//   final int level;
//   final VoidCallback onNextLevel;
//   final VoidCallback onMenu;

//   const LevelCompleteOverlay({
//     super.key,
//     required this.level,
//     required this.onNextLevel,
//     required this.onMenu,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: Colors.black.withOpacity(0.7),
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text(
//               'Ты прошл позвляю!',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 30,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               'Уровень $level завершён с пробоем!',
//               style: const TextStyle(color: Colors.white, fontSize: 18),
//             ),
//             const SizedBox(height: 30),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 ElevatedButton(
//                   onPressed: onNextLevel,
//                   child: const Text('След ревень'),
//                 ),
//                 const SizedBox(width: 20),
//                 TextButton(onPressed: onMenu, child: const Text('Менюшка')),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
