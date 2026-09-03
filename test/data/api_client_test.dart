import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mulgil/data/api_client.dart';

void main() {
  group('ApiClient', () {
    test('uses the deployed backend domain as the default base URL', () {
      expect(ApiConfig.defaultBaseUrl, 'https://api.mulgil.app');
    });

    test('builds API URLs, encodes JSON, and adds bearer auth', () async {
      final client = ApiClient(
        baseUri: Uri.parse('https://api.example.com/root/'),
        accessTokenProvider: () => ' test-token ',
        httpClient: MockClient((request) async {
          expect(request.method, 'POST');
          expect(
            request.url.toString(),
            'https://api.example.com/root/api/v1/courses?term=2026-2',
          );
          expect(_header(request, 'accept'), 'application/json');
          expect(_header(request, 'authorization'), 'Bearer test-token');
          expect(
            _header(request, 'content-type'),
            'application/json; charset=utf-8',
          );
          expect(jsonDecode(request.body), {'name': '운영체제'});

          return http.Response(
            '{"id":"c1"}',
            201,
            headers: {'content-type': 'application/json'},
          );
        }),
      );

      final result = await client.postJson(
        '/api/v1/courses',
        queryParameters: {'term': '2026-2', 'unused': null},
        body: {'name': '운영체제'},
      );

      expect(result, {'id': 'c1'});
    });

    test('omits authorization when no token is available', () async {
      final client = ApiClient(
        baseUri: Uri.parse('https://api.example.com'),
        accessTokenProvider: () => '',
        httpClient: MockClient((request) async {
          expect(_header(request, 'authorization'), isNull);
          return http.Response('[]', 200);
        }),
      );

      final result = await client.getJson('/api/v1/courses');

      expect(result, isEmpty);
    });

    test('returns null for empty successful responses', () async {
      final client = ApiClient(
        baseUri: Uri.parse('https://api.example.com'),
        httpClient: MockClient((request) async => http.Response('', 204)),
      );

      final result = await client.deleteJson('/api/v1/courses/c1');

      expect(result, isNull);
    });

    test('maps backend error payloads to ApiException', () async {
      final client = ApiClient(
        baseUri: Uri.parse('https://api.example.com'),
        httpClient: MockClient(
          (request) async => http.Response(
            jsonEncode({
              'code': 'UPLOAD_LIMIT_EXCEEDED',
              'message': 'Upload limit exceeded.',
              'details': {'field': 'byteSize'},
            }),
            422,
            headers: {'content-type': 'application/json'},
          ),
        ),
      );

      await expectLater(
        client.postJson('/api/v1/sessions/s1/materials/upload-url'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 422)
              .having((e) => e.code, 'code', 'UPLOAD_LIMIT_EXCEEDED')
              .having((e) => e.details['field'], 'details.field', 'byteSize'),
        ),
      );
    });

    test('rejects non-JSON successful responses', () async {
      final client = ApiClient(
        baseUri: Uri.parse('https://api.example.com'),
        httpClient: MockClient(
          (request) async => http.Response('<html>wrong</html>', 200),
        ),
      );

      await expectLater(
        client.getJson('/api/v1/courses'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 200)
              .having((e) => e.code, 'code', 'INVALID_RESPONSE'),
        ),
      );
    });

    test('keeps HTTP status code for non-JSON error responses', () async {
      final client = ApiClient(
        baseUri: Uri.parse('https://api.example.com'),
        httpClient: MockClient(
          (request) async => http.Response(
            '<html>bad gateway</html>',
            502,
            reasonPhrase: 'Bad Gateway',
          ),
        ),
      );

      await expectLater(
        client.getJson('/api/v1/courses'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 502)
              .having((e) => e.code, 'code', 'HTTP_502')
              .having((e) => e.message, 'message', 'Bad Gateway')
              .having(
                (e) => e.responseBody,
                'responseBody',
                '<html>bad gateway</html>',
              ),
        ),
      );
    });

    test('does not close injected http clients', () {
      final httpClient = _CloseTrackingClient();
      final client = ApiClient(httpClient: httpClient);

      client.close();

      expect(httpClient.isClosed, isFalse);
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

class _CloseTrackingClient extends http.BaseClient {
  bool isClosed = false;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    throw StateError('Unexpected request.');
  }

  @override
  void close() {
    isClosed = true;
    super.close();
  }
}
