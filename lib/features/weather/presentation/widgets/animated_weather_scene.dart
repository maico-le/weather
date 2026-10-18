import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/weather_mapper.dart';

class AnimatedWeatherScene extends StatefulWidget {
  final WeatherConditionType conditionType;
  final int? tempC;
  final String? weatherDesc;
  final double size;

  const AnimatedWeatherScene({
    super.key,
    required this.conditionType,
    this.tempC,
    this.weatherDesc,
    this.size = 185,
  });

  @override
  State<AnimatedWeatherScene> createState() => _AnimatedWeatherSceneState();
}

class _AnimatedWeatherSceneState extends State<AnimatedWeatherScene>
    with TickerProviderStateMixin {
  late AnimationController _danceAnimController;
  late AnimationController _breatheAnimController;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  // Duolingo organic squash-and-stretch scale
  double _pokeSquashY = 1.0;
  double _pokeSquashX = 1.0;
  double _pokeOffsetY = 0.0;

  // Speech bubble & interaction state
  String? _currentSpeech;
  Timer? _speechTimer;
  int _pokeCountInInterval = 0;
  Timer? _pokeResetTimer;

  // Flying burst particles on poke
  final List<_MascotParticle> _particles = [];

  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();

    // 1. Idle rhythmic dancing animation
    _danceAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    // 2. Breathing expansion
    _breatheAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    // 3. Spring bounce controller when tapped
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bounceAnimation = CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _danceAnimController.dispose();
    _breatheAnimController.dispose();
    _bounceController.dispose();
    _speechTimer?.cancel();
    _pokeResetTimer?.cancel();
    super.dispose();
  }

  void _onTapMascot() {
    HapticFeedback.mediumImpact();

    // Track spam tap count for Easter Egg
    _pokeCountInInterval++;
    _pokeResetTimer?.cancel();
    _pokeResetTimer = Timer(const Duration(seconds: 3), () {
      _pokeCountInInterval = 0;
    });

    // 1. Trigger energetic spring bounce
    _bounceController.forward(from: 0.0);

    // 2. Squash & stretch physics
    setState(() {
      _pokeSquashY = 0.76;
      _pokeSquashX = 1.24;
      _pokeOffsetY = 8.0;
    });

    Future.delayed(const Duration(milliseconds: 110), () {
      if (mounted) {
        setState(() {
          _pokeSquashY = 1.25;
          _pokeSquashX = 0.85;
          _pokeOffsetY = -16.0;
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) {
        setState(() {
          _pokeSquashY = 0.94;
          _pokeSquashX = 1.06;
          _pokeOffsetY = 2.0;
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 380), () {
      if (mounted) {
        setState(() {
          _pokeSquashY = 1.0;
          _pokeSquashX = 1.0;
          _pokeOffsetY = 0.0;
        });
      }
    });

    // 3. Spawn floating emotion particles (Stars & Hearts & Bubbles)
    _spawnParticles();

    // 4. Update Speech Bubble content
    _generateSpeech();
  }

  void _spawnParticles() {
    final List<String> symbols = ['✨', '❤️', '⭐', '🫧', '🎉', '🌟'];
    setState(() {
      for (int i = 0; i < 4; i++) {
        _particles.add(
          _MascotParticle(
            id: DateTime.now().microsecondsSinceEpoch + i,
            symbol: symbols[_random.nextInt(symbols.length)],
            startX: (_random.nextDouble() - 0.5) * 80,
            startY: 0,
            targetX: (_random.nextDouble() - 0.5) * 140,
            targetY: -60 - _random.nextDouble() * 50,
          ),
        );
      }
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _particles.clear();
        });
      }
    });
  }

  void _generateSpeech() {
    final now = DateTime.now();
    final hour = now.hour;
    final temp = widget.tempC ?? 30;

    String speech = '';

    // Easter egg: User taps repeatedly
    if (_pokeCountInInterval >= 4) {
      final easterEggs = [
        'Ui da nhột quá bạn ơi haha! Đừng chọc bụng tui nữa mà! 😆',
        'Á á tui chóng mặt quá rồi nè, tha cho tui xíu đi! 😵‍💫',
        'Bấm hoài dị, tính thử độ cảm ứng của màn hình hả? 😜',
        'Tui mến bạn lắm, nhưng chọc hoài là tui trốn đi ngủ đó! ❤️',
      ];
      speech = easterEggs[_random.nextInt(easterEggs.length)];
    } else if (hour >= 22 || hour < 5) {
      final nightQuotes = [
        'Khuya rồi đó sen ơi, ngủ sớm giữ sức khỏe mai cày tiếp nè! 🌙',
        'Đêm thanh bình ghê, chúc bạn có giấc ngủ thật ngon nha! 💤',
        'Tắt màn hình đi ngủ thôi, mai còn thức dậy đón bình minh với tui! 🛌',
      ];
      speech = nightQuotes[_random.nextInt(nightQuotes.length)];
    } else {
      switch (widget.conditionType) {
        case WeatherConditionType.sunny:
          final sunnyQuotes = [
            'Hôm nay trời nắng ráo ${temp}°C, ra đường nhớ thoa kem chống nắng nha sen! ☀️',
            'Nắng vàng rực rỡ, uống đủ 2 lít nước để da dẻ luôn mướt mát nha! 💧',
            'Thời tiết đẹp quá nè, rủ bạn bè đi cà phê trà sữa là hết ý! 🧋',
            'Nắng lên rồi! Chúc bạn một ngày ngập tràn năng lượng và may mắn! ✨',
          ];
          speech = sunnyQuotes[_random.nextInt(sunnyQuotes.length)];
          break;

        case WeatherConditionType.rainy:
          final rainyQuotes = [
            'Trời đang mưa rào nè, nhớ mang theo dù kẻo ướt sũng giống tui nha! ☔',
            'Mưa mát rượi luôn, nằm nhà cuộn chăn làm ly trà ấm thì còn gì bằng! 🍵',
            'Đường trơn ướt đó, chạy xe chậm rãi và nhớ bật đèn xe bạn nha! 🛵',
            'Mưa rửa trôi bụi bặm, cho tâm hồn thảnh thơi sau ngày dài làm việc! 🌧️',
          ];
          speech = rainyQuotes[_random.nextInt(rainyQuotes.length)];
          break;

        case WeatherConditionType.stormy:
          final stormQuotes = [
            'Sấm sét đùng đùng kìa! Ở trong nhà an toàn và nhớ rút bớt sạc điện nha! ⚡',
            'Gió giật mạnh nguy hiểm lắm, đừng đứng dưới cây to hay bảng hiệu nha! 🌪️',
            'Thời tiết dông bão phức tạp, theo dõi app tui thường xuyên để cập nhật nha! 🛡️',
          ];
          speech = stormQuotes[_random.nextInt(stormQuotes.length)];
          break;

        case WeatherConditionType.cloudy:
        case WeatherConditionType.partlyCloudy:
        case WeatherConditionType.foggy:
        case WeatherConditionType.snowy:
          final cloudQuotes = [
            'Trời nhiều mây râm mát ghê, ra ngoài hít thở không khí trong lành đi bạn ơi! ☁️',
            'Thời tiết chiều lòng người thế này, làm việc gì cũng thấy hiệu quả! 🌿',
            'Không khí mát mẻ dễ chịu, làm một chuyến dạo phố ngắm hoàng hôn thôi! 🌇',
          ];
          speech = cloudQuotes[_random.nextInt(cloudQuotes.length)];
          break;
      }
    }

    setState(() {
      _currentSpeech = speech;
    });

    _speechTimer?.cancel();
    _speechTimer = Timer(const Duration(seconds: 4, milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _currentSpeech = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 💬 Interactive Speech Bubble (or prompt hint)
        SizedBox(
          height: 64,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutBack,
                ),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: _currentSpeech != null
                ? GestureDetector(
                    key: ValueKey(_currentSpeech),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _currentSpeech = null);
                    },
                    child: _buildSpeechBubbleWidget(_currentSpeech!),
                  )
                : _buildHintPill(),
          ),
        ),

        const SizedBox(height: 6),

        // 🐾 Mascot Lottie with physics bounce & flying particles
        GestureDetector(
          onTap: _onTapMascot,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Mascot Character
              Transform.translate(
                offset: Offset(0, _pokeOffsetY),
                child: Transform.scale(
                  scaleX: _pokeSquashX,
                  scaleY: _pokeSquashY,
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: widget.size,
                    height: widget.size,
                    child: _buildMascotVisual(),
                  ),
                ),
              ),

              // Burst Particles
              ..._particles.map((p) {
                return TweenAnimationBuilder<double>(
                  key: ValueKey(p.id),
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 700),
                  builder: (context, val, child) {
                    final curX = p.startX + (p.targetX - p.startX) * val;
                    final curY = p.startY + (p.targetY - p.startY) * val;
                    final opacity = (1.0 - val).clamp(0.0, 1.0);
                    return Positioned(
                      left: widget.size / 2 + curX - 10,
                      top: widget.size / 2 + curY - 10,
                      child: Opacity(
                        opacity: opacity,
                        child: Transform.scale(
                          scale: 0.8 + 0.6 * val,
                          child: Text(
                            p.symbol,
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHintPill() {
    return GestureDetector(
      key: const ValueKey('hint_pill'),
      onTap: _onTapMascot,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.18),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.touch_app_rounded,
              size: 14,
              color: Color(0xFFFFD166),
            ),
            const SizedBox(width: 6),
            Text(
              'Chạm vào tui trò chuyện nè! ✨',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.9),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeechBubbleWidget(String text) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 290),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMascotVisual() {
    if (widget.conditionType == WeatherConditionType.sunny) {
      return Lottie.asset(
        'assets/animations/sunny_duolingo.json',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _buildVectorFallback(),
      );
    }

    if (widget.conditionType == WeatherConditionType.rainy) {
      return Lottie.asset(
        'assets/animations/rainy_duolingo.json',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _buildVectorFallback(),
      );
    }

    if (widget.conditionType == WeatherConditionType.stormy) {
      return Lottie.asset(
        'assets/animations/stormy_duolingo.json',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _buildVectorFallback(),
      );
    }

    if (widget.conditionType == WeatherConditionType.cloudy ||
        widget.conditionType == WeatherConditionType.partlyCloudy ||
        widget.conditionType == WeatherConditionType.foggy ||
        widget.conditionType == WeatherConditionType.snowy) {
      return Lottie.asset(
        'assets/animations/cloudy_duolingo.json',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _buildVectorFallback(),
      );
    }

    return _buildVectorFallback();
  }

  Widget _buildVectorFallback() {
    return AnimatedBuilder(
      animation: Listenable.merge([_danceAnimController, _breatheAnimController]),
      builder: (context, child) {
        final dance = _danceAnimController.value;
        final breathe = _breatheAnimController.value;
        final swayAngle = math.sin(dance * 2 * math.pi) * 0.08;
        final verticalHop = -math.sin(dance * 2 * math.pi).abs() * 10.0;
        final scaleY = 1.0 + (breathe * 0.04);
        final scaleX = 1.0 - (breathe * 0.02);

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
    );
  }
}

class _MascotParticle {
  final int id;
  final String symbol;
  final double startX;
  final double startY;
  final double targetX;
  final double targetY;

  _MascotParticle({
    required this.id,
    required this.symbol,
    required this.startX,
    required this.startY,
    required this.targetX,
    required this.targetY,
  });
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

  void _drawDuolingoSun(Canvas canvas, Size size, Offset center, {double scale = 1.0}) {
    final radius = size.width * 0.28 * scale;
    final shadowPaint = Paint()
      ..color = const Color(0xFFD97706).withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    canvas.drawCircle(Offset(center.dx, center.dy + 8), radius * 1.05, shadowPaint);

    final rayRot = danceProgress * 2 * math.pi;
    final rayPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 8; i++) {
      final angle = rayRot + (i * math.pi / 4);
      final rayDist = radius + 10 + math.sin(danceProgress * 4 * math.pi + i) * 4;
      final rayPos = Offset(center.dx + math.cos(angle) * rayDist, center.dy + math.sin(angle) * rayDist);
      canvas.drawCircle(rayPos, 9 * scale, rayPaint);
    }

    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFD166), Color(0xFFF59E0B)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, bodyPaint);

    final strokePaint = Paint()
      ..color = const Color(0xFF78350F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    canvas.drawCircle(center, radius, strokePaint);

    // Cute Eyes & Smile
    _drawCuteFace(canvas, center, radius, isBlinking: (danceProgress * 10).floor() % 7 == 0);
  }

  void _drawDuolingoPartlyCloudy(Canvas canvas, Size size, Offset center) {
    _drawDuolingoSun(canvas, size, Offset(center.dx + 25, center.dy - 15), scale: 0.75);
    _drawDuolingoCloud(canvas, size, Offset(center.dx - 10, center.dy + 15), isDark: false);
  }

  void _drawDuolingoCloud(Canvas canvas, Size size, Offset center, {required bool isDark}) {
    final baseColor = isDark ? const Color(0xFF475569) : Colors.white;
    final strokeColor = isDark ? const Color(0xFF0F172A) : const Color(0xFF1E293B);

    final cloudPaint = Paint()..color = baseColor;
    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    canvas.drawCircle(Offset(center.dx - 30, center.dy + 5), 32, cloudPaint);
    canvas.drawCircle(Offset(center.dx + 10, center.dy - 12), 40, cloudPaint);
    canvas.drawCircle(Offset(center.dx + 42, center.dy + 8), 28, cloudPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(center.dx - 45, center.dy + 5, 105, 36), const Radius.circular(18)), cloudPaint);

    canvas.drawCircle(Offset(center.dx - 30, center.dy + 5), 32, strokePaint);
    canvas.drawCircle(Offset(center.dx + 10, center.dy - 12), 40, strokePaint);
    canvas.drawCircle(Offset(center.dx + 42, center.dy + 8), 28, strokePaint);

    _drawCuteFace(canvas, Offset(center.dx + 5, center.dy + 10), 30);
  }

  void _drawDuolingoRain(Canvas canvas, Size size, Offset center) {
    _drawDuolingoCloud(canvas, size, Offset(center.dx, center.dy - 15), isDark: true);
    final dropPaint = Paint()..color = const Color(0xFF38BDF8)..strokeWidth = 4..strokeCap = StrokeCap.round;
    for (int i = 0; i < 4; i++) {
      final x = center.dx - 35 + (i * 24);
      final y = center.dy + 35 + ((danceProgress * 40 + (i * 12)) % 30);
      canvas.drawLine(Offset(x, y), Offset(x - 4, y + 12), dropPaint);
    }
  }

  void _drawDuolingoStorm(Canvas canvas, Size size, Offset center) {
    _drawDuolingoCloud(canvas, size, Offset(center.dx, center.dy - 15), isDark: true);
    final boltPath = Path();
    boltPath.moveTo(center.dx, center.dy + 30);
    boltPath.lineTo(center.dx - 12, center.dy + 50);
    boltPath.lineTo(center.dx - 2, center.dy + 50);
    boltPath.lineTo(center.dx - 10, center.dy + 72);
    boltPath.lineTo(center.dx + 8, center.dy + 45);
    boltPath.lineTo(center.dx - 2, center.dy + 45);
    boltPath.close();

    final boltPaint = Paint()..color = const Color(0xFFFDE047)..style = PaintingStyle.fill;
    canvas.drawPath(boltPath, boltPaint);
  }

  void _drawDuolingoSnow(Canvas canvas, Size size, Offset center) {
    _drawDuolingoCloud(canvas, size, Offset(center.dx, center.dy - 15), isDark: false);
    final flakePaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    for (int i = 0; i < 4; i++) {
      final x = center.dx - 30 + (i * 20);
      final y = center.dy + 35 + ((danceProgress * 30 + (i * 15)) % 30);
      canvas.drawCircle(Offset(x, y), 4, flakePaint);
    }
  }

  void _drawCuteFace(Canvas canvas, Offset center, double radius, {bool isBlinking = false}) {
    final eyePaint = Paint()..color = const Color(0xFF1E293B)..style = PaintingStyle.fill;
    final cheekPaint = Paint()..color = const Color(0xFFF43F5E).withValues(alpha: 0.55)..style = PaintingStyle.fill;

    // Cheeks
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx - radius * 0.45, center.dy + 4), width: 14, height: 9), cheekPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx + radius * 0.45, center.dy + 4), width: 14, height: 9), cheekPaint);

    // Eyes
    if (isBlinking) {
      final blinkPaint = Paint()..color = const Color(0xFF1E293B)..style = PaintingStyle.stroke..strokeWidth = 3.5..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(center.dx - radius * 0.35, center.dy - 4), Offset(center.dx - radius * 0.15, center.dy - 4), blinkPaint);
      canvas.drawLine(Offset(center.dx + radius * 0.15, center.dy - 4), Offset(center.dx + radius * 0.35, center.dy - 4), blinkPaint);
    } else {
      canvas.drawCircle(Offset(center.dx - radius * 0.25, center.dy - 4), 5.5, eyePaint);
      canvas.drawCircle(Offset(center.dx + radius * 0.25, center.dy - 4), 5.5, eyePaint);

      // Eye sparks
      final sparkPaint = Paint()..color = Colors.white;
      canvas.drawCircle(Offset(center.dx - radius * 0.25 + 1.8, center.dy - 5.5), 1.8, sparkPaint);
      canvas.drawCircle(Offset(center.dx + radius * 0.25 + 1.8, center.dy - 5.5), 1.8, sparkPaint);
    }

    // Smile
    final smilePath = Path();
    smilePath.moveTo(center.dx - 8, center.dy + 7);
    smilePath.quadraticBezierTo(center.dx, center.dy + 16, center.dx + 8, center.dy + 7);

    final smilePaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(smilePath, smilePaint);
  }

  @override
  bool shouldRepaint(covariant _DuolingoWeatherStylePainter oldDelegate) {
    return oldDelegate.danceProgress != danceProgress ||
        oldDelegate.condition != condition;
  }
}
