import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/utils/weather_mapper.dart';
import '../../data/models/weather_model.dart';
import 'animated_weather_scene.dart';
import 'glass_card.dart';

class WeatherStoryShareSheet extends StatefulWidget {
  final WeatherResponse weather;
  final String cityName;
  final String aiAdvice;

  const WeatherStoryShareSheet({
    super.key,
    required this.weather,
    required this.cityName,
    required this.aiAdvice,
  });

  static void show(
    BuildContext context, {
    required WeatherResponse weather,
    required String cityName,
    required String aiAdvice,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WeatherStoryShareSheet(
        weather: weather,
        cityName: cityName,
        aiAdvice: aiAdvice,
      ),
    );
  }

  @override
  State<WeatherStoryShareSheet> createState() => _WeatherStoryShareSheetState();
}

class _WeatherStoryShareSheetState extends State<WeatherStoryShareSheet> {
  final GlobalKey _storyKey = GlobalKey();
  bool _isExporting = false;

  Future<void> _shareStory() async {
    setState(() => _isExporting = true);
    HapticFeedback.mediumImpact();

    try {
      // Small delay to ensure render tree is settled
      await Future.delayed(const Duration(milliseconds: 100));

      final boundary =
          _storyKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Không tìm thấy khung ảnh');
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData?.buffer.asUint8List();

      if (pngBytes == null) {
        throw Exception('Lỗi chuyển đổi ảnh');
      }

      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/weather_story_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      final current = widget.weather.currentCondition;
      final textShare =
          '🌤️ Thời tiết hôm nay tại ${widget.cityName}: ${current.tempC}°C - ${current.weatherDesc}!\n✨ Chia sẻ từ Weather Glow.';

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'image/png')],
          text: textShare,
          subject: 'Thời tiết hôm nay tại ${widget.cityName}',
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi chia sẻ: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.weather.currentCondition;
    final condType = WeatherMapper.getConditionType(
      current.weatherCode,
      current.weatherDesc,
    );
    final vietnameseDesc = WeatherMapper.getVietnameseDesc(
      current.weatherDesc,
      condType,
    );
    final today = widget.weather.dailyForecast.isNotEmpty
        ? widget.weather.dailyForecast.first
        : null;

    final gradient = _getAtmosphericGradient(condType);

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Color(0xFFFFD166), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Chia Sẻ Thẻ Thời Tiết Story',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Story Card Preview (Scrollable container if needed)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Center(
                child: RepaintBoundary(
                  key: _storyKey,
                  child: Container(
                    width: 320,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradient,
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Top Branding & Date
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.wb_sunny_rounded,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'WEATHER GLOW',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              DateFormat('dd/MM/yyyy').format(DateTime.now()),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // City Name
                        Text(
                          widget.cityName,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 12),

                        // Cute Duolingo Vector Mascot
                        AnimatedWeatherScene(
                          conditionType: condType,
                          size: 140,
                        ),

                        // Large Temperature
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${current.tempC}',
                              style: const TextStyle(
                                fontSize: 68,
                                fontWeight: FontWeight.w200,
                                color: Colors.white,
                                height: 1.0,
                              ),
                            ),
                            const Text(
                              '°C',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w300,
                                color: Colors.white70,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),

                        // Weather Description
                        Text(
                          vietnameseDesc,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),

                        if (today != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Cao: ${today.maxTempC}°  •  Thấp: ${today.minTempC}°',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.85),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),

                        // 3 Quick Metrics Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildMiniMetric(
                              icon: Icons.water_drop_rounded,
                              label: 'Độ ẩm',
                              value: '${current.humidity}%',
                            ),
                            _buildMiniMetric(
                              icon: Icons.air_rounded,
                              label: 'Gió',
                              value: '${current.windSpeedKmph} km/h',
                            ),
                            _buildMiniMetric(
                              icon: Icons.wb_sunny_rounded,
                              label: 'UV',
                              value: '${current.uvIndex}',
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // AI Advice / Quote bubble
                        GlassCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          borderRadius: 16,
                          opacity: 0.18,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.format_quote_rounded,
                                color: Color(0xFFFFD166),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.aiAdvice.isNotEmpty
                                      ? widget.aiAdvice
                                      : 'Thời tiết hôm nay tuyệt vời để bạn tận hưởng ngày mới!',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.white,
                                    height: 1.35,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Footer Watermark
                        Text(
                          '✨ Tạo bởi Weather Glow • Dự báo khí tượng AI',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Action Buttons
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isExporting ? null : _shareStory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF38BDF8),
                    foregroundColor: const Color(0xFF0F172A),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: _isExporting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF0F172A),
                          ),
                        )
                      : const Icon(Icons.share_rounded, size: 22),
                  label: Text(
                    _isExporting
                        ? 'Đang kết xuất ảnh Story...'
                        : 'Chia Sẻ Lên Facebook / Instagram / Zalo',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetric({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getAtmosphericGradient(WeatherConditionType conditionType) {
    switch (conditionType) {
      case WeatherConditionType.sunny:
        return [
          const Color(0xFF0284C7),
          const Color(0xFF38BDF8),
          const Color(0xFFFBBF24),
        ];
      case WeatherConditionType.rainy:
        return [
          const Color(0xFF1E293B),
          const Color(0xFF0369A1),
          const Color(0xFF0284C7),
        ];
      case WeatherConditionType.stormy:
        return [
          const Color(0xFF0F172A),
          const Color(0xFF4C1D95),
          const Color(0xFF1E1B4B),
        ];
      case WeatherConditionType.partlyCloudy:
        return [
          const Color(0xFF0369A1),
          const Color(0xFF38BDF8),
          const Color(0xFFCBD5E1),
        ];
      case WeatherConditionType.cloudy:
        return [
          const Color(0xFF334155),
          const Color(0xFF475569),
          const Color(0xFF64748B),
        ];
      case WeatherConditionType.snowy:
        return [
          const Color(0xFF1E3A8A),
          const Color(0xFF60A5FA),
          const Color(0xFFF1F5F9),
        ];
      case WeatherConditionType.foggy:
        return [
          const Color(0xFF334155),
          const Color(0xFF64748B),
          const Color(0xFF94A3B8),
        ];
    }
  }
}
