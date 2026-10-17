import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';

class CacheService {
  static const String _keyLastCity = 'cached_last_city';
  static const String _keyWeatherData = 'cached_weather_json';
  static const String _keyAiAdvice = 'cached_ai_advice';
  static const String _keyAiEngine = 'cached_ai_engine';
  static const String _keyLastUpdated = 'cached_last_updated';

  Future<void> saveWeather(String city, Map<String, dynamic> rawJson, String? aiAdvice, String? aiEngine) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastCity, city);
    await prefs.setString(_keyWeatherData, jsonEncode(rawJson));
    await prefs.setString(_keyLastUpdated, DateTime.now().toIso8601String());
    if (aiAdvice != null) {
      await prefs.setString(_keyAiAdvice, aiAdvice);
    }
    if (aiEngine != null) {
      await prefs.setString(_keyAiEngine, aiEngine);
    }
  }

  Future<CachedWeatherData?> loadCachedWeather() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyWeatherData);
    if (jsonStr == null || jsonStr.isEmpty) return null;

    try {
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      final weather = WeatherResponse.fromJson(decoded);
      final city = prefs.getString(_keyLastCity) ?? 'Ho Chi Minh City';
      final aiAdvice = prefs.getString(_keyAiAdvice);
      final aiEngine = prefs.getString(_keyAiEngine);
      final updatedStr = prefs.getString(_keyLastUpdated);
      DateTime? updated;
      if (updatedStr != null) {
        updated = DateTime.tryParse(updatedStr);
      }

      return CachedWeatherData(
        city: city,
        weather: weather,
        aiAdvice: aiAdvice,
        aiEngine: aiEngine,
        updatedAt: updated,
      );
    } catch (_) {
      return null;
    }
  }

  Future<String> getLastCity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastCity) ?? 'Ho Chi Minh City';
  }
}

class CachedWeatherData {
  final String city;
  final WeatherResponse weather;
  final String? aiAdvice;
  final String? aiEngine;
  final DateTime? updatedAt;

  CachedWeatherData({
    required this.city,
    required this.weather,
    this.aiAdvice,
    this.aiEngine,
    this.updatedAt,
  });
}
