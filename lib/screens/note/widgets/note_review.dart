import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common_widgets.dart';

// Mirrors PATCH /handwriting-blocks/{id}/confirm — OCR confidence < 0.80 needs
// user confirm before AI can use it.
class PendingHandwritingBlock {
  final String id;
  final String guess;
  PendingHandwritingBlock({required this.id, required this.guess});
}

class NoteReviewBanner extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const NoteReviewBanner({super.key, required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: AppColors.yellowSoft,
        child: Row(
          children: [
            const Icon(Icons.edit_note, size: 16, color: Color(0xFFB15400)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '손글씨 확인이 필요해요 ($count건) · 확인 전까지 AI 생성에 반영되지 않아요',
                style: const TextStyle(fontSize: 12, color: Color(0xFFB15400)),
              ),
            ),
            const Icon(Icons.chevron_right, size: 16, color: Color(0xFFB15400)),
          ],
        ),
      ),
    );
  }
}

void showNoteReviewSheet(
  BuildContext context, {
  required List<PendingHandwritingBlock> pendingReview,
  required void Function(PendingHandwritingBlock block) onBlockConfirmed,
}) {
  showMulgilSheet(
    context,
    isScrollControlled: true,
    builder: (_) => StatefulBuilder(
      builder: (sheetCtx, sheetSetState) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(sheetCtx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('손글씨 인식 확인', style: AppTextStyles.h3),
              const SizedBox(height: 4),
              const Text(
                'AI가 읽은 내용이 맞는지 확인하고 필요하면 수정해주세요',
                style: TextStyle(fontSize: 12, color: AppColors.ink60),
              ),
              const SizedBox(height: 16),
              ...pendingReview.map(
                (b) => ReviewBlockField(
                  block: b,
                  onConfirm: (text) {
                    onBlockConfirmed(b);
                    sheetSetState(() {});
                    if (pendingReview.isEmpty) Navigator.pop(sheetCtx);
                  },
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

class ReviewBlockField extends StatefulWidget {
  final PendingHandwritingBlock block;
  final ValueChanged<String> onConfirm;
  const ReviewBlockField({
    super.key,
    required this.block,
    required this.onConfirm,
  });

  @override
  State<ReviewBlockField> createState() => _ReviewBlockFieldState();
}

class _ReviewBlockFieldState extends State<ReviewBlockField> {
  late final _ctrl = TextEditingController(text: widget.block.guess);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _ctrl,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'AI 인식 결과 (신뢰도 낮음)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          ),
          const SizedBox(height: 8),
          MulgilButton(label: '확인', onTap: () => widget.onConfirm(_ctrl.text)),
        ],
      ),
    );
  }
}
