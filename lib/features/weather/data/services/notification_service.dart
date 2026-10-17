import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPreferences {
  final bool isEnabled;
  final bool morningEnabled;
  final TimeOfDay morningTime;
  final bool noonEnabled;
  final TimeOfDay noonTime;
  final bool eveningEnabled;
  final TimeOfDay eveningTime;

  const NotificationPreferences({
    this.isEnabled = true,
    this.morningEnabled = true,
    this.morningTime = const TimeOfDay(hour: 7, minute: 0),
    this.noonEnabled = true,
    this.noonTime = const TimeOfDay(hour: 12, minute: 0),
    this.eveningEnabled = true,
    this.eveningTime = const TimeOfDay(hour: 18, minute: 0),
  });

  NotificationPreferences copyWith({
    bool? isEnabled,
    bool? morningEnabled,
    TimeOfDay? morningTime,
    bool? noonEnabled,
    TimeOfDay? noonTime,
    bool? eveningEnabled,
    TimeOfDay? eveningTime,
  }) {
    return NotificationPreferences(
      isEnabled: isEnabled ?? this.isEnabled,
      morningEnabled: morningEnabled ?? this.morningEnabled,
      morningTime: morningTime ?? this.morningTime,
      noonEnabled: noonEnabled ?? this.noonEnabled,
      noonTime: noonTime ?? this.noonTime,
      eveningEnabled: eveningEnabled ?? this.eveningEnabled,
      eveningTime: eveningTime ?? this.eveningTime,
    );
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  static const String _keyEnabled = 'notif_enabled';
  static const String _keyMorning = 'notif_morning';
  static const String _keyMorningHour = 'notif_morning_h';
  static const String _keyMorningMin = 'notif_morning_m';
  static const String _keyNoon = 'notif_noon';
  static const String _keyNoonHour = 'notif_noon_h';
  static const String _keyNoonMin = 'notif_noon_m';
  static const String _keyEvening = 'notif_evening';
  static const String _keyEveningHour = 'notif_evening_h';
  static const String _keyEveningMin = 'notif_evening_m';

  Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    try {
      await _notificationsPlugin.initialize(settings: initSettings);
      _isInitialized = true;
    } catch (e) {
      debugPrint('NotificationService init error: $e');
    }
  }

  Future<bool> requestPermission() async {
    try {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        final granted =
            await androidImplementation.requestNotificationsPermission();
        return granted ?? false;
      }
      return true;
    } catch (e) {
      debugPrint('requestPermission error: $e');
      return false;
    }
  }

  Future<NotificationPreferences> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return NotificationPreferences(
      isEnabled: prefs.getBool(_keyEnabled) ?? true,
      morningEnabled: prefs.getBool(_keyMorning) ?? true,
      morningTime: TimeOfDay(
        hour: prefs.getInt(_keyMorningHour) ?? 7,
        minute: prefs.getInt(_keyMorningMin) ?? 0,
      ),
      noonEnabled: prefs.getBool(_keyNoon) ?? true,
      noonTime: TimeOfDay(
        hour: prefs.getInt(_keyNoonHour) ?? 12,
        minute: prefs.getInt(_keyNoonMin) ?? 0,
      ),
      eveningEnabled: prefs.getBool(_keyEvening) ?? true,
      eveningTime: TimeOfDay(
        hour: prefs.getInt(_keyEveningHour) ?? 18,
        minute: prefs.getInt(_keyEveningMin) ?? 0,
      ),
    );
  }

  Future<void> savePreferences(NotificationPreferences pref) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyEnabled, pref.isEnabled);
    await prefs.setBool(_keyMorning, pref.morningEnabled);
    await prefs.setInt(_keyMorningHour, pref.morningTime.hour);
    await prefs.setInt(_keyMorningMin, pref.morningTime.minute);
    await prefs.setBool(_keyNoon, pref.noonEnabled);
    await prefs.setInt(_keyNoonHour, pref.noonTime.hour);
    await prefs.setInt(_keyNoonMin, pref.noonTime.minute);
    await prefs.setBool(_keyEvening, pref.eveningEnabled);
    await prefs.setInt(_keyEveningHour, pref.eveningTime.hour);
    await prefs.setInt(_keyEveningMin, pref.eveningTime.minute);
  }

  Future<void> showInstantWeatherNotification({
    required String cityName,
    required int tempC,
    required String condition,
    required int uvIndex,
    int rainChance = 10,
    String? sessionName,
  }) async {
    await initialize();

    final now = DateTime.now();
    String session = sessionName ?? _detectSession(now.hour);
    String title = '$session: $cityName $tempC°C';
    String body = _generateSessionBody(tempC, condition, uvIndex, rainChance, session);

    const androidDetails = AndroidNotificationDetails(
      'weather_glow_channel',
      'Thông Báo Thời Tiết Weather Glow',
      channelDescription: 'Cập nhật thời tiết buổi sáng, trưa, tối thông minh',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(''),
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    try {
      await _notificationsPlugin.show(
        id: now.millisecondsSinceEpoch ~/ 1000,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
      );
    } catch (e) {
      debugPrint('Error showing instant notification: $e');
    }
  }

  String _detectSession(int hour) {
    if (hour >= 5 && hour < 11) return '🌤️ Thời tiết Buổi Sáng';
    if (hour >= 11 && hour < 14) return '☀️ Thời tiết Buổi Trưa';
    if (hour >= 14 && hour < 18) return '⛅ Thời tiết Buổi Chiều';
    return '🌙 Thời tiết Buổi Tối';
  }

  String _generateSessionBody(
    int temp,
    String cond,
    int uv,
    int rain,
    String session,
  ) {
    String advice = '';
    if (session.contains('Sáng')) {
      advice = rain > 40
          ? 'Hôm nay xác suất mưa $rain%, hãy mang theo ô/áo mưa khi đi làm nhé!'
          : 'Thời tiết mát mẻ, khởi đầu ngày mới tràn đầy năng lượng!';
    } else if (session.contains('Trưa')) {
      advice = uv >= 8
          ? 'Chỉ số UV nguy hại ($uv), hãy hạn chế ra đường và thoa kem chống nắng!'
          : 'Nhiệt độ $temp°C, hãy uống nhiều nước và nghỉ ngơi hợp lý.';
    } else {
      advice = temp <= 22
          ? 'Trời se lạnh ($temp°C), bạn nên mặc áo khoác mỏng khi ra đường.'
          : 'Thời tiết tối dễ chịu, rất thích hợp để dạo phố hoặc thư giãn!';
    }

    return '$cond • Nhiệt độ: $temp°C • UV: $uv. $advice';
  }
}
