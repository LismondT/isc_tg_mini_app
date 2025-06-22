import 'package:flutter/material.dart';
import 'package:flutter_telegram_miniapp/flutter_telegram_miniapp.dart';
import 'package:go_router/go_router.dart';

import 'package:tg_mini_app/core/globals.dart';
import 'package:tg_mini_app/features/features.dart';

final router = GoRouter(
  initialLocation: '/',
  redirect: (BuildContext context, GoRouterState state) {
    final queryParams = state.uri.queryParameters.containsKey('tgWebAppData');
    if (queryParams && state.uri.toString() != '/') {
      return '/';
    }
    return null;
  },
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
