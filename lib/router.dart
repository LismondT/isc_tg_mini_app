import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tg_mini_app/core/globals.dart';
import 'package:tg_mini_app/features/game/game_screen.dart';
import 'package:tg_mini_app/features/level_selection/level_selection_screen.dart';
import 'package:tg_mini_app/features/phrase_progress/phrase_progress_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LevelSelectionScreen(),
      routes: [
        GoRoute(
          path: 'level/:levelId',
          builder: (context, state) {
            final levelId = int.parse(state.pathParameters['levelId']!);
            return GameScreen(level: levelId);
          },
        ),
        GoRoute(
          path: 'phrase/:levelId',
          builder: (context, state) {
            final levelId = int.parse(state.pathParameters['levelId']!);
            return PhraseProgressScreen(
              unlockedLetters: levelId - 1,
              fullPhrase: Globals.phrase,
              totalLevels: Globals.levelsCount,
            );
          },
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) =>
      const Scaffold(body: Center(child: Text('Page not found'))),
);
