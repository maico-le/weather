import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/weather_mapper.dart';
import '../../data/models/weather_model.dart';
import '../../data/services/ai_advisor_service.dart';
import '../../data/services/cache_service.dart';
import '../../data/services/city_manager_service.dart';
import '../../data/services/location_service.dart';
import '../../data/services/native_widget_service.dart';
import '../../data/services/weather_api_service.dart';
import '../widgets/ai_advice_card.dart';
import '../widgets/city_manager_sheet.dart';
import '../widgets/city_search_sheet.dart';
import '../widgets/current_weather_hero.dart';
import '../widgets/daily_forecast_list.dart';
import '../widgets/glass_card.dart';
import '../widgets/home_widget_preview.dart';
import '../widgets/hourly_forecast_list.dart';
import '../widgets/interactive_weather_sky.dart';
import '../widgets/weather_alert_banner.dart';
import '../widgets/weather_forecast_chart.dart';
import '../widgets/weather_metrics_grid.dart';
import '../widgets/weather_radar_map_widget.dart';
import '../widgets/weather_story_share_sheet.dart';
import 'settings_screen.dart';

class WeatherHomeScreen extends StatefulWidget {
  const WeatherHomeScreen({super.key});

  @override
  State<WeatherHomeScreen> createState() => _WeatherHomeScreenState();
}

class _WeatherHomeScreenState extends State<WeatherHomeScreen> {
  final WeatherApiService _apiService = WeatherApiService();
  final LocationService _locationService = LocationService();
  final AiAdvisorService _aiService = AiAdvisorService();
  final CacheService _cacheService = CacheService();
  final CityManagerService _cityManager = CityManagerService();

  List<SavedCity> _savedCities = [];
  int _activeCityIndex = 0;
  PageController _pageController = PageController();

  String _currentCity = 'Ho Chi Minh City';
  WeatherResponse? _weather;
  bool _isLoading = true;
  bool _isLocating = false;
  String? _errorMessage;
  DateTime? _lastUpdated;

  String? _aiAdvice;
  String _aiEngine = 'Gemini 2.5 Flash';
  bool _isAiOnline = true;
  bool _isLoadingAdvice = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final cities = await _cityManager.getSavedCities();
    final savedIndex = await _cityManager.getActiveIndex();
    final activeIdx = (savedIndex < cities.length) ? savedIndex : 0;

    _pageController = PageController(initialPage: activeIdx);

    setState(() {
      _savedCities = cities;
      _activeCityIndex = activeIdx;
      if (cities.isNotEmpty) {
        _currentCity = cities[activeIdx].name;
      }
    });

    final cached = await _cacheService.loadCachedWeather();
    if (cached != null && mounted && cached.city == _currentCity) {
      setState(() {
        _weather = cached.weather;
        _aiAdvice = cached.aiAdvice;
        _aiEngine = cached.aiEngine ?? 'Gemini 2.5 Flash';
        _lastUpdated = cached.updatedAt;
        _isLoading = false;
      });
    }

    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    if (_weather == null) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final result = await _apiService.fetchWeather(_currentCity);
      if (mounted) {
        setState(() {
          _weather = result.response;
          _isLoading = false;
          _lastUpdated = DateTime.now();
        });

        // Trigger AI advice in background
        _fetchAiAdvice(result.response, result.rawJson);

        // Sync with Native Android Home Screen Widget
        NativeWidgetService.updateWidgetData(
          cityName: result.response.nearestArea.areaName.isNotEmpty
              ? result.response.nearestArea.areaName
              : _currentCity,
          current: result.response.currentCondition,
          aiSummary: _aiAdvice ?? 'Thời tiết thuận lợi cho các hoạt động thường ngày.',
        );
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

  Future<void> _fetchAiAdvice(WeatherResponse response, [Map<String, dynamic>? rawJson]) async {
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

    final result = await _aiService.getAdvice(
      city: cityName,
      current: response.currentCondition,
      rainChance: rainChance,
    );

    if (mounted) {
      setState(() {
        _aiAdvice = result.advice;
        _aiEngine = result.engine;
        _isAiOnline = result.isOnline;
        _isLoadingAdvice = false;
      });

      // Save to cache
      if (rawJson != null) {
        _cacheService.saveWeather(_currentCity, rawJson, result.advice, result.engine);
      }

      // Update widget with new AI advice
      NativeWidgetService.updateWidgetData(
        cityName: cityName,
        current: response.currentCondition,
        aiSummary: result.advice,
      );
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
      await _cityManager.updateGpsCityName(loc);
      final cities = await _cityManager.getSavedCities();
      final gpsIdx = cities.indexWhere((c) => c.isGps);
      setState(() {
        _savedCities = cities;
      });

      if (!mounted) return;
      if (gpsIdx != -1) {
        _onSwitchCity(gpsIdx);
      } else {
        _onCityChanged(loc);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã cập nhật vị trí GPS thành công!'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      if (!mounted) return;
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
        _weather = null; // show loader
      });
      _fetchWeather();
    }
  }

  void _onSwitchCity(int index) {
    if (index >= 0 && index < _savedCities.length) {
      HapticFeedback.selectionClick();
      setState(() {
        _activeCityIndex = index;
        _currentCity = _savedCities[index].name;
        _weather = null;
      });
      _cityManager.setActiveIndex(index);
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
      _fetchWeather();
    }
  }

  void _openCityManager() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CityManagerSheet(
        savedCities: _savedCities,
        activeIndex: _activeCityIndex,
        onSelectCity: _onSwitchCity,
        onAddCity: (newCity) async {
          await _cityManager.addCity(newCity);
          final updated = await _cityManager.getSavedCities();
          setState(() {
            _savedCities = updated;
          });
          final newIdx = updated.indexWhere((c) => c.name.toLowerCase() == newCity.name.toLowerCase());
          if (newIdx != -1) {
            _onSwitchCity(newIdx);
          }
        },
        onDeleteCity: (id) async {
          await _cityManager.removeCity(id);
          final updated = await _cityManager.getSavedCities();
          setState(() {
            _savedCities = updated;
            if (_activeCityIndex >= updated.length) {
              _activeCityIndex = 0;
            }
          });
          if (updated.isNotEmpty) {
            _onSwitchCity(_activeCityIndex);
          }
        },
      ),
    );
  }

  void _openCitySearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CitySearchSheet(
        currentCity: _currentCity,
        onCitySelected: (city) async {
          await _cityManager.addCity(
            SavedCity(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              name: city,
              country: 'Thành phố',
            ),
          );
          final updated = await _cityManager.getSavedCities();
          final newIdx = updated.indexWhere((c) => c.name.toLowerCase() == city.toLowerCase());
          setState(() {
            _savedCities = updated;
          });
          if (newIdx != -1) {
            _onSwitchCity(newIdx);
          } else {
            _onCityChanged(city);
          }
        },
      ),
    );
  }

  void _openSettings() {
    final cityName = _weather?.nearestArea.areaName.isNotEmpty == true
        ? _weather!.nearestArea.areaName
        : _currentCity;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          cityName: cityName,
          currentCondition: _weather?.currentCondition,
        ),
      ),
    );
  }

  void _openStoryShare() {
    if (_weather == null) return;
    HapticFeedback.lightImpact();
    final displayCity = _weather!.nearestArea.areaName.isNotEmpty
        ? _weather!.nearestArea.areaName
        : _currentCity;
    WeatherStoryShareSheet.show(
      context,
      weather: _weather!,
      cityName: displayCity,
      aiAdvice: _aiAdvice ?? '',
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
          child: Column(
            children: [
              _buildTopBar(),
              _buildCityDotsIndicator(),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _savedCities.isNotEmpty ? _savedCities.length : 1,
                  onPageChanged: (page) {
                    if (page != _activeCityIndex && page < _savedCities.length) {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _activeCityIndex = page;
                        _currentCity = _savedCities[page].name;
                        _weather = null;
                      });
                      _cityManager.setActiveIndex(page);
                      _fetchWeather();
                    }
                  },
                  itemBuilder: (context, index) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        HapticFeedback.mediumImpact();
                        await _fetchWeather();
                      },
                      color: const Color(0xFF38BDF8),
                      backgroundColor: const Color(0xFF1E293B),
                      child: _buildBody(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // City selector button
          Expanded(
            child: GestureDetector(
              onTap: _openCityManager,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      _weather?.nearestArea.areaName.isNotEmpty == true
                          ? _weather!.nearestArea.areaName
                          : _currentCity,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Action Buttons (GPS & Search & Share & Settings)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Định vị GPS',
                onPressed: _isLocating ? null : _detectGPSLocation,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.12),
                  padding: const EdgeInsets.all(8),
                ),
                icon: _isLocating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.my_location_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 6),
              IconButton(
                tooltip: 'Tìm kiếm thành phố',
                onPressed: _openCitySearch,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.12),
                  padding: const EdgeInsets.all(8),
                ),
                icon: const Icon(Icons.search_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 6),
              IconButton(
                tooltip: 'Chia sẻ Story thời tiết',
                onPressed: _weather == null ? null : _openStoryShare,
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF38BDF8).withValues(alpha: 0.25),
                  padding: const EdgeInsets.all(8),
                ),
                icon: const Icon(Icons.ios_share_rounded, color: Color(0xFF38BDF8), size: 18),
              ),
              const SizedBox(width: 6),
              IconButton(
                tooltip: 'Cài đặt & Thông báo',
                onPressed: _openSettings,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.12),
                  padding: const EdgeInsets.all(8),
                ),
                icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCityDotsIndicator() {
    if (_savedCities.length <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_savedCities.length, (idx) {
          final isCurrent = idx == _activeCityIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: isCurrent ? 18 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: isCurrent ? const Color(0xFF38BDF8) : Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
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
              engine: _aiEngine,
              isOnline: _isAiOnline,
              isLoading: _isLoadingAdvice,
              onRefresh: () => _fetchAiAdvice(_weather!),
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 14)),

        // NEW: Interactive 24H Spline Chart
        if (hourly.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: WeatherForecastChart(hourly: hourly),
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 14)),

        // Hourly Forecast List Cards
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

        // Live Satellite Weather Radar Map
        if (_weather != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: WeatherRadarMapWidget(
                weather: _weather!,
                cityName: _weather?.nearestArea.areaName.isNotEmpty == true
                    ? _weather!.nearestArea.areaName
                    : _currentCity,
              ),
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
                    'Dữ liệu nguồn: wttr.in • Trợ lý AI: maico-le-server (Vercel) • Lottie & Flutter',
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
