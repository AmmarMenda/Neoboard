// lib/theme/leopard_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData leopardTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFF6E84A3),
  scaffoldBackgroundColor: const Color(0xFFECECEC),
  canvasColor: const Color(0xFFF5F5F5),
  dividerColor: const Color(0xFFBDBDBD),

  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF5A88D7),
    onPrimary: Colors.white,
    secondary: Color(0xFF7D7D7D),
    onSecondary: Colors.white,
    error: Color(0xFFD32F2F),
    onError: Colors.white,
    surface: Colors.white,
    onSurface: Colors.black,
    background: Color(0xFFECECEC),
    onBackground: Colors.black,
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFEFEFEF),
    foregroundColor: Colors.black87,
    elevation: 0.5,
    shadowColor: Colors.black,
    surfaceTintColor: Colors.transparent,
  ),

  // *** THE ONLY CHANGE IS ON THIS LINE ***
  // Replaced openSansTextTheme with loraTextTheme for a modern serif look.
  textTheme: GoogleFonts.loraTextTheme().apply(
    bodyColor: const Color(0xFF222222),
    displayColor: Colors.black,
  ),

  dialogTheme: DialogThemeData(
    backgroundColor: const Color(0xFFF5F5F5),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6.0),
      borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6.0),
      borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6.0),
      borderSide: const BorderSide(color: Color(0xFF5A88D7), width: 2.0),
    ),
  ),
);
