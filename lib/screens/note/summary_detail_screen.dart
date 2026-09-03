import 'package:flutter/material.dart';

import '../../data/api_client.dart';
import '../../data/app_services.dart';
import '../../data/learning_domain_api.dart';
import '../../data/notes_store.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../models/lecture.dart';
import '../quiz/quiz_session_screen.dart';
import 'widgets/ai_summary_tab.dart';
import 'widgets/ai_mindmap_tab.dart';
import 'widgets/ai_original_tab.dart';

// The 요약/마인드맵/원본 필기 tab view for one specific week.
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
  late Future<SessionSummary?> _summaryLoad;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _summaryLoad = _loadSummary();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<SessionSummary?> _loadSummary() async {
    try {
      _loadError = null;
      return await AppServices.learningDomain.getSessionSummary(
        widget.lecture.id,
      );
    } on ApiException catch (error) {
      _loadError = error.statusCode == 404 || error.statusCode == 409
          ? 'AI 요약이 아직 준비되지 않았어요.'
          : error.message;
    } on Exception {
      _loadError = 'AI 요약을 불러오지 못했어요.';
    }
    return null;
  }

  void _retry() {
    setState(() => _summaryLoad = _loadSummary());
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
        child: FutureBuilder<SessionSummary?>(
          future: _summaryLoad,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final summary = snapshot.data;
            final error = _loadError;
            if (summary == null || error != null) {
              return Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: _SummaryDetailNotice(
                      message: error ?? 'AI 요약이 아직 준비되지 않았어요.',
                      onRetry: _retry,
                    ),
                  ),
                ],
              );
            }
            return Column(
              children: [
                _buildHeader(context),
                _buildTabBar(context),
                Expanded(
                  child: TabBarView(
                    controller: _tab,
                    children: [
                      SummaryTab(
                        isTablet: context.isTablet,
                        items: summary.items,
                        onTakeQuiz: _openQuiz,
                      ),
                      MindmapTab(
                        centerLabel: widget.lecture.title,
                        nodeLabels: summary.mindmapNodeLabels,
                      ),
                      OriginalTab(paragraphs: _originalParagraphs()),
                    ],
                  ),
                ),
                if (!context.isTablet)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: MulgilButton(label: '퀴즈 풀기', onTap: _openQuiz),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<String> _originalParagraphs() {
    final body = NotesStore.instance
        .contentFor(widget.lecture)
        .typedText
        .trim();
    if (body.isEmpty) return const [];
    return body
        .split(RegExp(r'(?:\r?\n\s*){2,}'))
        .map((paragraph) => paragraph.trim())
        .where((paragraph) => paragraph.isNotEmpty)
        .toList();
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
              'AI 생성',
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

class _SummaryDetailNotice extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _SummaryDetailNotice({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            TextButton(onPressed: onRetry, child: const Text('다시 시도')),
          ],
        ),
      ),
    );
  }
}
