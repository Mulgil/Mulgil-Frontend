import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../data/mock_data.dart';
import '../../models/lecture.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  int _filter = 0;

  static const _filters = ['전체', '필기있음', '퀴즈완료'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('운영체제', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const Text('김민수 교수님', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _filters.asMap().entries.map((e) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: MulgilChip(
                      label: e.value,
                      selected: _filter == e.key,
                      onTap: () => setState(() => _filter = e.key),
                    ),
                  )).toList(),
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: ListView.separated(
                  itemCount: MockData.lectures.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (ctx, i) {
                    final lecture = MockData.lectures[i];
                    return GestureDetector(
                      onTap: lecture.done ? () => Navigator.of(context).pushNamed('/note/detail', arguments: lecture) : null,
                      child: _LectureCard(lecture: lecture),
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
        onPressed: () {},
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
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
        border: Border.all(color: const Color(0xFFEEEEEE)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Opacity(
        opacity: lecture.done ? 1.0 : 0.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${lecture.week} - ${lecture.title}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            Padding(
              padding: EdgeInsets.only(top: 2, bottom: lecture.done ? 8 : 0),
              child: Text(
                lecture.done ? "${lecture.date} · 필기 완료" : '필기 없음',
                style: const TextStyle(fontSize: 11, color: AppColors.textLight),
              ),
            ),
            if (lecture.done)
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: const Color(0xFFEEF7F8), borderRadius: BorderRadius.circular(8)),
                    child: Text('퀴즈 ${lecture.quiz}', style: const TextStyle(fontSize: 11, color: AppColors.tealDark)),
                  ),
                  const SizedBox(width: 8),
                  Text('⭐' * lecture.stars, style: const TextStyle(fontSize: 12)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
