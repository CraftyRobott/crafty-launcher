import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const CraftyLauncher());
}

class CraftyLauncher extends StatelessWidget {
  const CraftyLauncher({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crafty Launcher',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'Pixel',
      ),

      home: const HomeScreen(),
    );
  }
}