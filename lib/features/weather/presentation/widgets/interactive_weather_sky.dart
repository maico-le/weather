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
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Generate floating ambient light particles
    for (int i = 0; i < 25; i++) {
      _particles.add(
        _SkyParticle(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          radius: _random.nextDouble() * 2.5 + 1.0,
          speed: _random.nextDouble() * 0.05 + 0.02,
          opacity: _random.nextDouble() * 0.4 + 0.2,
        ),
      );
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
          // Dynamic Atmospheric Gradient
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

          // Interactive Particle Layer & Touch Ripple
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _InteractiveSkyPainter(
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

          // Main child content
          widget.child,
        ],
      ),
    );
  }
}

class _SkyParticle {
  double x;
  double y;
  final double radius;
  final double speed;
  final double opacity;

  _SkyParticle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.opacity,
  });
}

class _InteractiveSkyPainter extends CustomPainter {
  final List<_SkyParticle> particles;
  final double progress;
  final Offset touchPosition;
  final bool isInteracting;
  final WeatherConditionType condition;

  _InteractiveSkyPainter({
    required this.particles,
    required this.progress,
    required this.touchPosition,
    required this.isInteracting,
    required this.condition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw ambient floating particles
    final particlePaint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      final currentY = (p.y + progress * p.speed) % 1.0;
      final offset = Offset(p.x * size.width, currentY * size.height);

      particlePaint.color = Colors.white.withValues(
        alpha: p.opacity * (0.6 + 0.4 * math.sin(progress * 2 * math.pi)),
      );
      canvas.drawCircle(offset, p.radius, particlePaint);
    }

    // 2. Interactive celestial ripple when user touches / drags
    if (isInteracting && touchPosition != Offset.zero) {
      final ripplePaint = Paint()
        ..color = const Color(0xFF38BDF8).withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);

      canvas.drawCircle(touchPosition, 75, ripplePaint);

      final corePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

      canvas.drawCircle(touchPosition, 25, corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _InteractiveSkyPainter oldDelegate) => true;
}
