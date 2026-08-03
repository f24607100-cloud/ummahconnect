import 'package:flutter/material.dart';

class AppColors {
  // Common Colors
  static const Color gold = Color(0xFFD4AF37);
  static const Color lightGold = Color(0xFFF3E5AB);
  static const Color darkGold = Color(0xFFAA7C11);
  static const Color amber = Color(0xFFFFC107);
  
  // Light Theme Colors
  static const Color lightPrimary = Color(0xFF0F5132); // Islamic Deep Green
  static const Color lightOnPrimary = Colors.white;
  static const Color lightSecondary = Color(0xFF198754); // Secondary Green
  static const Color lightOnSecondary = Colors.white;
  static const Color lightBackground = Color(0xFFF5F7F6); // Soft off-white with green tint
  static const Color lightSurface = Colors.white;
  static const Color lightOnBackground = Color(0xFF1A2521); // Very dark green-gray
  static const Color lightOnSurface = Color(0xFF1A2521);
  
  // Dark Theme Colors
  static const Color darkPrimary = Color(0xFF1B4D3E); // Vibrant Deep Emerald
  static const Color darkOnPrimary = Color(0xFFE8F5E9);
  static const Color darkSecondary = Color(0xFF0F5132);
  static const Color darkOnSecondary = Color(0xFFE8F5E9);
  static const Color darkBackground = Color(0xFF0C1412); // Deep Charcoal Emerald
  static const Color darkSurface = Color(0xFF14221E); // Rich Forest Slate
  static const Color darkOnBackground = Color(0xFFE8F5E9);
  static const Color darkOnSurface = Color(0xFFE8F5E9);

  // Status & Utility Colors
  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF0288D1);
  static const Color cardShadowLight = Color(0x0A000000);
  static const Color cardShadowDark = Color(0x1F000000);
  
  // Glassmorphism overlays
  static Color glassBackgroundLight = Colors.white.withOpacity(0.45);
  static Color glassBorderLight = Colors.white.withOpacity(0.3);
  static Color glassBackgroundDark = const Color(0xFF14221E).withOpacity(0.5);
  static Color glassBorderDark = const Color(0xFF2E7D32).withOpacity(0.2);
}
