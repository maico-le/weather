import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'glass_card.dart';

class AiAdviceCard extends StatelessWidget {
  final String advice;
  final bool isLoading;

  const AiAdviceCard({
    super.key,
    required this.advice,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GlassCard(
        borderRadius: 22,
        opacity: 0.16,
        padding: const EdgeInsets.all(16),
        borderColor: const Color(0xFF38BDF8).withValues(alpha: 0.3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF38BDF8), Color(0xFF818CF8)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TRỢ LÝ THỜI TIẾT & TRANG PHỤC',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: Color(0xFF38BDF8),
                        ),
                      ),
                      Text(
                        'AI Hub',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (isLoading)
                    const Text(
                      'Đang phân tích dữ liệu khí tượng...',
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textSecondary,
                      ),
                    )
                  else
                    Text(
                      advice,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        height: 1.45,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
