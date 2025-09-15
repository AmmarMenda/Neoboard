// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/board_grid_screen.dart'; // Import your new screen
import 'theme/leopard_theme.dart';

void main() {
  runApp(const NeoBoardApp());
}

class NeoBoardApp extends StatelessWidget {
  const NeoBoardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NeoBoard',
      debugShowCheckedModeBanner: false,
      theme: leopardTheme,
      home: const BoardGridScreen(), // Set the new screen as the home
    );
  }
}
