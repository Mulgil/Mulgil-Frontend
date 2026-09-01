import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../data/mock_data.dart';

class OriginalTab extends StatelessWidget {
  const OriginalTab({super.key});

  @override
  Widget build(BuildContext context) {
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
          for (final (i, p) in MockData.originalNoteParagraphs.indexed) ...[
            Text(
              p,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.ink80,
                height: 1.7,
              ),
            ),
            if (i != MockData.originalNoteParagraphs.length - 1)
              const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}
