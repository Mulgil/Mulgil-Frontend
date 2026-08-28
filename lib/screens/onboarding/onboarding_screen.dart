import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/mulgil_logo.dart';
import '../../widgets/common_widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _ctrl = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: PageView(
        controller: _ctrl,
        onPageChanged: (_) {},
        physics: const NeverScrollableScrollPhysics(),
        children: [
          context.isTablet ? _SplashTablet(onStart: _next) : _SplashMobile(onStart: _next),
          _ScheduleStep(onNext: _next),
          _PersonaStep(onDone: _done),
        ],
      ),
    );
  }

  void _next() {
    _ctrl.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
  }

  void _done() {
    Navigator.of(context).pushReplacementNamed('/');
  }
}

// ── Splash ──────────────────────────────────────────

class _SplashMobile extends StatelessWidget {
  final VoidCallback onStart;
  const _SplashMobile({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.navy,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const MulgilBubbles(size: 64),
              const SizedBox(height: 20),
              const MulgilWordmark(),
              const SizedBox(height: 12),
              const Text('흐르듯 공부하다', style: TextStyle(color: Color(0xFFc9d8e0), fontSize: 16)),
              const SizedBox(height: 48),
              GestureDetector(
                onTap: onStart,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '시작하기',
                    style: TextStyle(color: AppColors.navy, fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SplashTablet extends StatelessWidget {
  final VoidCallback onStart;
  const _SplashTablet({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.navy,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const MulgilBubbles(size: 72),
              const SizedBox(height: 20),
              const MulgilWordmark(fontSize: 56),
              const SizedBox(height: 12),
              const Text('흐르듯 공부하다', style: TextStyle(color: Color(0xFFc9d8e0), fontSize: 18)),
            ],
          ),
          Container(width: 1, height: 220, margin: const EdgeInsets.symmetric(horizontal: 90), color: Colors.white.withValues(alpha: 0.15)),
          SizedBox(
            width: 380,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _FeatureRow(icon: '✎', title: '필기부터 복습까지, 한 앱에서', sub: '분산된 도구 없이 흐름을 이어가요'),
                const SizedBox(height: 18),
                _FeatureRow(icon: '⭐', title: '교수님 강조 포인트를 놓치지 않아요', sub: '필기 중 바로 마킹, AI가 기억해요'),
                const SizedBox(height: 28),
                GestureDetector(
                  onTap: onStart,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(14)),
                    alignment: Alignment.center,
                    child: const Text('시작하기', style: TextStyle(color: AppColors.navy, fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String icon, title, sub;
  const _FeatureRow({required this.icon, required this.title, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(10)),
            alignment: Alignment.center,
            child: Text(icon, style: const TextStyle(fontSize: 18, color: AppColors.navy, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(sub, style: const TextStyle(color: Color(0xFF9fb6c4), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Schedule Setup ───────────────────────────────────

class _ScheduleStep extends StatelessWidget {
  final VoidCallback onNext;
  const _ScheduleStep({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('온보딩 2/4', style: TextStyle(fontSize: 12, color: AppColors.tealDark, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              const Text('시간표를 등록해주세요', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              const Text('과목·교수님·시험 일정을 알면 리마인더를 딱 맞게 보내드려요', style: TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
              const SizedBox(height: 16),
              _DottedUploadBox(),
              const SizedBox(height: 16),
              _SubjectCard(name: '운영체제', professor: '김민수 교수님', time: '월 3, 목 3'),
              const SizedBox(height: 10),
              _SubjectCard(name: '자료구조', professor: '이하나 교수님', time: '화 2, 금 2'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(border: Border.all(color: AppColors.navy), borderRadius: BorderRadius.circular(10)),
                alignment: Alignment.center,
                child: const Text('+ 과목 추가', style: TextStyle(fontSize: 13, color: AppColors.navy)),
              ),
              const Spacer(),
              MulgilButton(label: '다음', onTap: onNext),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _DottedUploadBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFc8ccd0), width: 1, style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Column(
          children: const [
            Text('시간표 이미지 업로드', style: TextStyle(fontSize: 13, color: AppColors.tealDark, fontWeight: FontWeight.w700)),
            SizedBox(height: 2),
            Text('또는 아래에서 직접 입력', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
          ],
        ),
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final String name, professor, time;
  const _SubjectCard({required this.name, required this.professor, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: const Color(0xFFF7F7F7), borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          Text('$professor · $time', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

// ── Reminder Persona ──────────────────────────────────

class _PersonaStep extends StatefulWidget {
  final VoidCallback onDone;
  const _PersonaStep({required this.onDone});

  @override
  State<_PersonaStep> createState() => _PersonaStepState();
}

class _PersonaStepState extends State<_PersonaStep> {
  int _style = 0;
  int _intensity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('온보딩 3/4', style: TextStyle(fontSize: 12, color: AppColors.tealDark, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              const Text('리마인더 스타일을 골라주세요', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              const Text('언제든 설정에서 바꿀 수 있어요', style: TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
              const SizedBox(height: 20),
              _StyleOption(
                selected: _style == 0,
                icon: '🔔',
                title: '조용한 배너',
                desc: '"요약본이 준비됐어요. 확인해보세요" — 담백하게 알려드려요',
                onTap: () => setState(() => _style = 0),
              ),
              const SizedBox(height: 14),
              _StyleOption(
                selected: _style == 1,
                icon: '📣',
                title: '동기부여형 (과외쌤 톤)',
                desc: '"지금 복습하면 장기기억으로 갑니다!" — 팍팍 밀어드려요',
                onTap: () => setState(() => _style = 1),
              ),
              const SizedBox(height: 20),
              const Text('알림 강도', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 10),
              Row(
                children: ['낮음', '보통', '높음'].asMap().entries.map((e) {
                  final sel = e.key == _intensity;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _intensity = e.key),
                      child: Container(
                        margin: EdgeInsets.only(right: e.key < 2 ? 8 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: sel ? AppColors.navy : const Color(0xFFF7F7F7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(e.value, style: TextStyle(fontSize: 12.5, color: sel ? Colors.white : AppColors.textMuted)),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const Spacer(),
              MulgilButton(label: '완료', onTap: widget.onDone),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _StyleOption extends StatelessWidget {
  final bool selected;
  final String icon, title, desc;
  final VoidCallback onTap;
  const _StyleOption({required this.selected, required this.icon, required this.title, required this.desc, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          border: Border.all(color: selected ? AppColors.navy : const Color(0xFFEEEEEE), width: selected ? 2 : 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$icon $title', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.5)),
          ],
        ),
      ),
    );
  }
}
