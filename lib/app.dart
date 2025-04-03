import 'package:flutter/material.dart';
import 'package:game2048/screen/home.dart';

class Game2048App extends StatelessWidget {
  const Game2048App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "2048",
      home: Game2048(),
    );
  }
}