import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../data/mock_data.dart';
import '../../models/report.dart';

// Embedded directly in HomeScreen's "이번 주 리포트" section — no separate
// detail page, so this is just the section content, not a route/Scaffold.
class WeeklyReportSection extends StatelessWidget {
  const WeeklyReportSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: '이번 주 리포트'),
        _WeeklyReportSummaryRow(),
        SizedBox(height: 14),
        _StudyChart(),
        SizedBox(height: 14),
        _SubjectBreakdown(),
      ],
    );
  }
}

// Folds what used to be a separate "이번 주 달성" badge row in here — the two
// overlapped (both showed streak/quiz-accuracy), so this is the one place for
// the week's headline numbers now. 2x2 grid on phones; a wider tablet gets a
// single row since there's room for all four cards side by side.
class _WeeklyReportSummaryRow extends StatelessWidget {
  const _WeeklyReportSummaryRow();

  static const _totalStudy = _StatCard(
    label: '총 학습',
    value: MockData.weeklyTotalStudy,
    icon: '📚',
  );
  static const _quizAccuracy = _StatCard(
    label: '퀴즈 정답률',
    value: MockData.weeklyQuizAccuracy,
    icon: '🎯',
  );
  static const _streak = _StatCard(
    label: '연속 학습',
    value: MockData.currentStreak,
    icon: '🔥',
  );
  static const _notesDone = _StatCard(
    label: '필기 완료',
    value: MockData.weeklyNotesCompleted,
    icon: '📝',
  );

  @override
  Widget build(BuildContext context) {
    if (context.isTablet) {
      return const Row(
        children: [
          Expanded(child: _totalStudy),
          SizedBox(width: 10),
          Expanded(child: _quizAccuracy),
          SizedBox(width: 10),
          Expanded(child: _streak),
          SizedBox(width: 10),
          Expanded(child: _notesDone),
        ],
      );
    }
    return const Column(
      children: [
        Row(
          children: [
            Expanded(child: _totalStudy),
            SizedBox(width: 10),
            Expanded(child: _quizAccuracy),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _streak),
            SizedBox(width: 10),
            Expanded(child: _notesDone),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value, icon;
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return MulgilCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _StudyChart extends StatelessWidget {
  const _StudyChart();

  @override
  Widget build(BuildContext context) {
    final maxH = MockData.studyHours.reduce((a, b) => a > b ? a : b);
    return MulgilCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: '일별 학습 시간'),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(MockData.studyDays.length, (i) {
                final ratio = MockData.studyHours[i] / maxH;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: 90 * ratio,
                          decoration: BoxDecoration(
                            color: i == 3
                                ? AppColors.teal
                                : AppColors.teal.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          MockData.studyDays[i],
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectBreakdown extends StatelessWidget {
  const _SubjectBreakdown();

  @override
  Widget build(BuildContext context) {
    return MulgilCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: '과목별 학습'),
          const SizedBox(height: 12),
          ...MockData.subjectRecords.map((s) => _SubjectRow(subject: s)),
        ],
      ),
    );
  }
}

class _SubjectRow extends StatelessWidget {
  final SubjectRecord subject;
  const _SubjectRow({required this.subject});

  @override
  Widget build(BuildContext context) {
    final ratio = subject.hours / MockData.totalStudyHours;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                subject.name,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${subject.hours.toStringAsFixed(1)}h',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation(subject.color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
