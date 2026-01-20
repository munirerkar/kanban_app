import 'package:flutter/material.dart';

class AppTheme{
  AppTheme._();
  static ThemeData get lightTheme => ThemeData(
    fontFamily: 'Outfit',
    scaffoldBackgroundColor: Colors.white,
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF0659F5),
    secondary: Color(0xFF757373),
    surface: Colors.white,
    error: Colors.red
    ),
  );
}