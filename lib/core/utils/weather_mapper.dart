import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum WeatherConditionType {
  sunny,
  cloudy,
  partlyCloudy,
  rainy,
  stormy,
  snowy,
  foggy,
}

class WeatherMapper {
  static WeatherConditionType getConditionType(String code, String desc) {
    final lowerDesc = desc.toLowerCase();
    final c = int.tryParse(code) ?? 113;

    if (lowerDesc.contains('thunder') || lowerDesc.contains('storm') || c == 389 || c == 392 || c == 395) {
      return WeatherConditionType.stormy;
    }
    if (lowerDesc.contains('rain') || lowerDesc.contains('drizzle') || lowerDesc.contains('shower') ||
        (c >= 263 && c <= 314) || (c >= 353 && c <= 359)) {
      return WeatherConditionType.rainy;
    }
    if (lowerDesc.contains('snow') || lowerDesc.contains('sleet') || lowerDesc.contains('blizzard') ||
        (c >= 323 && c <= 338) || (c >= 368 && c <= 377)) {
      return WeatherConditionType.snowy;
    }
    if (lowerDesc.contains('fog') || lowerDesc.contains('mist') || c == 248 || c == 143) {
      return WeatherConditionType.foggy;
    }
    if (lowerDesc.contains('partly cloudy') || c == 116) {
      return WeatherConditionType.partlyCloudy;
    }
    if (lowerDesc.contains('cloud') || lowerDesc.contains('overcast') || c == 119 || c == 122) {
      return WeatherConditionType.cloudy;
    }
    return WeatherConditionType.sunny;
  }

  static String getVietnameseDesc(String desc, WeatherConditionType type) {
    switch (type) {
      case WeatherConditionType.sunny:
        return 'Trời quang, nắng đẹp';
      case WeatherConditionType.partlyCloudy:
        return 'Mây rải rác, có nắng';
      case WeatherConditionType.cloudy:
        return 'Nhiều mây, âm u';
      case WeatherConditionType.rainy:
        return 'Có mưa rào';
      case WeatherConditionType.stormy:
        return 'Dông sét, mưa lớn';
      case WeatherConditionType.snowy:
        return 'Tuyết rơi';
      case WeatherConditionType.foggy:
        return 'Sương mù dày đặc';
    }
  }

  static List<Color> getBackgroundGradient(WeatherConditionType type, {bool isNight = false}) {
    if (isNight) {
      return AppColors.nightGradient;
    }
    switch (type) {
      case WeatherConditionType.sunny:
        return const [
          Color(0xFF0288D1),
          Color(0xFF26C6DA),
          Color(0xFF80DEEA),
        ];
      case WeatherConditionType.partlyCloudy:
        return const [
          Color(0xFF1E3C72),
          Color(0xFF2A5298),
          Color(0xFF6DD5ED),
        ];
      case WeatherConditionType.cloudy:
        return const [
          Color(0xFF37474F),
          Color(0xFF546E7A),
          Color(0xFF78909C),
        ];
      case WeatherConditionType.rainy:
        return const [
          Color(0xFF1F3C58),
          Color(0xFF2B5278),
          Color(0xFF4A769E),
        ];
      case WeatherConditionType.stormy:
        return const [
          Color(0xFF141E30),
          Color(0xFF243B55),
          Color(0xFF4B1248),
        ];
      case WeatherConditionType.snowy:
        return const [
          Color(0xFF606C88),
          Color(0xFF3F4C6B),
          Color(0xFFD7E1EC),
        ];
      case WeatherConditionType.foggy:
        return const [
          Color(0xFF4B6CB7),
          Color(0xFF182848),
        ];
    }
  }

  static IconData getFallbackIcon(WeatherConditionType type) {
    switch (type) {
      case WeatherConditionType.sunny:
        return Icons.wb_sunny_rounded;
      case WeatherConditionType.partlyCloudy:
        return Icons.cloud_queue_rounded;
      case WeatherConditionType.cloudy:
        return Icons.cloud_rounded;
      case WeatherConditionType.rainy:
        return Icons.water_drop_rounded;
      case WeatherConditionType.stormy:
        return Icons.flash_on_rounded;
      case WeatherConditionType.snowy:
        return Icons.ac_unit_rounded;
      case WeatherConditionType.foggy:
        return Icons.blur_on_rounded;
    }
  }

  static String getLottieUrl(WeatherConditionType type) {
    // Official public LottieFiles animations
    switch (type) {
      case WeatherConditionType.sunny:
        return 'https://assets9.lottiefiles.com/packages/lf20_xlmz9xwm.json';
      case WeatherConditionType.partlyCloudy:
        return 'https://assets2.lottiefiles.com/packages/lf20_KmsV4y.json';
      case WeatherConditionType.cloudy:
        return 'https://assets2.lottiefiles.com/packages/lf20_DG3zL6.json';
      case WeatherConditionType.rainy:
        return 'https://assets2.lottiefiles.com/packages/lf20_rpC5oY.json';
      case WeatherConditionType.stormy:
        return 'https://assets2.lottiefiles.com/packages/lf20_T36FkZ.json';
      case WeatherConditionType.snowy:
        return 'https://assets10.lottiefiles.com/packages/lf20_RH37rO.json';
      case WeatherConditionType.foggy:
        return 'https://assets2.lottiefiles.com/packages/lf20_DG3zL6.json';
    }
  }
}
