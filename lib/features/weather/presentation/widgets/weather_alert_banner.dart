import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/weather_model.dart';
import 'glass_card.dart';

class WeatherAlertBanner extends StatefulWidget {
  final CurrentCondition current;
  final List<HourlyWeather> hourly;

  const WeatherAlertBanner({
    super.key,
    required this.current,
    required this.hourly,
  });

  @override
  State<WeatherAlertBanner> createState() => _WeatherAlertBannerState();
}

class _WeatherAlertBannerState extends State<WeatherAlertBanner> {
  bool _isDismissed = false;

  _AlertInfo? _detectAlert() {
    // 1. Extreme Storm / Thunder
    if (widget.current.weatherDesc.toLowerCase().contains('thunder') ||
        widget.current.weatherDesc.toLowerCase().contains('storm')) {
      return _AlertInfo(
        title: 'CẢNH BÁO DÔNG SÉT & MƯA LỚN',
        message: 'Đang có dông bão trong khu vực. Hạn chế ra đường và tránh xa các gốc cây to.',
        icon: Icons.flash_on_rounded,
        color: const Color(0xFFFF5252),
      );
    }

    // 2. High UV Index
    if (widget.current.uvIndex >= 8) {
      return _AlertInfo(
        title: 'CẢNH BÁO TIA UV NGUY HẠI (${widget.current.uvIndex}/11+)',
        message: 'Chỉ số UV ở mức rất cao, có thể gây bỏng rát da trong 15 phút. Nên dùng kem chống nắng và mũ nón.',
        icon: Icons.warning_amber_rounded,
        color: const Color(0xFFFF9100),
      );
    }

    // 3. High Rain Probability soon
    final upcomingRain = widget.hourly.take(3).any((h) => h.chanceOfRain >= 70);
    if (upcomingRain && !widget.current.weatherDesc.toLowerCase().contains('rain')) {
      return _AlertInfo(
        title: 'DỰ BÁO SẮP CÓ MƯA RÀO',
        message: 'Xác suất mưa lên tới hơn 70% trong 2-3 giờ tới. Hãy mang theo ô hoặc áo mưa.',
        icon: Icons.water_drop_rounded,
        color: const Color(0xFF40C4FF),
      );
    }

    // 4. Strong Wind
    if (widget.current.windSpeedKmph >= 35) {
      return _AlertInfo(
        title: 'CẢNH BÁO GIÓ MẠNH (${widget.current.windSpeedKmph} km/h)',
        message: 'Gió giật mạnh cấp 5-6. Cẩn trọng khi lưu thông trên các cầu cao và đường thoáng.',
        icon: Icons.air_rounded,
        color: const Color(0xFFFFD600),
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_isDismissed) return const SizedBox.shrink();

    final alert = _detectAlert();
    if (alert == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: GlassCard(
        borderRadius: 20,
        opacity: 0.22,
        borderColor: alert.color.withValues(alpha: 0.6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: alert.color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(alert.icon, color: alert.color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: alert.color,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alert.message,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textMuted),
              onPressed: () {
                setState(() {
                  _isDismissed = true;
                });
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertInfo {
  final String title;
  final String message;
  final IconData icon;
  final Color color;

  _AlertInfo({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
  });
}
