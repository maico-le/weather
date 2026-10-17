import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/weather_model.dart';
import 'animated_roll_counter.dart';
import 'glass_card.dart';

class WeatherMetricsGrid extends StatefulWidget {
  final CurrentCondition current;

  const WeatherMetricsGrid({super.key, required this.current});

  @override
  State<WeatherMetricsGrid> createState() => _WeatherMetricsGridState();
}

class _WeatherMetricsGridState extends State<WeatherMetricsGrid>
    with TickerProviderStateMixin {
  late AnimationController _windController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _swayController;
  late Animation<double> _swayAnimation;

  @override
  void initState() {
    super.initState();

    // 💨 1. Wind icon continuous spin - speed proportional to current windSpeedKmph
    _windController = AnimationController(
      vsync: this,
      duration: _computeWindDuration(widget.current.windSpeedKmph),
    )..repeat();

    // 💧 2. Pulse controller for breathing water droplet & UV sun flare
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );

    // ☁️ 3. Sway controller for floating cloud and rocking barometer needle
    _swayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _swayAnimation = CurvedAnimation(
      parent: _swayController,
      curve: Curves.easeInOutSine,
    );
  }

  Duration _computeWindDuration(int speedKmph) {
    final clamped = speedKmph.clamp(3, 70);
    // 3 km/h -> 3500ms (gentle breeze), 70 km/h -> 600ms (fast gale)
    final ms = (3500 - (clamped - 3) * (2900 / 67)).round();
    return Duration(milliseconds: ms);
  }

  @override
  void didUpdateWidget(covariant WeatherMetricsGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.current.windSpeedKmph != widget.current.windSpeedKmph) {
      _windController.duration =
          _computeWindDuration(widget.current.windSpeedKmph);
      if (!_windController.isAnimating) {
        _windController.repeat();
      }
    }
  }

  @override
  void dispose() {
    _windController.dispose();
    _pulseController.dispose();
    _swayController.dispose();
    super.dispose();
  }

  String _getUvLabel(int uv) {
    if (uv <= 2) return 'Thấp';
    if (uv <= 5) return 'Trung bình';
    if (uv <= 7) return 'Cao';
    if (uv <= 10) return 'Rất cao';
    return 'Cực độ';
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.current;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              Icon(
                Icons.dashboard_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
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
            // 1. Humidity (Breathing squash & stretch droplet)
            _buildMetricItem(
              iconWidget: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  final stretch = 0.09 * _pulseAnimation.value;
                  return Transform.scale(
                    scaleX: 1.0 - stretch,
                    scaleY: 1.0 + stretch,
                    alignment: Alignment.bottomCenter,
                    child: child,
                  );
                },
                child: const Icon(
                  Icons.water_drop_outlined,
                  size: 18,
                  color: AppColors.accentRain,
                ),
              ),
              label: 'ĐỘ ẨM',
              value: current.humidity,
              suffix: '%',
              subtext: current.humidity > 80 ? 'Không khí rất ẩm' : 'Dễ chịu',
            ),

            // 2. Wind (Cute Duolingo Lottie Pinwheel with rotating fallback)
            _buildMetricItem(
              iconWidget: SizedBox(
                width: 22,
                height: 22,
                child: Lottie.asset(
                  'assets/animations/wind_pinwheel_duolingo.json',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      RotationTransition(
                    turns: _windController,
                    child: const Icon(
                      Icons.air_rounded,
                      size: 18,
                      color: AppColors.accentWind,
                    ),
                  ),
                ),
              ),
              label: 'GIÓ',
              value: current.windSpeedKmph,
              suffix: ' km/h',
              subtext: 'Hướng ${current.windDir}',
            ),

            // 3. UV Index (Pulsing glowing sun disc)
            _buildMetricItem(
              iconWidget: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  final scale = 1.0 + 0.14 * _pulseAnimation.value;
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentSun.withValues(
                              alpha: 0.3 * _pulseAnimation.value,
                            ),
                            blurRadius: 7 * _pulseAnimation.value,
                            spreadRadius: 1 * _pulseAnimation.value,
                          ),
                        ],
                      ),
                      child: child,
                    ),
                  );
                },
                child: const Icon(
                  Icons.wb_sunny_outlined,
                  size: 18,
                  color: AppColors.accentSun,
                ),
              ),
              label: 'CHỈ SỐ UV',
              value: current.uvIndex,
              suffix: '',
              subtext: _getUvLabel(current.uvIndex),
            ),

            // 4. Pressure (Rocking barometer gauge needle)
            _buildMetricItem(
              iconWidget: AnimatedBuilder(
                animation: _swayAnimation,
                builder: (context, child) {
                  final angle = (_swayAnimation.value - 0.5) * 0.28;
                  return Transform.rotate(
                    angle: angle,
                    child: child,
                  );
                },
                child: const Icon(
                  Icons.speed_rounded,
                  size: 18,
                  color: Color(0xFFB388FF),
                ),
              ),
              label: 'ÁP SUẤT',
              value: current.pressureHpa,
              suffix: ' hPa',
              subtext: 'Áp suất khí quyển',
            ),

            // 5. Visibility (Subtle optical focus shimmer)
            _buildMetricItem(
              iconWidget: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: 0.75 + 0.25 * _pulseAnimation.value,
                    child: child,
                  );
                },
                child: const Icon(
                  Icons.visibility_outlined,
                  size: 18,
                  color: Color(0xFF64B5F6),
                ),
              ),
              label: 'TẦM NHÌN',
              value: current.visibilityKm,
              suffix: ' km',
              subtext: current.visibilityKm >= 10 ? 'Rõ ràng' : 'Giảm tầm nhìn',
            ),

            // 6. Cloud Cover (Gentle horizontal floating cloud)
            _buildMetricItem(
              iconWidget: AnimatedBuilder(
                animation: _swayAnimation,
                builder: (context, child) {
                  final offset = (_swayAnimation.value - 0.5) * 3.5;
                  return Transform.translate(
                    offset: Offset(offset, 0),
                    child: child,
                  );
                },
                child: const Icon(
                  Icons.cloud_outlined,
                  size: 18,
                  color: Color(0xFF90A4AE),
                ),
              ),
              label: 'ĐỘ MÂY',
              value: current.cloudcover,
              suffix: '%',
              subtext: 'Mức độ che phủ',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricItem({
    required Widget iconWidget,
    required String label,
    required num value,
    required String suffix,
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
              iconWidget,
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                    letterSpacing: 0.8,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          AnimatedRollCounter(
            value: value,
            suffix: suffix,
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
