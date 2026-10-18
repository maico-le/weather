import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/weather_mapper.dart';
import '../../data/models/weather_model.dart';
import 'animated_roll_counter.dart';
import 'animated_weather_scene.dart';

class CurrentWeatherHero extends StatelessWidget {
  final CurrentCondition current;
  final DailyWeather? today;

  const CurrentWeatherHero({
    super.key,
    required this.current,
    this.today,
  });

  @override
  Widget build(BuildContext context) {
    final conditionType = WeatherMapper.getConditionType(
      current.weatherCode,
      current.weatherDesc,
    );
    final vietnameseDesc = WeatherMapper.getVietnameseDesc(
      current.weatherDesc,
      conditionType,
    );

    bool isNight = false;
    final todayWeather = today;
    if (todayWeather != null) {
      final now = DateTime.now();
      final currentMinutes = now.hour * 60 + now.minute;
      final sunriseMinutes = _parseTimeToMinutes(todayWeather.astronomy.sunrise);
      final sunsetMinutes = _parseTimeToMinutes(todayWeather.astronomy.sunset);
      isNight = currentMinutes < sunriseMinutes || currentMinutes > sunsetMinutes;
    } else {
      final hour = DateTime.now().hour;
      isNight = hour >= 18 || hour < 6;
    }

    return Column(
      children: [
        // Interactive Vector Mascot Scene with speech bubble
        AnimatedWeatherScene(
          conditionType: conditionType,
          tempC: current.tempC,
          weatherDesc: vietnameseDesc,
          size: 185,
          isNight: isNight,
        ),
        const SizedBox(height: 6),

        // Large Temperature with Animated Rolling Counter
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedRollCounter(
              value: current.tempC,
              style: const TextStyle(
                fontSize: 84,
                fontWeight: FontWeight.w200,
                color: AppColors.textPrimary,
                height: 1.0,
                letterSpacing: -2,
              ),
            ),
            const Text(
              '°C',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w300,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        // Description
        Text(
          vietnameseDesc,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            letterSpacing: 0.2,
          ),
        ),

        const SizedBox(height: 6),

        // Feels like & High/Low
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Cảm giác như ${current.feelsLikeC}°',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            if (today != null) ...[
              const SizedBox(width: 8),
              const Text('•', style: TextStyle(color: AppColors.textMuted)),
              const SizedBox(width: 8),
              Text(
                'Cao: ${today!.maxTempC}°  Thấp: ${today!.minTempC}°',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  int _parseTimeToMinutes(String timeStr) {
    try {
      final trimmed = timeStr.trim().toUpperCase();
      final isPM = trimmed.endsWith('PM');
      final isAM = trimmed.endsWith('AM');
      final clean = trimmed.replaceAll('AM', '').replaceAll('PM', '').trim();
      final parts = clean.split(':');
      var hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      if (isPM && hour < 12) hour += 12;
      if (isAM && hour == 12) hour = 0;

      return hour * 60 + minute;
    } catch (_) {
      return 6 * 60; // fallback 06:00
    }
  }
}
