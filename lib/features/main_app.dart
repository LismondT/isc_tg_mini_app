import 'package:flutter/material.dart';
import 'package:tg_mini_app/router.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      title: 'Игра',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Color(0xFF7BC19D)),
    );
  }
}
