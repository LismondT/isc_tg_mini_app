import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tg_mini_app/core/core.dart';
import 'package:tg_mini_app/router.dart';

import 'level_connection_painter.dart';

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
      duration: const Duration(milliseconds: 600),
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

    double targetOffset = currentLevelIndex * (_itemWidth + _itemSpacing);

    if (animate) {
      setState(() => _isAnimating = true);
      _scrollController
          .animateTo(
            targetOffset,
            duration: const Duration(milliseconds: 600),
            curve: Curves.fastOutSlowIn,
          )
          .then((_) {
            if (mounted) {
              setState(() => _isAnimating = false);
              if (gameProgress.isWin) {
                router.push('/win');
              }
            }
          });
    } else {
      _scrollController.jumpTo(targetOffset);
    }
  }

  void _onLevelComplete(int completedLevel) {
    final gameProgress = Provider.of<GameProgress>(context, listen: false);

    setState(() {
      _isAnimating = true;
      _animatedLevel = completedLevel;
    });

    _animationController.reset();

    _animationController.forward().then((_) async {
      if (mounted) {
        setState(() {
          _animatedLevel = null;
          _isAnimating = false;
        });

        gameProgress.completeLevel(completedLevel);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _centerCurrentLevel();
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

    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              alignment: Alignment.centerLeft,
              fit: BoxFit.fitHeight,
              image: AssetImage('assets/images/icon.png'),
            ),
          ),
        ),
        backgroundColor: theme.tertiary,
      ),
      body: Column(
        children: [
          Expanded(child: Container()),
          Card.filled(
            margin: const EdgeInsets.all(8.0),
            color: theme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: gameProgress.isWin
                  ? Text(
                      'Поздравляем! Вы собрали фразу! Промокод выслан в чат!',
                      style: Theme.of(context).textTheme.bodyLarge,
                    )
                  : Text(
                      'Пройдите все уровни, чтобы получить промокод!',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
            ),
          ),
          SizedBox(
            height: 120,
            child: Stack(
              children: [
                SizedBox(
                  width: totalContentWidth + horizontalPadding * 2,
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
                    itemCount: totalLevels + 1,
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

                      if (level == totalLevels + 1) {
                        return _buildWinCircle(currentLevel == level);
                      }

                      return _buildLevelCircle(
                        level: level,
                        isCompleted: isCompleted,
                        isCurrent: isCurrent,
                        isLocked: isLocked,
                        theme: Theme.of(context).colorScheme,
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
              onPressed: gameProgress.isWin || _isAnimating
                  ? null
                  : () async {
                      final result = await router.push<bool>(
                        '/level/$currentLevel',
                      );
                      if (result == true) {
                        _onLevelComplete(currentLevel);
                      }
                    },
              child: const Text('Играть'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: FilledButton(
              onPressed: () {
                router.push('/phrase/$currentLevel');
              },
              child: const Text('Прогресс'),
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildWinCircle(bool isWin) {
    return Container(
      width: _itemWidth,
      margin: EdgeInsets.only(right: _itemSpacing),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isWin ? Colors.amber : Colors.grey[300],
              shape: BoxShape.circle,
              border: Border.all(color: Colors.transparent, width: 2),
            ),
            child: Center(child: const Icon(Icons.flag, color: Colors.black)),
          ),
          Padding(padding: const EdgeInsets.only(top: 20.0)),
        ],
      ),
    );
  }

  Widget _buildLevelCircle({
    required int level,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLocked,
    required ColorScheme theme,
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
                  ? theme.primary
                  : isCompleted
                  ? Color(0xFF7AC6D4)
                  : Colors.grey[300],
              shape: BoxShape.circle,
              border: Border.all(
                color: isCurrent ? theme.primary : Colors.transparent,
                width: 2,
              ),
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                        color: theme.primary,
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
                'Вы здесь',
                style: TextStyle(color: theme.onSurface, fontSize: 12),
              ),
            ),
          if (isLocked)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Icon(Icons.lock, size: 16, color: Colors.grey[600]),
            ),
          if (isCompleted) Padding(padding: const EdgeInsets.only(top: 20.0)),
        ],
      ),
    );
  }
}
