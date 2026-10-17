import 'dart:ui';
import 'package:flutter/material.dart';
import '../../data/models/weather_model.dart';
import '../../data/services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  final String cityName;
  final CurrentCondition? currentCondition;

  const SettingsScreen({
    super.key,
    this.cityName = 'TP. Hồ Chí Minh',
    this.currentCondition,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  NotificationPreferences _prefs = const NotificationPreferences();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await _notificationService.loadPreferences();
    if (mounted) {
      setState(() {
        _prefs = prefs;
        _isLoading = false;
      });
    }
  }

  Future<void> _updatePreferences(NotificationPreferences newPrefs) async {
    setState(() => _prefs = newPrefs);
    await _notificationService.savePreferences(newPrefs);
  }

  Future<void> _selectTime(
    BuildContext context,
    TimeOfDay initialTime,
    Function(TimeOfDay) onSelected,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF38BDF8),
              onPrimary: Colors.white,
              surface: Color(0xFF1E293B),
              onSurface: Colors.white,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onSelected(picked);
    }
  }

  Future<void> _triggerTestNotification() async {
    await _notificationService.requestPermission();

    final temp = widget.currentCondition?.tempC ?? 33;
    final cond = widget.currentCondition?.weatherDesc ?? 'Nắng nóng oi bức';
    final uv = widget.currentCondition?.uvIndex ?? 9;

    await _notificationService.showInstantWeatherNotification(
      cityName: widget.cityName,
      tempC: temp,
      condition: cond,
      uvIndex: uv,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle_outline, color: Color(0xFF34D399)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Đã phát thông báo thử nghiệm lên thanh trạng thái!',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1E293B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B19),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Cài Đặt & Thông Báo',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF070B19), Color(0xFF0D1B2A), Color(0xFF1B263B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  children: [
                    _buildSectionHeader('🔔 THÔNG BÁO THỜI TIẾT ĐỊNH KỲ'),
                    _buildNotificationMasterCard(),
                    const SizedBox(height: 16),
                    if (_prefs.isEnabled) ...[
                      _buildSectionHeader('⏰ CÁC BUỔI THÔNG BÁO TRONG NGÀY'),
                      _buildSessionCards(),
                      const SizedBox(height: 16),
                      _buildTestNotificationButton(),
                      const SizedBox(height: 24),
                    ],
                    _buildSectionHeader('📱 MÁY CHỦ & ĐỒNG BỘ'),
                    _buildServerCard(),
                    const SizedBox(height: 24),
                    _buildSectionHeader('ℹ️ THÔNG TIN ỨNG DỤNG'),
                    _buildAboutCard(),
                    const SizedBox(height: 32),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.6),
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildNotificationMasterCard() {
    return _buildGlassContainer(
      child: SwitchListTile(
        title: const Text(
          'Bật thông báo thời tiết',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Nhận thông báo cập nhật tình hình thời tiết và lời khuyên trang phục',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 13),
        ),
        value: _prefs.isEnabled,
        activeThumbColor: const Color(0xFF38BDF8),
        onChanged: (val) async {
          if (val) {
            await _notificationService.requestPermission();
          }
          _updatePreferences(_prefs.copyWith(isEnabled: val));
        },
      ),
    );
  }

  Widget _buildSessionCards() {
    return _buildGlassContainer(
      child: Column(
        children: [
          _buildSessionTile(
            title: '🌤️ Buổi Sáng',
            subtitle: 'Chuẩn bị đi làm, đi học & gợi ý trang phục',
            time: _prefs.morningTime,
            enabled: _prefs.morningEnabled,
            onToggle: (val) =>
                _updatePreferences(_prefs.copyWith(morningEnabled: val)),
            onPickTime: () => _selectTime(
              context,
              _prefs.morningTime,
              (picked) => _updatePreferences(_prefs.copyWith(morningTime: picked)),
            ),
          ),
          Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
          _buildSessionTile(
            title: '☀️ Buổi Trưa',
            subtitle: 'Cảnh báo chỉ số UV đỉnh điểm & nhiệt độ',
            time: _prefs.noonTime,
            enabled: _prefs.noonEnabled,
            onToggle: (val) =>
                _updatePreferences(_prefs.copyWith(noonEnabled: val)),
            onPickTime: () => _selectTime(
              context,
              _prefs.noonTime,
              (picked) => _updatePreferences(_prefs.copyWith(noonTime: picked)),
            ),
          ),
          Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
          _buildSessionTile(
            title: '🌙 Buổi Tối',
            subtitle: 'Thời tiết ban đêm & kế hoạch ra ngoài',
            time: _prefs.eveningTime,
            enabled: _prefs.eveningEnabled,
            onToggle: (val) =>
                _updatePreferences(_prefs.copyWith(eveningEnabled: val)),
            onPickTime: () => _selectTime(
              context,
              _prefs.eveningTime,
              (picked) => _updatePreferences(_prefs.copyWith(eveningTime: picked)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionTile({
    required String title,
    required String subtitle,
    required TimeOfDay time,
    required bool enabled,
    required Function(bool) onToggle,
    required VoidCallback onPickTime,
  }) {
    final formattedTime =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (enabled)
            InkWell(
              onTap: onPickTime,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  formattedTime,
                  style: const TextStyle(
                    color: Color(0xFF38BDF8),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          Switch(
            value: enabled,
            activeThumbColor: const Color(0xFF38BDF8),
            onChanged: onToggle,
          ),
        ],
      ),
    );
  }

  Widget _buildTestNotificationButton() {
    return _buildGlassContainer(
      child: InkWell(
        onTap: _triggerTestNotification,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send_rounded, color: Color(0xFF38BDF8), size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bắn thông báo thử nghiệm ngay',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Gửi thông báo thời tiết của buổi hiện tại lên máy để xem trước',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServerCard() {
    return _buildGlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.cloud_done_rounded, color: Color(0xFF34D399), size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Cổng API Maico Le Server',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF34D399).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Online',
                    style: TextStyle(
                      color: Color(0xFF34D399),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'https://maico-le-server.vercel.app',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              'AI Engine: Google Gemini 2.5 Flash via Go Serverless',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCard() {
    return _buildGlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF38BDF8), Color(0xFF818CF8)],
                    ),
                  ),
                  child: const Icon(Icons.wb_sunny_rounded, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Weather Glow',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Phiên bản 1.0.0 • Thiết kế bởi Maico Le',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: child,
        ),
      ),
    );
  }
}
