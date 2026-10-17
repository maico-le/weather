import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_endpoints.dart';
import '../models/weather_model.dart';

class WeatherApiService {
  final http.Client _client;

  WeatherApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<WeatherResponse> fetchWeather(String city) async {
    final url = Uri.parse(ApiEndpoints.weatherByCity(city));

    try {
      final response = await _client.get(
        url,
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'WeatherApp-Flutter/1.0',
        },
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        // wttr.in can be UTF-8 encoded
        final decoded = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return WeatherResponse.fromJson(decoded);
      } else {
        throw Exception('Failed to load weather: HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối thời tiết: $e');
    }
  }
}
