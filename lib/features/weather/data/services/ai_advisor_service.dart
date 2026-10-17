import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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
  static const String _appId = 'weather-glow';
  static const String _appSecret = 'weather-glow-secret-2026';

  static const String _prefAccessToken = 'auth_jwt_access_token';
  static const String _prefRefreshToken = 'auth_jwt_refresh_token';

  final http.Client _client;
  String? _accessToken;
  String? _refreshToken;

  AiAdvisorService({http.Client? client}) : _client = client ?? http.Client();

  Future<String?> _getOrFetchAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken ??= prefs.getString(_prefAccessToken);
    _refreshToken ??= prefs.getString(_prefRefreshToken);

    if (_accessToken != null && _accessToken!.isNotEmpty) {
      return _accessToken;
    }

    // If we have a refresh token, try refreshing first
    if (_refreshToken != null && _refreshToken!.isNotEmpty) {
      final refreshed = await _refreshAccessToken();
      if (refreshed != null) return refreshed;
    }

    // Authenticate and get new token pair
    return await _authenticate();
  }

  Future<String?> _authenticate() async {
    try {
      final res = await _client.post(
        Uri.parse('$serverBaseUrl/api/v1/auth/token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'appId': _appId,
          'appSecret': _appSecret,
        }),
      ).timeout(const Duration(seconds: 6));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        _accessToken = data['accessToken'] as String?;
        _refreshToken = data['refreshToken'] as String?;

        final prefs = await SharedPreferences.getInstance();
        if (_accessToken != null) await prefs.setString(_prefAccessToken, _accessToken!);
        if (_refreshToken != null) await prefs.setString(_prefRefreshToken, _refreshToken!);

        return _accessToken;
      }
    } catch (_) {}
    return null;
  }

  Future<String?> _refreshAccessToken() async {
    if (_refreshToken == null) return null;
    try {
      final res = await _client.post(
        Uri.parse('$serverBaseUrl/api/v1/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'refreshToken': _refreshToken,
        }),
      ).timeout(const Duration(seconds: 6));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        _accessToken = data['accessToken'] as String?;
        final prefs = await SharedPreferences.getInstance();
        if (_accessToken != null) await prefs.setString(_prefAccessToken, _accessToken!);
        return _accessToken;
      }
    } catch (_) {}
    return null;
  }

  Future<AiAdviceResult> getAdvice({
    required String city,
    required CurrentCondition current,
    int rainChance = 20,
  }) async {
    final url = Uri.parse('$serverBaseUrl/api/v1/weather/advice');
    final token = await _getOrFetchAccessToken();

    final headers = {
      'Content-Type': 'application/json',
      'X-App-ID': _appId,
      'X-App-Key': _appSecret,
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    final payload = jsonEncode({
      'appId': _appId,
      'city': city,
      'tempC': current.tempC,
      'condition': current.weatherDesc,
      'uv': current.uvIndex,
      'humidity': current.humidity,
      'rainChance': rainChance,
    });

    try {
      var response = await _client.post(url, headers: headers, body: payload)
          .timeout(const Duration(seconds: 8));

      // If token expired (401), try refreshing token once and retrying
      if (response.statusCode == 401 && _refreshToken != null) {
        final newToken = await _refreshAccessToken();
        if (newToken != null) {
          headers['Authorization'] = 'Bearer $newToken';
          response = await _client.post(url, headers: headers, body: payload)
              .timeout(const Duration(seconds: 8));
        }
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return AiAdviceResult(
          advice: data['advice'] as String? ?? _generateLocalAdvice(city, current, rainChance),
          engine: data['engine'] as String? ?? 'gemini-2.5-flash',
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
