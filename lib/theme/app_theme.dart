import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFE91E63); // pink
  static const Color accentColor = Color(0xFFF06292);  // soft pink
  static const Color backgroundColor = Color(0xFFFFF5F7); // pastel background
  static const Color cardColor = Color(0xFFFCE4EC);

  static ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    fontFamily: 'Montserrat',

    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
      headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black87),
      bodyLarge: TextStyle(fontSize: 16, color: Colors.black54),
      bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
      labelLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        shadowColor: primaryColor.withOpacity(0.3),
        elevation: 6,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: Colors.black38),
      prefixIconColor: primaryColor,
    ),
  );
}
