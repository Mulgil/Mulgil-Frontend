import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common_widgets.dart';

class NoteCard extends StatelessWidget {
  final String subject, title, time;
  final double progress;
  final VoidCallback? onTap;
  const NoteCard({
    super.key,
    required this.subject,
    required this.title,
    required this.time,
    required this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MulgilCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                subject,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.teal,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                time,
                style: const TextStyle(fontSize: 11, color: AppColors.ink40),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(title, style: AppTextStyles.body),
          const SizedBox(height: 8),
          MulgilProgressBar(value: progress),
        ],
      ),
    );
  }
}
