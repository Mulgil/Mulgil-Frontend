import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class NoteDrawingFooter extends StatelessWidget {
  final int currentPage;
  final int pageCount;
  final VoidCallback? onPrevPage;
  final VoidCallback? onNextPage;

  const NoteDrawingFooter({
    super.key,
    required this.currentPage,
    required this.pageCount,
    required this.onPrevPage,
    required this.onNextPage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onPrevPage,
                child: Icon(
                  Icons.chevron_left,
                  size: 18,
                  color: onPrevPage != null ? AppColors.ink : AppColors.ink40,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${currentPage + 1} / $pageCount 페이지',
                style: const TextStyle(fontSize: 11, color: AppColors.ink40),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onNextPage,
                child: Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: onNextPage != null ? AppColors.ink : AppColors.ink40,
                ),
              ),
            ],
          ),
          const Text(
            '확대 100%',
            style: TextStyle(fontSize: 11, color: AppColors.ink40),
          ),
        ],
      ),
    );
  }
}
