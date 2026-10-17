import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_endpoints.dart';
import '../models/weather_model.dart';

class FetchWeatherResult {
  final WeatherResponse response;
  final Map<String, dynamic> rawJson;

  FetchWeatherResult({required this.response, required this.rawJson});
}

class WeatherApiService {
  final http.Client _client;

  WeatherApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<FetchWeatherResult> fetchWeather(String city) async {
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
        final decoded = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return FetchWeatherResult(
          response: WeatherResponse.fromJson(decoded),
          rawJson: decoded,
        );
      } else {
        throw Exception('Failed to load weather: HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối thời tiết: $e');
    }
  }
}
