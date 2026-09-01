import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/course_form_sheet.dart';
import '../../widgets/weekly_timetable.dart';
import '../../widgets/exam_form_sheet.dart';
import '../../data/mock_data.dart';
import '../../data/auth_store.dart';
import '../../models/exam.dart';
import 'legal_document_screen.dart';
import '../../constants/routes.dart';
import 'widgets/app_info_panel.dart';
import 'widgets/exam_schedule_tile.dart';
import 'widgets/legal_texts.dart';
import 'widgets/nav_tile.dart';
import 'widgets/profile_card.dart';
import 'widgets/profile_panel.dart';
import 'widgets/section_label.dart';
import 'widgets/subjects_panel.dart';
import 'widgets/tablet_side_item.dart';

enum _SettingsTab { profile, subjects, appInfo }

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  _SettingsTab _tab = _SettingsTab.profile;

  void _openAddSubjectSheet() {
    showMulgilSheet(
      context,
      isScrollControlled: true,
      builder: (_) => CourseFormSheet(
        onAdd: (course, slots) => setState(() {
          MockData.courses.add(course);
          MockData.timetableSlots.addAll(slots);
        }),
      ),
    );
  }

  void _openAddExamSheet() {
    showMulgilSheet(
      context,
      isScrollControlled: true,
      builder: (_) => ExamFormSheet(
        onSubmit: (exam) => setState(() => MockData.exams.insert(0, exam)),
      ),
    );
  }

  void _openEditExamSheet(Exam exam) {
    showMulgilSheet(
      context,
      isScrollControlled: true,
      builder: (_) => ExamFormSheet(
        existingExam: exam,
        onSubmit: (updated) => setState(() {
          MockData.exams.replaceWhere((e) => e.id == exam.id, updated);
        }),
      ),
    );
  }

  void _deleteExamSchedule(Exam exam) {
    confirmDeleteExam(context, exam, () {
      setState(() => MockData.exams.removeWhere((e) => e.id == exam.id));
    });
  }

  void _openPrivacyPolicy() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const LegalDocumentScreen(
          title: '개인정보처리방침',
          updatedAt: '2026.08.01',
          body: kPrivacyPolicyBody,
        ),
      ),
    );
  }

  void _openTermsOfService() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const LegalDocumentScreen(
          title: '이용약관',
          updatedAt: '2026.08.01',
          body: kTermsOfServiceBody,
        ),
      ),
    );
  }

  void _openOpenSourceLicenses() {
    showLicensePage(
      context: context,
      applicationName: '물길 (Mulgil)',
      applicationVersion: '1.0.0',
    );
  }

  void _openContactSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('mulgil@gmail.com로 문의해주세요 (메일 앱 연결 예정)')),
    );
  }

  void _openBugReport() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('버그 제보 폼 연결 예정 (mock)')));
  }

  void _logout() {
    AuthStore.isLoggedIn = false;
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: context.isTablet ? _buildTablet() : _buildMobile()),
    );
  }

  Widget _buildMobile() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              BackIfPushed(),
              Text(
                '설정',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const ProfileCard(),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(child: SectionLabel(label: '과목 관리')),
              MulgilRaisedAddButton(onTap: _openAddSubjectSheet),
            ],
          ),
          WeeklyTimetable(onChanged: () => setState(() {})),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(child: SectionLabel(label: '시험 일정')),
              MulgilRaisedAddButton(onTap: _openAddExamSheet),
            ],
          ),
          const SizedBox(height: 12),
          if (MockData.exams.isEmpty)
            const EmptyExamBox()
          else
            ...MockData.exams.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ExamScheduleTile(
                  exam: e,
                  onEdit: () => _openEditExamSheet(e),
                  onDelete: () => _deleteExamSchedule(e),
                ),
              ),
            ),
          const SizedBox(height: 20),
          const SectionLabel(label: '앱 정보'),
          const NavTile(
            label: '버전 1.0.0',
            icon: Icons.info_outlined,
            showArrow: false,
          ),
          NavTile(
            label: '문의 · 피드백',
            icon: Icons.mail_outlined,
            sublabel: 'mulgil@gmail.com',
            onTap: _openContactSupport,
          ),
          NavTile(
            label: '개인정보처리방침',
            icon: Icons.shield_outlined,
            onTap: _openPrivacyPolicy,
          ),
          NavTile(
            label: '이용약관',
            icon: Icons.article_outlined,
            onTap: _openTermsOfService,
          ),
          NavTile(
            label: '오픈소스 라이선스',
            icon: Icons.code_outlined,
            onTap: _openOpenSourceLicenses,
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: _logout,
            child: const Center(
              child: Text(
                '로그아웃',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.coral,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTablet() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 220,
          height: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          decoration: const BoxDecoration(
            border: Border(right: BorderSide(color: AppColors.border)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '설정',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              TabletSideItem(
                label: '프로필',
                icon: '👤',
                selected: _tab == _SettingsTab.profile,
                onTap: () => setState(() => _tab = _SettingsTab.profile),
              ),
              TabletSideItem(
                label: '과목 관리',
                icon: '📚',
                selected: _tab == _SettingsTab.subjects,
                onTap: () => setState(() => _tab = _SettingsTab.subjects),
              ),
              TabletSideItem(
                label: '앱 정보',
                icon: 'ℹ️',
                selected: _tab == _SettingsTab.appInfo,
                onTap: () => setState(() => _tab = _SettingsTab.appInfo),
              ),
              const Spacer(),
              TextButton(
                onPressed: _logout,
                child: const Text(
                  '로그아웃',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.coral,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: MaxContentWidth(child: _buildTabletPanel()),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletPanel() {
    switch (_tab) {
      case _SettingsTab.profile:
        return const SettingsProfilePanel();
      case _SettingsTab.subjects:
        return SettingsSubjectsPanel(
          onAddSubject: _openAddSubjectSheet,
          onAddExam: _openAddExamSheet,
          onEditExam: _openEditExamSheet,
          onDeleteExam: _deleteExamSchedule,
          onChanged: () => setState(() {}),
        );
      case _SettingsTab.appInfo:
        return SettingsAppInfoPanel(
          onContactSupport: _openContactSupport,
          onBugReport: _openBugReport,
          onPrivacyPolicy: _openPrivacyPolicy,
          onTermsOfService: _openTermsOfService,
          onOpenSourceLicenses: _openOpenSourceLicenses,
        );
    }
  }
}
