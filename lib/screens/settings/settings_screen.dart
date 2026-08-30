import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/mulgil_logo.dart';
import '../../widgets/course_form_sheet.dart';
import '../../widgets/weekly_timetable.dart';
import '../../widgets/exam_form_sheet.dart';
import '../../data/mock_data.dart';
import '../../data/auth_store.dart';
import '../../models/exam.dart';
import 'legal_document_screen.dart';

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
          final i = MockData.exams.indexWhere((e) => e.id == exam.id);
          MockData.exams[i] = updated;
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
          body: _privacyPolicyBody,
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
          body: _termsOfServiceBody,
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

  // Mirrors POST /auth/logout — revokes the refresh token family server-side once wired up.
  void _logout() {
    AuthStore.isLoggedIn = false;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(child: context.isTablet ? _buildTablet() : _buildMobile()),
    );
  }

  Widget _buildMobile() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const BackIfPushed(),
              const Text(
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
          const _ProfileCard(),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(child: _SectionLabel(label: '과목 관리')),
              _AddSubjectButton(onTap: _openAddSubjectSheet),
            ],
          ),
          WeeklyTimetable(),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(child: _SectionLabel(label: '시험 일정')),
              _AddIconButton(onTap: _openAddExamSheet),
            ],
          ),
          const SizedBox(height: 12),
          if (MockData.exams.isEmpty)
            const _EmptyExamBox()
          else
            ...MockData.exams.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ExamScheduleTile(
                  exam: e,
                  onEdit: () => _openEditExamSheet(e),
                  onDelete: () => _deleteExamSchedule(e),
                ),
              ),
            ),
          const SizedBox(height: 20),
          const _SectionLabel(label: '앱 정보'),
          const _NavTile(
            label: '버전 1.0.0',
            icon: Icons.info_outlined,
            showArrow: false,
          ),
          _NavTile(
            label: '문의 · 피드백',
            icon: Icons.mail_outlined,
            sublabel: 'mulgil@gmail.com',
            onTap: _openContactSupport,
          ),
          _NavTile(
            label: '개인정보처리방침',
            icon: Icons.shield_outlined,
            onTap: _openPrivacyPolicy,
          ),
          _NavTile(
            label: '이용약관',
            icon: Icons.article_outlined,
            onTap: _openTermsOfService,
          ),
          _NavTile(
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
            border: Border(right: BorderSide(color: Color(0xFFEEEEEE))),
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
              _TabletSideItem(
                label: '프로필',
                icon: '👤',
                selected: _tab == _SettingsTab.profile,
                onTap: () => setState(() => _tab = _SettingsTab.profile),
              ),
              _TabletSideItem(
                label: '과목 관리',
                icon: '📚',
                selected: _tab == _SettingsTab.subjects,
                onTap: () => setState(() => _tab = _SettingsTab.subjects),
              ),
              _TabletSideItem(
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
            child: _buildTabletPanel(),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletPanel() {
    switch (_tab) {
      case _SettingsTab.profile:
        return _buildProfilePanel();
      case _SettingsTab.subjects:
        return _buildSubjectsPanel();
      case _SettingsTab.appInfo:
        return _buildAppInfoPanel();
    }
  }

  Widget _buildProfilePanel() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PanelTitle(title: '프로필'),
        SizedBox(height: 20),
        _ProfileCard(),
        SizedBox(height: 20),
        _SectionLabel(label: '학교 정보'),
        _InfoTile(label: '학교', value: '숭실대학교'),
        _InfoTile(label: '학과', value: '컴퓨터공학과'),
        _InfoTile(label: '학년', value: '3학년'),
      ],
    );
  }

  Widget _buildSubjectsPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const _PanelTitle(title: '과목 관리'),
            const Spacer(),
            _AddSubjectButton(onTap: _openAddSubjectSheet),
          ],
        ),
        const SizedBox(height: 20),
        WeeklyTimetable(),
        const SizedBox(height: 20),
        Row(
          children: [
            const Expanded(child: _SectionLabel(label: '시험 일정')),
            _AddIconButton(onTap: _openAddExamSheet),
          ],
        ),
        if (MockData.exams.isEmpty)
          const _EmptyExamBox()
        else
          ...MockData.exams.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ExamScheduleTile(
                exam: e,
                onEdit: () => _openEditExamSheet(e),
                onDelete: () => _deleteExamSchedule(e),
              ),
            ),
          ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF8),
            border: Border.all(color: AppColors.teal.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: AppColors.tealDark),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '과목을 추가하면 AI가 강의 패턴을 분석해 맞춤 퀴즈를 만들어요',
                  style: TextStyle(fontSize: 12, color: AppColors.tealDark),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppInfoPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _PanelTitle(title: '앱 정보'),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.navy,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Column(
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
              const Spacer(),
              const Column(
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
        const _SectionLabel(label: '지원'),
        _NavTile(
          label: '문의 · 피드백',
          icon: Icons.mail_outlined,
          sublabel: 'mulgil@gmail.com',
          onTap: _openContactSupport,
        ),
        _NavTile(
          label: '버그 신고',
          icon: Icons.bug_report_outlined,
          onTap: _openBugReport,
        ),
        const SizedBox(height: 20),
        const _SectionLabel(label: '법적 고지'),
        _NavTile(
          label: '개인정보처리방침',
          icon: Icons.shield_outlined,
          onTap: _openPrivacyPolicy,
        ),
        _NavTile(
          label: '이용약관',
          icon: Icons.article_outlined,
          onTap: _openTermsOfService,
        ),
        _NavTile(
          label: '오픈소스 라이선스',
          icon: Icons.code_outlined,
          onTap: _openOpenSourceLicenses,
        ),
      ],
    );
  }
}

// ── Shared sub-widgets ─────────────────────────────────────────

class _PanelTitle extends StatelessWidget {
  final String title;
  const _PanelTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.teal,
            child: Text(
              '유',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '지민',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                '소프트웨어학부 · 3학년',
                style: TextStyle(fontSize: 12, color: Color(0xFF9fb6c4)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textMuted,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final String label;
  final String? sublabel;
  final IconData? icon;
  final bool showArrow;
  final VoidCallback? onTap;
  const _NavTile({
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
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
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

class _InfoTile extends StatelessWidget {
  final String label, value;
  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExamScheduleTile extends StatelessWidget {
  final Exam exam;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _ExamScheduleTile({
    required this.exam,
    required this.onEdit,
    required this.onDelete,
  });

  int get _dDay => exam.examAt.difference(DateTime.now()).inDays;

  @override
  Widget build(BuildContext context) {
    final dDay = _dDay < 0 ? 0 : _dDay;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ExamDayBadge(dDay: dDay),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: exam.courseName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const TextSpan(
                        text: ' · ',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textMuted,
                        ),
                      ),
                      TextSpan(
                        text: exam.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  '${exam.examAt.year}.${exam.examAt.month}.${exam.examAt.day}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              size: 16,
              color: AppColors.textLight,
            ),
            onPressed: onEdit,
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(8),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              size: 16,
              color: AppColors.coral,
            ),
            onPressed: onDelete,
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(8),
          ),
        ],
      ),
    );
  }
}

class _EmptyExamBox extends StatelessWidget {
  const _EmptyExamBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        '등록된 시험이 없어요',
        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
      ),
    );
  }
}

class _AddIconButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddIconButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _RaisedAddButton(onTap: onTap);
  }
}

class _AddSubjectButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddSubjectButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _RaisedAddButton(onTap: onTap);
  }
}

// Filled, elevated "+" button shared by the 과목 추가 / 시험 일정 추가 actions —
// icon-only so it reads as a single clear affordance rather than a labeled outline button.
class _RaisedAddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _RaisedAddButton({required this.onTap});

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

class _TabletSideItem extends StatelessWidget {
  final String label, icon;
  final bool selected;
  final VoidCallback onTap;
  const _TabletSideItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.navy.withValues(alpha: 0.08)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.5,
                  color: selected ? AppColors.navy : AppColors.textSecondary,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _privacyPolicyBody = '''
물길(Mulgil)은 이용자의 개인정보를 소중히 다루며, 관련 법령을 준수합니다.

1. 수집하는 개인정보 항목
Google 로그인 시 이메일 주소, 이름을 수집합니다. 서비스 이용 과정에서 업로드한 강의자료(PDF), 필기, 녹음 파일, 퀴즈 응답 기록이 함께 저장됩니다.

2. 개인정보의 수집 및 이용 목적
로그인 및 회원 식별, 강의자료 기반 AI 요약·퀴즈 생성, 학습 리포트 제공, 알림 발송을 위해 사용됩니다.

3. 개인정보의 보유 및 이용 기간
회원 탈퇴 시 지체 없이 파기합니다. 단, 관계 법령에 따라 보존이 필요한 경우 해당 기간 동안 보관합니다.

4. 개인정보의 제3자 제공
이용자의 동의 없이 개인정보를 외부에 제공하지 않습니다. 다만 AI 분석을 위해 클라우드 인프라 사업자에게 위탁되는 처리는 계약을 통해 안전하게 관리됩니다.

5. 이용자의 권리
이용자는 언제든 자신의 개인정보 열람, 정정, 삭제를 요청할 수 있습니다.

(본 문서는 서비스 개발 단계의 예시 문구이며, 실제 배포 전 법무 검토를 거친 내용으로 교체되어야 합니다.)
''';

const _termsOfServiceBody = '''
제1조 (목적)
이 약관은 물길(Mulgil)이 제공하는 학습 지원 서비스의 이용조건 및 절차, 이용자와 회사의 권리·의무 및 책임사항을 규정함을 목적으로 합니다.

제2조 (서비스의 내용)
회사는 강의자료 업로드, AI 기반 요약·마인드맵·퀴즈 생성, 학습 리포트 제공 등의 서비스를 제공합니다.

제3조 (이용자의 의무)
이용자는 본인이 정당하게 이용 권한을 가진 강의자료만 업로드해야 하며, 타인의 저작권 및 지식재산권을 침해해서는 안 됩니다.

제4조 (AI 생성물에 대한 안내)
서비스가 제공하는 요약, 마인드맵, 예상 문제는 AI가 생성한 참고 자료이며, 실제 시험 출제나 정답을 보장하지 않습니다.

제5조 (서비스 이용의 제한)
이용자가 관계 법령 및 본 약관을 위반할 경우 서비스 이용이 제한될 수 있습니다.

(본 문서는 서비스 개발 단계의 예시 문구이며, 실제 배포 전 법무 검토를 거친 내용으로 교체되어야 합니다.)
''';
