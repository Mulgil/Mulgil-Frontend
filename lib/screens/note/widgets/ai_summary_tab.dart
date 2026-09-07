import 'package:flutter/material.dart';

import '../../../data/resource_upload_api.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common_widgets.dart';
import '../../../models/summary_item.dart';

class SummaryTab extends StatelessWidget {
  final bool isTablet;
  final List<SummaryItem> items;
  final VoidCallback onTakeQuiz;
  final SessionProcessingJob? generationJob;
  const SummaryTab({
    super.key,
    required this.isTablet,
    required this.items,
    required this.onTakeQuiz,
    this.generationJob,
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
        if (generationJob != null) ...[
          _QuizGenerationStatus(job: generationJob!),
          const SizedBox(height: 12),
        ],
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
          child: Column(
            children: [
              if (generationJob != null) ...[
                _QuizGenerationStatus(job: generationJob!),
                const SizedBox(height: 12),
              ],
              MulgilButton(label: '퀴즈 풀기', onTap: onTakeQuiz),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuizGenerationStatus extends StatelessWidget {
  final SessionProcessingJob job;

  const _QuizGenerationStatus({required this.job});

  @override
  Widget build(BuildContext context) {
    final active = job.status.isActive;
    final failed = job.status == ProcessingJobStatus.failed;
    if (!active && !failed) return const SizedBox.shrink();
    return MulgilCard(
      color: AppColors.surfaceAlt,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            active ? '퀴즈 생성 중' : '퀴즈 생성에 실패했어요.',
            style: AppTextStyles.label,
          ),
          const SizedBox(height: 8),
          Text(
            active
                ? job.safeProgressMessage
                : job.retryable
                ? '다시 시도해 주세요.'
                : '잠시 후 다시 확인해주세요.',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}

class SummaryItemCard extends StatelessWidget {
  final SummaryItem item;
  const SummaryItemCard({super.key, required this.item});

  static final RegExp _trailingKoreanPhrase = RegExp(
    r'([\uAC00-\uD7A3]{2,6}[.!?]?)$',
  );

  Widget _buildBody() {
    const style = TextStyle(
      fontSize: 12.5,
      color: AppColors.ink80,
      height: 1.6,
    );
    final match = _trailingKoreanPhrase.firstMatch(item.body);
    if (match == null || match.start == 0) {
      return Text(item.body, style: style);
    }

    return Semantics(
      label: item.body,
      excludeSemantics: true,
      child: Text.rich(
        TextSpan(
          style: style,
          children: [
            TextSpan(text: item.body.substring(0, match.start)),
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: Text(match.group(0)!, style: style),
            ),
          ],
        ),
      ),
    );
  }

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
          _buildBody(),
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
