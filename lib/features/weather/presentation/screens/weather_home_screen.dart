import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/weather_mapper.dart';
import '../../data/models/weather_model.dart';
import '../../data/services/ai_advisor_service.dart';
import '../../data/services/location_service.dart';
import '../../data/services/weather_api_service.dart';
import '../widgets/ai_advice_card.dart';
import '../widgets/city_search_sheet.dart';
import '../widgets/current_weather_hero.dart';
import '../widgets/daily_forecast_list.dart';
import '../widgets/glass_card.dart';
import '../widgets/home_widget_preview.dart';
import '../widgets/hourly_forecast_list.dart';
import '../widgets/interactive_weather_sky.dart';
import '../widgets/weather_alert_banner.dart';
import '../widgets/weather_metrics_grid.dart';

class WeatherHomeScreen extends StatefulWidget {
  const WeatherHomeScreen({super.key});

  @override
  State<WeatherHomeScreen> createState() => _WeatherHomeScreenState();
}

class _WeatherHomeScreenState extends State<WeatherHomeScreen> {
  final WeatherApiService _apiService = WeatherApiService();
  final LocationService _locationService = LocationService();
  final AiAdvisorService _aiService = AiAdvisorService();

  String _currentCity = 'Ho Chi Minh City';
  WeatherResponse? _weather;
  bool _isLoading = true;
  bool _isLocating = false;
  String? _errorMessage;
  DateTime? _lastUpdated;

  String? _aiAdvice;
  bool _isLoadingAdvice = false;

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
        _fetchAiAdvice(response);
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

  Future<void> _fetchAiAdvice(WeatherResponse response) async {
    if (!mounted) return;
    setState(() {
      _isLoadingAdvice = true;
    });

    final cityName = response.nearestArea.areaName.isNotEmpty
        ? response.nearestArea.areaName
        : _currentCity;
    final rainChance = response.dailyForecast.isNotEmpty &&
            response.dailyForecast[0].hourly.isNotEmpty
        ? response.dailyForecast[0].hourly[0].chanceOfRain
        : 20;

    final advice = await _aiService.getAdvice(
      city: cityName,
      current: response.currentCondition,
      rainChance: rainChance,
    );

    if (mounted) {
      setState(() {
        _aiAdvice = advice;
        _isLoadingAdvice = false;
      });
    }
  }

  Future<void> _detectGPSLocation() async {
    setState(() {
      _isLocating = true;
    });

    final loc = await _locationService.getCurrentLocationQuery();
    if (!mounted) return;

    setState(() {
      _isLocating = false;
    });

    if (loc != null) {
      _onCityChanged(loc);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã cập nhật thời tiết theo tọa độ GPS hiện tại!'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể lấy vị trí GPS. Vui lòng bật định vị.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
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

    return Scaffold(
      body: InteractiveWeatherSky(
        condition: conditionType,
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
                // Action Buttons (GPS & Search)
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Định vị GPS',
                      onPressed: _isLocating ? null : _detectGPSLocation,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.12),
                      ),
                      icon: _isLocating
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.my_location_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Tìm thành phố',
                      onPressed: _openCitySearch,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.12),
                      ),
                      icon: const Icon(Icons.search_rounded, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Extreme Weather Alert Banner (if any)
        SliverToBoxAdapter(
          child: WeatherAlertBanner(
            current: current,
            hourly: hourly,
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

        // AI Advice Card (Connected to maico-le-server with smart fallback)
        if (_aiAdvice != null || _isLoadingAdvice)
          SliverToBoxAdapter(
            child: AiAdviceCard(
              advice: _aiAdvice ?? '',
              isLoading: _isLoadingAdvice,
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 12)),

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

        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // Home Screen Widget Preview Section
        if (_weather != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: HomeWidgetPreview(weather: _weather!),
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
                    'Dữ liệu nguồn: wttr.in • Trợ lý AI: Maico Le Server • Lottie & Flutter',
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
