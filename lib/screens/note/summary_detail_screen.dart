import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/api_client.dart';
import '../../data/app_services.dart';
import '../../data/learning_domain_api.dart';
import '../../data/notes_store.dart';
import '../../data/resource_upload_api.dart';
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
  final LearningDomainApi? api;
  final ResourceUploadApi? jobsApi;

  const SummaryDetailScreen({
    super.key,
    required this.course,
    required this.lecture,
    this.api,
    this.jobsApi,
  });

  @override
  State<SummaryDetailScreen> createState() => _SummaryDetailScreenState();
}

class _SummaryDetailScreenState extends State<SummaryDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  late final LearningDomainApi _api;
  late final ResourceUploadApi _jobsApi;
  late Future<_SummaryLoadResult> _summaryLoad;
  Timer? _pollTimer;
  List<SessionProcessingJob> _jobs = const [];
  int _jobsRequestId = 0;
  _SummarySource _source = _SummarySource.review;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _api = widget.api ?? AppServices.learningDomain;
    _jobsApi = widget.jobsApi ?? AppServices.resourceUpload;
    _summaryLoad = _loadSummary(_source);
    unawaited(_loadJobs());
  }

  @override
  void dispose() {
    _tab.dispose();
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<_SummaryLoadResult> _loadSummary(_SummarySource source) async {
    try {
      final summary = await _api.getSessionSummary(
        widget.lecture.id,
        type: source.apiValue,
      );
      return _SummaryLoadResult(summary: summary);
    } on ApiException catch (error) {
      return _SummaryLoadResult(
        error: error.code == 'EMBEDDING_NOT_READY'
            ? 'AI 콘텐츠를 준비하고 있어요.'
            : error.statusCode == 404 || error.statusCode == 409
            ? 'AI 요약이 아직 준비되지 않았어요.'
            : 'AI 요약을 불러오지 못했어요.',
      );
    } on Exception {
      return const _SummaryLoadResult(error: 'AI 요약을 불러오지 못했어요.');
    }
  }

  Future<void> _loadJobs() async {
    final requestId = ++_jobsRequestId;
    try {
      final jobs = await _jobsApi.listSessionJobs(widget.lecture.id);
      if (!mounted || requestId != _jobsRequestId) return;
      setState(() => _jobs = jobs);
    } on Exception {
      // Artifact status is supplementary; summary content remains readable.
    } finally {
      if (mounted && requestId == _jobsRequestId) _schedulePolling();
    }
  }

  void _schedulePolling() {
    _pollTimer?.cancel();
    if (_jobs.any((job) => job.isSessionGeneration && job.status.isActive)) {
      _pollTimer = Timer(const Duration(seconds: 3), _loadJobs);
    }
  }

  void _retry() {
    setState(() => _summaryLoad = _loadSummary(_source));
    unawaited(_loadJobs());
  }

  void _selectSource(_SummarySource source) {
    if (_source == source) return;
    setState(() {
      _source = source;
      _summaryLoad = _loadSummary(source);
    });
    unawaited(_loadJobs());
  }

  void _openQuiz() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuizSessionScreen(
          course: widget.course,
          lecture: widget.lecture,
          summaryType: _source.apiValue,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<_SummaryLoadResult>(
          future: _summaryLoad,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final result = snapshot.data;
            final summary = result?.summary;
            final error = result?.error;
            if (summary == null || error != null) {
              return Column(
                children: [
                  _buildHeader(context),
                  _buildSourceSelector(context),
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
                _buildSourceSelector(context),
                _buildTabBar(context),
                Expanded(
                  child: TabBarView(
                    controller: _tab,
                    children: [
                      SummaryTab(
                        isTablet: context.isTablet,
                        items: summary.items,
                        onTakeQuiz: _openQuiz,
                        generationJob: _artifactJob('quiz'),
                      ),
                      MindmapTab(
                        centerLabel: widget.lecture.title,
                        nodeLabels: summary.mindmapNodeLabels,
                        generationJob: _artifactJob('mindmap'),
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

  SessionProcessingJob? _artifactJob(String artifact) {
    final type = '${_source.apiValue}_${artifact}_generate';
    SessionProcessingJob? latest;
    for (final job in _jobs) {
      if (job.type != type) continue;
      if (latest == null || job.createdAt.isAfter(latest.createdAt)) {
        latest = job;
      }
    }
    return latest;
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

  Widget _buildSourceSelector(BuildContext context) {
    final pad = context.isTablet ? 28.0 : 20.0;
    return Container(
      margin: EdgeInsets.fromLTRB(pad, 12, pad, 0),
      decoration: BoxDecoration(
        color: AppColors.chip,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: _SummarySource.values
            .map(
              (source) => Expanded(
                child: TextButton(
                  onPressed: () => _selectSource(source),
                  style: TextButton.styleFrom(
                    backgroundColor: _source == source
                        ? AppColors.tealSoft
                        : Colors.transparent,
                    foregroundColor: _source == source
                        ? AppColors.tealDark
                        : AppColors.ink60,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                  child: Text(source.label),
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _SummaryLoadResult {
  final SessionSummary? summary;
  final String? error;

  const _SummaryLoadResult({this.summary, this.error});
}

enum _SummarySource {
  preview('preview', '예습'),
  review('review', '복습');

  final String apiValue;
  final String label;

  const _SummarySource(this.apiValue, this.label);
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
