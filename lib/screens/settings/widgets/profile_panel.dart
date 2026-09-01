import 'package:flutter/material.dart';
import '../../../data/mock_data.dart';
import 'info_tile.dart';
import 'panel_title.dart';
import 'profile_card.dart';
import 'section_label.dart';

class SettingsProfilePanel extends StatelessWidget {
  const SettingsProfilePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final user = MockData.currentUser;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PanelTitle(title: '프로필'),
        const SizedBox(height: 20),
        const ProfileCard(),
        const SizedBox(height: 20),
        const SectionLabel(label: '학교 정보'),
        InfoTile(label: '학교', value: user.school),
        InfoTile(label: '학과', value: user.department),
        InfoTile(label: '학년', value: '${user.year}학년'),
      ],
    );
  }
}
