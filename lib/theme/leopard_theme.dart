import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData leopardTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(
    0xFF1A237E,
  ), // Deep indigo for a forward-thinking primary hue
  scaffoldBackgroundColor: const Color(
    0xFFFAFAFA,
  ), // Cleaner, lighter background for modern whitespace
  canvasColor: const Color(0xFFF0F4F8), // Soft gray-blue for subtle depth
  dividerColor: const Color(0xFFE0E0E0), // Lighter dividers for a refined look
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: Color(
      0xFF3F51B5,
    ), // Vibrant indigo accent for buttons and highlights
    onPrimary: Colors.white,
    secondary: Color(0xFF607D8B), // Muted blue-gray for secondary elements
    onSecondary: Colors.white,
    error: Color(0xFFB71C1C), // Deeper red for errors, maintaining contrast
    onError: Colors.white,
    surface: Color(0xFFFFFFFF), // Pure white surfaces for clarity
    onSurface: Color(0xFF212121), // Darker text for better readability
    background: Color(0xFFFAFAFA),
    onBackground: Color(0xFF212121),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(
      0xFFFFFFFF,
    ), // White app bar for a minimal, elevated feel
    foregroundColor: Color(0xFF212121),
    elevation: 1.0, // Subtle shadow for depth
    shadowColor: Colors.black12,
    surfaceTintColor: Colors.transparent,
  ),
  // *** THE ONLY CHANGE IS ON THIS LINE ***
  // Replaced openSansTextTheme with loraTextTheme for a modern serif look.
  textTheme: GoogleFonts.loraTextTheme().apply(
    bodyColor: const Color(
      0xFF212121,
    ), // Darker body text for stronger hierarchy
    displayColor: Color(
      0xFF1A237E,
    ), // Indigo for display text to tie into the theme
  ),
  dialogTheme: DialogThemeData(
    backgroundColor: const Color(0xFFF0F4F8), // Matching canvas for consistency
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ), // Softer corners for modernity
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Color(0xFFFFFFFF),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ), // Slightly more padding for usability
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(
        8.0,
      ), // Rounded for a contemporary feel
      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(
        color: Color(0xFF3F51B5),
        width: 2.0,
      ), // Matching primary accent
    ),
  ),
);
