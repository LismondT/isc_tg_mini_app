import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tg_mini_app/core/globals.dart';
import 'package:tg_mini_app/features/features.dart';
import 'package:tg_mini_app/features/win/win_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  redirect: (BuildContext context, GoRouterState state) {
    final tgWebAppData = state.uri.queryParameters['tgWebAppData'];
    if (tgWebAppData != null) {
      // Разбиваем на пары ключ-значение
      final params = tgWebAppData.split('&');

      for (final param in params) {
        if (param.startsWith('user=')) {
          final userJson = Uri.decodeComponent(param.substring(5));
          try {
            final userData = json.decode(userJson);
            final chatId = userData['id'] as int;
            debugPrint('Extracted Chat ID: $chatId');

            Globals.tgChatId = chatId;

            return '/';
          } catch (e) {
            debugPrint('Error decoding user JSON: $e');
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
