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
    // Backend marks a generated result outdated once the exam's source
    // material changes after generation — this needs regeneration, not a
    // retry, so it gets its own look instead of falling back to "생성하기".
    final isOutdated = status == AiJobStatus.outdated;

    final bg = isFailed
        ? AppColors.coralSoft
        : (isDone
              ? AppColors.tealSoft
              : (isOutdated ? AppColors.yellowSoft : AppColors.chip));
    final fg = isFailed
        ? AppColors.coral
        : (isDone
              ? AppColors.tealDark
              : (isOutdated ? const Color(0xFFB15400) : AppColors.textPrimary));
    final text = isRunning
        ? '생성 중...'
        : (isFailed
              ? '실패 · 재시도'
              : (isDone
                    ? '$label 완료 · 보기'
                    : (isOutdated ? '자료가 바뀌었어요 · 다시 생성' : label)));

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
