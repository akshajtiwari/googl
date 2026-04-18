import 'package:flutter/material.dart';

class AppTheme {
  static const primaryColor = Color(0xFF1A3A5C);
  static const accentColor = Color(0xFF2E5F8A);
  static const bgColor = Color(0xFFF4F6F9);
  static const cardColor = Colors.white;

  static ThemeData get theme => ThemeData(
        fontFamily: 'Inter',
        scaffoldBackgroundColor: bgColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
        ),
        cardTheme: CardThemeData( // ✅ FIXED
          color: cardColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
          bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF444444)),
        ),
      );
}