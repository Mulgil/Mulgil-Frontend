import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/mulgil_logo.dart';
import '../../data/auth_store.dart';
import '../../constants/routes.dart';

// Replace with POST /auth/oauth/google once the Google Sign-In SDK is wired up.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _loading = false);
    AuthStore.isLoggedIn = true;
    Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: SafeArea(
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
              const SizedBox(height: 56),
              _GoogleSignInButton(
                loading: _loading,
                onTap: _loading ? null : _signInWithGoogle,
              ),
              const SizedBox(height: 12),
              const Text(
                '계속 진행하면 이용약관과 개인정보처리방침에 동의하는 것으로 간주됩니다',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF7f96a4), fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  final bool loading;
  final VoidCallback? onTap;
  const _GoogleSignInButton({required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: const Color(0xFF747775)),
          ),
          child: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.navy,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 20, height: 20, child: _GoogleGLogo()),
                    SizedBox(width: 12),
                    Text(
                      'Google로 계속하기',
                      style: TextStyle(
                        color: Color(0xFF1F1F1F),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// Stylized rendition of the official multicolor Google "G" mark, since this
// app has no SVG asset pipeline to drop in Google's brand SVG directly.
class _GoogleGLogo extends StatelessWidget {
  const _GoogleGLogo();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GoogleGPainter());
  }
}

class _GoogleGPainter extends CustomPainter {
  static double _clockToRad(double clockDeg) => (clockDeg - 90) * math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = radius * 0.62;
    final rect = Rect.fromCircle(
      center: center,
      radius: radius - strokeWidth / 2,
    );

    void arc(double fromClockDeg, double toClockDeg, Color color) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
        rect,
        _clockToRad(fromClockDeg),
        _clockToRad(toClockDeg) - _clockToRad(fromClockDeg),
        false,
        paint,
      );
    }

    arc(300, 390, const Color(0xFFEA4335)); // red: top
    arc(30, 75, const Color(0xFF4285F4)); // blue: upper-right
    arc(105, 145, const Color(0xFF4285F4)); // blue: lower-right
    arc(145, 215, const Color(0xFF34A853)); // green: bottom
    arc(215, 300, const Color(0xFFFBBC05)); // yellow: left

    // Crossbar filling the mouth of the G, matching the real mark's shape.
    final barPaint = Paint()..color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(
        center.dx - strokeWidth * 0.05,
        center.dy - strokeWidth * 0.32,
        radius - (center.dx - strokeWidth * 0.05) + 0.5,
        strokeWidth * 0.64,
      ),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GoogleGPainter oldDelegate) => false;
}
