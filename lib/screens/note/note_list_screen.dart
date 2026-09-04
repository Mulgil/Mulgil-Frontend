import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../data/learning_domain_store.dart';
import '../../data/notes_store.dart';
import '../../models/course.dart';
import '../../models/lecture.dart';
import '../../constants/routes.dart';
import '../../widgets/session_week_list.dart';
import '../recording/recording_upload_screen.dart';
import 'pdf_upload_screen.dart';
import 'widgets/lecture_card.dart';
import 'widgets/session_materials_sheet.dart';

class NoteListScreen extends StatefulWidget {
  final String? initialCourse;
  const NoteListScreen({super.key, this.initialCourse});

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  int _filter = 0;
  String? _courseName;
  final _learningStore = LearningDomainStore.instance;

  static const _filters = ['전체', '필기있음', '퀴즈완료'];

  @override
  void initState() {
    super.initState();
    _courseName = widget.initialCourse;
    unawaited(_learningStore.load());
  }

  Course? _selectedCourse() {
    final courses = _learningStore.courses;
    if (courses.isEmpty) return null;
    final selectedName = _courseName;
    if (selectedName != null) {
      for (final course in courses) {
        if (course.name == selectedName) return course;
      }
    }
    return courses.first;
  }

  @override
  Widget build(BuildContext context) {
    final pad = context.isTablet ? 28.0 : 20.0;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(pad, pad, pad, 0),
          child: ListenableBuilder(
            listenable: _learningStore,
            builder: (context, _) {
              final selectedCourse = _selectedCourse();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const BackIfPushed(),
                      Expanded(child: _buildCourseHeader(selectedCourse)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filters
                          .asMap()
                          .entries
                          .map(
                            (e) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: MulgilChip(
                                label: e.value,
                                selected: _filter == e.key,
                                onTap: () => setState(() => _filter = e.key),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Expanded(child: _buildLectureList(selectedCourse)),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.navy,
        onPressed: () => _openAddSheet(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCourseHeader(Course? selectedCourse) {
    if (selectedCourse == null) {
      return Text('필기', style: AppTextStyles.h2);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CourseDropdown(
          selected: selectedCourse.name,
          options: _learningStore.courseNames,
          onChanged: (value) => setState(() => _courseName = value),
        ),
        if (selectedCourse.instructor != null)
          Text(
            selectedCourse.instructor!,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
      ],
    );
  }

  Widget _buildLectureList(Course? selectedCourse) {
    if (_learningStore.isLoading && !_learningStore.hasLoaded) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_learningStore.needsAuthentication ||
        _learningStore.errorMessage != null) {
      return _NoteStatusNotice(
        message:
            _learningStore.errorMessage ??
            'Google 로그인 토큰이 연결되면 서버 필기 목록을 불러와요.',
        onRetry: _learningStore.refresh,
      );
    }
    if (selectedCourse == null) {
      return const Center(
        child: Text(
          '등록된 과목이 없어요',
          style: TextStyle(color: AppColors.textMuted),
        ),
      );
    }
    return ListenableBuilder(
      listenable: NotesStore.instance,
      builder: (context, _) {
        final courseLectures = _courseLectures(selectedCourse);
        final lectures = _filteredLectures(courseLectures);
        if (lectures.isEmpty) {
          return Center(
            child: Text(
              courseLectures.isEmpty
                  ? '${selectedCourse.name} 과목에는 아직 차시가 없어요'
                  : '조건에 맞는 필기가 없어요',
              style: const TextStyle(color: AppColors.textMuted),
            ),
          );
        }
        return SessionWeekList(
          sessions: lectures,
          itemBuilder: (_, lecture) => LectureCard(
            lecture: lecture,
            showWeek: false,
            onTap: () => Navigator.of(
              context,
            ).pushNamed(AppRoutes.noteDetail, arguments: lecture),
          ),
        );
      },
    );
  }

  List<Lecture> _courseLectures(Course course) {
    final localNotes = NotesStore.instance.lectures
        .where((lecture) => lecture.courseId == course.id)
        .toList();
    final sessions = _learningStore.sessionsFor(course.id);
    return [...localNotes, ...sessions];
  }

  List<Lecture> _filteredLectures(List<Lecture> courseLectures) {
    switch (_filter) {
      case 1:
        return courseLectures.where((l) => l.done).toList();
      case 2:
        return courseLectures.where((l) => l.quiz != null).toList();
      default:
        return courseLectures;
    }
  }

  void _openAddSheet(BuildContext context) {
    final selectedCourse = _selectedCourse();
    if (selectedCourse == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('과목을 먼저 등록해주세요.')));
      return;
    }
    showMulgilSheet(
      context,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.picture_as_pdf_outlined,
                color: AppColors.navy,
              ),
              title: const Text('PDF 자료 업로드'),
              subtitle: const Text('강의자료·기출 PDF를 올려요 (최대 50MB, 150페이지)'),
              onTap: () async {
                Navigator.pop(sheetCtx);
                final outcome = await showMulgilModalScreen<PdfUploadOutcome>(
                  context,
                  builder: (_) => const PdfUploadScreen(),
                );
                if (!context.mounted || outcome == null) return;
                await showSessionMaterialsSheet(
                  context,
                  lecture: outcome.lecture,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.mic_none, color: AppColors.navy),
              title: const Text('강의 녹음 업로드'),
              subtitle: const Text('녹음 파일을 올리면 음성 인식 후 차시에 매핑해요 (최대 3시간)'),
              onTap: () {
                Navigator.pop(sheetCtx);
                showMulgilModalScreen(
                  context,
                  builder: (_) => const RecordingUploadScreen(),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.edit_note_outlined,
                color: AppColors.navy,
              ),
              title: const Text('새 노트 작성'),
              subtitle: const Text('타이핑 또는 필기로 바로 시작해요'),
              onTap: () {
                Navigator.pop(sheetCtx);
                _promptNewNoteTitle(context, selectedCourse);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _promptNewNoteTitle(BuildContext context, Course course) {
    final ctrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('새 노트'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: '노트 제목을 입력하세요'),
          onSubmitted: (_) => _createAndOpenNote(dialogCtx, ctrl.text, course),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => _createAndOpenNote(dialogCtx, ctrl.text, course),
            child: const Text('만들기'),
          ),
        ],
      ),
    );
  }

  void _createAndOpenNote(
    BuildContext dialogCtx,
    String rawTitle,
    Course course,
  ) {
    final title = rawTitle.trim().isEmpty ? '제목 없는 노트' : rawTitle.trim();
    Navigator.pop(dialogCtx);
    final lecture = NotesStore.instance.createNote(
      title: title,
      courseId: course.id,
    );
    Navigator.of(context).pushNamed(AppRoutes.noteDetail, arguments: lecture);
  }
}

class _NoteStatusNotice extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _NoteStatusNotice({required this.message, required this.onRetry});

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
