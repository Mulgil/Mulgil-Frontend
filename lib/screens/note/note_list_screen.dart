import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../data/mock_data.dart';
import '../../data/notes_store.dart';
import '../../models/lecture.dart';
import '../../constants/routes.dart';
import 'widgets/lecture_card.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  int _filter = 0;
  String _course = MockData.courseNames.first;

  static const _filters = ['전체', '필기있음', '퀴즈완료'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: MaxContentWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const BackIfPushed(),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CourseDropdown(
                            selected: _course,
                            options: MockData.courseNames,
                            onChanged: (v) => setState(() => _course = v),
                          ),
                          Text(
                            MockData.courseProfessors[_course] ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.exams, arguments: _course),
                      icon: const Icon(Icons.event_note, size: 16),
                      label: const Text('시험', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.navy,
                        side: const BorderSide(color: AppColors.navy),
                      ),
                    ),
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
                Expanded(
                  child: ListenableBuilder(
                    listenable: NotesStore.instance,
                    builder: (context, _) {
                      final courseLectures = _courseLectures();
                      final lectures = _filteredLectures(courseLectures);
                      if (lectures.isEmpty) {
                        return Center(
                          child: Text(
                            courseLectures.isEmpty
                                ? '$_course 과목에는 아직 필기가 없어요'
                                : '조건에 맞는 필기가 없어요',
                            style: const TextStyle(color: AppColors.textMuted),
                          ),
                        );
                      }
                      return ListView.separated(
                        itemCount: lectures.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (ctx, i) {
                          final lecture = lectures[i];
                          return LectureCard(
                            lecture: lecture,
                            onTap: lecture.done
                                ? () => Navigator.of(context).pushNamed(
                                    AppRoutes.noteDetail,
                                    arguments: lecture,
                                  )
                                : null,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
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

  // Notes belonging to the selected course, before the 전체/필기있음/퀴즈완료 tab
  // filter — kept separate so the empty state can tell "이 과목엔 필기가 아예
  // 없음" apart from "필터 조건에 맞는 게 없음".
  List<Lecture> _courseLectures() {
    final courseId = MockData.courseByName(_course)?.id;
    return NotesStore.instance.lectures
        .where((l) => l.courseId == courseId)
        .toList();
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
              onTap: () {
                Navigator.pop(sheetCtx);
                Navigator.of(context).pushNamed(AppRoutes.notePdfUpload);
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
                _promptNewNoteTitle(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _promptNewNoteTitle(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('새 노트'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: '노트 제목을 입력하세요'),
          onSubmitted: (_) => _createAndOpenNote(dialogCtx, ctrl.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => _createAndOpenNote(dialogCtx, ctrl.text),
            child: const Text('만들기'),
          ),
        ],
      ),
    );
  }

  void _createAndOpenNote(BuildContext dialogCtx, String rawTitle) {
    final title = rawTitle.trim().isEmpty ? '제목 없는 노트' : rawTitle.trim();
    final courseId = MockData.courseByName(_course)?.id;
    Navigator.pop(dialogCtx);
    if (courseId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('과목을 다시 선택해주세요')));
      return;
    }
    final lecture = NotesStore.instance.createNote(
      title: title,
      courseId: courseId,
    );
    Navigator.of(context).pushNamed(AppRoutes.noteDetail, arguments: lecture);
  }
}