import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/mulgil_logo.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/course_form_sheet.dart';
import '../../widgets/weekly_timetable.dart';
import '../../data/mock_data.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _ctrl = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: PageView(
        controller: _ctrl,
        onPageChanged: (_) {},
        physics: const NeverScrollableScrollPhysics(),
        children: [
          context.isTablet
              ? _SplashTablet(onStart: _next)
              : _SplashMobile(onStart: _next),
          _ScheduleStep(onNext: _done),
        ],
      ),
    );
  }

  void _next() {
    _ctrl.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _done() {
    Navigator.of(context).pushReplacementNamed('/');
  }
}

// ── Splash ──────────────────────────────────────────

class _SplashMobile extends StatelessWidget {
  final VoidCallback onStart;
  const _SplashMobile({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.navy,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const MulgilBubbles(size: 64),
              const SizedBox(height: 20),
              const MulgilWordmark(),
              const SizedBox(height: 12),
              const Text(
                '흐르듯 공부하다',
                style: TextStyle(color: Color(0xFFc9d8e0), fontSize: 16),
              ),
              const SizedBox(height: 48),
              GestureDetector(
                onTap: onStart,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '시작하기',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SplashTablet extends StatelessWidget {
  final VoidCallback onStart;
  const _SplashTablet({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.navy,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const MulgilBubbles(size: 72),
              const SizedBox(height: 20),
              const MulgilWordmark(fontSize: 56),
              const SizedBox(height: 12),
              const Text(
                '흐르듯 공부하다',
                style: TextStyle(color: Color(0xFFc9d8e0), fontSize: 18),
              ),
            ],
          ),
          Container(
            width: 1,
            height: 220,
            margin: const EdgeInsets.symmetric(horizontal: 90),
            color: Colors.white.withValues(alpha: 0.15),
          ),
          SizedBox(
            width: 380,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _FeatureRow(
                  icon: '✎',
                  title: '필기부터 복습까지, 한 앱에서',
                  sub: '분산된 도구 없이 흐름을 이어가요',
                ),
                const SizedBox(height: 18),
                _FeatureRow(
                  icon: '⭐',
                  title: '교수님 강조 포인트를 놓치지 않아요',
                  sub: '필기 중 바로 마킹, AI가 기억해요',
                ),
                const SizedBox(height: 28),
                GestureDetector(
                  onTap: onStart,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '시작하기',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String icon, title, sub;
  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.teal,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            alignment: Alignment.center,
            child: Text(
              icon,
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.navy,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: const TextStyle(
                    color: Color(0xFF9fb6c4),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Schedule Setup ───────────────────────────────────

class _ScheduleStep extends StatefulWidget {
  final VoidCallback onNext;
  const _ScheduleStep({required this.onNext});

  @override
  State<_ScheduleStep> createState() => _ScheduleStepState();
}

class _ScheduleStepState extends State<_ScheduleStep> {
  void _openAddSubjectSheet() {
    showMulgilSheet(
      context,
      isScrollControlled: true,
      builder: (_) => CourseFormSheet(
        onAdd: (course, slots) => setState(() {
          MockData.courses.add(course);
          MockData.timetableSlots.addAll(slots);
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '온보딩 2/2',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.tealDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text('시간표를 등록해주세요', style: AppTextStyles.h2),
              const SizedBox(height: 4),
              const Text(
                '과목·교수님·시험 일정을 알면 리마인더를 딱 맞게 보내드려요',
                style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WeeklyTimetable(),
                      const SizedBox(height: 14),
                      ...MockData.courses.map(
                        (course) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _SubjectCard(
                            name: course.name,
                            professor: course.instructor ?? '',
                            time: MockData.slotsSummary(course.id),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _openAddSubjectSheet,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.navy),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '+ 과목 추가',
                    style: TextStyle(fontSize: 13, color: AppColors.navy),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              MulgilButton(label: '완료', onTap: widget.onNext),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final String name, professor, time;
  const _SubjectCard({
    required this.name,
    required this.professor,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            '$professor · $time',
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
