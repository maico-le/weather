import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SavedCity {
  final String id;
  final String name;
  final String country;
  final bool isGps;

  const SavedCity({
    required this.id,
    required this.name,
    this.country = 'Vietnam',
    this.isGps = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'country': country,
        'isGps': isGps,
      };

  factory SavedCity.fromJson(Map<String, dynamic> json) {
    return SavedCity(
      id: json['id'] as String? ?? json['name'] as String? ?? 'Ho Chi Minh City',
      name: json['name'] as String? ?? 'Ho Chi Minh City',
      country: json['country'] as String? ?? 'Vietnam',
      isGps: json['isGps'] as bool? ?? false,
    );
  }
}

class CityManagerService {
  static const String _keySavedCities = 'weather_saved_cities_list';
  static const String _keyActiveCityIndex = 'weather_active_city_index';

  static final List<SavedCity> defaultCities = [
    const SavedCity(id: 'gps_current', name: 'Ho Chi Minh City', country: 'Vietnam', isGps: true),
    const SavedCity(id: 'hanoi', name: 'Hanoi', country: 'Vietnam'),
    const SavedCity(id: 'danang', name: 'Da Nang', country: 'Vietnam'),
  ];

  Future<List<SavedCity>> getSavedCities() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keySavedCities);
    if (jsonStr == null || jsonStr.isEmpty) {
      // First run: save defaults
      await saveCities(defaultCities);
      return defaultCities;
    }

    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      final cities = list.map((item) => SavedCity.fromJson(item as Map<String, dynamic>)).toList();
      return cities.isNotEmpty ? cities : defaultCities;
    } catch (_) {
      return defaultCities;
    }
  }

  Future<void> saveCities(List<SavedCity> cities) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(cities.map((c) => c.toJson()).toList());
    await prefs.setString(_keySavedCities, jsonStr);
  }

  Future<void> addCity(SavedCity city) async {
    final current = await getSavedCities();
    if (!current.any((c) => c.name.toLowerCase() == city.name.toLowerCase())) {
      current.add(city);
      await saveCities(current);
    }
  }

  Future<void> removeCity(String id) async {
    final current = await getSavedCities();
    // Keep at least one city
    if (current.length <= 1) return;
    current.removeWhere((c) => c.id == id);
    await saveCities(current);
  }

  Future<void> updateGpsCityName(String newName) async {
    final current = await getSavedCities();
    final index = current.indexWhere((c) => c.isGps);
    if (index != -1) {
      current[index] = SavedCity(
        id: current[index].id,
        name: newName,
        country: current[index].country,
        isGps: true,
      );
      await saveCities(current);
    }
  }

  Future<int> getActiveIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyActiveCityIndex) ?? 0;
  }

  Future<void> setActiveIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyActiveCityIndex, index);
  }
}
