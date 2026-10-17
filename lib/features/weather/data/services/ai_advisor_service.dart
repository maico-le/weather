import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class AiAdviceResult {
  final String advice;
  final String engine;
  final bool isOnline;

  AiAdviceResult({
    required this.advice,
    required this.engine,
    required this.isOnline,
  });
}

class AiAdvisorService {
  static const String serverBaseUrl = 'https://maico-le-server.vercel.app';

  final http.Client _client;

  AiAdvisorService({http.Client? client}) : _client = client ?? http.Client();

  Future<AiAdviceResult> getAdvice({
    required String city,
    required CurrentCondition current,
    int rainChance = 20,
  }) async {
    final url = Uri.parse('$serverBaseUrl/api/v1/weather/advice');

    try {
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'appId': 'weather-glow',
          'city': city,
          'tempC': current.tempC,
          'condition': current.weatherDesc,
          'uv': current.uvIndex,
          'humidity': current.humidity,
          'rainChance': rainChance,
        }),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return AiAdviceResult(
          advice: data['advice'] as String? ?? _generateLocalAdvice(city, current, rainChance),
          engine: data['engine'] as String? ?? 'gemini-1.5-flash',
          isOnline: true,
        );
      }
    } catch (_) {
      // Graceful offline fallback
    }

    return AiAdviceResult(
      advice: _generateLocalAdvice(city, current, rainChance),
      engine: 'Smart Rules Engine (Nội bộ)',
      isOnline: false,
    );
  }

  Future<bool> checkServerOnline() async {
    try {
      final res = await _client.get(
        Uri.parse('$serverBaseUrl/api/v1/health'),
      ).timeout(const Duration(seconds: 4));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  String _generateLocalAdvice(String city, CurrentCondition current, int rainChance) {
    final desc = current.weatherDesc.toLowerCase();
    final List<String> parts = [];

    if (desc.contains('rain') || rainChance >= 60) {
      parts.add('Khu vực $city đang có mưa rào (${current.tempC}°C, xác suất $rainChance%). Hãy mang theo ô hoặc áo mưa khi ra ngoài.');
    } else if (current.tempC >= 32) {
      parts.add('Thời tiết tại $city khá oi bức với nền nhiệt ${current.tempC}°C. Bạn nên ưu tiên trang phục mỏng nhẹ, thoáng khí và bù nước thường xuyên.');
    } else if (current.tempC <= 20) {
      parts.add('Không khí tại $city se lạnh (${current.tempC}°C). Bạn nên mặc thêm áo khoác giữ ấm.');
    } else {
      parts.add('Thời tiết tại $city hôm nay tương đối thuận lợi (${current.tempC}°C, ${current.weatherDesc}). Rất thích hợp cho các hoạt động ngoài trời.');
    }

    if (current.uvIndex >= 8) {
      parts.add('Chỉ số UV ở mức nguy hại (${current.uvIndex}/11+), hãy nhớ bôi kem chống nắng và đeo kính râm.');
    }

    return parts.join(' ');
  }
}
