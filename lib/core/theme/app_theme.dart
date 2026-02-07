import 'package:flutter/material.dart';

class AppTheme {

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Arial',
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blueGrey,
        brightness: Brightness.light,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Arial',
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blueGrey,
        brightness: Brightness.dark,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );
  }
}
