import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'features/weather/presentation/screens/weather_home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Edge to edge immersive experience
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather Glow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const WeatherHomeScreen(),
    );
  }
}
