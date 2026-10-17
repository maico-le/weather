import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/weather_mapper.dart';
import '../../data/models/weather_model.dart';
import 'glass_card.dart';

class HourlyForecastList extends StatelessWidget {
  final List<HourlyWeather> hourly;

  const HourlyForecastList({super.key, required this.hourly});

  @override
  Widget build(BuildContext context) {
    if (hourly.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.access_time_rounded, size: 16, color: AppColors.textSecondary),
              SizedBox(width: 8),
              Text(
                'DỰ BÁO THEO GIỜ',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        GlassCard(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          borderRadius: 20,
          opacity: 0.12,
          child: SizedBox(
            height: 124,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: hourly.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final item = hourly[index];
                final condType = WeatherMapper.getConditionType(
                  item.weatherCode,
                  item.weatherDesc,
                );
                final icon = WeatherMapper.getFallbackIcon(condType);

                return Container(
                  width: 68,
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: index == 0
                        ? Colors.white.withValues(alpha: 0.12)
                        : Colors.transparent,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        index == 0 ? 'Bây giờ' : item.formattedTime,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: index == 0 ? FontWeight.w700 : FontWeight.w400,
                          color: index == 0 ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                      Icon(
                        icon,
                        size: 26,
                        color: condType == WeatherConditionType.sunny
                            ? AppColors.accentSun
                            : condType == WeatherConditionType.rainy
                                ? AppColors.accentRain
                                : Colors.white,
                      ),
                      if (item.chanceOfRain > 0)
                        Text(
                          '${item.chanceOfRain}%',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accentRain,
                          ),
                        )
                      else
                        const SizedBox(height: 13),
                      Text(
                        '${item.tempC}°',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
