import 'package:flutter/material.dart';

class ColorTheme {
  // ============================================
  // PRIMARY ACCENT COLORS (Used in both modes)
  // ============================================
  static const Color neonYellow = Color(0xFFFFD700);
  static const Color primaryBlack = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  // ============================================
  // DARK MODE PALETTE
  // ============================================
  // Backgrounds
  static const Color darkBgPrimary = Color(0xFF0F0F0F); // Main background
  static const Color darkBgSecondary = Color(0xFF1A1A1A); // Cards, surfaces
  static const Color darkBgTertiary = Color(0xFF2A2A2A); // Hover, alt surfaces

  // Text Colors
  static const Color darkTextPrimary = Color(0xFFFFFFFF); // Main text
  static const Color darkTextSecondary = Color(0xFFB0B0B0); // Secondary text
  static const Color darkTextTertiary = Color(0xFF808080); // Tertiary text

  // Borders & Dividers
  static const Color darkBorderLight = Color(0xFF3A3A3A); // Light borders
  static const Color darkBorderMed = Color(0xFF4A4A4A); // Medium borders
  static const Color darkBorderDark = Color(0xFF2A2A2A); // Dark borders

  // Status Colors (Dark)
  static const Color darkSuccess = Color(0xFF4CAF50);
  static const Color darkError = Color(0xFFFF6B6B);
  static const Color darkWarning = Color(0xFFFFB74D);
  static const Color darkInfo = Color(0xFF29B6F6);

  // ============================================
  // LIGHT MODE PALETTE
  // ============================================
  // Backgrounds
  static const Color lightBgPrimary = Color(0xFFFAFAFA); // Main background
  static const Color lightBgSecondary = Color(0xFFFFFFFF); // Cards, surfaces
  static const Color lightBgTertiary = Color(0xFFF5F5F5); // Hover, alt surfaces

  // Text Colors
  static const Color lightTextPrimary = Color(0xFF1A1A1A); // Main text
  static const Color lightTextSecondary = Color(0xFF666666); // Secondary text
  static const Color lightTextTertiary = Color(0xFF999999); // Tertiary text

  // Borders & Dividers
  static const Color lightBorderLight = Color(0xFFE8E8E8); // Light borders
  static const Color lightBorderMed = Color(0xFFD0D0D0); // Medium borders
  static const Color lightBorderDark = Color(0xFFC0C0C0); // Dark borders

  // Status Colors (Light)
  static const Color lightSuccess = Color(0xFF2E7D32);
  static const Color lightError = Color(0xFFC62828);
  static const Color lightWarning = Color(0xFFF57C00);
  static const Color lightInfo = Color(0xFF1565C0);

  // ============================================
  // SEMANTIC COLORS (Used Across Both Modes)
  // ============================================
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFFF6B6B);
  static const Color warning = Color(0xFFFFB74D);
  static const Color info = Color(0xFF29B6F6);

  // ============================================
  // LEGACY SUPPORT (Backward Compatibility)
  // ============================================
  static const Color primary = primaryBlack; // Black
  static const Color accent = neonYellow; // Neon Yellow
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color secondaryColor = neonYellow; // Neon Yellow

  // ============================================
  // GRADIENT HELPERS
  // ============================================
  static const List<Color> darkGradient = [darkBgSecondary, darkBgTertiary];

  static const List<Color> lightGradient = [lightBgSecondary, lightBgTertiary];

  static const List<Color> accentGradient = [
    Color(0xFFFFD700),
    Color(0xFFFFC700),
  ];
}
