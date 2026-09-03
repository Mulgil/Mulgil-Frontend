import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../../../data/auth_store.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthStore.user;
    final name = user?.displayLabel ?? '사용자';
    final subtitle = user?.email.trim().isNotEmpty == true
        ? user!.email
        : 'Google 계정으로 로그인됨';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.teal,
            child: Text(
              user?.avatarInitial ?? '물',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Color(0xFF9fb6c4)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
