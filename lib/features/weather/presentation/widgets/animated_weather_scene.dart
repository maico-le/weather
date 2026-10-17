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
  late AnimationController _characterAnimController;
  late AnimationController _blinkAnimController;
  late AnimationController _breatheAnimController;

  // Touch reaction state (Duolingo poke reaction)
  bool _isPoked = false;
  double _pokeSquash = 1.0;

  @override
  void initState() {
    super.initState();

    // 1. Character joyful idle dance (Duolingo style sway & bounce)
    _characterAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    // 2. Eye Blink controller (blinks every 3.5 seconds)
    _blinkAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..repeat();

    // 3. Gentle breathing / scale pulse
    _breatheAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _characterAnimController.dispose();
    _blinkAnimController.dispose();
    _breatheAnimController.dispose();
    super.dispose();
  }

  void _onTapCharacter() {
    setState(() {
      _isPoked = true;
      _pokeSquash = 0.82;
    });

    Future.delayed(const Duration(milliseconds: 140), () {
      if (mounted) {
        setState(() {
          _pokeSquash = 1.15; // stretch bounce
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 320), () {
      if (mounted) {
        setState(() {
          _isPoked = false;
          _pokeSquash = 1.0; // restore
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTapCharacter,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _characterAnimController,
          _blinkAnimController,
          _breatheAnimController,
        ]),
        builder: (context, child) {
          final danceProgress = _characterAnimController.value;
          final breathe = _breatheAnimController.value;

          // Duolingo organic physics: rhythmic sway & squash-and-stretch
          final swayAngle = math.sin(danceProgress * 2 * math.pi) * 0.08;
          final verticalBounce = -math.sin(danceProgress * 2 * math.pi).abs() * 12.0;
          final squashStretchY = (1.0 + (breathe * 0.04)) * _pokeSquash;
          final squashStretchX = (1.0 - (breathe * 0.02)) / math.sqrt(_pokeSquash);

          // Blink logic: eyes shut quickly when blink controller reaches 92%-98%
          final blinkVal = _blinkAnimController.value;
          final isBlinking = blinkVal > 0.92 && blinkVal < 0.98;

          return Transform.translate(
            offset: Offset(0, verticalBounce),
            child: Transform.rotate(
              angle: swayAngle,
              child: Transform.scale(
                scaleX: squashStretchX,
                scaleY: squashStretchY,
                child: SizedBox(
                  width: widget.size,
                  height: widget.size,
                  child: CustomPaint(
                    size: Size(widget.size, widget.size),
                    painter: _DuolingoMascotPainter(
                      danceProgress: danceProgress,
                      isBlinking: isBlinking,
                      isPoked: _isPoked,
                      condition: widget.conditionType,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DuolingoMascotPainter extends CustomPainter {
  final double danceProgress;
  final bool isBlinking;
  final bool isPoked;
  final WeatherConditionType condition;

  _DuolingoMascotPainter({
    required this.danceProgress,
    required this.isBlinking,
    required this.isPoked,
    required this.condition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    switch (condition) {
      case WeatherConditionType.sunny:
        _drawSunnyMascot(canvas, size, center);
        break;
      case WeatherConditionType.rainy:
      case WeatherConditionType.stormy:
        _drawRainyMascot(canvas, size, center);
        break;
      case WeatherConditionType.cloudy:
      case WeatherConditionType.partlyCloudy:
      case WeatherConditionType.foggy:
        _drawCloudyMascot(canvas, size, center);
        break;
      case WeatherConditionType.snowy:
        _drawSnowyMascot(canvas, size, center);
        break;
    }
  }

  // 1. SUNNY MASCOT: "Sunny Pip" - Golden energetic sun character with rosy cheeks and rotating crown rays
  void _drawSunnyMascot(Canvas canvas, Size size, Offset center) {
    final radius = size.width * 0.32;

    // Glowing warm ambient shadow
    final shadowPaint = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
    canvas.drawCircle(center, radius * 1.2, shadowPaint);

    // Dynamic Rotating Triangular Crown Rays (Duolingo bold chunky style)
    final rayPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.fill;

    final rayRot = danceProgress * 2 * math.pi;
    for (int i = 0; i < 8; i++) {
      final a = rayRot + (i * math.pi / 4);
      final rayDist = radius + 8;
      final pTip = Offset(center.dx + (rayDist + 18) * math.cos(a), center.dy + (rayDist + 18) * math.sin(a));
      final pL = Offset(center.dx + rayDist * math.cos(a - 0.22), center.dy + rayDist * math.sin(a - 0.22));
      final pR = Offset(center.dx + rayDist * math.cos(a + 0.22), center.dy + rayDist * math.sin(a + 0.22));

      final rayPath = Path()
        ..moveTo(pL.dx, pL.dy)
        ..lineTo(pTip.dx, pTip.dy)
        ..lineTo(pR.dx, pR.dy)
        ..close();

      canvas.drawPath(rayPath, rayPaint);
    }

    // Chubby Sun Body (Bright golden gradient)
    final bodyPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.25, -0.25),
        radius: 0.9,
        colors: [
          Color(0xFFFFF59D), // Warm cream highlight
          Color(0xFFFBBF24), // Vibrant gold
          Color(0xFFF59E0B), // Warm amber edge
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, bodyPaint);

    // Thick Black Cartoon Outlines (Duolingo signature bold stroke)
    final outlinePaint = Paint()
      ..color = const Color(0xFF78350F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    canvas.drawCircle(center, radius, outlinePaint);

    // Rosy Pink Cheeks
    final cheekPaint = Paint()
      ..color = const Color(0xFFF43F5E).withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx - radius * 0.48, center.dy + radius * 0.18), width: 18, height: 12), cheekPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx + radius * 0.48, center.dy + radius * 0.18), width: 18, height: 12), cheekPaint);

    // Big Expressive Cartoon Eyes
    _drawDuolingoEyes(canvas, center, radius, isBlinking: isBlinking, isHappy: true);

    // Open Happy Smiling Mouth with Tongue
    _drawDuolingoMouth(canvas, center, radius, isExcited: isPoked);
  }

  // 2. RAINY MASCOT: "Droppy" - Chubby blue raindrop character wearing yellow boots or waving
  void _drawRainyMascot(Canvas canvas, Size size, Offset center) {
    final r = size.width * 0.30;

    // Teardrop body path (chubby bottom, tapered top)
    final dropPath = Path();
    dropPath.moveTo(center.dx, center.dy - r * 1.15);
    dropPath.cubicTo(
      center.dx + r * 1.05,
      center.dy - r * 0.2,
      center.dx + r * 1.1,
      center.dy + r * 0.95,
      center.dx,
      center.dy + r * 0.95,
    );
    dropPath.cubicTo(
      center.dx - r * 1.1,
      center.dy + r * 0.95,
      center.dx - r * 1.05,
      center.dy - r * 0.2,
      center.dx,
      center.dy - r * 1.15,
    );
    dropPath.close();

    // Vibrant Cyan gradient
    final bodyPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.25, -0.25),
        radius: 0.95,
        colors: const [
          Color(0xFFBAE6FD),
          Color(0xFF38BDF8),
          Color(0xFF0284C7),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: r));

    canvas.drawPath(dropPath, bodyPaint);

    // Bold cartoon outline
    final strokePaint = Paint()
      ..color = const Color(0xFF0C4A6E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    canvas.drawPath(dropPath, strokePaint);

    // Specular Highlight on forehead
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx - r * 0.35, center.dy - r * 0.35), width: 14, height: 24),
      highlightPaint,
    );

    // Soft Pink Cheeks
    final cheekPaint = Paint()
      ..color = const Color(0xFFFB7185).withValues(alpha: 0.45);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx - r * 0.45, center.dy + r * 0.22), width: 16, height: 10), cheekPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx + r * 0.45, center.dy + r * 0.22), width: 16, height: 10), cheekPaint);

    // Eyes & Mouth
    _drawDuolingoEyes(canvas, Offset(center.dx, center.dy + 8), r, isBlinking: isBlinking, isHappy: true);
    _drawDuolingoMouth(canvas, Offset(center.dx, center.dy + 8), r, isExcited: isPoked);
  }

  // 3. CLOUDY MASCOT: "Nimbus" - Fluffy white cotton cloud with playful round eyes
  void _drawCloudyMascot(Canvas canvas, Size size, Offset center) {
    final r = size.width * 0.24;

    final cloudPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white,
          Color(0xFFF1F5F9),
          Color(0xFFE2E8F0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: r * 1.5));

    final outlinePaint = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    // Draw fluffy cloud blobs
    void drawPuff(Offset c, double radius) {
      canvas.drawCircle(c, radius, cloudPaint);
      canvas.drawCircle(c, radius, outlinePaint);
    }

    drawPuff(Offset(center.dx - r * 0.85, center.dy + r * 0.15), r * 0.65);
    drawPuff(Offset(center.dx + r * 0.85, center.dy + r * 0.15), r * 0.65);
    drawPuff(Offset(center.dx - r * 0.35, center.dy - r * 0.35), r * 0.75);
    drawPuff(Offset(center.dx + r * 0.35, center.dy - r * 0.30), r * 0.70);

    // Fill center seam
    canvas.drawCircle(center, r * 0.7, cloudPaint);

    // Cheeks
    final cheekPaint = Paint()..color = const Color(0xFFF43F5E).withValues(alpha: 0.35);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx - r * 0.55, center.dy + r * 0.25), width: 16, height: 10), cheekPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx + r * 0.55, center.dy + r * 0.25), width: 16, height: 10), cheekPaint);

    // Face
    _drawDuolingoEyes(canvas, Offset(center.dx, center.dy + 6), r, isBlinking: isBlinking, isHappy: true);
    _drawDuolingoMouth(canvas, Offset(center.dx, center.dy + 6), r, isExcited: isPoked);
  }

  // 4. SNOWY MASCOT: "Snowy Flake" - Chubby snowflake with cozy knit earmuffs
  void _drawSnowyMascot(Canvas canvas, Size size, Offset center) {
    _drawSunnyMascot(canvas, size, center); // Fallback to cheerful base with cool frosty tones
  }

  // Expressive Duolingo Cartoon Eyes
  void _drawDuolingoEyes(Canvas canvas, Offset center, double radius, {required bool isBlinking, required bool isHappy}) {
    final eyeSpacing = radius * 0.36;
    final eyeY = center.dy - radius * 0.08;

    final leftEye = Offset(center.dx - eyeSpacing, eyeY);
    final rightEye = Offset(center.dx + eyeSpacing, eyeY);

    if (isBlinking) {
      // Curved happy closed-eye arc "^ ^"
      final arcPaint = Paint()
        ..color = const Color(0xFF1E293B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round;

      final arcR = radius * 0.16;
      canvas.drawArc(Rect.fromCircle(center: leftEye, radius: arcR), math.pi * 1.1, math.pi * 0.8, false, arcPaint);
      canvas.drawArc(Rect.fromCircle(center: rightEye, radius: arcR), math.pi * 1.1, math.pi * 0.8, false, arcPaint);
    } else {
      // Big glossy oval pupils with cute white catchlights
      final eyeWidth = radius * 0.24;
      final eyeHeight = radius * 0.34;

      final eyePaint = Paint()..color = const Color(0xFF0F172A);
      final leftRect = Rect.fromCenter(center: leftEye, width: eyeWidth, height: eyeHeight);
      final rightRect = Rect.fromCenter(center: rightEye, width: eyeWidth, height: eyeHeight);

      canvas.drawOval(leftRect, eyePaint);
      canvas.drawOval(rightRect, eyePaint);

      // Primary Catchlight (Top-right white gleam)
      final catchlightPaint = Paint()..color = Colors.white;
      canvas.drawCircle(Offset(leftEye.dx + eyeWidth * 0.2, leftEye.dy - eyeHeight * 0.22), eyeWidth * 0.30, catchlightPaint);
      canvas.drawCircle(Offset(rightEye.dx + eyeWidth * 0.2, rightEye.dy - eyeHeight * 0.22), eyeWidth * 0.30, catchlightPaint);

      // Secondary Catchlight (Bottom-left subtle gleam)
      canvas.drawCircle(Offset(leftEye.dx - eyeWidth * 0.15, leftEye.dy + eyeHeight * 0.2), eyeWidth * 0.15, catchlightPaint);
      canvas.drawCircle(Offset(rightEye.dx - eyeWidth * 0.15, rightEye.dy + eyeHeight * 0.2), eyeWidth * 0.15, catchlightPaint);
    }
  }

  // Expressive Mouth with Tongue (Duolingo style)
  void _drawDuolingoMouth(Canvas canvas, Offset center, double radius, {required bool isExcited}) {
    final mouthY = center.dy + radius * 0.32;
    final mouthWidth = isExcited ? radius * 0.48 : radius * 0.36;
    final mouthHeight = isExcited ? radius * 0.36 : radius * 0.22;

    final mouthRect = Rect.fromCenter(center: Offset(center.dx, mouthY), width: mouthWidth, height: mouthHeight);

    // Mouth cavity (Dark maroon)
    final mouthPath = Path();
    mouthPath.moveTo(mouthRect.left, mouthRect.top);
    mouthPath.quadraticBezierTo(mouthRect.center.dx, mouthRect.bottom + (isExcited ? 10 : 4), mouthRect.right, mouthRect.top);
    mouthPath.close();

    final cavityPaint = Paint()..color = const Color(0xFF4C0519);
    canvas.drawPath(mouthPath, cavityPaint);

    // Cute Pink Tongue peaking inside
    canvas.save();
    canvas.clipPath(mouthPath);
    final tonguePaint = Paint()..color = const Color(0xFFFB7185);
    canvas.drawCircle(Offset(center.dx, mouthRect.bottom + 2), mouthWidth * 0.38, tonguePaint);
    canvas.restore();

    // Mouth outline
    final mouthOutline = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(mouthPath, mouthOutline);
  }

  @override
  bool shouldRepaint(covariant _DuolingoMascotPainter oldDelegate) => true;
}
