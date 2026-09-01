import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class ChoiceButton extends StatelessWidget {
  final int index;
  final String label;
  final bool selected;
  final bool wrong;
  final VoidCallback? onTap;
  const ChoiceButton({
    super.key,
    required this.index,
    required this.label,
    required this.selected,
    required this.wrong,
    required this.onTap,
  });

  static const _letters = ['A', 'B', 'C', 'D'];

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? AppColors.tealDark
        : (wrong ? AppColors.coralSoft : AppColors.surface);
    final border = selected
        ? AppColors.tealDark
        : (wrong ? AppColors.coral : AppColors.border);
    final fg = selected ? Colors.white : AppColors.ink;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border, width: 1.5),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: 0.25)
                    : AppColors.chip,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                _letters[index],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: fg,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OxButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const OxButton({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
