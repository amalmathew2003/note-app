import 'package:flutter/material.dart';

class AppColors {
  // Common Colors
  static const Color primary = Color(0xFF10B981); // Emerald Green (Fresh & Modern)
  static const Color accent = Color(0xFF3B82F6); // Modern Blue
  
  // Dark Palette (Default)
  static const Color bgDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color surfaceLightDark = Color(0xFF334155);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Light Palette
  static const Color bgLight = Color(0xFFF8FAFB);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceLightLight = Color(0xFFF1F5F9);
  static const Color textPrimaryLight = Color(0xFF1E293B);
  static const Color textSecondaryLight = Color(0xFF64748B);

  // Helper getters for current theme
  static Color getBackgroundColor(bool isDark) => isDark ? bgDark : bgLight;
  static Color getSurfaceColor(bool isDark) => isDark ? surfaceDark : surfaceLight;
  static Color getTextColor(bool isDark) => isDark ? textPrimaryDark : textPrimaryLight;
  static Color getSecondaryTextColor(bool isDark) => isDark ? textSecondaryDark : textSecondaryLight;

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const List<Color> cardColors = [
    Color(0xFFE5E7EB), // Gray
    Color(0xFFFEF3C7), // Amber
    Color(0xFFDBEAFE), // Blue
    Color(0xFFD1FAE5), // Green
    Color(0xFFFCE7F3), // Pink
    Color(0xFFEDE9FE), // Purple
  ];

  static const List<Color> cardColorsDark = [
    Color(0xFF374151), // Gray
    Color(0xFF78350F), // Amber
    Color(0xFF1E3A8A), // Blue
    Color(0xFF064E3B), // Green
    Color(0xFF831843), // Pink
    Color(0xFF4C1D95), // Purple
  ];
}
