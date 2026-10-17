import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/services/city_manager_service.dart';
import 'glass_card.dart';

class CityManagerSheet extends StatefulWidget {
  final List<SavedCity> savedCities;
  final int activeIndex;
  final Function(int index) onSelectCity;
  final Function(SavedCity city) onAddCity;
  final Function(String id) onDeleteCity;

  const CityManagerSheet({
    super.key,
    required this.savedCities,
    required this.activeIndex,
    required this.onSelectCity,
    required this.onAddCity,
    required this.onDeleteCity,
  });

  @override
  State<CityManagerSheet> createState() => _CityManagerSheetState();
}

class _CityManagerSheetState extends State<CityManagerSheet> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, String>> _popularCities = [
    {'name': 'Ho Chi Minh City', 'country': 'Vietnam'},
    {'name': 'Hanoi', 'country': 'Vietnam'},
    {'name': 'Da Nang', 'country': 'Vietnam'},
    {'name': 'Nha Trang', 'country': 'Vietnam'},
    {'name': 'Da Lat', 'country': 'Vietnam'},
    {'name': 'Hue', 'country': 'Vietnam'},
    {'name': 'Can Tho', 'country': 'Vietnam'},
    {'name': 'Vung Tau', 'country': 'Vietnam'},
    {'name': 'Tokyo', 'country': 'Japan'},
    {'name': 'Seoul', 'country': 'South Korea'},
    {'name': 'Singapore', 'country': 'Singapore'},
    {'name': 'Bangkok', 'country': 'Thailand'},
    {'name': 'London', 'country': 'United Kingdom'},
    {'name': 'Paris', 'country': 'France'},
    {'name': 'New York', 'country': 'United States'},
    {'name': 'Sydney', 'country': 'Australia'},
  ];

  bool _isAdding = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_city_rounded, color: Color(0xFF38BDF8), size: 22),
                    const SizedBox(width: 8),
                    const Text(
                      'Quản Lý Thành Phố',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _isAdding = !_isAdding;
                    });
                  },
                  icon: Icon(_isAdding ? Icons.close : Icons.add_rounded, size: 18, color: const Color(0xFF38BDF8)),
                  label: Text(
                    _isAdding ? 'Đóng' : 'Thêm mới',
                    style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white12, height: 1),

          Expanded(
            child: _isAdding ? _buildAddCitySection() : _buildCityListSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildCityListSection() {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: widget.savedCities.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final city = widget.savedCities[index];
        final isActive = index == widget.activeIndex;

        return Dismissible(
          key: Key(city.id),
          direction: city.isGps || widget.savedCities.length <= 1
              ? DismissDirection.none
              : DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete_outline, color: Colors.white),
          ),
          onDismissed: (_) {
            HapticFeedback.mediumImpact();
            widget.onDeleteCity(city.id);
          },
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              widget.onSelectCity(index);
              Navigator.of(context).pop();
            },
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF38BDF8).withValues(alpha: 0.25)
                          : Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      city.isGps ? Icons.my_location_rounded : Icons.location_on_outlined,
                      color: isActive ? const Color(0xFF38BDF8) : AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              city.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            if (city.isGps) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'GPS',
                                  style: TextStyle(fontSize: 10, color: Color(0xFF10B981), fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          city.country,
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  if (isActive)
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF38BDF8), size: 22)
                  else if (!city.isGps && widget.savedCities.length > 1)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.white38, size: 18),
                      onPressed: () => widget.onDeleteCity(city.id),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddCitySection() {
    final query = _searchController.text.toLowerCase().trim();
    final filtered = _popularCities.where((c) {
      final name = c['name']!.toLowerCase();
      final country = c['country']!.toLowerCase();
      return name.contains(query) || country.contains(query);
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search input
          TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Nhập tên thành phố (vd: Tokyo, Paris, Huế)...',
              hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF38BDF8)),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.add_circle, color: Color(0xFF38BDF8)),
                      onPressed: () {
                        final val = _searchController.text.trim();
                        if (val.isNotEmpty) {
                          widget.onAddCity(
                            SavedCity(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              name: val,
                              country: 'Thế giới',
                            ),
                          );
                          setState(() {
                            _isAdding = false;
                          });
                        }
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.08),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 16),
          const Text(
            'Gợi ý thành phố phổ biến:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),

          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, idx) {
                final item = filtered[idx];
                final isAlreadyAdded = widget.savedCities.any(
                  (c) => c.name.toLowerCase() == item['name']!.toLowerCase(),
                );

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.location_pin, color: AppColors.textMuted, size: 20),
                  title: Text(item['name']!, style: const TextStyle(color: Colors.white, fontSize: 15)),
                  subtitle: Text(item['country']!, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  trailing: isAlreadyAdded
                      ? const Text('Đã thêm', style: TextStyle(color: Colors.white38, fontSize: 12))
                      : IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: Color(0xFF38BDF8)),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            widget.onAddCity(
                              SavedCity(
                                id: DateTime.now().millisecondsSinceEpoch.toString(),
                                name: item['name']!,
                                country: item['country']!,
                              ),
                            );
                            setState(() {
                              _isAdding = false;
                            });
                          },
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
