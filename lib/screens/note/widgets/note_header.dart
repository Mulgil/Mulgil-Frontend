import 'package:flutter/material.dart';
import '../../../data/mock_data.dart';
import '../../../models/lecture.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common_widgets.dart';
import '../summary_detail_screen.dart';

class NoteDetailHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback onMenu;

  const NoteDetailHeader({
    super.key,
    required this.title,
    required this.onBack,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: onBack,
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(
                  Icons.arrow_back_ios,
                  size: 18,
                  color: AppColors.ink,
                ),
              ),
            ),
            const Spacer(),
            Column(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const Text(
                  '● 저장됨',
                  style: TextStyle(fontSize: 10, color: AppColors.teal),
                ),
              ],
            ),
            const Spacer(),
            GestureDetector(
              onTap: onMenu,
              child: const Text('☰', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

void showNoteDetailMenuSheet(
  BuildContext context, {
  required Lecture lecture,
  required bool hasPendingReview,
  required VoidCallback onOpenReview,
}) {
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
            title: const Text('원본 PDF 보기'),
            onTap: () {
              Navigator.pop(sheetCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('다운로드 URL 요청 중... (mock)')),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.auto_awesome_outlined,
              color: AppColors.navy,
            ),
            title: const Text('AI 요약으로 이동'),
            onTap: () {
              Navigator.pop(sheetCtx);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SummaryDetailScreen(
                    course: MockData.courseById(lecture.courseId)?.name ?? '',
                    lecture: lecture,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.edit_note_outlined,
              color: AppColors.navy,
            ),
            title: const Text('손글씨 확인 항목 다시 열기'),
            onTap: () {
              Navigator.pop(sheetCtx);
              if (!hasPendingReview) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('확인이 필요한 손글씨가 없어요')),
                );
              } else {
                onOpenReview();
              }
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
