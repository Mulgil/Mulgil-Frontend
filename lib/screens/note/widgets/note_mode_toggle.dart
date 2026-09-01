import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class NoteModeToggle extends StatelessWidget {
  final bool isDrawing;
  final VoidCallback onSelectDrawing;
  final VoidCallback onSelectTyped;

  const NoteModeToggle({
    super.key,
    required this.isDrawing,
    required this.onSelectDrawing,
    required this.onSelectTyped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: ModeTab(
              label: '✎ 필기',
              selected: isDrawing,
              onTap: onSelectDrawing,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ModeTab(
              label: '⌨ 타이핑 노트',
              selected: !isDrawing,
              onTap: onSelectTyped,
            ),
          ),
        ],
      ),
    );
  }
}

class ModeTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const ModeTab({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.navy : AppColors.chip,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppColors.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
