import 'package:flutter/material.dart';

import '../../../data/auth_store.dart';
import 'info_tile.dart';
import 'panel_title.dart';
import 'profile_card.dart';
import 'section_label.dart';

class SettingsProfilePanel extends StatelessWidget {
  const SettingsProfilePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthStore.user;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PanelTitle(title: '프로필'),
        const SizedBox(height: 20),
        const ProfileCard(),
        const SizedBox(height: 20),
        const SectionLabel(label: '계정 정보'),
        InfoTile(label: '이름', value: user?.displayLabel ?? '사용자'),
        InfoTile(
          label: '이메일',
          value: user?.email.trim().isNotEmpty == true ? user!.email : '-',
        ),
      ],
    );
  }
}
