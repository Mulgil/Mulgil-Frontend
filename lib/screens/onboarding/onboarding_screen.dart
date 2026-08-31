import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/mulgil_logo.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/course_form_sheet.dart';
import '../../widgets/exam_form_sheet.dart';
import '../../widgets/weekly_timetable.dart';
import '../../data/mock_data.dart';
import '../../constants/routes.dart';
import '../../models/course.dart';
import '../../models/exam.dart';

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
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
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

  List<Exam> _examsFor(String courseName) =>
      MockData.exams.where((e) => e.courseName == courseName).toList();

  // Pass `existing` to edit that exam in place; omit it to add a new one —
  // a course can have zero, one, or several exams (중간/기말/퀴즈 등), so this
  // is called once per exam row rather than once per course.
  Future<void> _openExamSheet(Course course, {Exam? existing}) async {
    final result = await showMulgilSheet<Exam>(
      context,
      isScrollControlled: true,
      builder: (_) => _ExamQuickSheet(course: course, existing: existing),
    );
    if (result == null) return;
    setState(() {
      if (existing != null) {
        MockData.exams.replaceWhere((e) => e.id == existing.id, result);
      } else {
        MockData.exams.add(result);
      }
    });
  }

  Future<void> _deleteExam(Exam exam) async {
    await confirmDeleteExam(
      context,
      exam,
      () => setState(() => MockData.exams.removeWhere((e) => e.id == exam.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: MaxContentWidth(
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
                        Row(
                          children: [
                            const Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Text(
                                  '시간표',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                            MulgilRaisedAddButton(onTap: _openAddSubjectSheet),
                          ],
                        ),
                        const SizedBox(height: 10),
                        WeeklyTimetable(onChanged: () => setState(() {})),
                        const SizedBox(height: 20),
                        const SectionHeader(
                          title: '시험 일정',
                          subtitle: '과목을 탭해서 시험 날짜를 등록해주세요',
                        ),
                        ...MockData.courses.map(
                          (course) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _ExamScheduleCard(
                              course: course,
                              exams: _examsFor(course.name),
                              onAddExam: () => _openExamSheet(course),
                              onEditExam: (exam) =>
                                  _openExamSheet(course, existing: exam),
                              onDeleteExam: _deleteExam,
                            ),
                          ),
                        ),
                      ],
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
      ),
    );
  }
}

// A course can have zero, one, or several exams (중간고사·기말고사·퀴즈 등), so this
// renders the whole list for the course plus a row to add another — not a
// single exam slot per course.
class _ExamScheduleCard extends StatelessWidget {
  final Course course;
  final List<Exam> exams;
  final VoidCallback onAddExam;
  final ValueChanged<Exam> onEditExam;
  final ValueChanged<Exam> onDeleteExam;
  const _ExamScheduleCard({
    required this.course,
    required this.exams,
    required this.onAddExam,
    required this.onEditExam,
    required this.onDeleteExam,
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
            course.name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          if (course.instructor != null)
            Text(
              course.instructor!,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          const SizedBox(height: 10),
          if (exams.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                '등록된 시험이 없어요',
                style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
              ),
            )
          else
            ...exams.map(
              (exam) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () => onEditExam(exam),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${exam.title} · ${exam.examAt.month}월 ${exam.examAt.day}일',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.navy,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => onDeleteExam(exam),
                        behavior: HitTestBehavior.opaque,
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: AppColors.ink40,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          GestureDetector(
            onTap: onAddExam,
            behavior: HitTestBehavior.opaque,
            child: const Row(
              children: [
                Icon(Icons.add, size: 15, color: AppColors.tealDark),
                SizedBox(width: 4),
                Text(
                  '시험 추가',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.tealDark,
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

// Bottom sheet for setting a course's exam name + date during onboarding.
// Deliberately lighter than ExamFormSheet — no session-range picker, since
// onboarding runs before any lecture notes exist to pick a range from.
class _ExamQuickSheet extends StatefulWidget {
  final Course course;
  final Exam? existing;
  const _ExamQuickSheet({required this.course, required this.existing});

  @override
  State<_ExamQuickSheet> createState() => _ExamQuickSheetState();
}

class _ExamQuickSheetState extends State<_ExamQuickSheet> {
  static const _presets = ['중간고사', '기말고사', '퀴즈'];

  late final _titleCtrl = TextEditingController(
    text: widget.existing?.title ?? _presets.first,
  );
  late DateTime _examAt =
      widget.existing?.examAt ?? DateTime.now().add(const Duration(days: 14));

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _examAt,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _examAt = picked);
  }

  void _submit() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('시험 이름을 입력해주세요')));
      return;
    }
    final existing = widget.existing;
    Navigator.pop(
      context,
      Exam(
        id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        courseName: widget.course.name,
        title: title,
        examAt: _examAt,
        sessionTitles: existing?.sessionTitles ?? const [],
        hasPastExamAttached: existing?.hasPastExamAttached ?? false,
        summaryStatus: existing?.summaryStatus ?? AiJobStatus.none,
        quizStatus: existing?.quizStatus ?? AiJobStatus.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.course.name} 시험 일정',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: _presets
                .map(
                  (p) => MulgilChip(
                    label: p,
                    selected: _titleCtrl.text == p,
                    onTap: () => setState(() => _titleCtrl.text = p),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(
              labelText: '시험명',
              hintText: '예: 중간고사',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 14),
          MulgilCard(
            onTap: _pickDate,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '시험 날짜',
                  style: TextStyle(fontSize: 13, color: AppColors.ink60),
                ),
                Text(
                  '${_examAt.year}.${_examAt.month}.${_examAt.day}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          MulgilButton(
            label: widget.existing == null ? '등록' : '수정',
            onTap: _submit,
          ),
        ],
      ),
    );
  }
}
