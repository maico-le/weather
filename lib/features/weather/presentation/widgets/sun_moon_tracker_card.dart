import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/weather_model.dart';
import 'glass_card.dart';

class SunMoonTrackerCard extends StatelessWidget {
  final AstronomyInfo astronomy;

  const SunMoonTrackerCard({
    super.key,
    required this.astronomy,
  });

  int _parseTimeToMinutes(String timeStr) {
    try {
      // Formats like "05:48 AM", "05:45 PM", "5:48 am"
      final clean = timeStr.trim().toUpperCase();
      final parts = clean.split(' ');
      final timeParts = parts[0].split(':');
      int hour = int.parse(timeParts[0]);
      final int minute = int.parse(timeParts[1]);

      if (parts.length > 1) {
        if (parts[1] == 'PM' && hour < 12) hour += 12;
        if (parts[1] == 'AM' && hour == 12) hour = 0;
      }
      return hour * 60 + minute;
    } catch (_) {
      return 6 * 60; // fallback 06:00
    }
  }

  String _translateMoonPhase(String phase) {
    final lower = phase.toLowerCase();
    if (lower.contains('new')) return 'Trăng Mới (Sóc)';
    if (lower.contains('waxing crescent')) return 'Trăng Lưỡi Liềm Đầu Tháng';
    if (lower.contains('first quarter')) return 'Bán Nguyệt Đầu Tháng';
    if (lower.contains('waxing gibbous')) return 'Trăng Khuyết Lớn';
    if (lower.contains('full')) return 'Trăng Tròn (Rằm)';
    if (lower.contains('waning gibbous')) return 'Trăng Khuyết Cuối Tháng';
    if (lower.contains('last quarter')) return 'Bán Nguyệt Cuối Tháng';
    if (lower.contains('waning crescent')) return 'Trăng Lưỡi Liềm Cuối Tháng';
    return phase;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;

    final sunriseMinutes = _parseTimeToMinutes(astronomy.sunrise);
    final sunsetMinutes = _parseTimeToMinutes(astronomy.sunset);

    final bool isDaytime =
        currentMinutes >= sunriseMinutes && currentMinutes <= sunsetMinutes;

    double progress = 0.0;
    String statusCountdown = '';
    String subStatus = '';

    if (isDaytime) {
      final totalDayMinutes = sunsetMinutes - sunriseMinutes;
      final elapsed = currentMinutes - sunriseMinutes;
      progress = (elapsed / totalDayMinutes).clamp(0.0, 1.0);

      final remainingMinutes = sunsetMinutes - currentMinutes;
      final remHours = remainingMinutes ~/ 60;
      final remMins = remainingMinutes % 60;

      if (progress >= 0.82) {
        statusCountdown = 'Giờ vàng hoàng hôn (Golden Hour) ✨';
        subStatus = 'Thời điểm lý tưởng nhất để chụp ảnh ngoài trời';
      } else {
        if (remHours > 0) {
          statusCountdown = 'Còn $remHours giờ $remMins phút nữa là hoàng hôn';
        } else {
          statusCountdown = 'Còn $remMins phút nữa là mặt trời lặn';
        }
        final dayHours = totalDayMinutes ~/ 60;
        final dayMins = totalDayMinutes % 60;
        subStatus = 'Tổng thời gian chiếu sáng: $dayHours giờ $dayMins phút';
      }
    } else {
      // Nighttime
      int remainingToSunrise;
      if (currentMinutes < sunriseMinutes) {
        remainingToSunrise = sunriseMinutes - currentMinutes;
      } else {
        // after sunset until next sunrise
        remainingToSunrise = (24 * 60 - currentMinutes) + sunriseMinutes;
      }
      final remHours = remainingToSunrise ~/ 60;
      final remMins = remainingToSunrise % 60;
      statusCountdown = 'Còn $remHours giờ $remMins phút nữa là bình minh 🌅';
      subStatus =
          'Tuần trăng: ${_translateMoonPhase(astronomy.moonPhase)} • Sáng ${astronomy.moonIllumination}%';
    }

    return GlassCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 24,
      opacity: 0.12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDaytime
                          ? const Color(0xFFFBBF24).withValues(alpha: 0.2)
                          : const Color(0xFF818CF8).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isDaytime
                          ? Icons.wb_sunny_rounded
                          : Icons.nightlight_round,
                      size: 16,
                      color: isDaytime
                          ? const Color(0xFFFBBF24)
                          : const Color(0xFF818CF8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'MẶT TRỜI & MẶT TRĂNG',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  DateFormat('HH:mm').format(now),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Arc Curve Canvas
          SizedBox(
            height: 110,
            width: double.infinity,
            child: CustomPaint(
              painter: _SunArcPainter(
                progress: progress,
                isDaytime: isDaytime,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Sunrise and Sunset Times Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.wb_twilight_rounded,
                    size: 18,
                    color: Color(0xFFF59E0B),
                  ),
                  const SizedBox(width: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bình Minh',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                      Text(
                        astronomy.sunrise,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Hoàng Hôn',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                      Text(
                        astronomy.sunset,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.nights_stay_rounded,
                    size: 18,
                    color: Color(0xFFEC4899),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Real-time Countdown Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusCountdown,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subStatus,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDaytime
                        ? const Color(0xFFFBBF24)
                        : const Color(0xFFA5B4FC),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SunArcPainter extends CustomPainter {
  final double progress;
  final bool isDaytime;

  _SunArcPainter({
    required this.progress,
    required this.isDaytime,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double left = 24.0;
    final double right = size.width - 24.0;
    final double baselineY = size.height - 12.0;
    final double arcHeight = size.height - 30.0;

    // 1. Draw Horizon Line
    final horizonPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(10, baselineY),
      Offset(size.width - 10, baselineY),
      horizonPaint,
    );

    // 2. Build Smooth Sine Arc Path
    final path = Path();
    const int segments = 60;
    for (int i = 0; i <= segments; i++) {
      final double t = i / segments;
      final double x = left + t * (right - left);
      final double y = baselineY - math.sin(math.pi * t) * arcHeight;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // 3. Draw Background Dash Arc
    final bgArcPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, bgArcPaint);

    if (isDaytime) {
      // 4. Draw Traveled Path (Golden Gradient Line)
      final traveledPath = Path();
      final int activeSegments = (segments * progress).round();
      for (int i = 0; i <= activeSegments; i++) {
        final double t = i / segments;
        final double x = left + t * (right - left);
        final double y = baselineY - math.sin(math.pi * t) * arcHeight;
        if (i == 0) {
          traveledPath.moveTo(x, y);
        } else {
          traveledPath.lineTo(x, y);
        }
      }

      final activeArcPaint = Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
        ).createShader(Rect.fromLTWH(left, 0, right - left, size.height))
        ..strokeWidth = 3.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(traveledPath, activeArcPaint);

      // 5. Draw Glowing Sun Disc
      final double sunX = left + progress * (right - left);
      final double sunY = baselineY - math.sin(math.pi * progress) * arcHeight;

      // Glow halo
      final glowPaint = Paint()
        ..color = const Color(0xFFFBBF24).withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(Offset(sunX, sunY), 14, glowPaint);

      // Outer ring
      final ringPaint = Paint()
        ..color = const Color(0xFFFFD166)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(Offset(sunX, sunY), 8, ringPaint);

      // Core disc
      final corePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(sunX, sunY), 5, corePaint);
    } else {
      // Nighttime: Draw Moon at zenith center
      final double moonX = size.width / 2;
      final double moonY = baselineY - arcHeight;

      final glowPaint = Paint()
        ..color = const Color(0xFF818CF8).withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
      canvas.drawCircle(Offset(moonX, moonY), 16, glowPaint);

      final moonPaint = Paint()
        ..color = const Color(0xFFE0E7FF)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(moonX, moonY), 8, moonPaint);

      // Moon crescent shadow
      final shadowPaint = Paint()
        ..color = const Color(0xFF1E1B4B)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(moonX - 3, moonY - 2), 6, shadowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SunArcPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isDaytime != isDaytime;
  }
}
