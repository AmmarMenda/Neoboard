// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/board_list_screen.dart';
import 'theme/leopard_theme.dart'; // Import your new theme file

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
      theme: leopardTheme, // Apply the new theme here
      home: const BoardListScreen(),
    );
  }
}
