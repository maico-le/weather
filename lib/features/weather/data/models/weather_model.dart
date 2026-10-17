class WeatherResponse {
  final CurrentCondition currentCondition;
  final List<DailyWeather> dailyForecast;
  final NearestArea nearestArea;

  WeatherResponse({
    required this.currentCondition,
    required this.dailyForecast,
    required this.nearestArea,
  });

  factory WeatherResponse.fromJson(Map<String, dynamic> json) {
    final currentList = json['current_condition'] as List<dynamic>? ?? [];
    final weatherList = json['weather'] as List<dynamic>? ?? [];
    final areaList = json['nearest_area'] as List<dynamic>? ?? [];

    return WeatherResponse(
      currentCondition: currentList.isNotEmpty
          ? CurrentCondition.fromJson(currentList[0] as Map<String, dynamic>)
          : CurrentCondition.empty(),
      dailyForecast: weatherList
          .map((item) => DailyWeather.fromJson(item as Map<String, dynamic>))
          .toList(),
      nearestArea: areaList.isNotEmpty
          ? NearestArea.fromJson(areaList[0] as Map<String, dynamic>)
          : NearestArea.empty(),
    );
  }
}

class CurrentCondition {
  final int tempC;
  final int feelsLikeC;
  final int humidity;
  final int cloudcover;
  final int uvIndex;
  final int visibilityKm;
  final int pressureHpa;
  final int windSpeedKmph;
  final String windDir;
  final String weatherCode;
  final String weatherDesc;
  final String observationTime;

  CurrentCondition({
    required this.tempC,
    required this.feelsLikeC,
    required this.humidity,
    required this.cloudcover,
    required this.uvIndex,
    required this.visibilityKm,
    required this.pressureHpa,
    required this.windSpeedKmph,
    required this.windDir,
    required this.weatherCode,
    required this.weatherDesc,
    required this.observationTime,
  });

  factory CurrentCondition.fromJson(Map<String, dynamic> json) {
    final descList = json['weatherDesc'] as List<dynamic>? ?? [];
    final desc = descList.isNotEmpty
        ? (descList[0]['value'] ?? '').toString().trim()
        : 'Clear';

    return CurrentCondition(
      tempC: int.tryParse(json['temp_C']?.toString() ?? '0') ?? 0,
      feelsLikeC: int.tryParse(json['FeelsLikeC']?.toString() ?? '0') ?? 0,
      humidity: int.tryParse(json['humidity']?.toString() ?? '0') ?? 0,
      cloudcover: int.tryParse(json['cloudcover']?.toString() ?? '0') ?? 0,
      uvIndex: int.tryParse(json['uvIndex']?.toString() ?? '0') ?? 0,
      visibilityKm: int.tryParse(json['visibility']?.toString() ?? '10') ?? 10,
      pressureHpa: int.tryParse(json['pressure']?.toString() ?? '1013') ?? 1013,
      windSpeedKmph: int.tryParse(json['windspeedKmph']?.toString() ?? '0') ?? 0,
      windDir: json['winddir16Point']?.toString() ?? 'N',
      weatherCode: json['weatherCode']?.toString() ?? '113',
      weatherDesc: desc,
      observationTime: json['observation_time']?.toString() ?? '',
    );
  }

  factory CurrentCondition.empty() {
    return CurrentCondition(
      tempC: 28,
      feelsLikeC: 30,
      humidity: 75,
      cloudcover: 20,
      uvIndex: 5,
      visibilityKm: 10,
      pressureHpa: 1012,
      windSpeedKmph: 10,
      windDir: 'E',
      weatherCode: '113',
      weatherDesc: 'Clear',
      observationTime: '',
    );
  }
}

class AstronomyInfo {
  final String sunrise;
  final String sunset;
  final String moonrise;
  final String moonset;
  final String moonPhase;
  final int moonIllumination;

  AstronomyInfo({
    required this.sunrise,
    required this.sunset,
    required this.moonrise,
    required this.moonset,
    required this.moonPhase,
    required this.moonIllumination,
  });

  factory AstronomyInfo.fromJson(Map<String, dynamic> json) {
    return AstronomyInfo(
      sunrise: json['sunrise']?.toString() ?? '05:48 AM',
      sunset: json['sunset']?.toString() ?? '05:45 PM',
      moonrise: json['moonrise']?.toString() ?? '06:00 PM',
      moonset: json['moonset']?.toString() ?? '06:00 AM',
      moonPhase: json['moon_phase']?.toString() ?? 'Full Moon',
      moonIllumination:
          int.tryParse(json['moon_illumination']?.toString() ?? '50') ?? 50,
    );
  }

  factory AstronomyInfo.defaultInfo() {
    return AstronomyInfo(
      sunrise: '05:48 AM',
      sunset: '05:45 PM',
      moonrise: '06:15 PM',
      moonset: '06:00 AM',
      moonPhase: 'Waxing Gibbous',
      moonIllumination: 78,
    );
  }
}

class DailyWeather {
  final String date;
  final int maxTempC;
  final int minTempC;
  final int avgTempC;
  final int uvIndex;
  final List<HourlyWeather> hourly;
  final AstronomyInfo astronomy;

  DailyWeather({
    required this.date,
    required this.maxTempC,
    required this.minTempC,
    required this.avgTempC,
    required this.uvIndex,
    required this.hourly,
    required this.astronomy,
  });

  factory DailyWeather.fromJson(Map<String, dynamic> json) {
    final hourlyList = json['hourly'] as List<dynamic>? ?? [];
    final astroList = json['astronomy'] as List<dynamic>? ?? [];

    return DailyWeather(
      date: json['date']?.toString() ?? '',
      maxTempC: int.tryParse(json['maxtempC']?.toString() ?? '0') ?? 0,
      minTempC: int.tryParse(json['mintempC']?.toString() ?? '0') ?? 0,
      avgTempC: int.tryParse(json['avgtempC']?.toString() ?? '0') ?? 0,
      uvIndex: int.tryParse(json['uvIndex']?.toString() ?? '0') ?? 0,
      hourly: hourlyList
          .map((item) => HourlyWeather.fromJson(item as Map<String, dynamic>))
          .toList(),
      astronomy: astroList.isNotEmpty
          ? AstronomyInfo.fromJson(astroList[0] as Map<String, dynamic>)
          : AstronomyInfo.defaultInfo(),
    );
  }
}

class HourlyWeather {
  final String time; // e.g. "0", "300", "600", "900", "1200", "1500", "1800", "2100"
  final int tempC;
  final int feelsLikeC;
  final String weatherCode;
  final String weatherDesc;
  final int chanceOfRain;
  final int humidity;
  final int windSpeedKmph;

  HourlyWeather({
    required this.time,
    required this.tempC,
    required this.feelsLikeC,
    required this.weatherCode,
    required this.weatherDesc,
    required this.chanceOfRain,
    required this.humidity,
    required this.windSpeedKmph,
  });

  String get formattedTime {
    final t = int.tryParse(time) ?? 0;
    final hours = t ~/ 100;
    final minutes = t % 100;
    final hStr = hours.toString().padLeft(2, '0');
    final mStr = minutes.toString().padLeft(2, '0');
    return '$hStr:$mStr';
  }

  factory HourlyWeather.fromJson(Map<String, dynamic> json) {
    final descList = json['weatherDesc'] as List<dynamic>? ?? [];
    final desc = descList.isNotEmpty
        ? (descList[0]['value'] ?? '').toString().trim()
        : 'Clear';

    return HourlyWeather(
      time: json['time']?.toString() ?? '0',
      tempC: int.tryParse(json['tempC']?.toString() ?? '0') ?? 0,
      feelsLikeC: int.tryParse(json['FeelsLikeC']?.toString() ?? '0') ?? 0,
      weatherCode: json['weatherCode']?.toString() ?? '113',
      weatherDesc: desc,
      chanceOfRain: int.tryParse(json['chanceofrain']?.toString() ?? '0') ?? 0,
      humidity: int.tryParse(json['humidity']?.toString() ?? '0') ?? 0,
      windSpeedKmph: int.tryParse(json['windspeedKmph']?.toString() ?? '0') ?? 0,
    );
  }
}

class NearestArea {
  final String areaName;
  final String country;
  final String region;
  final double latitude;
  final double longitude;

  NearestArea({
    required this.areaName,
    required this.country,
    required this.region,
    required this.latitude,
    required this.longitude,
  });

  factory NearestArea.fromJson(Map<String, dynamic> json) {
    String extractValue(List<dynamic>? list) {
      if (list != null && list.isNotEmpty) {
        return (list[0]['value'] ?? '').toString();
      }
      return '';
    }

    final latStr = json['latitude']?.toString() ?? '10.8231';
    final lonStr = json['longitude']?.toString() ?? '106.6297';

    return NearestArea(
      areaName: extractValue(json['areaName'] as List<dynamic>?),
      country: extractValue(json['country'] as List<dynamic>?),
      region: extractValue(json['region'] as List<dynamic>?),
      latitude: double.tryParse(latStr) ?? 10.8231,
      longitude: double.tryParse(lonStr) ?? 106.6297,
    );
  }

  factory NearestArea.empty() {
    return NearestArea(
      areaName: 'Ho Chi Minh City',
      country: 'Vietnam',
      region: 'Dong Nam Bo',
      latitude: 10.8231,
      longitude: 106.6297,
    );
  }
}
