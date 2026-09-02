import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common_widgets.dart';
import '../../../data/mock_data.dart';
import '../../../constants/routes.dart';
import '../../../models/exam.dart';

class UpcomingExamsCard extends StatefulWidget {
  final List<Exam>? exams;
  final ValueChanged<Exam>? onExamTap;

  const UpcomingExamsCard({super.key, this.exams, this.onExamTap});

  @override
  State<UpcomingExamsCard> createState() => _UpcomingExamsCardState();
}

class _UpcomingExamsCardState extends State<UpcomingExamsCard> {
  final _ctrl = PageController();
  int _page = 0;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exams = List.of(widget.exams ?? MockData.exams)
      ..sort((a, b) => a.examAt.compareTo(b.examAt));
    if (exams.isEmpty) return const SizedBox.shrink();
    // No onTap on the card itself — an InkWell wrapping the whole PageView
    // would fight the PageView's own drag recognizer and swallow swipes, so
    // each page gets its own tap target instead (see itemBuilder below).
    return MulgilCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '다가오는 시험일정',
                style: TextStyle(fontSize: 12, color: AppColors.ink60),
              ),
              if (exams.length > 1)
                Text(
                  '${_page + 1} / ${exams.length}',
                  style: const TextStyle(fontSize: 11, color: AppColors.ink40),
                ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 34,
            child: PageView.builder(
              controller: _ctrl,
              itemCount: exams.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (_, i) {
                final exam = exams[i];
                final dDay = exam.examAt.difference(DateTime.now()).inDays;
                final ValueChanged<Exam>? onTap =
                    widget.onExamTap ??
                    (widget.exams == null
                        ? (exam) =>
                              Navigator.of(context).pushNamed(AppRoutes.exams)
                        : null);
                return GestureDetector(
                  behavior: onTap == null
                      ? HitTestBehavior.deferToChild
                      : HitTestBehavior.opaque,
                  onTap: onTap == null ? null : () => onTap(exam),
                  child: Row(
                    children: [
                      ExamDayBadge(dDay: dDay < 0 ? 0 : dDay),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${exam.courseName} · ${exam.title}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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
