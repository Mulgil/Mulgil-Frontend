import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../data/mock_data.dart';
import '../../models/report.dart';

class WeeklyReportScreen extends StatelessWidget {
  const WeeklyReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(context.isTablet ? 28 : 20),
          child: context.isTablet ? _buildTablet(context) : _buildMobile(context),
        ),
      ),
    );
  }

  Widget _buildMobile(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(context),
        const SizedBox(height: 16),
        _summaryRow(),
        const SizedBox(height: 14),
        const _StudyChart(),
        const SizedBox(height: 14),
        const _SubjectBreakdown(),
        const SizedBox(height: 14),
        const _AchievementBadges(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTablet(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(context),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  _summaryRow(),
                  const SizedBox(height: 14),
                  const _StudyChart(),
                ],
              ),
            ),
            const SizedBox(width: 20),
            const Expanded(
              flex: 2,
              child: Column(
                children: [
                  _SubjectBreakdown(),
                  SizedBox(height: 14),
                  _AchievementBadges(),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      children: [
        GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.arrow_back_ios, size: 18, color: AppColors.textPrimary)),
        const SizedBox(width: 8),
        const Text('주간 리포트', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const Spacer(),
        const Text('2026년 8월 4주', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
      ],
    );
  }

  Widget _summaryRow() {
    return const Row(
      children: [
        Expanded(child: _StatCard(label: '총 학습', value: '18h 42m', icon: '📚')),
        SizedBox(width: 10),
        Expanded(child: _StatCard(label: '퀴즈 정답률', value: '74%', icon: '🎯')),
        SizedBox(width: 10),
        Expanded(child: _StatCard(label: '연속 학습', value: '12일', icon: '🔥')),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value, icon;
  const _StatCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
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
                            color: i == 3 ? AppColors.teal : AppColors.teal.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(MockData.studyDays[i], style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
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
              Text(subject.name, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
              Text('${subject.hours.toStringAsFixed(1)}h', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: const Color(0xFFF0F0F0),
              valueColor: AlwaysStoppedAnimation(subject.color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementBadges extends StatelessWidget {
  const _AchievementBadges();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: '이번 주 달성'),
          const SizedBox(height: 12),
          Row(
            children: MockData.achievements.map((b) => Expanded(
              child: Column(
                children: [
                  Text(b.icon, style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 4),
                  Text(b.label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  Text(b.desc, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}
