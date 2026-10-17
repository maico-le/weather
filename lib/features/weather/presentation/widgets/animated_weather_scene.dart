import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/utils/weather_mapper.dart';

class AnimatedWeatherScene extends StatefulWidget {
  final WeatherConditionType conditionType;
  final double size;

  const AnimatedWeatherScene({
    super.key,
    required this.conditionType,
    this.size = 190,
  });

  @override
  State<AnimatedWeatherScene> createState() => _AnimatedWeatherSceneState();
}

class _AnimatedWeatherSceneState extends State<AnimatedWeatherScene>
    with TickerProviderStateMixin {
  late AnimationController _mainAnimController;
  late AnimationController _floatingAnimController;

  @override
  void initState() {
    super.initState();
    // 6-second smooth cycle for weather particle movement & sun rotation
    _mainAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    // 3-second gentle vertical levitation
    _floatingAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _mainAnimController.dispose();
    _floatingAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_mainAnimController, _floatingAnimController]),
      builder: (context, child) {
        // Subtle floating bounce (levitation)
        final floatY = math.sin(_floatingAnimController.value * math.pi) * 8.0;

        return Transform.translate(
          offset: Offset(0, -floatY),
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _PremiumWeatherScenePainter(
                progress: _mainAnimController.value,
                floatProgress: _floatingAnimController.value,
                type: widget.conditionType,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PremiumWeatherScenePainter extends CustomPainter {
  final double progress;
  final double floatProgress;
  final WeatherConditionType type;

  _PremiumWeatherScenePainter({
    required this.progress,
    required this.floatProgress,
    required this.type,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    switch (type) {
      case WeatherConditionType.sunny:
        _drawLuminousSun(canvas, size, center, isStandalone: true);
        break;
      case WeatherConditionType.partlyCloudy:
        _drawPartlyCloudy(canvas, size, center);
        break;
      case WeatherConditionType.cloudy:
      case WeatherConditionType.foggy:
        _drawVolumetricClouds(canvas, size, center, isDark: false);
        break;
      case WeatherConditionType.rainy:
        _drawRainyScene(canvas, size, center);
        break;
      case WeatherConditionType.stormy:
        _drawThunderstormScene(canvas, size, center);
        break;
      case WeatherConditionType.snowy:
        _drawSnowyScene(canvas, size, center);
        break;
    }
  }

  // 1. Premium 3D Sun with corona flares, dynamic rotating rays, and glass specular
  void _drawLuminousSun(Canvas canvas, Size size, Offset center, {bool isStandalone = false}) {
    final scale = isStandalone ? 1.0 : 0.72;
    final sunRadius = size.width * 0.24 * scale;
    final rayLength = size.width * 0.14 * scale;
    final angle = progress * 2 * math.pi;

    // Ambient Outer Bloom Glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFA000).withValues(alpha: 0.45),
          const Color(0xFFFFD54F).withValues(alpha: 0.15),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: sunRadius * 2.2))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
    canvas.drawCircle(center, sunRadius * 1.8, glowPaint);

    // Glowing Corona Flares (8 Rays with pulsing lengths)
    for (int i = 0; i < 8; i++) {
      final a = angle + (i * math.pi / 4);
      final pulse = math.sin((progress * 4 * math.pi) + (i * 0.8)) * 4.0;
      final p1 = Offset(
        center.dx + (sunRadius + 10) * math.cos(a),
        center.dy + (sunRadius + 10) * math.sin(a),
      );
      final p2 = Offset(
        center.dx + (sunRadius + 10 + rayLength + pulse) * math.cos(a),
        center.dy + (sunRadius + 10 + rayLength + pulse) * math.sin(a),
      );

      final rayPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFFFFD54F),
            const Color(0xFFFF8F00).withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromPoints(p1, p2))
        ..strokeWidth = 4.5 * scale
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(p1, p2, rayPaint);
    }

    // Secondary Shorter Diamond Rays (45 degree offset)
    for (int i = 0; i < 8; i++) {
      final a = angle + (i * math.pi / 4) + (math.pi / 8);
      final p1 = Offset(
        center.dx + (sunRadius + 8) * math.cos(a),
        center.dy + (sunRadius + 8) * math.sin(a),
      );
      final p2 = Offset(
        center.dx + (sunRadius + 8 + rayLength * 0.5) * math.cos(a),
        center.dy + (sunRadius + 8 + rayLength * 0.5) * math.sin(a),
      );

      final miniRayPaint = Paint()
        ..color = const Color(0xFFFFE082).withValues(alpha: 0.7)
        ..strokeWidth = 2.5 * scale
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(p1, p2, miniRayPaint);
    }

    // 3D Spherical Sun Body (Deep radial gradient)
    final sunBodyShader = RadialGradient(
      center: const Alignment(-0.35, -0.35),
      radius: 0.85,
      colors: const [
        Color(0xFFFFF9C4), // Bright specular white-yellow
        Color(0xFFFFEE58), // Vibrant yellow
        Color(0xFFFFA000), // Rich amber gold
        Color(0xFFE65100), // Deep warm orange edge
      ],
      stops: const [0.0, 0.35, 0.75, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: sunRadius));

    final sunBodyPaint = Paint()..shader = sunBodyShader;
    canvas.drawCircle(center, sunRadius, sunBodyPaint);

    // Specular Lens Reflection (Arc highlight)
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0 * scale
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    final highlightRect = Rect.fromCircle(
      center: Offset(center.dx - 4, center.dy - 4),
      radius: sunRadius * 0.82,
    );
    canvas.drawArc(highlightRect, math.pi * 1.1, math.pi * 0.5, false, highlightPaint);
  }

  // 2. Partly Cloudy (Sun peeking from behind multi-layer glass cloud)
  void _drawPartlyCloudy(Canvas canvas, Size size, Offset center) {
    // Sun positioned in the upper right
    final sunCenter = Offset(center.dx + size.width * 0.22, center.dy - size.height * 0.16);
    _drawLuminousSun(canvas, size, sunCenter, isStandalone: false);

    // Front Frosted Cloud
    final cloudCenter = Offset(center.dx - size.width * 0.08, center.dy + size.height * 0.08);
    _drawVolumetricClouds(canvas, size, cloudCenter, isDark: false);
  }

  // 3. Volumetric Frosted Glassmorphism Cloud with Depth & Soft Shadows
  void _drawVolumetricClouds(Canvas canvas, Size size, Offset center, {required bool isDark}) {
    final r = size.width * 0.22;

    // Drop shadow under cloud
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: isDark ? 0.35 : 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(center.dx, center.dy + r * 0.45), width: r * 2.8, height: r * 0.9),
        Radius.circular(r * 0.5),
      ),
      shadowPaint,
    );

    // Secondary Back Cloud (adds 3D layering)
    final backColor = isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1);
    final backPaint = Paint()
      ..color = backColor.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    final backOffset = Offset(center.dx + r * 0.35, center.dy - r * 0.25);
    canvas.drawCircle(backOffset, r * 0.65, backPaint);

    // Main Front Cloud (Triple circle clusters + Pill base)
    final mainShader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? const [
              Color(0xFF64748B), // Slate highlight
              Color(0xFF334155),
              Color(0xFF1E293B), // Deep slate base
            ]
          : const [
              Colors.white, // Crisp bright top
              Color(0xFFF1F5F9),
              Color(0xFFE2E8F0), // Soft glass bottom
            ],
    ).createShader(Rect.fromCenter(center: center, width: r * 3, height: r * 2));

    final mainPaint = Paint()..shader = mainShader;

    // Left puff
    canvas.drawCircle(Offset(center.dx - r * 0.72, center.dy + r * 0.12), r * 0.65, mainPaint);
    // Center big dome
    canvas.drawCircle(Offset(center.dx, center.dy - r * 0.35), r * 0.95, mainPaint);
    // Right puff
    canvas.drawCircle(Offset(center.dx + r * 0.82, center.dy + r * 0.14), r * 0.60, mainPaint);

    // Base rounded platform
    final baseRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(center.dx, center.dy + r * 0.30), width: r * 2.7, height: r * 0.95),
      Radius.circular(r * 0.5),
    );
    canvas.drawRRect(baseRect, mainPaint);

    // Top Rim Lighting / Frosted Glass Edge Highlight
    final rimPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.8),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(center.dx - r * 1.3, center.dy - r * 1.3, r * 2.6, r * 2.6))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(Offset(center.dx, center.dy - r * 0.35), r * 0.95, rimPaint);
  }

  // 4. Rainy Scene with Dynamic Diagonal Rain Streamlines and Splash Particles
  void _drawRainyScene(Canvas canvas, Size size, Offset center) {
    // Darker rain cloud lifted slightly
    final cloudCenter = Offset(center.dx, center.dy - size.height * 0.14);
    _drawVolumetricClouds(canvas, size, cloudCenter, isDark: true);

    // 5 Slanted Rain Streaks
    final rainPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF38BDF8).withValues(alpha: 0.1),
          const Color(0xFF0284C7),
          const Color(0xFF38BDF8),
        ],
      ).createShader(Rect.fromLTWH(0, center.dy, size.width, size.height * 0.4))
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final startY = cloudCenter.dy + (size.width * 0.22 * 0.7);
    final dropSpacing = size.width * 0.15;

    for (int i = 0; i < 5; i++) {
      final x = (center.dx - dropSpacing * 2.0) + i * dropSpacing;
      final yCycle = (progress * 2.5 + (i * 0.22)) % 1.0;
      final currentY = startY + (yCycle * size.height * 0.38);

      // Raindrop trail (slightly tilted 12 degrees)
      final p1 = Offset(x - 4, currentY);
      final p2 = Offset(x, currentY + 18);
      canvas.drawLine(p1, p2, rainPaint);

      // Ground splash ripple on bottom of drop cycle
      if (yCycle > 0.85) {
        final splashAlpha = (1.0 - yCycle) / 0.15;
        final splashPaint = Paint()
          ..color = const Color(0xFF38BDF8).withValues(alpha: splashAlpha * 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

        canvas.drawOval(
          Rect.fromCenter(center: Offset(x, startY + size.height * 0.38), width: 14 * (1.0 - splashAlpha), height: 5),
          splashPaint,
        );
      }
    }
  }

  // 5. Thunderstorm Scene with Ambient Violet Lightning Flash & Forked Bolt
  void _drawThunderstormScene(Canvas canvas, Size size, Offset center) {
    // Lightning Flash Frequency (random-feeling periodic burst)
    final flashVal = math.sin(progress * 16 * math.pi);
    final isFlashing = flashVal > 0.82;

    if (isFlashing) {
      // Background Violet Electrical Pulse
      final flashBloom = Paint()
        ..color = const Color(0xFFA855F7).withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 35);
      canvas.drawCircle(center, size.width * 0.45, flashBloom);
    }

    _drawRainyScene(canvas, size, center);

    // Glowing Neon Yellow Forked Lightning Bolt
    if (isFlashing) {
      final boltGlow = Paint()
        ..color = const Color(0xFFFDE047).withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7.0
        ..strokeJoin = StrokeJoin.miter
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      final boltCore = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeJoin = StrokeJoin.miter;

      final boltPath = Path();
      boltPath.moveTo(center.dx - 2, center.dy - 6);
      boltPath.lineTo(center.dx - 14, center.dy + 22);
      boltPath.lineTo(center.dx + 4, center.dy + 20);
      boltPath.lineTo(center.dx - 6, center.dy + 52);

      // Branch bolt
      boltPath.moveTo(center.dx - 4, center.dy + 20);
      boltPath.lineTo(center.dx + 12, center.dy + 38);

      canvas.drawPath(boltPath, boltGlow);
      canvas.drawPath(boltPath, boltCore);
    }
  }

  // 6. Snowy Scene with Hexagonal Drifting Crystals
  void _drawSnowyScene(Canvas canvas, Size size, Offset center) {
    final cloudCenter = Offset(center.dx, center.dy - size.height * 0.14);
    _drawVolumetricClouds(canvas, size, cloudCenter, isDark: false);

    final startY = cloudCenter.dy + (size.width * 0.22 * 0.7);

    for (int i = 0; i < 6; i++) {
      final baseX = (center.dx - size.width * 0.3) + i * (size.width * 0.12);
      final yCycle = (progress + (i * 0.18)) % 1.0;
      final currentY = startY + (yCycle * size.height * 0.36);

      // Horizontal sway (gentle breeze)
      final swayX = baseX + math.sin((progress * 4 * math.pi) + i) * 8.0;

      // Hexagonal snowflake
      final flakePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      final c = Offset(swayX, currentY);
      const flkSize = 4.5;
      for (int k = 0; k < 3; k++) {
        final a = (k * math.pi / 3) + (progress * 2 * math.pi);
        canvas.drawLine(
          Offset(c.dx - flkSize * math.cos(a), c.dy - flkSize * math.sin(a)),
          Offset(c.dx + flkSize * math.cos(a), c.dy + flkSize * math.sin(a)),
          flakePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PremiumWeatherScenePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.floatProgress != floatProgress ||
        oldDelegate.type != type;
  }
}
