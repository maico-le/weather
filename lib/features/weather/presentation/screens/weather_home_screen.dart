import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/weather_mapper.dart';
import '../../data/models/weather_model.dart';
import '../../data/services/weather_api_service.dart';
import '../widgets/city_search_sheet.dart';
import '../widgets/current_weather_hero.dart';
import '../widgets/daily_forecast_list.dart';
import '../widgets/glass_card.dart';
import '../widgets/hourly_forecast_list.dart';
import '../widgets/weather_metrics_grid.dart';

class WeatherHomeScreen extends StatefulWidget {
  const WeatherHomeScreen({super.key});

  @override
  State<WeatherHomeScreen> createState() => _WeatherHomeScreenState();
}

class _WeatherHomeScreenState extends State<WeatherHomeScreen> {
  final WeatherApiService _apiService = WeatherApiService();

  String _currentCity = 'Ho Chi Minh City';
  WeatherResponse? _weather;
  bool _isLoading = true;
  String? _errorMessage;
  DateTime? _lastUpdated;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.fetchWeather(_currentCity);
      if (mounted) {
        setState(() {
          _weather = response;
          _isLoading = false;
          _lastUpdated = DateTime.now();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  void _onCityChanged(String newCity) {
    if (newCity != _currentCity) {
      setState(() {
        _currentCity = newCity;
      });
      _fetchWeather();
    }
  }

  void _openCitySearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CitySearchSheet(
        currentCity: _currentCity,
        onCitySelected: _onCityChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final conditionType = _weather != null
        ? WeatherMapper.getConditionType(
            _weather!.currentCondition.weatherCode,
            _weather!.currentCondition.weatherDesc,
          )
        : WeatherConditionType.sunny;

    final backgroundGradient = WeatherMapper.getBackgroundGradient(conditionType);

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 700),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: backgroundGradient,
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _fetchWeather,
            color: const Color(0xFF38BDF8),
            backgroundColor: const Color(0xFF1E293B),
            child: _buildBody(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _weather == null) {
      return _buildLoadingState();
    }

    if (_errorMessage != null && _weather == null) {
      return _buildErrorState();
    }

    final current = _weather!.currentCondition;
    final today = _weather!.dailyForecast.isNotEmpty ? _weather!.dailyForecast[0] : null;
    final hourly = today?.hourly ?? [];
    final daily = _weather!.dailyForecast;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        // App Bar / Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // City selector
                GestureDetector(
                  onTap: _openCitySearch,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _weather?.nearestArea.areaName.isNotEmpty == true
                            ? _weather!.nearestArea.areaName
                            : _currentCity,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                // Search button
                IconButton(
                  onPressed: _openCitySearch,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.12),
                  ),
                  icon: const Icon(Icons.search_rounded, color: Colors.white),
                ),
              ],
            ),
          ),
        ),

        // Hero Weather Info
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: CurrentWeatherHero(
              current: current,
              today: today,
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // Hourly Forecast
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: HourlyForecastList(hourly: hourly),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // Multi-day Forecast
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: DailyForecastList(daily: daily),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // Weather Metrics Grid
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: WeatherMetricsGrid(current: current),
          ),
        ),

        // Footer
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Center(
              child: Column(
                children: [
                  if (_lastUpdated != null)
                    Text(
                      'Cập nhật: ${DateFormat('HH:mm - dd/MM/yyyy').format(_lastUpdated!)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  const SizedBox(height: 4),
                  const Text(
                    'Dữ liệu nguồn: wttr.in • Tối ưu bởi Lottie & Flutter',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          SizedBox(height: 16),
          Text(
            'Đang kết nối trạm thời tiết...',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GlassCard(
          borderRadius: 24,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 56,
                color: Color(0xFFFF6B6B),
              ),
              const SizedBox(height: 16),
              const Text(
                'Không thể tải dữ liệu thời tiết',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? 'Đã xảy ra lỗi không xác định',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _fetchWeather,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF38BDF8),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
