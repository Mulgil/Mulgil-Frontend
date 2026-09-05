import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class NoteToolbar extends StatelessWidget {
  final int selectedTool;
  final ValueChanged<int> onToolSelected;
  final bool canUndo;
  final bool canRedo;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final double penWidth;
  final ValueChanged<double> onPenWidthSelected;
  final double highlighterWidth;
  final ValueChanged<double> onHighlighterWidthSelected;
  final int lastEraserTool;

  const NoteToolbar({
    super.key,
    required this.selectedTool,
    required this.onToolSelected,
    required this.canUndo,
    required this.canRedo,
    required this.onUndo,
    required this.onRedo,
    required this.penWidth,
    required this.onPenWidthSelected,
    required this.highlighterWidth,
    required this.onHighlighterWidthSelected,
    required this.lastEraserTool,
  });

  static const penSizes = [
    (label: '얇게', width: 1.5),
    (label: '보통', width: 2.5),
    (label: '굵게', width: 4.0),
  ];
  static const highlighterSizes = [
    (label: '얇게', width: 10.0),
    (label: '보통', width: 16.0),
    (label: '굵게', width: 22.0),
  ];

  Future<T?> _showMenuBelow<T>(
    BuildContext buttonContext,
    List<PopupMenuEntry<T>> items,
  ) {
    final box = buttonContext.findRenderObject() as RenderBox;
    final overlay =
        Overlay.of(buttonContext).context.findRenderObject() as RenderBox;
    final topLeft = box.localToGlobal(
      Offset(0, box.size.height + 4),
      ancestor: overlay,
    );
    final bottomRight = box.localToGlobal(
      box.size.bottomRight(Offset.zero) + const Offset(0, 4),
      ancestor: overlay,
    );
    return showMenu<T>(
      context: buttonContext,
      position: RelativeRect.fromRect(
        Rect.fromPoints(topLeft, bottomRight),
        Offset.zero & overlay.size,
      ),
      items: items,
    );
  }

  Future<void> _showSizeMenu(
    BuildContext buttonContext,
    List<({String label, double width})> sizes,
    int toolIndex,
    ValueChanged<double> onSelected,
  ) async {
    final selected = await _showMenuBelow<double>(
      buttonContext,
      sizes
          .map((s) => PopupMenuItem(value: s.width, child: Text(s.label)))
          .toList(),
    );
    if (selected != null) {
      onSelected(selected);
      onToolSelected(toolIndex);
    }
  }

  Future<void> _showEraserMenu(BuildContext buttonContext) async {
    final selected = await _showMenuBelow<int>(buttonContext, const [
      PopupMenuItem(value: 2, child: Text('영역 지우개')),
      PopupMenuItem(value: 3, child: Text('한 획 지우개')),
    ]);
    if (selected != null) onToolSelected(selected);
  }

  Widget _buildButton({
    required String icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
    void Function(BuildContext buttonContext)? onLongPress,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Builder(
        builder: (buttonContext) => GestureDetector(
          onTap: onTap,
          onLongPress: onLongPress == null
              ? null
              : () => onLongPress(buttonContext),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? AppColors.navy : AppColors.chip,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              '$icon $label',
              style: TextStyle(
                fontSize: 13,
                color: selected ? Colors.white : AppColors.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eraserIcon = lastEraserTool == 3 ? '⌦' : '⌫';
    final eraserLabel = lastEraserTool == 3 ? '한 획 지우개' : '영역 지우개';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildButton(
              icon: '✎',
              label: '펜',
              selected: selectedTool == 0,
              onTap: () => onToolSelected(0),
              onLongPress: (ctx) =>
                  _showSizeMenu(ctx, penSizes, 0, onPenWidthSelected),
            ),
            _buildButton(
              icon: '▮',
              label: '형광펜',
              selected: selectedTool == 1,
              onTap: () => onToolSelected(1),
              onLongPress: (ctx) => _showSizeMenu(
                ctx,
                highlighterSizes,
                1,
                onHighlighterWidthSelected,
              ),
            ),
            _buildButton(
              icon: eraserIcon,
              label: eraserLabel,
              selected: selectedTool == 2 || selectedTool == 3,
              onTap: () => onToolSelected(lastEraserTool),
              onLongPress: (ctx) => _showEraserMenu(ctx),
            ),
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.chip,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Text('가 텍스트', style: TextStyle(fontSize: 13)),
            ),
            const SizedBox(width: 6),
            _buildButton(
              icon: '★',
              label: '교수 언급',
              selected: selectedTool == 4,
              onTap: () => onToolSelected(4),
            ),
          ],
        ),
      ),
    );
  }
}
