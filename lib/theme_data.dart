import 'package:flutter/material.dart';

class AppTheme {
  //Ski Racing inspired colors
  static const Color primaryBlue = Color(0xFF005EB8); // Classic race blue
  static const Color accentRed = Color(0xFFE03C31); // Gate red
  static const Color snowWhite = Color(0xFFF8F9FA);
  static const Color iceBlue = Color(0xFFD1E8FF);
  static const Color darkSlate = Color(0xFF2D3436);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        secondary: accentRed,
        surface: snowWhite,
      ),
      scaffoldBackgroundColor: snowWhite,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: darkSlate,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(color: darkSlate),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.dark,
        primary: iceBlue,
        secondary: accentRed,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
