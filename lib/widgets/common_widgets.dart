import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// Shared bottom-sheet chrome (white background, rounded top corners) used across
// add/edit/menu sheets throughout the app.
Future<T?> showMulgilSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool isScrollControlled = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: builder,
  );
}

class MulgilButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool filled;
  final Color? fillColor;
  final Color? textColor;

  const MulgilButton({
    super.key,
    required this.label,
    this.onTap,
    this.filled = true,
    this.fillColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final bg = fillColor ?? (filled ? AppColors.navy : Colors.transparent);
    final fg = textColor ?? (filled ? Colors.white : AppColors.navy);
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: filled
              ? null
              : BoxDecoration(
                  border: Border.all(color: AppColors.navy),
                  borderRadius: BorderRadius.circular(14),
                ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}

class MulgilChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const MulgilChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.navy : const Color(0xFFF2F2F2),
      borderRadius: BorderRadius.circular(100),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: selected ? Colors.white : AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class MulgilProgressBar extends StatelessWidget {
  final double value;
  final Color color;
  const MulgilProgressBar({
    super.key,
    required this.value,
    this.color = AppColors.teal,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 5,
        backgroundColor: const Color(0xFFEEF0F2),
        color: color,
      ),
    );
  }
}

class MulgilToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  const MulgilToggle({super.key, required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onChanged?.call(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 40,
          height: 24,
          decoration: BoxDecoration(
            color: value ? AppColors.teal : const Color(0xFFD8DDE1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.all(3),
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class StarBadge extends StatelessWidget {
  final int stars;
  const StarBadge({super.key, required this.stars});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text('⭐' * stars, style: const TextStyle(fontSize: 11)),
    );
  }
}

// D-2 이하는 임박(빨강), D-3~D-20은 준비 기간(노랑), D-21 이상은 여유(초록).
Color examUrgencyColor(int dDay) {
  if (dDay <= 2) return AppColors.coral;
  if (dDay <= 20) return AppColors.yellow;
  return AppColors.green;
}

class ExamDayBadge extends StatelessWidget {
  final int dDay;
  const ExamDayBadge({super.key, required this.dDay});

  @override
  Widget build(BuildContext context) {
    final color = examUrgencyColor(dDay);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        'D-$dDay',
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }
}

// Shows a back arrow only when there's actually a previous route to pop to —
// several screens double as both a shell tab (no back needed) and a pushed
// detail screen (needs back), so a hardcoded arrow is wrong in one context or the other.
class BackIfPushed extends StatelessWidget {
  const BackIfPushed({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Navigator.canPop(context)) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back_ios,
            size: 18,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

class CourseDropdown extends StatelessWidget {
  final String selected;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final double fontSize;
  const CourseDropdown({
    super.key,
    required this.selected,
    required this.options,
    required this.onChanged,
    this.fontSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onChanged,
      offset: const Offset(0, 36),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (_) =>
          options.map((o) => PopupMenuItem(value: o, child: Text(o))).toList(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              selected,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 2),
          const Icon(Icons.expand_more, size: 20, color: AppColors.textPrimary),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const SectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
