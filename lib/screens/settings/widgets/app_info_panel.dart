import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/mulgil_logo.dart';
import 'nav_tile.dart';
import 'panel_title.dart';
import 'section_label.dart';

class SettingsAppInfoPanel extends StatelessWidget {
  final VoidCallback onContactSupport;
  final VoidCallback onBugReport;
  final VoidCallback onPrivacyPolicy;
  final VoidCallback onTermsOfService;
  final VoidCallback onOpenSourceLicenses;

  const SettingsAppInfoPanel({
    super.key,
    required this.onContactSupport,
    required this.onBugReport,
    required this.onPrivacyPolicy,
    required this.onTermsOfService,
    required this.onOpenSourceLicenses,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PanelTitle(title: '앱 정보'),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.navy,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: const Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MulgilWordmark(fontSize: 28),
                  SizedBox(height: 4),
                  Text(
                    '흐르듯 공부하다',
                    style: TextStyle(fontSize: 13, color: Color(0xFF9fb6c4)),
                  ),
                ],
              ),
              Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '버전 1.0.0',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '빌드 2026.08',
                    style: TextStyle(fontSize: 11, color: Color(0xFF9fb6c4)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const SectionLabel(label: '지원'),
        NavTile(
          label: '문의 · 피드백',
          icon: Icons.mail_outlined,
          sublabel: 'mulgil@gmail.com',
          onTap: onContactSupport,
        ),
        NavTile(
          label: '버그 신고',
          icon: Icons.bug_report_outlined,
          onTap: onBugReport,
        ),
        const SizedBox(height: 20),
        const SectionLabel(label: '법적 고지'),
        NavTile(
          label: '개인정보처리방침',
          icon: Icons.shield_outlined,
          onTap: onPrivacyPolicy,
        ),
        NavTile(
          label: '이용약관',
          icon: Icons.article_outlined,
          onTap: onTermsOfService,
        ),
        NavTile(
          label: '오픈소스 라이선스',
          icon: Icons.code_outlined,
          onTap: onOpenSourceLicenses,
        ),
      ],
    );
  }
}
