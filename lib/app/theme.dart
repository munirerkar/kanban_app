import 'package:flutter/material.dart';

class AppTheme{
  AppTheme._();

  static ThemeData get lightTheme => ThemeData(
    fontFamily: 'Outfit',
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF0659F5),
      onPrimary: Colors.white,
      secondary: Color(0xFF000000),
      surface: Colors.white,
      onSurface: Color(0xFF1D1B20),
      onSurfaceVariant: Color(0xFF49454F),
      surfaceContainerHighest: Color(0xFFF2F2F2),
      error: Colors.red,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0659F5),
        foregroundColor: Colors.white,
      ),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    fontFamily: 'Outfit',
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF0659F5),
      onPrimary: Colors.white,
      secondary: Color(0xFFFFFFFF),
      surface: Color(0xFF1E1E1E),
      onSurface: Color(0xFFE0E0E0),
      onSurfaceVariant: Color(0xFFBDBDBD),
      surfaceContainerHighest: Color(0xFF2C2C2C),
      error: Colors.red,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3A86FF),
        foregroundColor: Colors.white,
      ),
    ),
  );
}