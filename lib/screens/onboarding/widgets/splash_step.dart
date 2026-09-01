import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/mulgil_logo.dart';

// ── Splash ──────────────────────────────────────────

class SplashMobile extends StatelessWidget {
  final VoidCallback onStart;
  const SplashMobile({super.key, required this.onStart});

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
              const Text(
                '흐르듯 공부하다',
                style: TextStyle(color: Color(0xFFc9d8e0), fontSize: 16),
              ),
              const SizedBox(height: 48),
              GestureDetector(
                onTap: onStart,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '시작하기',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
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

class SplashTablet extends StatelessWidget {
  final VoidCallback onStart;
  const SplashTablet({super.key, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.navy,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MulgilBubbles(size: 72),
              SizedBox(height: 20),
              MulgilWordmark(fontSize: 56),
              SizedBox(height: 12),
              Text(
                '흐르듯 공부하다',
                style: TextStyle(color: Color(0xFFc9d8e0), fontSize: 18),
              ),
            ],
          ),
          Container(
            width: 1,
            height: 220,
            margin: const EdgeInsets.symmetric(horizontal: 90),
            color: Colors.white.withValues(alpha: 0.15),
          ),
          SizedBox(
            width: 380,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const _FeatureRow(
                  icon: '✎',
                  title: '필기부터 복습까지, 한 앱에서',
                  sub: '분산된 도구 없이 흐름을 이어가요',
                ),
                const SizedBox(height: 18),
                const _FeatureRow(
                  icon: '⭐',
                  title: '교수님 강조 포인트를 놓치지 않아요',
                  sub: '필기 중 바로 마킹, AI가 기억해요',
                ),
                const SizedBox(height: 28),
                GestureDetector(
                  onTap: onStart,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '시작하기',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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
  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.teal,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            alignment: Alignment.center,
            child: Text(
              icon,
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.navy,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: const TextStyle(
                    color: Color(0xFF9fb6c4),
                    fontSize: 12,
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
