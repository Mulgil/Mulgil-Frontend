import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// Generic confirm/warning dialog for reuse across the app (time conflicts,
// destructive actions, etc.) — returns true only if the user tapped confirm.
Future<bool> showMulgilConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = '확인',
  String cancelLabel = '취소',
  bool danger = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
      content: Text(message, style: const TextStyle(color: AppColors.textSecondary)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(cancelLabel)),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmLabel, style: TextStyle(color: danger ? AppColors.coral : AppColors.navy, fontWeight: FontWeight.w700)),
        ),
      ],
    ),
  );
  return result ?? false;
}
