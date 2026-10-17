import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/weather_model.dart';
import 'glass_card.dart';

enum RadarLayerType {
  rain, // Precipitation radar
  wind, // Wind flow streamlines
  temp, // Thermal heat map
}

class WeatherRadarMapWidget extends StatefulWidget {
  final WeatherResponse weather;
  final String cityName;

  const WeatherRadarMapWidget({
    super.key,
    required this.weather,
    required this.cityName,
  });

  @override
  State<WeatherRadarMapWidget> createState() => _WeatherRadarMapWidgetState();
}

class _WeatherRadarMapWidgetState extends State<WeatherRadarMapWidget>
    with SingleTickerProviderStateMixin {
  RadarLayerType _activeLayer = RadarLayerType.rain;
  late AnimationController _sweepAnimController;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    _sweepAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _sweepAnimController.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _sweepAnimController.repeat();
      } else {
        _sweepAnimController.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final area = widget.weather.nearestArea;
    final lat = area.latitude;
    final lon = area.longitude;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Layer Switcher
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _getLayerColor(_activeLayer).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.radar_rounded,
                      color: _getLayerColor(_activeLayer),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Radar Vệ Tinh Trực Quan',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              // Layer buttons
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLayerTab(RadarLayerType.rain, 'Mưa'),
                    _buildLayerTab(RadarLayerType.wind, 'Gió'),
                    _buildLayerTab(RadarLayerType.temp, 'Nhiệt'),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Radar Screen Canvas Container
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // Animated Custom Radar Canvas
                AnimatedBuilder(
                  animation: _sweepAnimController,
                  builder: (context, _) {
                    return SizedBox(
                      height: 220,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: _RadarCanvasPainter(
                          animationProgress: _sweepAnimController.value,
                          layerType: _activeLayer,
                          centerLat: lat,
                          centerLon: lon,
                          condition: widget.weather.currentCondition,
                        ),
                      ),
                    );
                  },
                ),

                // Top Left Overlay: Coordinates & Station Info
                Positioned(
                  top: 10,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _isPlaying ? const Color(0xFF10B981) : Colors.amber,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${lat.toStringAsFixed(2)}°N, ${lon.toStringAsFixed(2)}°E • ${_isPlaying ? "LIVE SCAN" : "PAUSED"}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Right Overlay: Play/Pause button
                Positioned(
                  bottom: 10,
                  right: 12,
                  child: GestureDetector(
                    onTap: _togglePlayPause,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isPlaying ? 'Tạm dừng' : 'Quét radar',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Center City Pin Badge
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on, color: Colors.white, size: 12),
                        const SizedBox(width: 3),
                        Text(
                          widget.cityName,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Legend scale bar
          _buildRadarLegend(),
        ],
      ),
    );
  }

  Widget _buildLayerTab(RadarLayerType type, String label) {
    final isSelected = _activeLayer == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeLayer = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? _getLayerColor(type).withValues(alpha: 0.35)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildRadarLegend() {
    switch (_activeLayer) {
      case RadarLayerType.rain:
        return _buildLegendRow(
          title: 'Mức độ mưa:',
          colors: [
            Colors.transparent,
            const Color(0xFF0284C7),
            const Color(0xFF10B981),
            const Color(0xFFF59E0B),
            const Color(0xFFEF4444),
          ],
          labels: ['Nhẹ', 'Vừa', 'Mưa to', 'Giông'],
        );
      case RadarLayerType.wind:
        return _buildLegendRow(
          title: 'Vận tốc gió:',
          colors: [
            const Color(0xFF064E3B),
            const Color(0xFF10B981),
            const Color(0xFF34D399),
            const Color(0xFFFBBF24),
          ],
          labels: ['<10km/h', '20km/h', '40km/h', 'Bão'],
        );
      case RadarLayerType.temp:
        return _buildLegendRow(
          title: 'Nhiệt độ:',
          colors: [
            const Color(0xFF38BDF8),
            const Color(0xFF10B981),
            const Color(0xFFF59E0B),
            const Color(0xFFDC2626),
          ],
          labels: ['<22°C', '26°C', '32°C', '>36°C'],
        );
    }
  }

  Widget _buildLegendRow({
    required String title,
    required List<Color> colors,
    required List<String> labels,
  }) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              gradient: LinearGradient(colors: colors),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          labels.last,
          style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Color _getLayerColor(RadarLayerType layer) {
    switch (layer) {
      case RadarLayerType.rain:
        return const Color(0xFF38BDF8);
      case RadarLayerType.wind:
        return const Color(0xFF34D399);
      case RadarLayerType.temp:
        return const Color(0xFFF59E0B);
    }
  }
}

class _RadarCanvasPainter extends CustomPainter {
  final double animationProgress;
  final RadarLayerType layerType;
  final double centerLat;
  final double centerLon;
  final CurrentCondition condition;

  _RadarCanvasPainter({
    required this.animationProgress,
    required this.layerType,
    required this.centerLat,
    required this.centerLon,
    required this.condition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.sqrt(size.width * size.width + size.height * size.height) / 2;

    // Dark Map Background
    final bgPaint = Paint()..color = const Color(0xFF090D16);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Geographic Map Grids & Rings
    final ringPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 1; i <= 3; i++) {
      final r = (maxRadius / 3) * i;
      canvas.drawCircle(center, r, ringPaint);
    }

    // Crosshairs
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), ringPaint);
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), ringPaint);

    // Render Weather Data Patterns (Mây mưa, Gió, hoặc Nhiệt)
    switch (layerType) {
      case RadarLayerType.rain:
        _paintPrecipitationClouds(canvas, size, center);
        break;
      case RadarLayerType.wind:
        _paintWindStreamlines(canvas, size, center);
        break;
      case RadarLayerType.temp:
        _paintThermalBlobs(canvas, size, center);
        break;
    }

    // Dynamic Sweeping Beam (Radar Antenna sweep)
    final sweepAngle = animationProgress * 2 * math.pi;
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        center: FractionalOffset.center,
        startAngle: 0.0,
        endAngle: math.pi / 2,
        colors: [
          _getSweepColor().withValues(alpha: 0.35),
          Colors.transparent,
        ],
        transform: GradientRotation(sweepAngle - (math.pi / 2)),
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, maxRadius, sweepPaint);

    // Leading sweeping line
    final sweepLineEnd = Offset(
      center.dx + maxRadius * math.cos(sweepAngle),
      center.dy + maxRadius * math.sin(sweepAngle),
    );
    final sweepLinePaint = Paint()
      ..color = _getSweepColor().withValues(alpha: 0.7)
      ..strokeWidth = 1.5;
    canvas.drawLine(center, sweepLineEnd, sweepLinePaint);

    // Concentric pulsing ping
    final pulseRadius = (animationProgress * maxRadius * 0.9);
    final pulsePaint = Paint()
      ..color = _getSweepColor().withValues(alpha: (1.0 - animationProgress) * 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, pulseRadius, pulsePaint);
  }

  void _paintPrecipitationClouds(Canvas canvas, Size size, Offset center) {
    // Generate organic rain cloud clusters drifting with time
    final rnd = math.Random(42);
    final isRainy = condition.weatherDesc.toLowerCase().contains('rain') ||
        condition.weatherDesc.toLowerCase().contains('shower');

    final cloudCount = isRainy ? 12 : 6;
    for (int i = 0; i < cloudCount; i++) {
      final baseAngle = rnd.nextDouble() * 2 * math.pi;
      final dist = (rnd.nextDouble() * 0.6 + 0.1) * (size.height / 2);
      final drift = (animationProgress * 30);

      final cloudCenter = Offset(
        center.dx + math.cos(baseAngle) * dist + drift,
        center.dy + math.sin(baseAngle) * dist,
      );

      final cloudRadius = rnd.nextDouble() * 45 + 25;
      final intensity = rnd.nextDouble();

      Color cloudColor;
      if (intensity > 0.75) {
        cloudColor = const Color(0xFFEF4444).withValues(alpha: 0.45); // Heavy rain
      } else if (intensity > 0.45) {
        cloudColor = const Color(0xFF10B981).withValues(alpha: 0.4); // Moderate
      } else {
        cloudColor = const Color(0xFF0284C7).withValues(alpha: 0.35); // Light
      }

      final paint = Paint()
        ..color = cloudColor
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);

      canvas.drawCircle(cloudCenter, cloudRadius, paint);
    }
  }

  void _paintWindStreamlines(Canvas canvas, Size size, Offset center) {
    final streamPaint = Paint()
      ..color = const Color(0xFF34D399).withValues(alpha: 0.4)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final windSpeed = condition.windSpeedKmph.clamp(10, 60);
    final rows = 6;
    final cols = 6;

    final stepX = size.width / cols;
    final stepY = size.height / rows;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final startX = (c * stepX) + (stepX / 2);
        final startY = (r * stepY) + (stepY / 2);

        final offsetFactor = (animationProgress * windSpeed * 2) % 30;
        final length = 18.0;

        // Curved streamline flow
        final p = Path();
        p.moveTo(startX + offsetFactor - 15, startY);
        p.quadraticBezierTo(
          startX + offsetFactor,
          startY - 5,
          startX + offsetFactor + length,
          startY + 2,
        );

        canvas.drawPath(p, streamPaint);
      }
    }
  }

  void _paintThermalBlobs(Canvas canvas, Size size, Offset center) {
    final temp = condition.tempC;
    Color centerColor;
    if (temp >= 35) {
      centerColor = const Color(0xFFEF4444); // Red hot
    } else if (temp >= 30) {
      centerColor = const Color(0xFFF59E0B); // Amber
    } else {
      centerColor = const Color(0xFF10B981); // Pleasant green
    }

    final thermalPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.8,
        colors: [
          centerColor.withValues(alpha: 0.4),
          centerColor.withValues(alpha: 0.15),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), thermalPaint);
  }

  Color _getSweepColor() {
    switch (layerType) {
      case RadarLayerType.rain:
        return const Color(0xFF38BDF8);
      case RadarLayerType.wind:
        return const Color(0xFF34D399);
      case RadarLayerType.temp:
        return const Color(0xFFF59E0B);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarCanvasPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.layerType != layerType ||
        oldDelegate.condition != condition;
  }
}
