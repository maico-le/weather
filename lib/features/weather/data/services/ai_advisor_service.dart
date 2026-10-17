import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class AiAdvisorService {
  // Configurable server URL (Local dev or Vercel production)
  // When deployed to Vercel: e.g. https://maico-le-server.vercel.app
  static String serverBaseUrl = 'https://maico-le-server.vercel.app';

  final http.Client _client;

  AiAdvisorService({http.Client? client}) : _client = client ?? http.Client();

  Future<String?> getAdvice({
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
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return data['advice'] as String?;
      }
    } catch (_) {
      // Graceful fallback to local advice engine
      return _generateLocalAdvice(city, current, rainChance);
    }
    return _generateLocalAdvice(city, current, rainChance);
  }

  String _generateLocalAdvice(String city, CurrentCondition current, int rainChance) {
    final desc = current.weatherDesc.toLowerCase();
    if (desc.contains('rain') || rainChance >= 60) {
      return 'Khu vực $city đang có mưa rào (${current.tempC}°C). Hãy nhớ mang theo ô hoặc áo mưa và đi lại cẩn thận nhé!';
    }
    if (current.tempC >= 32) {
      return 'Thời tiết tại $city khá oi bức (${current.tempC}°C). Bạn nên chọn trang phục vải mỏng thoáng mát và uống đủ nước.';
    }
    if (current.uvIndex >= 8) {
      return 'Chỉ số UV tại $city ở mức rất cao (${current.uvIndex}/11+). Đừng quên bôi kem chống nắng và che chắn kỹ trước khi ra ngoài.';
    }
    return 'Thời tiết tại $city hôm nay tương đối thuận lợi (${current.tempC}°C, ${current.weatherDesc}). Rất thích hợp cho các hoạt động và lịch trình ngoài trời!';
  }
}
