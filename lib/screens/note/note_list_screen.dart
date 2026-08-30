import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../data/mock_data.dart';
import '../../data/notes_store.dart';
import '../../models/lecture.dart';

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
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
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
                    ).pushNamed('/exams', arguments: _course),
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
                    final lectures = _filteredLectures();
                    if (lectures.isEmpty) {
                      return const Center(
                        child: Text(
                          '해당하는 강의가 없어요',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      );
                    }
                    return ListView.separated(
                      itemCount: lectures.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (ctx, i) {
                        final lecture = lectures[i];
                        return GestureDetector(
                          onTap: lecture.done
                              ? () => Navigator.of(
                                  context,
                                ).pushNamed('/note/detail', arguments: lecture)
                              : null,
                          child: _LectureCard(lecture: lecture),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.navy,
        onPressed: () => _openAddSheet(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  List<Lecture> _filteredLectures() {
    final lectures = NotesStore.instance.lectures;
    switch (_filter) {
      case 1:
        return lectures.where((l) => l.done).toList();
      case 2:
        return lectures.where((l) => l.quiz != null).toList();
      default:
        return lectures;
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
                Navigator.of(context).pushNamed('/note/pdf-upload');
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
    final lecture = NotesStore.instance.createNote(title: title);
    Navigator.pop(dialogCtx);
    Navigator.of(context).pushNamed('/note/detail', arguments: lecture);
  }
}

class _LectureCard extends StatelessWidget {
  final Lecture lecture;
  const _LectureCard({required this.lecture});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEEEEEE)),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Opacity(
        opacity: lecture.done ? 1.0 : 0.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${lecture.week} - ${lecture.title}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 2, bottom: lecture.done ? 8 : 0),
              child: Text(
                lecture.done ? "${lecture.date} · 필기 완료" : '필기 없음',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textLight,
                ),
              ),
            ),
            if (lecture.done)
              Row(
                children: [
                  if (lecture.quiz != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF7F8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '퀴즈 ${lecture.quiz}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.tealDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (lecture.stars > 0)
                    Text(
                      '⭐' * lecture.stars,
                      style: const TextStyle(fontSize: 12),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
