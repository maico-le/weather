import 'package:flutter/material.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/constants/app_colors.dart';
import 'glass_card.dart';

class CitySearchSheet extends StatefulWidget {
  final String currentCity;
  final ValueChanged<String> onCitySelected;

  const CitySearchSheet({
    super.key,
    required this.currentCity,
    required this.onCitySelected,
  });

  @override
  State<CitySearchSheet> createState() => _CitySearchSheetState();
}

class _CitySearchSheetState extends State<CitySearchSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(String city) {
    if (city.trim().isNotEmpty) {
      widget.onCitySelected(city.trim());
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text(
            'Chọn thành phố',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Search input
          TextField(
            controller: _controller,
            style: const TextStyle(color: Colors.white),
            textInputAction: TextInputAction.search,
            onSubmitted: _submit,
            decoration: InputDecoration(
              hintText: 'Nhập tên thành phố (vd: Hanoi, Tokyo...)',
              hintStyle: const TextStyle(color: AppColors.textMuted),
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
              suffixIcon: IconButton(
                icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.accentRain),
                onPressed: () => _submit(_controller.text),
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.08),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
              ),
            ),
          ),

          const SizedBox(height: 20),
          const Text(
            'GỢI Ý PHỔ BIẾN',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 12),

          // Quick selection chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ApiEndpoints.defaultCities.map((city) {
              final isSelected = city.toLowerCase() == widget.currentCity.toLowerCase();
              return InkWell(
                onTap: () => _submit(city),
                borderRadius: BorderRadius.circular(12),
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  borderRadius: 12,
                  opacity: isSelected ? 0.28 : 0.08,
                  borderColor: isSelected ? const Color(0xFF38BDF8) : null,
                  child: Text(
                    city,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? const Color(0xFF38BDF8) : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
