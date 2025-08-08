import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/main_app_shell_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme.apply(
          fontFamily: GoogleFonts.vt323().fontFamily,
        );

    return MaterialApp(
      title: 'Retro Imageboard',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF008080),
        textTheme: textTheme,
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFFC0C0C0),
          titleTextStyle: GoogleFonts.vt323(fontSize: 24, color: Colors.black),
        ),
        tabBarTheme: TabBarTheme(
          labelStyle: GoogleFonts.vt323(fontSize: 18),
          unselectedLabelStyle: GoogleFonts.vt323(fontSize: 16),
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey[800],
          indicator: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.black, width: 2),
            ),
          ),
        ),
      ),
      home: const MainAppShellScreen(),
    );
  }
}
