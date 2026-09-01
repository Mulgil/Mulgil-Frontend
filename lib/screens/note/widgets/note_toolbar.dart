import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class NoteToolbar extends StatelessWidget {
  final int selectedTool;
  final ValueChanged<int> onToolSelected;
  final bool canUndo;
  final bool canRedo;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final bool showProfTag;
  final VoidCallback onToggleProfTag;

  const NoteToolbar({
    super.key,
    required this.selectedTool,
    required this.onToolSelected,
    required this.canUndo,
    required this.canRedo,
    required this.onUndo,
    required this.onRedo,
    required this.showProfTag,
    required this.onToggleProfTag,
  });

  static const _tools = [
    {'icon': '✎', 'label': '펜', 'color': AppColors.navy},
    {'icon': '▮', 'label': '형광펜', 'color': Colors.transparent},
    {'icon': '⌫', 'label': '영역 지우개', 'color': Colors.transparent},
    {'icon': '⌦', 'label': '한 획 지우개', 'color': Colors.transparent},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ..._tools.asMap().entries.map((e) {
              final sel = selectedTool == e.key;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: GestureDetector(
                  onTap: () => onToolSelected(e.key),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.navy : AppColors.chip,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      '${e.value['icon']} ${e.value['label']}',
                      style: TextStyle(
                        fontSize: 13,
                        color: sel ? Colors.white : AppColors.ink,
                      ),
                    ),
                  ),
                ),
              );
            }),
            Container(
              width: 1,
              height: 24,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              color: AppColors.border,
            ),
            GestureDetector(
              onTap: canUndo ? onUndo : null,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.chip,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  Icons.undo,
                  size: 18,
                  color: canUndo ? AppColors.ink : AppColors.ink40,
                ),
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: canRedo ? onRedo : null,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.chip,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  Icons.redo,
                  size: 18,
                  color: canRedo ? AppColors.ink : AppColors.ink40,
                ),
              ),
            ),
            Container(
              width: 1,
              height: 24,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              color: AppColors.border,
            ),
            GestureDetector(
              onTap: onToggleProfTag,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: showProfTag ? AppColors.coral : AppColors.chip,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  '교수★',
                  style: TextStyle(
                    fontSize: 13,
                    color: showProfTag ? Colors.white : AppColors.ink,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.chip,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Text('가 텍스트', style: TextStyle(fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }
}
