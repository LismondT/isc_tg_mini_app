import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tg_mini_app/core/globals.dart';
import 'package:tg_mini_app/features/features.dart';
import 'package:tg_mini_app/features/win/win_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  redirect: (BuildContext context, GoRouterState state) {
    if (state.uri.toString().contains('WebAppData')) {
      final uri = Uri.parse(state.uri.toString());
      final tgWebAppData = uri.queryParameters['tgWebAppData'];

      if (tgWebAppData != null) {
        final decodedParams = Uri.decodeQueryComponent(tgWebAppData);
        final params = Uri.splitQueryString(decodedParams);
        final userJson = params['user'];

        if (userJson != null) {
          try {
            final userData = json.decode(userJson);
            final chatId = userData['id'];

            Globals.tgChatId = int.parse(chatId);
            return '/debug/$chatId';
          } catch (e) {
            return '/debug/${e.toString()}';
          }
        }
      }
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
        GoRoute(path: 'win', builder: (context, state) => WinScreen()),
        GoRoute(
          path: 'debug/:info',
          builder: (context, state) {
            final info = state.pathParameters['info'];
            return Scaffold(body: Center(child: Text('Info: $info')));
          },
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) {
    final error = state.error;
    return Scaffold(body: Center(child: Text('Page not found $error')));
  },
);
