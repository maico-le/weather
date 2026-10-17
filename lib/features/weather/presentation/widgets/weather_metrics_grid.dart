import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/weather_model.dart';
import 'glass_card.dart';

class WeatherMetricsGrid extends StatelessWidget {
  final CurrentCondition current;

  const WeatherMetricsGrid({super.key, required this.current});

  String _getUvLabel(int uv) {
    if (uv <= 2) return 'Thấp';
    if (uv <= 5) return 'Trung bình';
    if (uv <= 7) return 'Cao';
    if (uv <= 10) return 'Rất cao';
    return 'Cực độ';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.dashboard_outlined, size: 16, color: AppColors.textSecondary),
              SizedBox(width: 8),
              Text(
                'CHỈ SỐ THỜI TIẾT',
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
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.45,
          children: [
            _buildMetricItem(
              icon: Icons.water_drop_outlined,
              iconColor: AppColors.accentRain,
              label: 'ĐỘ ẨM',
              value: '${current.humidity}%',
              subtext: current.humidity > 80 ? 'Không khí rất ẩm' : 'Dễ chịu',
            ),
            _buildMetricItem(
              icon: Icons.air_rounded,
              iconColor: AppColors.accentWind,
              label: 'GIÓ',
              value: '${current.windSpeedKmph} km/h',
              subtext: 'Hướng ${current.windDir}',
            ),
            _buildMetricItem(
              icon: Icons.wb_sunny_outlined,
              iconColor: AppColors.accentSun,
              label: 'CHỈ SỐ UV',
              value: '${current.uvIndex}',
              subtext: _getUvLabel(current.uvIndex),
            ),
            _buildMetricItem(
              icon: Icons.speed_rounded,
              iconColor: const Color(0xFFB388FF),
              label: 'ÁP SUẤT',
              value: '${current.pressureHpa} hPa',
              subtext: 'Áp suất khí quyển',
            ),
            _buildMetricItem(
              icon: Icons.visibility_outlined,
              iconColor: const Color(0xFF64B5F6),
              label: 'TẦM NHÌN',
              value: '${current.visibilityKm} km',
              subtext: current.visibilityKm >= 10 ? 'Rõ ràng' : 'Giảm tầm nhìn',
            ),
            _buildMetricItem(
              icon: Icons.cloud_outlined,
              iconColor: const Color(0xFF90A4AE),
              label: 'ĐỘ MÂY',
              value: '${current.cloudcover}%',
              subtext: 'Mức độ che phủ',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String subtext,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      borderRadius: 20,
      opacity: 0.12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            subtext,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
