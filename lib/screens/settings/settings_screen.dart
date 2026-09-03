import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/course_form_sheet.dart';
import '../../data/auth_store.dart';
import '../../data/learning_domain_store.dart';
import '../../models/exam.dart';
import '../report/weekly_report_section.dart';
import 'legal_document_screen.dart';
import '../../constants/routes.dart';
import 'widgets/app_info_panel.dart';
import 'widgets/legal_texts.dart';
import 'widgets/nav_tile.dart';
import 'widgets/profile_card.dart';
import 'widgets/profile_panel.dart';
import 'widgets/subjects_panel.dart';
import 'widgets/tablet_side_item.dart';

enum _SettingsTab { profile, subjects, report, appInfo }

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  _SettingsTab _tab = _SettingsTab.profile;
  final _learningStore = LearningDomainStore.instance;

  @override
  void initState() {
    super.initState();
    unawaited(_learningStore.load());
  }

  void _openAddSubjectSheet() {
    if (!AuthStore.hasAccessToken) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google 로그인 연결 후 서버에 저장할 수 있어요.')),
      );
      return;
    }
    showMulgilSheet(
      context,
      isScrollControlled: true,
      builder: (_) => CourseFormSheet(
        existingSlots: _learningStore.timetableSlots,
        onAdd: _learningStore.createCourseWithSlots,
      ),
    );
  }

  void _openAddExamSheet() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('시험 등록은 차시 선택 연결 후 서버에 저장할 수 있어요.')),
    );
  }

  void _openEditExamSheet(Exam _) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('시험 수정 API가 아직 없어 화면 저장을 비워뒀어요.')),
    );
  }

  void _deleteExamSchedule(Exam _) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('시험 삭제 API가 아직 없어 화면 저장을 비워뒀어요.')),
    );
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('mulgil@gmail.com로 문의해주세요.')));
  }

  void _openBugReport() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('버그 제보 폼이 아직 연결되지 않았어요.')));
  }

  void _logout() {
    AuthStore.isLoggedIn = false;
    _learningStore.clear();
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  void _openSubjectsPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            _SettingsSubPage(title: '과목 관리', child: _buildSubjectsPanel()),
      ),
    );
  }

  void _openReportPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            const _SettingsSubPage(title: '리포트', child: WeeklyReportSection()),
      ),
    );
  }

  void _openAppInfoPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _SettingsSubPage(
          title: '앱 정보',
          child: SettingsAppInfoPanel(
            onContactSupport: _openContactSupport,
            onBugReport: _openBugReport,
            onPrivacyPolicy: _openPrivacyPolicy,
            onTermsOfService: _openTermsOfService,
            onOpenSourceLicenses: _openOpenSourceLicenses,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: context.isTablet ? _buildTablet() : _buildMobile()),
    );
  }

  // Mobile used to stack profile + report + subjects + app-info in one long
  // scroll, which made just checking your profile a lot of scrolling.
  // Profile stays the default view; the other three sections are one tap
  // away instead, mirroring the tablet's sidebar tabs as pushed sub-pages.
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
          NavTile(
            label: '과목 관리',
            icon: Icons.menu_book_outlined,
            onTap: _openSubjectsPage,
          ),
          NavTile(
            label: '리포트',
            icon: Icons.bar_chart_outlined,
            onTap: _openReportPage,
          ),
          NavTile(
            label: '앱 정보',
            icon: Icons.info_outlined,
            onTap: _openAppInfoPage,
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
                label: '리포트',
                icon: '📊',
                selected: _tab == _SettingsTab.report,
                onTap: () => setState(() => _tab = _SettingsTab.report),
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
        return _buildSubjectsPanel();
      case _SettingsTab.report:
        return const WeeklyReportSection();
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

  Widget _buildSubjectsPanel() {
    return ListenableBuilder(
      listenable: _learningStore,
      builder: (context, _) => SettingsSubjectsPanel(
        onAddSubject: _openAddSubjectSheet,
        onAddExam: _openAddExamSheet,
        onEditExam: _openEditExamSheet,
        onDeleteExam: _deleteExamSchedule,
        onChanged: () => setState(() {}),
        courses: _learningStore.courses,
        timetableSlots: _learningStore.timetableSlots,
        exams: _learningStore.exams,
        onAddCourse: _learningStore.createCourseWithSlots,
        onDeleteCourse: _learningStore.deleteCourse,
        isLoading: _learningStore.isLoading,
        needsAuthentication: _learningStore.needsAuthentication,
        errorMessage: _learningStore.errorMessage,
        onRetry: _learningStore.refresh,
      ),
    );
  }
}

// Thin pushed-page shell for a mobile settings section (과목 관리/리포트/앱 정보) —
// same panel widgets the tablet sidebar shows, just reached by a tap instead
// of always being on screen.
class _SettingsSubPage extends StatelessWidget {
  final String title;
  final Widget child;
  const _SettingsSubPage({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const BackIfPushed(),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
