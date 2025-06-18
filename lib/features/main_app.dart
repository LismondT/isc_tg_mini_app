import 'package:flutter/material.dart';
import 'package:tg_mini_app/router.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      title: 'Level Selection',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        brightness: Brightness.light,
      ),
    );
  }
}
