import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../../../widgets/common_widgets.dart';
import '../../../models/summary_item.dart';

class SummaryTab extends StatelessWidget {
  final bool isTablet;
  final List<SummaryItem> items;
  final VoidCallback onTakeQuiz;
  const SummaryTab({
    super.key,
    required this.isTablet,
    required this.items,
    required this.onTakeQuiz,
  });

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
    if (items.isEmpty) return const _EmptySummary();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        ...items.map((item) => SummaryItemCard(item: item)),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    if (items.isEmpty) return const _EmptySummary();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items.map((item) => SummaryItemCard(item: item)).toList(),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 2,
          child: MulgilButton(label: '퀴즈 풀기', onTap: onTakeQuiz),
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
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
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
                    '교수님 강조',
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

class _EmptySummary extends StatelessWidget {
  const _EmptySummary();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 80),
        child: Text(
          'AI 요약이 아직 없어요',
          style: TextStyle(color: AppColors.textMuted),
        ),
      ),
    );
  }
}
