import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mulgil/data/api_client.dart';
import 'package:mulgil/data/auth_api.dart';
import 'package:mulgil/data/auth_store.dart';

void main() {
  tearDown(AuthStore.clear);

  group('AuthApi', () {
    test('refreshes an expired access token and retries job polling', () async {
      AuthStore.saveTokens(
        accessToken: 'expired-access-token',
        refreshToken: 'refresh-token',
      );
      late final AuthApi auth;
      var jobRequests = 0;
      final client = ApiClient(
        baseUri: Uri.parse('https://api.example.com'),
        accessTokenProvider: AuthStore.accessTokenProvider,
        onUnauthorized: () => auth.refreshAccessToken(),
        httpClient: MockClient((request) async {
          if (request.url.path == '/api/v1/auth/refresh') {
            expect(_header(request, 'authorization'), isNull);
            expect(jsonDecode(request.body), {'refreshToken': 'refresh-token'});
            return http.Response(
              jsonEncode({
                'accessToken': 'fresh-access-token',
                'refreshToken': 'rotated-refresh-token',
                'tokenType': 'Bearer',
                'accessExpiresAt': '2026-09-03T12:00:00Z',
              }),
              200,
              headers: {'content-type': 'application/json'},
            );
          }

          jobRequests++;
          final authorization = _header(request, 'authorization');
          if (authorization == 'Bearer expired-access-token') {
            return http.Response(
              jsonEncode({
                'code': 'UNAUTHENTICATED',
                'message': 'Authentication failed.',
                'details': <String, Object?>{},
              }),
              401,
              headers: {'content-type': 'application/json'},
            );
          }
          expect(authorization, 'Bearer fresh-access-token');
          return http.Response(
            jsonEncode({'id': 'job-1', 'status': 'running'}),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );
      auth = AuthApi(client);

      final result = await client.getJson('/api/v1/jobs/job-1');

      expect(result, {'id': 'job-1', 'status': 'running'});
      expect(jobRequests, 2);
      expect(AuthStore.accessToken, 'fresh-access-token');
      expect(AuthStore.refreshToken, 'rotated-refresh-token');
    });

    test('posts Google ID token and stores backend tokens', () async {
      final api = AuthApi(
        ApiClient(
          baseUri: Uri.parse('https://api.example.com'),
          httpClient: MockClient((request) async {
            expect(request.method, 'POST');
            expect(
              request.url.toString(),
              'https://api.example.com/api/v1/auth/oauth/google',
            );
            expect(jsonDecode(request.body), {'idToken': 'google-id-token'});

            return http.Response(
              jsonEncode({
                'accessToken': 'access-token',
                'refreshToken': 'refresh-token',
                'tokenType': 'Bearer',
                'accessExpiresAt': '2026-09-03T12:00:00Z',
                'user': {
                  'id': '0198f9a8-aaaa-7bbb-8ccc-ddddeeeeffff',
                  'email': 'mulgil@example.com',
                  'displayName': '물길',
                },
              }),
              200,
              headers: {'content-type': 'application/json'},
            );
          }),
        ),
      );

      final tokens = await api.signInWithGoogleIdToken(' google-id-token ');

      expect(tokens.accessToken, 'access-token');
      expect(tokens.refreshToken, 'refresh-token');
      expect(tokens.user?.displayName, '물길');
      expect(AuthStore.accessToken, 'access-token');
      expect(AuthStore.refreshToken, 'refresh-token');
      expect(AuthStore.user?.email, 'mulgil@example.com');
      expect(AuthStore.isLoggedIn, isTrue);
    });

    test('rejects auth responses without backend tokens', () async {
      final api = AuthApi(
        ApiClient(
          baseUri: Uri.parse('https://api.example.com'),
          httpClient: MockClient(
            (request) async => http.Response(
              jsonEncode({'tokenType': 'Bearer'}),
              200,
              headers: {'content-type': 'application/json'},
            ),
          ),
        ),
      );

      await expectLater(
        api.signInWithGoogleIdToken('google-id-token'),
        throwsA(
          isA<ApiException>().having(
            (error) => error.code,
            'code',
            'INVALID_RESPONSE',
          ),
        ),
      );
      expect(AuthStore.isLoggedIn, isFalse);
    });
  });
}

String? _header(http.BaseRequest request, String name) {
  for (final entry in request.headers.entries) {
    if (entry.key.toLowerCase() == name.toLowerCase()) {
      return entry.value;
    }
  }
  return null;
}
