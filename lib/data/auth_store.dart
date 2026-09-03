import 'dart:async';

// In-memory stand-in for a persisted session. Secure storage should replace
// this once Google Sign-In is wired up.
abstract final class AuthStore {
  static const _devAccessToken = String.fromEnvironment(
    'MULGIL_DEV_ACCESS_TOKEN',
  );
  static const _devRefreshToken = String.fromEnvironment(
    'MULGIL_DEV_REFRESH_TOKEN',
  );

  static bool _isLoggedIn = false;
  static String? accessToken;
  static String? refreshToken;
  static AuthUser? user;

  static bool get isLoggedIn => _isLoggedIn || _hasToken(accessToken);
  static bool get hasAccessToken => _hasToken(accessToken);

  static set isLoggedIn(bool value) {
    _isLoggedIn = value;
    if (!value) {
      clearTokens();
    }
  }

  static FutureOr<String?> accessTokenProvider() => accessToken;

  static bool saveDevTokensFromEnvironment() {
    if (!_hasToken(_devAccessToken)) return false;
    saveTokens(accessToken: _devAccessToken, refreshToken: _devRefreshToken);
    return true;
  }

  static void saveTokens({
    required String accessToken,
    required String refreshToken,
    AuthUser? user,
  }) {
    final trimmedAccessToken = accessToken.trim();
    AuthStore.accessToken = trimmedAccessToken.isEmpty
        ? null
        : trimmedAccessToken;
    AuthStore.refreshToken = refreshToken.trim().isEmpty
        ? null
        : refreshToken.trim();
    _isLoggedIn = _hasToken(AuthStore.accessToken);
    AuthStore.user = _isLoggedIn ? user : null;
  }

  static void clearTokens() {
    _isLoggedIn = false;
    accessToken = null;
    refreshToken = null;
    user = null;
  }

  static void clear() {
    _isLoggedIn = false;
    clearTokens();
  }

  static bool _hasToken(String? token) =>
      token != null && token.trim().isNotEmpty;
}

class AuthUser {
  final String id;
  final String email;
  final String displayName;

  const AuthUser({
    required this.id,
    required this.email,
    required this.displayName,
  });

  String get displayLabel {
    final name = displayName.trim();
    if (name.isNotEmpty) return name;
    final mail = email.trim();
    if (mail.isEmpty) return '사용자';
    return mail.split('@').first;
  }

  String get avatarInitial {
    final label = displayLabel.trim();
    return label.isEmpty ? '물' : label.substring(0, 1);
  }
}
