import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common_widgets.dart';
import '../../../data/mock_data.dart';
import '../../../models/summary_item.dart';
import '../../../constants/routes.dart';

class SummaryTab extends StatelessWidget {
  final bool isTablet;
  const SummaryTab({super.key, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 28 : 20),
      child: isTablet
          ? MaxContentWidth(child: _buildTabletLayout(context))
          : _buildMobileLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        ...MockData.summaryItems.map((item) => SummaryItemCard(item: item)),
        const SizedBox(height: 12),
        const ProfEmphasisBlock(),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: MockData.summaryItems
                .map((item) => SummaryItemCard(item: item))
                .toList(),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              const ProfEmphasisBlock(),
              const SizedBox(height: 16),
              MulgilButton(
                label: '퀴즈 풀기',
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.quiz),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SummaryItemCard extends StatelessWidget {
  final SummaryItem item;
  const SummaryItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(
          color: item.isEmphasis
              ? AppColors.coral.withValues(alpha: 0.4)
              : AppColors.border,
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              if (item.isEmphasis) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.coralSoft,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Text(
                    '⭐ 교수님 강조',
                    style: TextStyle(fontSize: 10, color: AppColors.coral),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item.body,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.ink80,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class ProfEmphasisBlock extends StatelessWidget {
  const ProfEmphasisBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.coralSoft,
        border: Border.all(color: AppColors.coral.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🎯 교수님 강조 포인트',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.coral,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            MockData.profEmphasisPoint.title,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.ink,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            MockData.profEmphasisPoint.body,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.ink80,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
