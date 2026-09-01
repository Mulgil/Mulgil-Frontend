import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../constants/routes.dart';
import 'widgets/splash_step.dart';
import 'widgets/schedule_step.dart';

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
          context.isTablet
              ? SplashTablet(onStart: _next)
              : SplashMobile(onStart: _next),
          ScheduleStep(onNext: _done),
        ],
      ),
    );
  }

  void _next() {
    _ctrl.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _done() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }
}
