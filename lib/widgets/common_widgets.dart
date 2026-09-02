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
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: builder,
  );
}

// Presents a multi-step flow (file upload wizards, etc.) as a tall modal sheet
// — dimmed background, rounded top corners — instead of a full route push, so
// stepping through pick/upload/confirm stages doesn't read as leaving the tab.
Future<T?> showMulgilModalScreen<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  double heightFraction = 0.9,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => SizedBox(
      height: MediaQuery.of(ctx).size.height * heightFraction,
      child: builder(ctx),
    ),
  );
}

// Reusable bordered surface card — replaces the ad hoc box-shadow `Container`s
// that used to be copy-pasted per screen, so every card in the app shares the
// same flat, bordered look instead of drifting into inconsistent shadows/radii.
class MulgilCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;

  const MulgilCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.lg);
    return Material(
      color: color ?? AppColors.surface,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: AppColors.border),
          ),
          child: child,
        ),
      ),
    );
  }
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
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: filled
              ? null
              : BoxDecoration(
                  border: Border.all(color: AppColors.navy),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
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

// Marks the week matching MockData.currentWeekLabel across the 필기/퀴즈/요약
// week lists, so students land near the right week without hunting for it.
class CurrentWeekBadge extends StatelessWidget {
  const CurrentWeekBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.tealSoft,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: const Text(
        '이번 주',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.tealDark,
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
      color: selected ? AppColors.navy : AppColors.chip,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: selected ? Colors.white : AppColors.ink60,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.1,
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
        backgroundColor: AppColors.border,
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
            color: value ? AppColors.teal : AppColors.ink20,
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
        color: AppColors.yellowSoft,
        borderRadius: BorderRadius.circular(AppRadius.sm),
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

Color examUrgencySoftColor(int dDay) {
  if (dDay <= 2) return AppColors.coralSoft;
  if (dDay <= 20) return AppColors.yellowSoft;
  return AppColors.greenSoft;
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
        color: examUrgencySoftColor(dDay),
        borderRadius: BorderRadius.circular(AppRadius.sm),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
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

// Title + optional muted subtitle, with either a custom trailing widget or a
// "전체 →" more-link — mirrors Festi's section-header pattern (bold title,
// quiet subtitle, chevron link) instead of the old label-only version.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final String? moreLabel;
  final VoidCallback? onMore;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.moreLabel,
    this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: AppColors.ink,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.ink60,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null)
            trailing!
          else if (onMore != null)
            GestureDetector(
              onTap: onMore,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    moreLabel ?? '전체',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink60,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: AppColors.ink60,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// Filled, elevated circular "+" button used to trigger add sheets (과목 추가,
// 시험 일정 추가, ...) next to a section label — icon-only so it reads as one
// clear affordance rather than a labeled outline button.
class MulgilRaisedAddButton extends StatelessWidget {
  final VoidCallback onTap;
  const MulgilRaisedAddButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.navy,
      shape: const CircleBorder(),
      elevation: 3,
      shadowColor: AppColors.navy.withValues(alpha: 0.45),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 30,
          height: 30,
          child: Icon(Icons.add, size: 18, color: Colors.white),
        ),
      ),
    );
  }
}

// Caps a single-column screen's content width and centers it on wide/tablet
// viewports — without this, a phone-style Column just stretches full-bleed
// on a tablet, which reads as broken rather than "responsive". Screens that
// already build a dedicated tablet layout (side-by-side panels, etc.) don't
// need this; it's for the plain single-column screens.
//
// Sized as a fraction of the screen (not a fixed pixel cap) so it scales with
// however wide the device/window actually is instead of looking arbitrarily
// narrow on one and cramped on another; phones are left untouched at 100%.
class MaxContentWidth extends StatelessWidget {
  final Widget child;
  final double widthFraction;
  const MaxContentWidth({
    super.key,
    required this.child,
    this.widthFraction = 0.95,
  });

  @override
  Widget build(BuildContext context) {
    // Measured off the constraints actually handed to this widget, not the
    // window's MediaQuery size — a screen embedded next to a sidebar (see
    // ShellScreen's tablet layout) only ever gets the remaining space, and
    // MediaQuery.size would still report the full window width regardless.
    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth;
        final isWide = available > 768;
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isWide ? available * widthFraction : double.infinity,
            ),
            child: Padding(
              padding: isWide
                  ? const EdgeInsets.symmetric(vertical: 24)
                  : EdgeInsets.zero,
              child: child,
            ),
          ),
        );
      },
    );
  }
}
