import 'package:flutter/material.dart';

class AppTheme {
  static const pastelPink = Color(0xFFFFB3BA);
  static const pastelBlue = Color(0xFFBAE1FF);
  static const pastelGreen = Color(0xFFBAFFB3);
  static const pastelYellow = Color(0xFFFFFFBA);
  static const pastelPurple = Color(0xFFD4BAFF);
  static const softGray = Color(0xFFF5F5F5);
  static const darkGray = Color(0xFF424242);
  static const lightText = Color(0xFF757575);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: pastelPurple,
        secondary: pastelBlue,
        surface: softGray,
        onPrimary: Colors.white,
        onSecondary: darkGray,
        onSurface: darkGray,
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: darkGray),
        titleTextStyle: TextStyle(
          color: darkGray,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: softGray,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: pastelPurple,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: pastelPurple,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: softGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: pastelPurple, width: 2),
        ),
      ),
    );
  }
}
