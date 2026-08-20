import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color slateNavy = Color(0xFF0F172A);
  static const Color emerald = Color(0xFF10B981);
  static const Color indigo = Color(0xFF6366F1);

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: slateNavy,
      colorScheme: base.colorScheme.copyWith(
        brightness: Brightness.dark,
        primary: emerald,
        secondary: indigo,
        surface: const Color(0xFF111827),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF111827),
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF111827),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF111827),
        selectedItemColor: emerald,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
