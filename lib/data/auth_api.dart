import 'api_client.dart';
import 'auth_store.dart';

class AuthApi {
  final ApiClient _apiClient;

  const AuthApi(this._apiClient);

  Future<AuthTokens> signInWithGoogleIdToken(String idToken) async {
    final trimmedIdToken = idToken.trim();
    if (trimmedIdToken.isEmpty) {
      throw ArgumentError.value(idToken, 'idToken', 'must not be blank');
    }

    final response = await _apiClient.postJson(
      '/api/v1/auth/oauth/google',
      body: {'idToken': trimmedIdToken},
    );
    final tokens = AuthTokens.fromJson(_asMap(response));
    AuthStore.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      user: tokens.user,
    );
    return tokens;
  }

  static Map<String, Object?> _asMap(Object? value) {
    if (value is Map) {
      return value.map((key, detail) => MapEntry(key.toString(), detail));
    }
    throw const ApiException(
      statusCode: 200,
      code: 'INVALID_RESPONSE',
      message: 'Expected an auth token response.',
    );
  }
}

class AuthTokens {
  final String accessToken;
  final String refreshToken;
  final AuthUser? user;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    this.user,
  });

  factory AuthTokens.fromJson(Map<String, Object?> json) {
    final accessToken = json['accessToken']?.toString().trim() ?? '';
    final refreshToken = json['refreshToken']?.toString().trim() ?? '';
    if (accessToken.isEmpty || refreshToken.isEmpty) {
      throw const ApiException(
        statusCode: 200,
        code: 'INVALID_RESPONSE',
        message: 'Auth token response is missing required tokens.',
      );
    }
    return AuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: _userFromJson(json['user']),
    );
  }

  static AuthUser? _userFromJson(Object? value) {
    if (value is! Map) return null;
    final user = value.map((key, detail) => MapEntry(key.toString(), detail));
    final id = user['id']?.toString().trim() ?? '';
    final email = user['email']?.toString().trim() ?? '';
    final displayName = user['displayName']?.toString().trim() ?? '';
    if (id.isEmpty && email.isEmpty && displayName.isEmpty) return null;
    return AuthUser(id: id, email: email, displayName: displayName);
  }
}
