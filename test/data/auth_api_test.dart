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
      expect(AuthStore.accessToken, 'access-token');
      expect(AuthStore.refreshToken, 'refresh-token');
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
