import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract final class GoogleAuthConfig {
  static const webClientId = String.fromEnvironment(
    'MULGIL_GOOGLE_WEB_CLIENT_ID',
  );
  static const serverClientId = String.fromEnvironment(
    'MULGIL_GOOGLE_SERVER_CLIENT_ID',
  );

  static String? get resolvedWebClientId => _blankToNull(webClientId);
  static String? get resolvedServerClientId =>
      _blankToNull(serverClientId) ?? resolvedWebClientId;

  static String? _blankToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

class GoogleAuthService {
  final GoogleSignIn _googleSignIn;
  Future<void>? _initializeFuture;

  GoogleAuthService({GoogleSignIn? googleSignIn})
    : _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  Stream<GoogleSignInAuthenticationEvent> get authenticationEvents =>
      _googleSignIn.authenticationEvents;

  Future<void> initialize() {
    final clientId = GoogleAuthConfig.resolvedWebClientId;
    return _initializeFuture ??= _googleSignIn.initialize(
      clientId: kIsWeb ? clientId : null,
      serverClientId: kIsWeb ? null : GoogleAuthConfig.resolvedServerClientId,
    );
  }

  bool supportsAuthenticate() => _googleSignIn.supportsAuthenticate();

  Future<GoogleSignInAccount> authenticate() async {
    await initialize();
    return _googleSignIn.authenticate();
  }

  Future<GoogleSignInAccount?>? attemptLightweightAuthentication() {
    return _googleSignIn.attemptLightweightAuthentication();
  }
}
