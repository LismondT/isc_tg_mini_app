import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tg_mini_app/main.dart';

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
            return GameScreen(level: levelId, onLevelComplete: (a) => {});
          },
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) =>
      const Scaffold(body: Center(child: Text('Page not found'))),
);
