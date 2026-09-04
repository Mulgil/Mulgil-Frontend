import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mulgil/data/api_client.dart';
import 'package:mulgil/data/resource_upload_api.dart';
import 'package:mulgil/models/lecture.dart';
import 'package:mulgil/screens/note/widgets/session_materials_sheet.dart';

void main() {
  testWidgets('shows uploaded PDFs and opens a newly issued download URL', (
    tester,
  ) async {
    Uri? openedUrl;
    final api = ResourceUploadApi(
      ApiClient(
        baseUri: Uri.parse('https://api.example.com'),
        httpClient: MockClient((request) async {
          switch ('${request.method} ${request.url}') {
            case 'GET https://api.example.com/api/v1/sessions/session-1/materials':
              return _jsonResponse([
                {
                  'id': 'material-1',
                  'sessionId': 'session-1',
                  'filename': 'week-1.pdf',
                  'mimeType': 'application/pdf',
                  'byteSize': 2048,
                  'pageCount': 2,
                  'sourcePhase': 'preview_pdf',
                  'version': 1,
                  'status': 'uploaded',
                },
              ]);
            case 'GET https://api.example.com/api/v1/sessions/session-1/jobs':
              return _jsonResponse([]);
            case 'GET https://api.example.com/api/v1/materials/material-1/download-url':
              return _jsonResponse({
                'downloadUrl': 'https://storage.example.com/material-1',
                'expiresAt': '2026-09-01T00:10:00Z',
              });
          }
          fail('Unexpected request: ${request.method} ${request.url}');
        }),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SessionMaterialsSheet(
            lecture: const Lecture(
              id: 'session-1',
              courseId: 'course-1',
              week: '1주차',
              title: '1차시',
              done: false,
              stars: 0,
            ),
            api: api,
            openUrl: (url) async {
              openedUrl = url;
              return true;
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('week-1.pdf'), findsOneWidget);
    expect(find.text('예습 · 2페이지 · 2KB'), findsOneWidget);
    expect(find.text('업로드 완료'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.open_in_new));
    await tester.pumpAndSettle();

    expect(openedUrl, Uri.parse('https://storage.example.com/material-1'));
  });

  testWidgets('deletes an uploaded PDF and reloads the material list', (
    tester,
  ) async {
    var deleted = false;
    final requests = <String>[];
    final api = ResourceUploadApi(
      ApiClient(
        baseUri: Uri.parse('https://api.example.com'),
        httpClient: MockClient((request) async {
          requests.add('${request.method} ${request.url.path}');
          switch ('${request.method} ${request.url.path}') {
            case 'GET /api/v1/sessions/session-1/materials':
              return _jsonResponse(deleted ? [] : [_materialJson()]);
            case 'GET /api/v1/sessions/session-1/jobs':
              return _jsonResponse([]);
            case 'DELETE /api/v1/materials/material-1':
              deleted = true;
              return http.Response('', 204);
          }
          fail('Unexpected request: ${request.method} ${request.url}');
        }),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SessionMaterialsSheet(
            lecture: const Lecture(
              id: 'session-1',
              courseId: 'course-1',
              week: '1주차',
              title: '1차시',
              done: false,
              stars: 0,
            ),
            api: api,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('week-1.pdf'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(deleted, isTrue);
    expect(find.text('week-1.pdf'), findsNothing);
    expect(find.text('PDF 자료 0개'), findsOneWidget);
    expect(find.text('등록된 PDF 자료가 없어요'), findsOneWidget);
    expect(requests, [
      'GET /api/v1/sessions/session-1/materials',
      'GET /api/v1/sessions/session-1/jobs',
      'DELETE /api/v1/materials/material-1',
      'GET /api/v1/sessions/session-1/materials',
      'GET /api/v1/sessions/session-1/jobs',
    ]);
  });

  testWidgets('does not expose provider retry controls in material status', (
    tester,
  ) async {
    final api = ResourceUploadApi(
      ApiClient(
        baseUri: Uri.parse('https://api.example.com'),
        httpClient: MockClient((request) async {
          switch ('${request.method} ${request.url}') {
            case 'GET https://api.example.com/api/v1/sessions/session-1/materials':
              return _jsonResponse([_materialJson()]);
            case 'GET https://api.example.com/api/v1/sessions/session-1/jobs':
              return _jsonResponse([
                {
                  'id': 'job-1',
                  'type': 'chunk_embed',
                  'status': 'failed',
                  'inputVersion': 1,
                  'attemptCount': 1,
                  'maxAttempts': 3,
                  'errorCode': 'PROVIDER_FAILED',
                  'retryable': true,
                  'createdAt': '2026-09-01T00:00:00Z',
                  'finishedAt': '2026-09-01T00:01:00Z',
                },
              ]);
          }
          fail('Unexpected request: ${request.method} ${request.url}');
        }),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SessionMaterialsSheet(
            lecture: const Lecture(
              id: 'session-1',
              courseId: 'course-1',
              week: '1주차',
              title: '1차시',
              done: false,
              stars: 0,
            ),
            api: api,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('업로드 완료'), findsOneWidget);
    expect(find.text('PDF 업로드는 완료됐지만 AI 분석이 완료되지 않았어요.'), findsOneWidget);
    expect(find.textContaining('PROVIDER_FAILED'), findsNothing);
    expect(find.text('재시도'), findsNothing);
  });
}

Map<String, Object?> _materialJson({String status = 'uploaded'}) {
  return {
    'id': 'material-1',
    'sessionId': 'session-1',
    'filename': 'week-1.pdf',
    'mimeType': 'application/pdf',
    'byteSize': 2048,
    'pageCount': 2,
    'sourcePhase': 'preview_pdf',
    'version': 1,
    'status': status,
  };
}

http.Response _jsonResponse(Object body) {
  return http.Response.bytes(
    utf8.encode(jsonEncode(body)),
    200,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}
