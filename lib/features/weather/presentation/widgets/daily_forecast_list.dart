import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/weather_mapper.dart';
import '../../data/models/weather_model.dart';
import 'glass_card.dart';

class DailyForecastList extends StatelessWidget {
  final List<DailyWeather> daily;

  const DailyForecastList({super.key, required this.daily});

  String _formatDay(String dateStr, int index) {
    if (index == 0) return 'Hôm nay';
    if (index == 1) return 'Ngày mai';

    try {
      final date = DateTime.parse(dateStr);
      final weekday = DateFormat('EEEE', 'en_US').format(date);
      switch (weekday) {
        case 'Monday': return 'Thứ Hai';
        case 'Tuesday': return 'Thứ Ba';
        case 'Wednesday': return 'Thứ Tư';
        case 'Thursday': return 'Thứ Năm';
        case 'Friday': return 'Thứ Sáu';
        case 'Saturday': return 'Thứ Bảy';
        case 'Sunday': return 'Chủ Nhật';
        default: return weekday;
      }
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (daily.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.calendar_month_outlined, size: 16, color: AppColors.textSecondary),
              SizedBox(width: 8),
              Text(
                'DỰ BÁO CÁC NGÀY TỚI',
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
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          borderRadius: 20,
          opacity: 0.12,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daily.length,
            separatorBuilder: (context, index) => Divider(
              color: Colors.white.withValues(alpha: 0.1),
              height: 16,
            ),
            itemBuilder: (context, index) {
              final day = daily[index];
              // Middle of the day condition (index 4 is 12:00)
              final midHour = day.hourly.length > 4 ? day.hourly[4] : day.hourly.firstOrNull;
              final condType = midHour != null
                  ? WeatherMapper.getConditionType(midHour.weatherCode, midHour.weatherDesc)
                  : WeatherConditionType.sunny;
              final icon = WeatherMapper.getFallbackIcon(condType);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 90,
                      child: Text(
                        _formatDay(day.date, index),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: index == 0 ? FontWeight.w700 : FontWeight.w500,
                          color: index == 0 ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Icon(
                      icon,
                      size: 22,
                      color: condType == WeatherConditionType.sunny
                          ? AppColors.accentSun
                          : condType == WeatherConditionType.rainy
                              ? AppColors.accentRain
                              : Colors.white,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${day.minTempC}°',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          height: 5,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.withValues(alpha: 0.4),
                                Colors.amber.withValues(alpha: 0.8),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${day.maxTempC}°',
                      style: const TextStyle(
                        fontSize: 14,
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
      ],
    );
  }
}
