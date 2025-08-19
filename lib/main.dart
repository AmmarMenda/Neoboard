// lib/main.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/board_list_screen.dart';

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
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFE0E0E0),
        primaryColor: const Color(0xFFC0C0C0),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFC0C0C0),
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        textTheme: GoogleFonts.vt323TextTheme(
          Theme.of(context).textTheme.apply(
                bodyColor: Colors.black,
                displayColor: Colors.black,
              ),
        ),
      ),
      home: const BoardListScreen(),
    );
  }
}
