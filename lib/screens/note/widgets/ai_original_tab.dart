import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class OriginalTab extends StatelessWidget {
  final List<String> paragraphs;

  const OriginalTab({super.key, required this.paragraphs});

  @override
  Widget build(BuildContext context) {
    if (paragraphs.isEmpty) {
      return const Center(
        child: Text(
          '원본 필기가 아직 없어요',
          style: TextStyle(color: AppColors.textMuted),
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bg,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (i, paragraph) in paragraphs.indexed) ...[
            Text(
              paragraph,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.ink80,
                height: 1.7,
              ),
            ),
            if (i != paragraphs.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}
