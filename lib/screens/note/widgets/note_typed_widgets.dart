import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class NoteTypedEditor extends StatelessWidget {
  final TextEditingController controller;

  const NoteTypedEditor({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: controller,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        style: const TextStyle(fontSize: 14, color: AppColors.ink, height: 1.6),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: '마크다운으로 정리해보세요...',
        ),
      ),
    );
  }
}

class NoteTypedFooter extends StatelessWidget {
  final int wordCount;
  final bool saving;

  const NoteTypedFooter({
    super.key,
    required this.wordCount,
    required this.saving,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$wordCount 단어',
            style: const TextStyle(fontSize: 11, color: AppColors.ink40),
          ),
          Text(
            saving ? '저장 중...' : '● 저장됨',
            style: TextStyle(
              fontSize: 11,
              color: saving ? AppColors.ink40 : AppColors.teal,
            ),
          ),
        ],
      ),
    );
  }
}
