import 'dart:async';

import 'package:flutter/material.dart';
import '../../data/learning_domain_store.dart';
import '../../models/course.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../models/exam.dart';
import 'widgets/exam_card.dart';

class ExamListScreen extends StatefulWidget {
  const ExamListScreen({super.key});

  @override
  State<ExamListScreen> createState() => _ExamListScreenState();
}

class _ExamListScreenState extends State<ExamListScreen> {
  final _learningStore = LearningDomainStore.instance;
  String? _courseIdFilter;
  String? _courseNameFilter;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    unawaited(_learningStore.load());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _readRouteFilter(ModalRoute.of(context)?.settings.arguments);
      _initialized = true;
    }
  }

  void _readRouteFilter(Object? arguments) {
    if (arguments is Exam) {
      _courseIdFilter = arguments.courseId;
      _courseNameFilter = arguments.courseName;
      return;
    }
    if (arguments is Course) {
      _courseIdFilter = arguments.id;
      _courseNameFilter = arguments.name;
      return;
    }
    if (arguments is String) {
      _courseNameFilter = arguments;
    }
  }

  List<Exam> get _exams {
    final exams = _learningStore.exams;
    if (_courseIdFilter != null) {
      return exams.where((e) => e.courseId == _courseIdFilter).toList();
    }
    if (_courseNameFilter != null) {
      return exams.where((e) => e.courseName == _courseNameFilter).toList();
    }
    return exams;
  }

  String get _title {
    final courseName = _courseNameFilter;
    return courseName == null ? '시험 관리' : '시험 관리 · $courseName';
  }

  void _attachPastExam(Exam _) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('기출 PDF 업로드 연결 후 사용할 수 있어요.')));
  }

  Future<void> _generate(Exam _, {required bool isSummary}) async {
    final label = isSummary ? '요약 생성' : '예상 문제 생성';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label API 연결 후 사용할 수 있어요.')));
  }

  void _openCreateSheet() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('시험 등록은 차시 선택 연결 후 서버에 저장할 수 있어요.')),
    );
  }

  void _openEditSheet(Exam _) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('시험 수정 API가 아직 없어 화면 저장을 비워뒀어요.')),
    );
  }

  void _deleteExam(Exam _) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('시험 삭제 API가 아직 없어 화면 저장을 비워뒀어요.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: MaxContentWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios,
                        size: 18,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_title, style: AppTextStyles.h2)),
                  ],
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: ListenableBuilder(
                    listenable: _learningStore,
                    builder: (context, _) {
                      final exams = _exams;
                      if (_learningStore.isLoading &&
                          !_learningStore.hasLoaded) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (_learningStore.needsAuthentication ||
                          _learningStore.errorMessage != null) {
                        return _ExamStatusNotice(
                          message:
                              _learningStore.errorMessage ??
                              'Google 로그인 토큰이 연결되면 서버 시험 일정을 불러와요.',
                          onRetry: _learningStore.refresh,
                        );
                      }
                      if (exams.isEmpty) {
                        return const Center(
                          child: Text(
                            '등록된 시험이 없어요',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        );
                      }
                      return ListView.separated(
                        itemCount: exams.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => ExamCard(
                          exam: exams[i],
                          onAttachPastExam: () => _attachPastExam(exams[i]),
                          onGenerateSummary: () =>
                              _generate(exams[i], isSummary: true),
                          onGenerateQuiz: () =>
                              _generate(exams[i], isSummary: false),
                          onEdit: () => _openEditSheet(exams[i]),
                          onDelete: () => _deleteExam(exams[i]),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                MulgilButton(label: '+ 시험 등록', onTap: _openCreateSheet),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExamStatusNotice extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ExamStatusNotice({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
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
