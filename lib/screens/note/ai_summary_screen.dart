import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../data/mock_data.dart';
import '../../constants/routes.dart';
import 'widgets/ai_summary_tab.dart';
import 'widgets/ai_mindmap_tab.dart';
import 'widgets/ai_original_tab.dart';

class AiSummaryScreen extends StatefulWidget {
  const AiSummaryScreen({super.key});

  @override
  State<AiSummaryScreen> createState() => _AiSummaryScreenState();
}

class _AiSummaryScreenState extends State<AiSummaryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  String _course = MockData.courseNames.first;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  SummaryTab(isTablet: context.isTablet),
                  const MindmapTab(),
                  const OriginalTab(),
                ],
              ),
            ),
            if (!context.isTablet)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: MulgilButton(
                  label: '퀴즈 풀기',
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.quiz),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back_ios,
              size: 18,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'AI 요약 · ',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          CourseDropdown(
            selected: _course,
            options: MockData.courseNames,
            onChanged: (v) => setState(() => _course = v),
            fontSize: 15,
          ),
          const Expanded(
            child: Text(
              ' 2주차',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
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

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
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
