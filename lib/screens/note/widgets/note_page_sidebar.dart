import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

// Its own gesture region, isolated from the drawing canvas.
class NotePageSidebar extends StatefulWidget {
  final int pageCount;
  final int currentPage;
  final bool visible;
  final ValueChanged<int> onPageSelected;
  final VoidCallback onCollapse;
  final VoidCallback onExpand;

  const NotePageSidebar({
    super.key,
    required this.pageCount,
    required this.currentPage,
    required this.visible,
    required this.onPageSelected,
    required this.onCollapse,
    required this.onExpand,
  });

  @override
  State<NotePageSidebar> createState() => _NotePageSidebarState();
}

class _NotePageSidebarState extends State<NotePageSidebar> {
  double _dragDx = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: (_) => _dragDx = 0,
      onHorizontalDragUpdate: (d) => _dragDx += d.delta.dx,
      onHorizontalDragEnd: (_) {
        if (_dragDx < -20 && widget.visible) widget.onCollapse();
        if (_dragDx > 20 && !widget.visible) widget.onExpand();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: widget.visible ? 100 : 18,
        decoration: const BoxDecoration(
          border: Border(right: BorderSide(color: AppColors.border)),
        ),
        child: widget.visible
            ? ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: widget.pageCount,
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => widget.onPageSelected(i),
                  child: Container(
                    height: 70,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: i == widget.currentPage
                          ? AppColors.tealSoft
                          : AppColors.surfaceAlt,
                      border: i == widget.currentPage
                          ? Border.all(color: AppColors.teal, width: 1.5)
                          : null,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${i + 1} 페이지',
                      style: TextStyle(
                        fontSize: 11,
                        color: i == widget.currentPage
                            ? AppColors.tealDark
                            : AppColors.ink40,
                      ),
                    ),
                  ),
                ),
              )
            : GestureDetector(
                onTap: widget.onExpand,
                child: const Center(
                  child: Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: AppColors.ink40,
                  ),
                ),
              ),
      ),
    );
  }
}
