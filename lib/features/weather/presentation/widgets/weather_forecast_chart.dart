import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/weather_model.dart';
import 'glass_card.dart';

enum ChartMetricType {
  temperature,
  precipitation,
  wind,
}

class WeatherForecastChart extends StatefulWidget {
  final List<HourlyWeather> hourly;

  const WeatherForecastChart({
    super.key,
    required this.hourly,
  });

  @override
  State<WeatherForecastChart> createState() => _WeatherForecastChartState();
}

class _WeatherForecastChartState extends State<WeatherForecastChart> {
  ChartMetricType _selectedMetric = ChartMetricType.temperature;
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.hourly.isEmpty) {
      return const SizedBox.shrink();
    }

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Metric Switcher Tabs
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _getMetricColor(_selectedMetric).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getMetricIcon(_selectedMetric),
                      color: _getMetricColor(_selectedMetric),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Biểu Đồ Xu Hướng 24H',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              // Segmented controls
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildMetricTab(
                      type: ChartMetricType.temperature,
                      label: '°C',
                    ),
                    _buildMetricTab(
                      type: ChartMetricType.precipitation,
                      label: '% Mưa',
                    ),
                    _buildMetricTab(
                      type: ChartMetricType.wind,
                      label: 'Gió',
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Detail display for highlighted point
          _buildInfoBanner(),

          const SizedBox(height: 10),

          // Interactive Canvas
          SizedBox(
            height: 150,
            width: double.infinity,
            child: GestureDetector(
              onTapDown: (details) => _handleTouch(details.localPosition),
              onPanUpdate: (details) => _handleTouch(details.localPosition),
              onPanEnd: (_) => setState(() => _hoveredIndex = null),
              child: CustomPaint(
                painter: _WeatherSplineChartPainter(
                  hourly: widget.hourly,
                  metricType: _selectedMetric,
                  selectedIndex: _hoveredIndex,
                  primaryColor: _getMetricColor(_selectedMetric),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Hourly labels underneath
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: widget.hourly.map((h) {
              return Text(
                h.formattedTime,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTab({required ChartMetricType type, required String label}) {
    final isSelected = _selectedMetric == type;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedMetric = type;
          _hoveredIndex = null;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? _getMetricColor(type).withValues(alpha: 0.35)
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

  Widget _buildInfoBanner() {
    final activeIndex = _hoveredIndex ?? (widget.hourly.length ~/ 2);
    final activeItem = widget.hourly[math.min(activeIndex, widget.hourly.length - 1)];

    String valueStr = '';
    String subStr = '';
    switch (_selectedMetric) {
      case ChartMetricType.temperature:
        valueStr = '${activeItem.tempC}°C (Cảm giác: ${activeItem.feelsLikeC}°C)';
        subStr = activeItem.weatherDesc;
        break;
      case ChartMetricType.precipitation:
        valueStr = '${activeItem.chanceOfRain}% xác suất mưa';
        subStr = activeItem.chanceOfRain > 50 ? 'Khả năng có mưa rào' : 'Thời tiết khô ráo';
        break;
      case ChartMetricType.wind:
        valueStr = '${activeItem.windSpeedKmph} km/h';
        subStr = activeItem.windSpeedKmph >= 30 ? 'Gió giật mạnh' : 'Gió nhẹ vừa phải';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Lúc ${activeItem.formattedTime}: $valueStr',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            subStr,
            style: TextStyle(
              fontSize: 11,
              color: _getMetricColor(_selectedMetric),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _handleTouch(Offset localPosition) {
    if (widget.hourly.isEmpty) return;
    final chartWidth = context.size?.width ?? 300;
    final count = widget.hourly.length;
    if (count <= 1) return;

    final step = chartWidth / (count - 1);
    int index = (localPosition.dx / step).round();
    index = index.clamp(0, count - 1);

    if (_hoveredIndex != index) {
      HapticFeedback.selectionClick();
      setState(() {
        _hoveredIndex = index;
      });
    }
  }

  Color _getMetricColor(ChartMetricType type) {
    switch (type) {
      case ChartMetricType.temperature:
        return const Color(0xFFF59E0B); // Amber
      case ChartMetricType.precipitation:
        return const Color(0xFF38BDF8); // Cyan
      case ChartMetricType.wind:
        return const Color(0xFF10B981); // Emerald
    }
  }

  IconData _getMetricIcon(ChartMetricType type) {
    switch (type) {
      case ChartMetricType.temperature:
        return Icons.thermostat_rounded;
      case ChartMetricType.precipitation:
        return Icons.water_drop_rounded;
      case ChartMetricType.wind:
        return Icons.air_rounded;
    }
  }
}

class _WeatherSplineChartPainter extends CustomPainter {
  final List<HourlyWeather> hourly;
  final ChartMetricType metricType;
  final int? selectedIndex;
  final Color primaryColor;

  _WeatherSplineChartPainter({
    required this.hourly,
    required this.metricType,
    required this.selectedIndex,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (hourly.isEmpty) return;

    // Extract values
    final values = hourly.map((h) {
      switch (metricType) {
        case ChartMetricType.temperature:
          return h.tempC.toDouble();
        case ChartMetricType.precipitation:
          return h.chanceOfRain.toDouble();
        case ChartMetricType.wind:
          return h.windSpeedKmph.toDouble();
      }
    }).toList();

    double minVal = values.reduce(math.min);
    double maxVal = values.reduce(math.max);

    // Give a margin on top/bottom
    if (minVal == maxVal) {
      minVal -= 2;
      maxVal += 2;
    } else {
      final diff = maxVal - minVal;
      minVal -= diff * 0.15;
      maxVal += diff * 0.25;
    }

    final count = values.length;
    final stepX = count > 1 ? size.width / (count - 1) : 0.0;

    // Compute coordinate points
    final points = <Offset>[];
    for (int i = 0; i < count; i++) {
      final x = i * stepX;
      final normalizedY = (values[i] - minVal) / (maxVal - minVal);
      final y = size.height - (normalizedY * size.height);
      points.add(Offset(x, y));
    }

    // Draw horizontal dashed grid lines
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 1; i <= 3; i++) {
      final gridY = size.height * (i / 4);
      canvas.drawLine(Offset(0, gridY), Offset(size.width, gridY), gridPaint);
    }

    // Build smooth cubic bezier curve
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final controlX = (p0.dx + p1.dx) / 2;
      path.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
    }

    // Draw Gradient Area fill under curve
    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          primaryColor.withValues(alpha: 0.35),
          primaryColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Draw Spline Stroke
    final strokePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3;

    canvas.drawPath(path, strokePaint);

    // Draw Data Points & Value Labels
    final activeIndex = selectedIndex ?? -1;

    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final isSelected = (i == activeIndex);

      // Outer halo
      if (isSelected) {
        final haloPaint = Paint()
          ..color = primaryColor.withValues(alpha: 0.3)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(p, 10, haloPaint);

        // Vertical highlight guideline
        final guidePaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;
        canvas.drawLine(Offset(p.dx, 0), Offset(p.dx, size.height), guidePaint);
      }

      // Point circle
      final dotPaint = Paint()
        ..color = isSelected ? Colors.white : primaryColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(p, isSelected ? 5 : 3.5, dotPaint);

      final dotBorderPaint = Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(p, isSelected ? 5 : 3.5, dotBorderPaint);

      // Point text value
      final val = values[i].round();
      final suffix = metricType == ChartMetricType.temperature
          ? '°'
          : metricType == ChartMetricType.precipitation
              ? '%'
              : '';
      final textSpan = TextSpan(
        text: '$val$suffix',
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.textSecondary,
          fontSize: isSelected ? 12 : 10,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      final textOffset = Offset(
        p.dx - (textPainter.width / 2),
        p.dy - textPainter.height - 6,
      );
      textPainter.paint(canvas, textOffset);
    }
  }

  @override
  bool shouldRepaint(covariant _WeatherSplineChartPainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.metricType != metricType ||
        oldDelegate.hourly != hourly ||
        oldDelegate.primaryColor != primaryColor;
  }
}
