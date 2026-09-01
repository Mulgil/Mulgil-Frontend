import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../data/mock_data.dart';
import '../../../constants/routes.dart';
import 'header_icon_button.dart';

class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    final hasUnread = MockData.notifications.any((n) => !n.isRead);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        HeaderIconButton(
          icon: Icons.notifications_outlined,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.notifications),
        ),
        if (hasUnread)
          Positioned(
            right: 1,
            top: 1,
            child: IgnorePointer(
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.coral,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surfaceAlt, width: 1.5),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
