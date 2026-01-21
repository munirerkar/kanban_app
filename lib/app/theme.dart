import 'package:flutter/material.dart';

class AppTheme{
  AppTheme._();
  static ThemeData get lightTheme => ThemeData(
    fontFamily: 'Outfit',
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF0659F5),
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
}