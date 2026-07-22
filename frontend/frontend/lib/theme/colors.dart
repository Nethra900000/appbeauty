import 'package:flutter/material.dart';

class AppColors {
  // Pastel Gradients
  static const List<Color> pastelGradient = [
    Color(0xFFFFF2EC), // Soft Nude / Beige
    Color(0xFFFFF0F5), // Lavender Blush
    Color(0xFFFFE4E1), // Misty Rose
    Color(0xFFE6E6FA), // Lavender
  ];

  static const List<Color> scanningGradient = [
    Color(0xFFFF9A9E),
    Color(0xFFFECFEF),
    Color(0xFFFEF7FC),
  ];

  static const List<Color> goldPremiumGradient = [
    Color(0xFFF6D365),
    Color(0xFFFDA085),
  ];

  // Core Theme Colors
  static const Color primary = Color(0xFFD4A373); // Muted Gold / Earthy Beige
  static const Color secondary = Color(0xFFCCA7A2); // Soft Rose Gold
  static const Color accent = Color(0xFFB5E2FA); // Soft Pastel Blue
  
  static const Color textDark = Color(0xFF4A3E3D); // Soft Dark Charcoal/Brown
  static const Color textLight = Color(0xFF8A7A78); // Muted Rose Charcoal
  static const Color background = Color(0xFFFAF6F0); // Warm Alabaster
  
  // Glassmorphic properties
  static Color glassBg = Colors.white.withOpacity(0.4);
  static Color glassBorder = Colors.white.withOpacity(0.6);
  static Color glassShadow = const Color(0x0A000000);
  
  // Face Scan Grid Color
  static const Color scanGrid = Color(0x80FFA7C4);
  static const Color scanLine = Color(0xFFFF4D80);
}
