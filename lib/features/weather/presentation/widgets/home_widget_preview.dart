import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/weather_mapper.dart';
import '../../data/models/weather_model.dart';
import 'glass_card.dart';

class HomeWidgetPreview extends StatelessWidget {
  final WeatherResponse weather;

  const HomeWidgetPreview({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final current = weather.currentCondition;
    final area = weather.nearestArea;
    final condType = WeatherMapper.getConditionType(current.weatherCode, current.weatherDesc);
    final icon = WeatherMapper.getFallbackIcon(condType);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.widgets_outlined, size: 16, color: AppColors.textSecondary),
              SizedBox(width: 8),
              Text(
                'TIỆN ÍCH MÀN HÌNH CHÍNH (WIDGET)',
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
          borderRadius: 22,
          padding: const EdgeInsets.all(18),
          opacity: 0.16,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.near_me_rounded, size: 14, color: Color(0xFF38BDF8)),
                          const SizedBox(width: 4),
                          Text(
                            area.areaName.isNotEmpty ? area.areaName : 'Hồ Chí Minh',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${current.tempC}° • ${WeatherMapper.getVietnameseDesc(current.weatherDesc, condType)}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Icon(icon, size: 36, color: AppColors.accentSun),
                ],
              ),
              const SizedBox(height: 12),
              Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _miniStat('ĐỘ ẨM', '${current.humidity}%'),
                  _miniStat('GIÓ', '${current.windSpeedKmph} km/h'),
                  _miniStat('UV', '${current.uvIndex}'),
                  _miniStat('CẢM GIÁC', '${current.feelsLikeC}°'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _miniStat(String title, String val) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          val,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
