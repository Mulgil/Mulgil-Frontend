import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/mulgil_logo.dart';

enum _SettingsTab { profile, notifications, subjects, data, appInfo }

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  _SettingsTab _tab = _SettingsTab.profile;

  bool _quizNotif = true;
  bool _examNotif = true;
  bool _summaryNotif = false;
  bool _quietMode = false;
  final String _quietStart = '22:00';
  final String _quietEnd = '08:00';

  final _subjects = [
    {'name': '운영체제', 'professor': '김민수 교수님', 'time': '월 3, 목 3', 'dDay': 4},
    {'name': '자료구조', 'professor': '이하나 교수님', 'time': '화 2, 금 2', 'dDay': 9},
    {'name': '데이터베이스', 'professor': '박철수 교수님', 'time': '수 1, 금 3', 'dDay': 16},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: context.isTablet ? _buildTablet() : _buildMobile(),
      ),
    );
  }

  Widget _buildMobile() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('설정', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 20),
          const _ProfileCard(),
          const SizedBox(height: 20),
          const _SectionLabel(label: '알림'),
          _ToggleTile(label: '퀴즈 알림', sublabel: '복습 시간에 맞춰 알려드려요', value: _quizNotif, onChanged: (v) => setState(() => _quizNotif = v)),
          _ToggleTile(label: '시험 D-Day 알림', sublabel: '시험 3일 전부터 매일 아침', value: _examNotif, onChanged: (v) => setState(() => _examNotif = v)),
          _ToggleTile(label: 'AI 요약 완료 알림', sublabel: '필기 분석이 끝나면 알려드려요', value: _summaryNotif, onChanged: (v) => setState(() => _summaryNotif = v)),
          _ToggleTile(label: '방해 금지 시간', sublabel: '$_quietStart ~ $_quietEnd', value: _quietMode, onChanged: (v) => setState(() => _quietMode = v)),
          const SizedBox(height: 20),
          const _SectionLabel(label: '과목 관리'),
          ..._subjects.map((s) => _SubjectTile(subject: s, onDelete: () => setState(() => _subjects.remove(s)))),
          _AddSubjectButton(onTap: () {}),
          const SizedBox(height: 20),
          const _SectionLabel(label: '데이터'),
          const _NavTile(label: 'PDF로 내보내기', icon: Icons.picture_as_pdf_outlined, sublabel: '모든 노트를 PDF 파일로 저장'),
          const _NavTile(label: 'CSV로 내보내기', icon: Icons.table_chart_outlined, sublabel: '퀴즈·오답 데이터 스프레드시트'),
          const _NavTile(label: '클라우드 백업', icon: Icons.cloud_upload_outlined, sublabel: '마지막 백업: 2026년 8월 28일'),
          const SizedBox(height: 8),
          const _StorageBar(usedMb: 42, totalMb: 200),
          const SizedBox(height: 8),
          _DangerTile(label: '모든 데이터 초기화', onTap: () => _confirmReset(context)),
          const SizedBox(height: 20),
          const _SectionLabel(label: '앱 정보'),
          const _NavTile(label: '버전 1.0.0', icon: Icons.info_outlined, showArrow: false),
          _NavTile(label: '문의 · 피드백', icon: Icons.mail_outlined, sublabel: 'mulgil@gmail.com', onTap: () {}),
          const _NavTile(label: '개인정보처리방침', icon: Icons.shield_outlined),
          const _NavTile(label: '이용약관', icon: Icons.article_outlined),
          const _NavTile(label: '오픈소스 라이선스', icon: Icons.code_outlined),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () {},
            child: const Center(
              child: Text('로그아웃', style: TextStyle(fontSize: 14, color: AppColors.coral, fontWeight: FontWeight.w600)),
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
          decoration: const BoxDecoration(border: Border(right: BorderSide(color: Color(0xFFEEEEEE)))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('설정', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const SizedBox(height: 20),
              _TabletSideItem(label: '프로필', icon: '👤', selected: _tab == _SettingsTab.profile, onTap: () => setState(() => _tab = _SettingsTab.profile)),
              _TabletSideItem(label: '알림', icon: '🔔', selected: _tab == _SettingsTab.notifications, onTap: () => setState(() => _tab = _SettingsTab.notifications)),
              _TabletSideItem(label: '과목 관리', icon: '📚', selected: _tab == _SettingsTab.subjects, onTap: () => setState(() => _tab = _SettingsTab.subjects)),
              _TabletSideItem(label: '데이터', icon: '📊', selected: _tab == _SettingsTab.data, onTap: () => setState(() => _tab = _SettingsTab.data)),
              _TabletSideItem(label: '앱 정보', icon: 'ℹ️', selected: _tab == _SettingsTab.appInfo, onTap: () => setState(() => _tab = _SettingsTab.appInfo)),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: const Text('로그아웃', style: TextStyle(fontSize: 13, color: AppColors.coral, fontWeight: FontWeight.w600)),
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
      case _SettingsTab.notifications:
        return _buildNotificationsPanel();
      case _SettingsTab.subjects:
        return _buildSubjectsPanel();
      case _SettingsTab.data:
        return _buildDataPanel();
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
        _InfoTile(label: '학교', value: '한국대학교'),
        _InfoTile(label: '학과', value: '컴퓨터공학과'),
        _InfoTile(label: '학년', value: '3학년'),
      ],
    );
  }

  Widget _buildNotificationsPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _PanelTitle(title: '알림'),
        const SizedBox(height: 20),
        const _SectionLabel(label: '알림 종류'),
        _ToggleTile(label: '퀴즈 알림', sublabel: '복습 시간에 맞춰 알려드려요', value: _quizNotif, onChanged: (v) => setState(() => _quizNotif = v)),
        _ToggleTile(label: '시험 D-Day 알림', sublabel: '시험 3일 전부터 매일 아침', value: _examNotif, onChanged: (v) => setState(() => _examNotif = v)),
        _ToggleTile(label: 'AI 요약 완료 알림', sublabel: '필기 분석이 끝나면 알려드려요', value: _summaryNotif, onChanged: (v) => setState(() => _summaryNotif = v)),
        const SizedBox(height: 20),
        const _SectionLabel(label: '방해 금지 시간'),
        _ToggleTile(label: '방해 금지 모드', sublabel: '설정한 시간 동안 알림을 보내지 않아요', value: _quietMode, onChanged: (v) => setState(() => _quietMode = v)),
        if (_quietMode) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _TimeTile(label: '시작', time: _quietStart, onTap: () {})),
              const SizedBox(width: 12),
              Expanded(child: _TimeTile(label: '종료', time: _quietEnd, onTap: () {})),
            ],
          ),
        ],
        const SizedBox(height: 20),
        const _SectionLabel(label: '알림 스타일'),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFFF7F7F7), borderRadius: BorderRadius.circular(14)),
          child: const Row(
            children: [
              Text('📣', style: TextStyle(fontSize: 20)),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('동기부여형', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  Text('"지금 복습하면 장기기억으로 갑니다!"', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ],
              ),
              Spacer(),
              Text('변경', style: TextStyle(fontSize: 12, color: AppColors.tealDark, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
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
            _AddSubjectButton(onTap: () {}),
          ],
        ),
        const SizedBox(height: 20),
        ..._subjects.map((s) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _SubjectTile(subject: s, onDelete: () => setState(() => _subjects.remove(s))),
        )),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFFF0FDF8), border: Border.all(color: AppColors.teal.withValues(alpha: 0.3)), borderRadius: BorderRadius.circular(14)),
          child: const Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: AppColors.tealDark),
              SizedBox(width: 8),
              Expanded(child: Text('과목을 추가하면 AI가 강의 패턴을 분석해 맞춤 퀴즈를 만들어요', style: TextStyle(fontSize: 12, color: AppColors.tealDark))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDataPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _PanelTitle(title: '데이터'),
        const SizedBox(height: 20),
        const _SectionLabel(label: '내보내기'),
        const _NavTile(label: 'PDF로 내보내기', icon: Icons.picture_as_pdf_outlined, sublabel: '모든 노트를 PDF 파일로 저장'),
        const _NavTile(label: 'CSV로 내보내기', icon: Icons.table_chart_outlined, sublabel: '퀴즈·오답 데이터 스프레드시트'),
        const SizedBox(height: 20),
        const _SectionLabel(label: '백업'),
        const _NavTile(label: '클라우드 백업', icon: Icons.cloud_upload_outlined, sublabel: '마지막 백업: 2026년 8월 28일'),
        const _NavTile(label: '백업 복원', icon: Icons.cloud_download_outlined, sublabel: '이전 데이터로 복원'),
        const SizedBox(height: 20),
        const _SectionLabel(label: '저장 공간'),
        const _StorageBar(usedMb: 42, totalMb: 200),
        const SizedBox(height: 20),
        const _SectionLabel(label: '위험 구역'),
        _DangerTile(label: '모든 데이터 초기화', onTap: () => _confirmReset(context)),
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
          decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MulgilWordmark(fontSize: 28),
                  SizedBox(height: 4),
                  Text('흐르듯 공부하다', style: TextStyle(fontSize: 13, color: Color(0xFF9fb6c4))),
                ],
              ),
              const Spacer(),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('버전 1.0.0', style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600)),
                  SizedBox(height: 2),
                  Text('빌드 2026.08', style: TextStyle(fontSize: 11, color: Color(0xFF9fb6c4))),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const _SectionLabel(label: '지원'),
        _NavTile(label: '문의 · 피드백', icon: Icons.mail_outlined, sublabel: 'mulgil@gmail.com', onTap: () {}),
        _NavTile(label: '버그 신고', icon: Icons.bug_report_outlined, onTap: () {}),
        const SizedBox(height: 20),
        const _SectionLabel(label: '법적 고지'),
        const _NavTile(label: '개인정보처리방침', icon: Icons.shield_outlined),
        const _NavTile(label: '이용약관', icon: Icons.article_outlined),
        const _NavTile(label: '오픈소스 라이선스', icon: Icons.code_outlined),
      ],
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('데이터 초기화', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('모든 노트, 퀴즈, 오답이 삭제됩니다. 이 작업은 되돌릴 수 없어요.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('초기화', style: TextStyle(color: AppColors.coral))),
        ],
      ),
    );
  }
}

// ── Shared sub-widgets ─────────────────────────────────────────

class _PanelTitle extends StatelessWidget {
  final String title;
  const _PanelTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary));
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          const CircleAvatar(radius: 26, backgroundColor: AppColors.teal, child: Text('유', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w700))),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('지민', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              Text('소프트웨어학부 · 3학년', style: TextStyle(fontSize: 12, color: Color(0xFF9fb6c4))),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {},
            child: const Icon(Icons.edit_outlined, color: Color(0xFF9fb6c4), size: 18),
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
      child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final String label;
  final String? sublabel;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleTile({required this.label, this.sublabel, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFFF7F7F7), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                if (sublabel != null)
                  Text(sublabel!, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
          MulgilToggle(value: value, onChanged: onChanged),
        ],
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
  const _NavTile({required this.label, this.sublabel, this.icon, this.showArrow = true, this.onTap});

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
                      Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                      if (sublabel != null)
                        Text(sublabel!, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    ],
                  ),
                ),
                if (showArrow) const Icon(Icons.chevron_right, size: 18, color: AppColors.textLight),
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
      decoration: BoxDecoration(color: const Color(0xFFF7F7F7), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textMuted)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _SubjectTile extends StatelessWidget {
  final Map subject;
  final VoidCallback onDelete;
  const _SubjectTile({required this.subject, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: BoxDecoration(color: const Color(0xFFF7F7F7), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(subject['name'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.coral.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                      child: Text('D-${subject['dDay']}', style: const TextStyle(fontSize: 10, color: AppColors.coral, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text('${subject['professor']} · ${subject['time']}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.textLight),
            onPressed: () {},
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(8),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.coral),
            onPressed: onDelete,
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(8),
          ),
        ],
      ),
    );
  }
}

class _AddSubjectButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddSubjectButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(border: Border.all(color: AppColors.navy), borderRadius: BorderRadius.circular(12)),
          alignment: Alignment.center,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, size: 16, color: AppColors.navy),
              SizedBox(width: 4),
              Text('과목 추가', style: TextStyle(fontSize: 13, color: AppColors.navy, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StorageBar extends StatelessWidget {
  final int usedMb, totalMb;
  const _StorageBar({required this.usedMb, required this.totalMb});

  @override
  Widget build(BuildContext context) {
    final ratio = usedMb / totalMb;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFF7F7F7), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('사용 중인 저장 공간', style: TextStyle(fontSize: 13, color: AppColors.textPrimary)),
              Text('${usedMb}MB / ${totalMb}MB', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: const Color(0xFFE0E0E0),
              valueColor: const AlwaysStoppedAnimation(AppColors.teal),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeTile extends StatelessWidget {
  final String label, time;
  final VoidCallback onTap;
  const _TimeTile({required this.label, required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF7F7F7),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              Text(time, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DangerTile extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _DangerTile({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.coral.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.coral.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_outlined, size: 18, color: AppColors.coral),
              const SizedBox(width: 10),
              Text(label, style: const TextStyle(fontSize: 14, color: AppColors.coral, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabletSideItem extends StatelessWidget {
  final String label, icon;
  final bool selected;
  final VoidCallback onTap;
  const _TabletSideItem({required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.navy.withValues(alpha: 0.08) : Colors.transparent,
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
              Text(label, style: TextStyle(fontSize: 13.5, color: selected ? AppColors.navy : AppColors.textSecondary, fontWeight: selected ? FontWeight.w700 : FontWeight.w400)),
            ],
          ),
        ),
      ),
    );
  }
}
