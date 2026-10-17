import 'package:flutter/material.dart';

class AppColors {
  // Sunny / Clear Day Gradient
  static const List<Color> sunnyGradient = [
    Color(0xFF2980B9),
    Color(0xFF6DD5FA),
    Color(0xFFFFFFFF),
  ];

  // Night / Clear Night Gradient
  static const List<Color> nightGradient = [
    Color(0xFF0F2027),
    Color(0xFF203A43),
    Color(0xFF2C5364),
  ];

  // Rainy / Overcast Gradient
  static const List<Color> rainGradient = [
    Color(0xFF3A6073),
    Color(0xFF3A7BD5),
    Color(0xFF4A00E0),
  ];

  // Thunderstorm Gradient
  static const List<Color> stormGradient = [
    Color(0xFF141E30),
    Color(0xFF243B55),
    Color(0xFF4B1248),
  ];

  // Glassmorphism Card Accents
  static const Color glassBackground = Color(0x1FFFFFFF);
  static const Color glassBorder = Color(0x38FFFFFF);
  static const Color glassHighlight = Color(0x59FFFFFF);

  // Typography
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xCCFFFFFF);
  static const Color textMuted = Color(0x88FFFFFF);

  // Indicators
  static const Color accentSun = Color(0xFFFFD166);
  static const Color accentRain = Color(0xFF4CC9F0);
  static const Color accentWind = Color(0xFF06D6A0);
  static const Color accentUV = Color(0xFFFF70A6);
}
