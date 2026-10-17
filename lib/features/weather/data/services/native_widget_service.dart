import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';

class NativeWidgetService {
  static const MethodChannel _channel = MethodChannel('com.maicole.weather/widget');

  static const String _keyWidgetData = 'flutter.weather_widget_data';

  /// Update widget data both to SharedPreferences (for XML RemoteViews) and notify MethodChannel
  static Future<void> updateWidgetData({
    required String cityName,
    required CurrentCondition current,
    required String aiSummary,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'city': cityName,
        'temp': '${current.tempC}°',
        'desc': current.weatherDesc,
        'humidity': '${current.humidity}%',
        'wind': '${current.windSpeedKmph} km/h',
        'aiAdvice': aiSummary,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await prefs.setString(_keyWidgetData, jsonEncode(data));

      // Invoke Android platform channel to refresh AppWidget layout if available
      try {
        await _channel.invokeMethod('updateAppWidget', data);
      } catch (_) {
        // AppWidget channel may not be registered yet on dev machine
      }
    } catch (_) {
      // Ignore widget failure on non-supported targets
    }
  }
}
