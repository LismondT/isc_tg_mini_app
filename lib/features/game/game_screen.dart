import 'package:flutter/material.dart';
import 'package:tg_mini_app/router.dart';

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
                      router.pop(true);
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
