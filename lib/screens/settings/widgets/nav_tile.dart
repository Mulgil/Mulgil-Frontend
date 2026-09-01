import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class NavTile extends StatelessWidget {
  final String label;
  final String? sublabel;
  final IconData? icon;
  final bool showArrow;
  final VoidCallback? onTap;
  const NavTile({
    super.key,
    required this.label,
    this.sublabel,
    this.icon,
    this.showArrow = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: AppColors.textMuted),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (sublabel != null)
                        Text(
                          sublabel!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                    ],
                  ),
                ),
                if (showArrow)
                  const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: AppColors.textLight,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
