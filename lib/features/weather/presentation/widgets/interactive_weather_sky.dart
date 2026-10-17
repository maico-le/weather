import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/utils/weather_mapper.dart';

class InteractiveWeatherSky extends StatefulWidget {
  final WeatherConditionType condition;
  final Widget child;

  const InteractiveWeatherSky({
    super.key,
    required this.condition,
    required this.child,
  });

  @override
  State<InteractiveWeatherSky> createState() => _InteractiveWeatherSkyState();
}

class _InteractiveWeatherSkyState extends State<InteractiveWeatherSky>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  Offset _touchPosition = Offset.zero;
  bool _isInteracting = false;
  final List<_SkyParticle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    // Fast 1.5s repeating loop for real-time rain/sunray/snow motion
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    _initParticles();
  }

  void _initParticles() {
    _particles.clear();
    // 70 full-screen particles adapted dynamically to condition
    for (int i = 0; i < 70; i++) {
      _particles.add(
        _SkyParticle(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          length: _random.nextDouble() * 26 + 14,
          speed: _random.nextDouble() * 0.8 + 0.6,
          opacity: _random.nextDouble() * 0.5 + 0.25,
          thickness: _random.nextDouble() * 1.5 + 1.0,
          driftAngle: (_random.nextDouble() - 0.5) * 0.15,
        ),
      );
    }
  }

  @override
  void didUpdateWidget(covariant InteractiveWeatherSky oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.condition != widget.condition) {
      _initParticles();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent event) {
    setState(() {
      _touchPosition = event.localPosition;
      _isInteracting = true;
    });
  }

  void _onPointerMove(PointerMoveEvent event) {
    setState(() {
      _touchPosition = event.localPosition;
    });
  }

  void _onPointerUp(PointerUpEvent event) {
    setState(() {
      _isInteracting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = WeatherMapper.getBackgroundGradient(widget.condition);

    return Listener(
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      child: Stack(
        children: [
          // Dynamic Atmospheric Gradient Background
          AnimatedContainer(
            duration: const Duration(milliseconds: 700),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: colors,
              ),
            ),
          ),

          // FULLSCREEN LIVE WEATHER PARTICLES (Rain streaks, Sunbeams, Lightning flash, Snow)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _LiveAtmosphericSkyPainter(
                    particles: _particles,
                    progress: _animController.value,
                    touchPosition: _touchPosition,
                    isInteracting: _isInteracting,
                    condition: widget.condition,
                  ),
                );
              },
            ),
          ),

          // Main child content (Cards, Lists, Hero)
          widget.child,
        ],
      ),
    );
  }
}

class _SkyParticle {
  double x;
  double y;
  final double length;
  final double speed;
  final double opacity;
  final double thickness;
  final double driftAngle;

  _SkyParticle({
    required this.x,
    required this.y,
    required this.length,
    required this.speed,
    required this.opacity,
    required this.thickness,
    required this.driftAngle,
  });
}

class _LiveAtmosphericSkyPainter extends CustomPainter {
  final List<_SkyParticle> particles;
  final double progress;
  final Offset touchPosition;
  final bool isInteracting;
  final WeatherConditionType condition;

  _LiveAtmosphericSkyPainter({
    required this.particles,
    required this.progress,
    required this.touchPosition,
    required this.isInteracting,
    required this.condition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (condition) {
      case WeatherConditionType.rainy:
      case WeatherConditionType.stormy:
        _paintFullScreenRain(canvas, size);
        if (condition == WeatherConditionType.stormy) {
          _paintThunderFlash(canvas, size);
        }
        break;
      case WeatherConditionType.sunny:
        _paintSunBeamsAndMotes(canvas, size);
        break;
      case WeatherConditionType.snowy:
        _paintFullScreenSnow(canvas, size);
        break;
      case WeatherConditionType.partlyCloudy:
      case WeatherConditionType.cloudy:
      case WeatherConditionType.foggy:
        _paintAmbientDustAndMist(canvas, size);
        break;
    }

    // Touch Ripple Interaction
    if (isInteracting && touchPosition != Offset.zero) {
      final ripplePaint = Paint()
        ..color = const Color(0xFF38BDF8).withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);
      canvas.drawCircle(touchPosition, 75, ripplePaint);

      final corePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(touchPosition, 25, corePaint);
    }
  }

  // 1. FULLSCREEN REAL-TIME FALLING RAIN
  void _paintFullScreenRain(Canvas canvas, Size size) {
    final rainPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (final p in particles) {
      // Dynamic fall trajectory
      final currentY = ((p.y + (progress * p.speed * 2.2)) % 1.1) * size.height;
      final currentX = (p.x * size.width) - (currentY * 0.15); // slanted rain

      if (currentY >= 0 && currentY <= size.height) {
        final dropLength = p.length * 1.5;
        final p1 = Offset(currentX, currentY);
        final p2 = Offset(currentX - (dropLength * 0.15), currentY + dropLength);

        rainPaint
          ..color = const Color(0xFFBAE6FD).withValues(alpha: p.opacity * 0.65)
          ..strokeWidth = p.thickness;

        canvas.drawLine(p1, p2, rainPaint);

        // Ground splash ripple on bottom 15% of screen
        if (currentY > size.height * 0.88) {
          final splashProgress = (currentY - size.height * 0.88) / (size.height * 0.12);
          final splashPaint = Paint()
            ..color = const Color(0xFF38BDF8).withValues(alpha: (1.0 - splashProgress) * 0.4)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0;

          canvas.drawOval(
            Rect.fromCenter(
              center: Offset(currentX, size.height - 10),
              width: 14 * splashProgress,
              height: 4 * splashProgress,
            ),
            splashPaint,
          );
        }
      }
    }
  }

  // 2. PERIODIC THUNDER LIGHTNING BURST
  void _paintThunderFlash(Canvas canvas, Size size) {
    // Flash spike based on fast sine pulsation
    final flashVal = math.sin(progress * 12 * math.pi);
    if (flashVal > 0.85) {
      final flashAlpha = (flashVal - 0.85) / 0.15 * 0.35;
      final flashPaint = Paint()
        ..color = const Color(0xFFA855F7).withValues(alpha: flashAlpha);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), flashPaint);
    }
  }

  // 3. SUNNY: DIAGONAL SUNBEAMS & GOLDEN SOLAR DUST MOTES
  void _paintSunBeamsAndMotes(Canvas canvas, Size size) {
    // 3 Shimmering Volumetric Sunbeams cascading from top right
    final beamPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

    for (int i = 0; i < 3; i++) {
      final beamPulse = 0.12 + 0.06 * math.sin((progress * 2 * math.pi) + (i * 1.5));
      beamPaint.shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          const Color(0xFFFFE082).withValues(alpha: beamPulse),
          const Color(0xFFFFA000).withValues(alpha: beamPulse * 0.4),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 0.9],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      final beamPath = Path();
      final startOffset = i * (size.width * 0.28);
      beamPath.moveTo(size.width - startOffset, 0);
      beamPath.lineTo(size.width - startOffset - 90, 0);
      beamPath.lineTo(0, size.height * (0.6 + i * 0.15));
      beamPath.lineTo(0, size.height * (0.8 + i * 0.15));
      beamPath.close();

      canvas.drawPath(beamPath, beamPaint);
    }

    // Golden Floating Solar Motes drifting gently upward
    final motePaint = Paint()..style = PaintingStyle.fill;
    for (final p in particles) {
      final currentY = ((p.y - (progress * p.speed * 0.2)) % 1.0) * size.height;
      final sway = math.sin((progress * 4 * math.pi) + (p.x * 10)) * 12;
      final currentX = (p.x * size.width) + sway;

      final alpha = p.opacity * (0.4 + 0.4 * math.sin((progress * 2 * math.pi) + p.y));
      motePaint.color = const Color(0xFFFFF9C4).withValues(alpha: alpha.clamp(0.0, 1.0));
      canvas.drawCircle(Offset(currentX, currentY), p.thickness * 1.2, motePaint);
    }
  }

  // 4. SNOWY: SWAYING FALLING SNOWFLAKES
  void _paintFullScreenSnow(Canvas canvas, Size size) {
    final snowPaint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      final currentY = ((p.y + (progress * p.speed * 0.5)) % 1.0) * size.height;
      final sway = math.sin((progress * 3 * math.pi) + (p.y * 6)) * 18;
      final currentX = (p.x * size.width) + sway;

      snowPaint.color = Colors.white.withValues(alpha: p.opacity * 0.8);
      canvas.drawCircle(Offset(currentX, currentY), p.thickness * 1.6, snowPaint);
    }
  }

  // 5. AMBIENT MIST & DUST
  void _paintAmbientDustAndMist(Canvas canvas, Size size) {
    final dustPaint = Paint()..style = PaintingStyle.fill;

    for (final p in particles.take(30)) {
      final currentY = ((p.y + (progress * p.speed * 0.15)) % 1.0) * size.height;
      final currentX = p.x * size.width;

      dustPaint.color = Colors.white.withValues(
        alpha: p.opacity * (0.3 + 0.3 * math.sin(progress * 2 * math.pi)),
      );
      canvas.drawCircle(Offset(currentX, currentY), p.thickness * 1.2, dustPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LiveAtmosphericSkyPainter oldDelegate) => true;
}
