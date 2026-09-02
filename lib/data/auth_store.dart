import 'dart:async';

// In-memory stand-in for a persisted session. Secure storage should replace
// this once Google Sign-In is wired up.
abstract final class AuthStore {
  static bool _isLoggedIn = false;
  static String? accessToken;
  static String? refreshToken;

  static bool get isLoggedIn => _isLoggedIn || _hasToken(accessToken);

  static set isLoggedIn(bool value) {
    _isLoggedIn = value;
    if (!value) {
      clearTokens();
    }
  }

  static FutureOr<String?> accessTokenProvider() => accessToken;

  static void saveTokens({
    required String accessToken,
    required String refreshToken,
  }) {
    final trimmedAccessToken = accessToken.trim();
    AuthStore.accessToken = trimmedAccessToken.isEmpty
        ? null
        : trimmedAccessToken;
    AuthStore.refreshToken = refreshToken.trim().isEmpty
        ? null
        : refreshToken.trim();
    _isLoggedIn = _hasToken(AuthStore.accessToken);
  }

  static void clearTokens() {
    _isLoggedIn = false;
    accessToken = null;
    refreshToken = null;
  }

  static void clear() {
    _isLoggedIn = false;
    clearTokens();
  }

  static bool _hasToken(String? token) =>
      token != null && token.trim().isNotEmpty;
}
