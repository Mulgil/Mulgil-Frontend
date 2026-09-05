import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../data/api_client.dart';
import '../../data/app_services.dart';
import '../../data/auth_api.dart';
import '../../data/google_auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/mulgil_logo.dart';
import '../../widgets/google_sign_in_sdk_button.dart';
import '../../constants/routes.dart';

class LoginScreen extends StatefulWidget {
  final AuthApi? authApi;
  final GoogleAuthService? googleAuthService;

  const LoginScreen({super.key, this.authApi, this.googleAuthService});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final AuthApi _authApi;
  late final GoogleAuthService _googleAuthService;
  late final Future<void> _googleInitialization;
  StreamSubscription<GoogleSignInAuthenticationEvent>? _authSubscription;

  bool _loading = false;
  bool _completingSignIn = false;

  @override
  void initState() {
    super.initState();
    _authApi = widget.authApi ?? AppServices.auth;
    _googleAuthService = widget.googleAuthService ?? AppServices.googleAuth;
    _googleInitialization = _initializeGoogleSignIn();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeGoogleSignIn() async {
    await _googleAuthService.initialize();
    if (!kIsWeb) return;

    _authSubscription = _googleAuthService.authenticationEvents.listen(
      _handleGoogleAuthenticationEvent,
      onError: _handleGoogleAuthenticationError,
    );

    _googleAuthService.attemptLightweightAuthentication();
  }

  Future<void> _signInWithGoogle() async {
    if (_loading) return;
    _setLoading(true);
    try {
      if (!_googleAuthService.supportsAuthenticate()) {
        _showSignInFailure('Google 로그인 버튼을 눌러주세요.');
        return;
      }
      await _completeGoogleSignIn(await _googleAuthService.authenticate());
    } catch (error) {
      _showSignInFailure(error);
    } finally {
      if (!_completingSignIn) {
        _setLoading(false);
      }
    }
  }

  Future<void> _handleGoogleAuthenticationEvent(
    GoogleSignInAuthenticationEvent event,
  ) async {
    if (event is GoogleSignInAuthenticationEventSignIn) {
      await _completeGoogleSignIn(event.user);
    }
  }

  void _handleGoogleAuthenticationError(
    Object error, [
    StackTrace? stackTrace,
  ]) {
    _showSignInFailure(error);
  }

  Future<void> _completeGoogleSignIn(GoogleSignInAccount account) async {
    if (_completingSignIn) return;
    _completingSignIn = true;
    _setLoading(true);
    try {
      final idToken = account.authentication.idToken?.trim();
      if (idToken == null || idToken.isEmpty) {
        throw StateError('Missing Google ID token.');
      }

      await _authApi.signInWithGoogleIdToken(idToken);
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
    } catch (error) {
      _showSignInFailure(error);
    } finally {
      _completingSignIn = false;
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    if (!mounted || _loading == value) return;
    setState(() => _loading = value);
  }

  void _showSignInFailure(Object error) {
    if (!mounted) return;
    _setLoading(false);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(_messageFor(error))));
  }

  String _messageFor(Object error) {
    if (error is GoogleSignInException) {
      return switch (error.code) {
        GoogleSignInExceptionCode.canceled => 'Google 로그인이 취소됐어요.',
        GoogleSignInExceptionCode.uiUnavailable => 'Google 로그인 창을 열 수 없어요.',
        _ => error.description ?? 'Google 로그인에 실패했어요.',
      };
    }
    if (error is ApiException) {
      return error.message;
    }
    if (error is String) {
      return error;
    }
    return 'Google 로그인에 실패했어요. 잠시 후 다시 시도해주세요.';
  }

  Widget _buildGoogleSignInEntry(BuildContext context, double width) {
    return FutureBuilder<void>(
      future: _googleInitialization,
      builder: (context, snapshot) {
        final isReady =
            snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasError;
        if (kIsWeb && isReady) {
          return _GoogleSignInWebButton(loading: _loading, width: width);
        }
        return _GoogleSignInButton(
          loading: _loading || (!isReady && !snapshot.hasError),
          onTap: _loading
              ? null
              : snapshot.hasError
              ? () => _showSignInFailure('Google 로그인 설정을 확인해주세요.')
              : _signInWithGoogle,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final contentWidth = constraints.maxWidth;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const MulgilWordmark(fontSize: 56),
                      const SizedBox(height: 12),
                      const Text(
                        '흐르듯 공부하다',
                        style: TextStyle(
                          color: Color(0xFFc9d8e0),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 56),
                      _buildGoogleSignInEntry(context, contentWidth),
                      const SizedBox(height: 12),
                      const Text(
                        '계속 진행하면 이용약관과 개인정보처리방침에 동의하는 것으로 간주됩니다',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF7f96a4),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleSignInWebButton extends StatelessWidget {
  final bool loading;
  final double width;

  const _GoogleSignInWebButton({required this.loading, required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AbsorbPointer(
            absorbing: loading,
            child: googleSignInSdkButton(minimumWidth: width),
          ),
          if (loading)
            const Positioned.fill(
              child: ColoredBox(
                color: Colors.white70,
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.navy,
                    ),
                  ),
                ),
              ),
            ),
        ],
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
