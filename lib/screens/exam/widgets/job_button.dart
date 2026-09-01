import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../models/exam.dart';

class JobButton extends StatelessWidget {
  final String label;
  final AiJobStatus status;
  final VoidCallback onTap;
  const JobButton({
    super.key,
    required this.label,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isRunning =
        status == AiJobStatus.queued || status == AiJobStatus.running;
    final isFailed = status == AiJobStatus.failed;
    final isDone = status == AiJobStatus.succeeded;

    final bg = isFailed
        ? AppColors.coralSoft
        : (isDone ? AppColors.tealSoft : AppColors.chip);
    final fg = isFailed
        ? AppColors.coral
        : (isDone ? AppColors.tealDark : AppColors.textPrimary);
    final text = isRunning
        ? '생성 중...'
        : (isFailed ? '실패 · 재시도' : (isDone ? '$label 완료 · 보기' : label));

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        onTap: isRunning ? null : onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: isRunning
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    text,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: fg,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
