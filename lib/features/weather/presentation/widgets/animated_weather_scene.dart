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
    this.size = 190,
  });

  @override
  State<AnimatedWeatherScene> createState() => _AnimatedWeatherSceneState();
}

class _AnimatedWeatherSceneState extends State<AnimatedWeatherScene>
    with TickerProviderStateMixin {
  late AnimationController _danceAnimController;
  late AnimationController _breatheAnimController;

  // Touch poke bounce reaction (Duolingo signature physics)
  double _pokeSquashY = 1.0;
  double _pokeSquashX = 1.0;

  @override
  void initState() {
    super.initState();

    // 1. Duolingo signature rhythmic idle animation (chuyển động nhún nhảy vui vẻ)
    _danceAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    // 2. Nhịp thở co giãn đàn hồi (Breathing squash-and-stretch)
    _breatheAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _danceAnimController.dispose();
    _breatheAnimController.dispose();
    super.dispose();
  }

  void _onTapWeatherScene() {
    // Duolingo organic squash-and-stretch on click/tap
    setState(() {
      _pokeSquashY = 0.80; // nhún xẹp xuống
      _pokeSquashX = 1.20; // bè ngang ra
    });

    Future.delayed(const Duration(milliseconds: 130), () {
      if (mounted) {
        setState(() {
          _pokeSquashY = 1.18; // bật nảy vọt lên cao
          _pokeSquashX = 0.88; // thân thon lại
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _pokeSquashY = 1.0;
          _pokeSquashX = 1.0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.conditionType == WeatherConditionType.sunny) {
      return GestureDetector(
        onTap: _onTapWeatherScene,
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: Lottie.asset(
            'assets/animations/sunny_duolingo.json',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return _buildVectorFallback();
            },
          ),
        ),
      );
    }

    return _buildVectorFallback();
  }

  Widget _buildVectorFallback() {
    return GestureDetector(
      onTap: _onTapWeatherScene,
      child: AnimatedBuilder(
        animation: Listenable.merge([_danceAnimController, _breatheAnimController]),
        builder: (context, child) {
          final dance = _danceAnimController.value;
          final breathe = _breatheAnimController.value;

          // Duolingo Motion Physics:
          // 1. Lắc lư qua lại (rhythmic sway)
          final swayAngle = math.sin(dance * 2 * math.pi) * 0.09;
          // 2. Nhún nhảy theo phương đứng (bouncing hop)
          final verticalHop = -math.sin(dance * 2 * math.pi).abs() * 14.0;
          // 3. Co giãn tự nhiên (squash & stretch)
          final scaleY = (1.0 + (breathe * 0.05)) * _pokeSquashY;
          final scaleX = (1.0 - (breathe * 0.03)) * _pokeSquashX;

          return Transform.translate(
            offset: Offset(0, verticalHop),
            child: Transform.rotate(
              angle: swayAngle,
              child: Transform.scale(
                scaleX: scaleX,
                scaleY: scaleY,
                child: SizedBox(
                  width: widget.size,
                  height: widget.size,
                  child: CustomPaint(
                    size: Size(widget.size, widget.size),
                    painter: _DuolingoWeatherStylePainter(
                      danceProgress: dance,
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

class _DuolingoWeatherStylePainter extends CustomPainter {
  final double danceProgress;
  final WeatherConditionType condition;

  _DuolingoWeatherStylePainter({
    required this.danceProgress,
    required this.condition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    switch (condition) {
      case WeatherConditionType.sunny:
        _drawDuolingoSun(canvas, size, center);
        break;
      case WeatherConditionType.partlyCloudy:
        _drawDuolingoPartlyCloudy(canvas, size, center);
        break;
      case WeatherConditionType.cloudy:
      case WeatherConditionType.foggy:
        _drawDuolingoCloud(canvas, size, center, isDark: false);
        break;
      case WeatherConditionType.rainy:
        _drawDuolingoRain(canvas, size, center);
        break;
      case WeatherConditionType.stormy:
        _drawDuolingoStorm(canvas, size, center);
        break;
      case WeatherConditionType.snowy:
        _drawDuolingoSnow(canvas, size, center);
        break;
    }
  }

  // 1. MẶT TRỜI PHONG CÁCH DUOLINGO (Chunky, Vector phẳng, Tia nắng cựa quậy nhún nhảy)
  void _drawDuolingoSun(Canvas canvas, Size size, Offset center, {double scale = 1.0}) {
    final radius = size.width * 0.28 * scale;

    // Drop Shadow đậm phong cách Duolingo
    final shadowPaint = Paint()
      ..color = const Color(0xFFD97706).withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    canvas.drawCircle(Offset(center.dx, center.dy + 8), radius * 1.05, shadowPaint);

    // 8 Tia nắng hình khối mập mạp xoay và vươn dài nhịp nhàng
    final rayRot = danceProgress * 2 * math.pi;
    final rayPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.fill;

    final rayOutline = Paint()
      ..color = const Color(0xFF78350F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (int i = 0; i < 8; i++) {
      final a = rayRot + (i * math.pi / 4);
      final pulse = math.sin((danceProgress * 4 * math.pi) + i) * 6.0;
      final rayDist = radius + 6;
      final tipDist = rayDist + 20 * scale + pulse;

      final pTip = Offset(center.dx + tipDist * math.cos(a), center.dy + tipDist * math.sin(a));
      final pL = Offset(center.dx + rayDist * math.cos(a - 0.25), center.dy + rayDist * math.sin(a - 0.25));
      final pR = Offset(center.dx + rayDist * math.cos(a + 0.25), center.dy + rayDist * math.sin(a + 0.25));

      final rayPath = Path()
        ..moveTo(pL.dx, pL.dy)
        ..lineTo(pTip.dx, pTip.dy)
        ..lineTo(pR.dx, pR.dy)
        ..close();

      canvas.drawPath(rayPath, rayPaint);
      canvas.drawPath(rayPath, rayOutline);
    }

    // Khối thân mặt trời vàng rực
    final sunPaint = Paint()
      ..color = const Color(0xFFFBBF24)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, sunPaint);

    // Nửa vầng trăng bóng đổ bên trong (Inner Shadow phong cách UI Duolingo)
    final innerShade = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.fill;
    final shadePath = Path();
    shadePath.addArc(Rect.fromCircle(center: center, radius: radius), math.pi * 0.15, math.pi * 0.7);
    shadePath.quadraticBezierTo(center.dx, center.dy + radius * 0.6, center.dx + radius * 0.85, center.dy + radius * 0.45);
    canvas.drawPath(shadePath, innerShade);

    // Viền đậm (Chunky Black Outline)
    final bodyOutline = Paint()
      ..color = const Color(0xFF78350F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0 * scale;
    canvas.drawCircle(center, radius, bodyOutline);

    // Vệt bóng sáng trắng trên đầu (White Specular Highlight)
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.5 * scale;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(center.dx - 4, center.dy - 4), radius: radius * 0.72),
      math.pi * 1.1,
      math.pi * 0.4,
      false,
      highlightPaint,
    );
  }

  // 2. MÂY PHONG CÁCH DUOLINGO (Mập mạp, mút xốp, viền đen dày dặn)
  void _drawDuolingoCloud(Canvas canvas, Size size, Offset center, {required bool isDark}) {
    final r = size.width * 0.25;

    // Bóng đổ mây
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(center.dx, center.dy + r * 0.5), width: r * 2.8, height: r * 0.9),
        Radius.circular(r * 0.5),
      ),
      shadowPaint,
    );

    final fillColor = isDark ? const Color(0xFF475569) : Colors.white;
    final shadeColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final outlineColor = isDark ? const Color(0xFF0F172A) : const Color(0xFF1E293B);

    final fillPaint = Paint()..color = fillColor;
    final shadePaint = Paint()..color = shadeColor;
    final outlinePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    // Vẽ cụm các khối tròn mây
    void drawCloudBlob(Offset c, double radius) {
      canvas.drawCircle(c, radius, fillPaint);
      canvas.drawCircle(c, radius, outlinePaint);
    }

    // Các búi mây xung quanh
    drawCloudBlob(Offset(center.dx - r * 0.8, center.dy + r * 0.15), r * 0.65);
    drawCloudBlob(Offset(center.dx + r * 0.8, center.dy + r * 0.15), r * 0.65);
    drawCloudBlob(Offset(center.dx - r * 0.35, center.dy - r * 0.35), r * 0.75);
    drawCloudBlob(Offset(center.dx + r * 0.35, center.dy - r * 0.30), r * 0.70);

    // Thân mây chính đè lên
    canvas.drawCircle(center, r * 0.75, fillPaint);
    final baseRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(center.dx, center.dy + r * 0.30), width: r * 2.6, height: r * 0.85),
      Radius.circular(r * 0.45),
    );
    canvas.drawRRect(baseRect, fillPaint);
    canvas.drawRRect(baseRect, outlinePaint);

    // Vệt bóng đổ dưới đáy mây phong cách phẳng (Flat UI bottom shading)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(center.dx, center.dy + r * 0.48), width: r * 2.3, height: r * 0.4),
        Radius.circular(r * 0.3),
      ),
      shadePaint,
    );
  }

  // 3. TRỜI NẮNG CÓ MÂY
  void _drawDuolingoPartlyCloudy(Canvas canvas, Size size, Offset center) {
    final sunCenter = Offset(center.dx + size.width * 0.22, center.dy - size.height * 0.16);
    _drawDuolingoSun(canvas, size, sunCenter, scale: 0.7);

    final cloudCenter = Offset(center.dx - size.width * 0.08, center.dy + size.height * 0.1);
    _drawDuolingoCloud(canvas, size, cloudCenter, isDark: false);
  }

  // 4. MƯA PHONG CÁCH DUOLINGO (Giọt nước hạt đậu tròn trĩnh rơi nhún nhảy)
  void _drawDuolingoRain(Canvas canvas, Size size, Offset center) {
    final cloudCenter = Offset(center.dx, center.dy - size.height * 0.14);
    _drawDuolingoCloud(canvas, size, cloudCenter, isDark: true);

    // Các giọt mưa hình viên thuốc / giọt nước mập mạp
    final dropPaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..style = PaintingStyle.fill;

    final dropOutline = Paint()
      ..color = const Color(0xFF0284C7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final startY = cloudCenter.dy + size.height * 0.15;
    const dropSpacing = 28.0;

    for (int i = 0; i < 4; i++) {
      final x = (center.dx - dropSpacing * 1.5) + i * dropSpacing;
      final yCycle = (danceProgress * 2.2 + (i * 0.28)) % 1.0;
      final y = startY + yCycle * (size.height * 0.34);

      final dropRRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(x, y), width: 10, height: 20),
        const Radius.circular(6),
      );

      canvas.drawRRect(dropRRect, dropPaint);
      canvas.drawRRect(dropRRect, dropOutline);
    }
  }

  // 5. GIÔNG BÃO DUOLINGO (Tia sét mập màu vàng viền đen giật nhấp nháy)
  void _drawDuolingoStorm(Canvas canvas, Size size, Offset center) {
    _drawDuolingoRain(canvas, size, center);

    // Tia sét hình ziczac to bản, viền đen dày
    final boltVal = math.sin(danceProgress * 10 * math.pi);
    if (boltVal > 0.6) {
      final boltPaint = Paint()
        ..color = const Color(0xFFFACC15)
        ..style = PaintingStyle.fill;

      final boltOutline = Paint()
        ..color = const Color(0xFF713F12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeJoin = StrokeJoin.round;

      final path = Path();
      path.moveTo(center.dx, center.dy - 6);
      path.lineTo(center.dx - 16, center.dy + 24);
      path.lineTo(center.dx + 4, center.dy + 22);
      path.lineTo(center.dx - 10, center.dy + 56);
      path.lineTo(center.dx + 8, center.dy + 16);
      path.lineTo(center.dx - 8, center.dy + 18);
      path.close();

      canvas.drawPath(path, boltPaint);
      canvas.drawPath(path, boltOutline);
    }
  }

  // 6. TUYẾT RƠI DUOLINGO
  void _drawDuolingoSnow(Canvas canvas, Size size, Offset center) {
    final cloudCenter = Offset(center.dx, center.dy - size.height * 0.14);
    _drawDuolingoCloud(canvas, size, cloudCenter, isDark: false);

    final flakePaint = Paint()..color = Colors.white;
    final flakeOutline = Paint()
      ..color = const Color(0xFF94A3B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final startY = cloudCenter.dy + size.height * 0.15;
    for (int i = 0; i < 5; i++) {
      final x = (center.dx - 50) + i * 25;
      final yCycle = (danceProgress * 1.5 + (i * 0.22)) % 1.0;
      final y = startY + yCycle * (size.height * 0.32);

      canvas.drawCircle(Offset(x, y), 6, flakePaint);
      canvas.drawCircle(Offset(x, y), 6, flakeOutline);
    }
  }

  @override
  bool shouldRepaint(covariant _DuolingoWeatherStylePainter oldDelegate) => true;
}
