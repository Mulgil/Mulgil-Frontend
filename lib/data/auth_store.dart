import 'dart:async';

// In-memory stand-in for a persisted session. Secure storage should replace
// this once Google Sign-In is wired up.
abstract final class AuthStore {
  static bool _isLoggedIn = false;
  static String? accessToken;
  static String? refreshToken;

  static bool get isLoggedIn => _isLoggedIn || accessToken != null;

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
    AuthStore.accessToken = accessToken;
    AuthStore.refreshToken = refreshToken;
    _isLoggedIn = true;
  }

  static void clearTokens() {
    accessToken = null;
    refreshToken = null;
  }

  static void clear() {
    _isLoggedIn = false;
    clearTokens();
  }
}
