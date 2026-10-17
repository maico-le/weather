import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/utils/weather_mapper.dart';

class AnimatedWeatherScene extends StatefulWidget {
  final WeatherConditionType conditionType;
  final double size;

  const AnimatedWeatherScene({
    super.key,
    required this.conditionType,
    this.size = 180,
  });

  @override
  State<AnimatedWeatherScene> createState() => _AnimatedWeatherSceneState();
}

class _AnimatedWeatherSceneState extends State<AnimatedWeatherScene>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lottieUrl = WeatherMapper.getLottieUrl(widget.conditionType);

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Lottie Animation with fallback to Vector Painter
          Lottie.network(
            lottieUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return _buildVectorFallback();
            },
            frameBuilder: (context, child, composition) {
              if (composition == null) {
                return _buildVectorFallback();
              }
              return child;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVectorFallback() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _WeatherVectorPainter(
            progress: _controller.value,
            type: widget.conditionType,
          ),
        );
      },
    );
  }
}

class _WeatherVectorPainter extends CustomPainter {
  final double progress;
  final WeatherConditionType type;

  _WeatherVectorPainter({required this.progress, required this.type});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    switch (type) {
      case WeatherConditionType.sunny:
        _drawSunny(canvas, size, center);
        break;
      case WeatherConditionType.partlyCloudy:
        _drawPartlyCloudy(canvas, size, center);
        break;
      case WeatherConditionType.cloudy:
      case WeatherConditionType.foggy:
        _drawCloud(canvas, size, center, const Color(0xFFECEFF1));
        break;
      case WeatherConditionType.rainy:
        _drawRain(canvas, size, center);
        break;
      case WeatherConditionType.stormy:
        _drawStorm(canvas, size, center);
        break;
      case WeatherConditionType.snowy:
        _drawSnow(canvas, size, center);
        break;
    }
  }

  void _drawSunny(Canvas canvas, Size size, Offset center) {
    final sunRadius = size.width * 0.22;
    final rayLength = size.width * 0.12;
    final angle = progress * 2 * math.pi;

    // Glowing halo
    final haloPaint = Paint()
      ..color = const Color(0xFFFFD54F).withValues(alpha: 0.3 + 0.1 * math.sin(progress * 2 * math.pi))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(center, sunRadius * 1.3, haloPaint);

    // Rays
    final rayPaint = Paint()
      ..color = const Color(0xFFFFB300)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 8; i++) {
      final a = angle + (i * math.pi / 4);
      final p1 = Offset(
        center.dx + (sunRadius + 8) * math.cos(a),
        center.dy + (sunRadius + 8) * math.sin(a),
      );
      final p2 = Offset(
        center.dx + (sunRadius + 8 + rayLength) * math.cos(a),
        center.dy + (sunRadius + 8 + rayLength) * math.sin(a),
      );
      canvas.drawLine(p1, p2, rayPaint);
    }

    // Sun core
    final sunGradient = const RadialGradient(
      colors: [Color(0xFFFFF176), Color(0xFFFF8F00)],
    ).createShader(Rect.fromCircle(center: center, radius: sunRadius));

    final sunPaint = Paint()..shader = sunGradient;
    canvas.drawCircle(center, sunRadius, sunPaint);
  }

  void _drawPartlyCloudy(Canvas canvas, Size size, Offset center) {
    final sunCenter = Offset(center.dx + size.width * 0.15, center.dy - size.height * 0.15);
    _drawSunny(canvas, size * 0.7, sunCenter);
    _drawCloud(canvas, size, Offset(center.dx - size.width * 0.05, center.dy + size.height * 0.1), const Color(0xFFFFFFFF));
  }

  void _drawCloud(Canvas canvas, Size size, Offset center, Color baseColor) {
    final paint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.fill;

    // Float oscillation
    final floatOffset = math.sin(progress * 2 * math.pi) * 4;
    final c = Offset(center.dx, center.dy + floatOffset);

    final r = size.width * 0.18;
    canvas.drawCircle(Offset(c.dx - r * 0.7, c.dy + r * 0.2), r * 0.7, paint);
    canvas.drawCircle(Offset(c.dx, c.dy - r * 0.3), r * 0.9, paint);
    canvas.drawCircle(Offset(c.dx + r * 0.8, c.dy + r * 0.2), r * 0.65, paint);

    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(c.dx, c.dy + r * 0.3), width: r * 2.6, height: r * 0.9),
      Radius.circular(r * 0.45),
    );
    canvas.drawRRect(rect, paint);
  }

  void _drawRain(Canvas canvas, Size size, Offset center) {
    _drawCloud(canvas, size, Offset(center.dx, center.dy - size.height * 0.15), const Color(0xFFCFD8DC));

    final rainPaint = Paint()
      ..color = const Color(0xFF4FC3F7)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final startY = center.dy + size.height * 0.1;
    final dropSpacing = size.width * 0.18;

    for (int i = 0; i < 4; i++) {
      final x = (center.dx - dropSpacing * 1.5) + i * dropSpacing;
      final yProgress = (progress + (i * 0.25)) % 1.0;
      final y = startY + yProgress * (size.height * 0.3);

      canvas.drawLine(
        Offset(x - 3, y),
        Offset(x, y + 14),
        rainPaint,
      );
    }
  }

  void _drawStorm(Canvas canvas, Size size, Offset center) {
    _drawRain(canvas, size, center);

    // Flashing lightning bolt
    if ((progress * 10) % 2 > 1.2) {
      final boltPaint = Paint()
        ..color = const Color(0xFFFFEB3B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeJoin = StrokeJoin.round;

      final path = Path();
      path.moveTo(center.dx - 5, center.dy);
      path.lineTo(center.dx - 12, center.dy + 25);
      path.lineTo(center.dx + 4, center.dy + 22);
      path.lineTo(center.dx - 4, center.dy + 48);

      canvas.drawPath(path, boltPaint);
    }
  }

  void _drawSnow(Canvas canvas, Size size, Offset center) {
    _drawCloud(canvas, size, Offset(center.dx, center.dy - size.height * 0.15), const Color(0xFFECEFF1));

    final snowPaint = Paint()..color = Colors.white;
    final startY = center.dy + size.height * 0.1;

    for (int i = 0; i < 5; i++) {
      final x = (center.dx - size.width * 0.25) + i * (size.width * 0.12);
      final yProgress = (progress + (i * 0.2)) % 1.0;
      final y = startY + yProgress * (size.height * 0.28);
      canvas.drawCircle(Offset(x, y), 3, snowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WeatherVectorPainter oldDelegate) => true;
}
