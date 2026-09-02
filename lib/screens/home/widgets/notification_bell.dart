import 'package:flutter/material.dart';

import '../../../constants/routes.dart';
import 'header_icon_button.dart';

class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context) => HeaderIconButton(
    icon: Icons.notifications_outlined,
    onTap: () => Navigator.of(context).pushNamed(AppRoutes.notifications),
  );
}
