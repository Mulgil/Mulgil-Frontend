import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../models/lecture.dart';
import '../quiz/quiz_session_screen.dart';
import 'widgets/ai_summary_tab.dart';
import 'widgets/ai_mindmap_tab.dart';
import 'widgets/ai_original_tab.dart';

// The 요약/마인드맵/원본 필기 tab view for one specific week — pushed from
// AiSummaryScreen's week list (or straight from a note's "AI 요약" link).
class SummaryDetailScreen extends StatefulWidget {
  final String course;
  final Lecture lecture;
  const SummaryDetailScreen({
    super.key,
    required this.course,
    required this.lecture,
  });

  @override
  State<SummaryDetailScreen> createState() => _SummaryDetailScreenState();
}

class _SummaryDetailScreenState extends State<SummaryDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  void _openQuiz() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            QuizSessionScreen(course: widget.course, lecture: widget.lecture),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildTabBar(context),
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  SummaryTab(isTablet: context.isTablet, onTakeQuiz: _openQuiz),
                  const MindmapTab(),
                  const OriginalTab(),
                ],
              ),
            ),
            if (!context.isTablet)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: MulgilButton(label: '퀴즈 풀기', onTap: _openQuiz),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final pad = context.isTablet ? 28.0 : 20.0;
    return Container(
      padding: EdgeInsets.fromLTRB(pad, pad, pad, 0),
      child: Row(
        children: [
          const BackIfPushed(),
          Expanded(
            child: Text(
              'AI 요약 · ${widget.course} ${widget.lecture.week}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.tealSoft,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: const Text(
              '✨ AI 생성',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.tealDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    final pad = context.isTablet ? 28.0 : 20.0;
    return Container(
      margin: EdgeInsets.fromLTRB(pad, 12, pad, 0),
      decoration: BoxDecoration(
        color: AppColors.chip,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: TabBar(
        controller: _tab,
        indicator: BoxDecoration(
          color: AppColors.navy,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.ink60,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: '요약'),
          Tab(text: '마인드맵'),
          Tab(text: '원본 필기'),
        ],
      ),
    );
  }
}
