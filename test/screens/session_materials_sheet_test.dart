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
  testWidgets('shows document analysis separately from completed indexing', (
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
              return _jsonResponse([
                _jobJson(
                  type: 'pdf_extract',
                  status: 'succeeded',
                  finishedAt: '2026-09-01T00:01:00Z',
                ),
                _jobJson(
                  id: 'job-2',
                  type: 'chunk_embed',
                  status: 'succeeded',
                  finishedAt: '2026-09-01T00:02:00Z',
                ),
              ]);
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
    expect(find.text('업로드 완료 · 예습 · 2페이지 · 2KB'), findsOneWidget);
    expect(find.text('PDF 분석 상태'), findsOneWidget);
    expect(find.text('PDF 분석이 완료됐어요.'), findsOneWidget);
    expect(find.text('AI 콘텐츠 준비 상태'), findsOneWidget);
    expect(find.text('AI 콘텐츠 준비가 완료됐어요.'), findsOneWidget);
    expect(find.text('대기 0개 · 진행 0개 · 완료 1개 · 실패 0개'), findsOneWidget);
    expect(find.text('요약, 마인드맵, 연습 문제, 기출 문제 생성에만 반영돼요.'), findsOneWidget);

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
    expect(find.text('이 PDF를 삭제할까요?\n첨부 자료에서 영구 삭제돼요.'), findsOneWidget);
    await tester.tap(find.text('삭제'));
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

  testWidgets('keeps both material actions within a 375px sheet', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Uri? openedUrl;
    var materialRequests = 0;
    var jobRequests = 0;
    final api = ResourceUploadApi(
      ApiClient(
        baseUri: Uri.parse('https://api.example.com'),
        httpClient: MockClient((request) async {
          switch ('${request.method} ${request.url}') {
            case 'GET https://api.example.com/api/v1/sessions/session-1/materials':
              materialRequests++;
              return _jsonResponse([_materialJson()]);
            case 'GET https://api.example.com/api/v1/sessions/session-1/jobs':
              jobRequests++;
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
      _sheet(
        api,
        openUrl: (url) async {
          openedUrl = url;
          return true;
        },
      ),
    );
    await tester.pumpAndSettle();

    final refreshAction = tester.getRect(find.byIcon(Icons.refresh));
    final openAction = tester.getRect(find.byIcon(Icons.open_in_new));
    final deleteAction = tester.getRect(find.byIcon(Icons.close));
    expect(refreshAction.right, lessThanOrEqualTo(375));
    expect(openAction.left, greaterThanOrEqualTo(0));
    expect(deleteAction.right, lessThanOrEqualTo(375));

    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pumpAndSettle();
    expect(materialRequests, 2);
    expect(jobRequests, 2);

    await tester.tap(find.byIcon(Icons.open_in_new));
    await tester.pumpAndSettle();
    expect(openedUrl, Uri.parse('https://storage.example.com/material-1'));

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.text('이 PDF를 삭제할까요?\n첨부 자료에서 영구 삭제돼요.'), findsOneWidget);
  });

  testWidgets(
    'keeps uploaded PDFs openable when chunk embedding is queued or failed',
    (tester) async {
      for (final status in ['queued', 'failed']) {
        Uri? openedUrl;
        final api = ResourceUploadApi(
          ApiClient(
            baseUri: Uri.parse('https://api.example.com'),
            httpClient: MockClient((request) async {
              switch ('${request.method} ${request.url}') {
                case 'GET https://api.example.com/api/v1/sessions/session-1/materials':
                  return _jsonResponse([_materialJson()]);
                case 'GET https://api.example.com/api/v1/sessions/session-1/jobs':
                  return _jsonResponse([
                    _jobJson(
                      type: 'pdf_ocr',
                      status: 'succeeded',
                      finishedAt: '2026-09-01T00:01:00Z',
                    ),
                    _jobJson(
                      id: 'chunk-$status',
                      type: 'chunk_embed',
                      status: status,
                      errorCode: 'PROVIDER_FAILED',
                      finishedAt: status == 'failed'
                          ? '2026-09-01T00:02:00Z'
                          : null,
                    ),
                  ]);
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
                key: ValueKey(status),
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

        expect(find.text('PDF 분석이 완료됐어요.'), findsOneWidget);
        expect(find.text('AI 콘텐츠 준비 상태'), findsOneWidget);
        expect(
          find.text(
            status == 'queued' ? 'AI 콘텐츠를 준비하고 있어요.' : 'AI 콘텐츠 준비에 실패했어요.',
          ),
          findsOneWidget,
        );
        final openButton = tester.widget<IconButton>(
          find.ancestor(
            of: find.byIcon(Icons.open_in_new),
            matching: find.byType(IconButton),
          ),
        );
        expect(openButton.onPressed, isNotNull);
        expect(find.textContaining('PROVIDER_FAILED'), findsNothing);

        await tester.tap(find.byIcon(Icons.open_in_new));
        await tester.pumpAndSettle();
        expect(openedUrl, Uri.parse('https://storage.example.com/material-1'));
      }
    },
  );

  testWidgets(
    'does not poll for generated output jobs after relevant jobs complete',
    (tester) async {
      var jobsRequests = 0;
      final api = ResourceUploadApi(
        ApiClient(
          baseUri: Uri.parse('https://api.example.com'),
          httpClient: MockClient((request) async {
            switch ('${request.method} ${request.url}') {
              case 'GET https://api.example.com/api/v1/sessions/session-1/materials':
                return _jsonResponse([_materialJson()]);
              case 'GET https://api.example.com/api/v1/sessions/session-1/jobs':
                jobsRequests++;
                return _jsonResponse([
                  _jobJson(
                    type: 'pdf_extract',
                    status: 'succeeded',
                    finishedAt: '2026-09-01T00:01:00Z',
                  ),
                  _jobJson(
                    id: 'generated-job',
                    type: 'summary_generate',
                    status: 'running',
                  ),
                ]);
            }
            fail('Unexpected request: ${request.method} ${request.url}');
          }),
        ),
      );

      await tester.pumpWidget(_sheet(api));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 4));

      expect(jobsRequests, 1);
    },
  );

  testWidgets(
    'polls again for queued document analysis and running indexing jobs',
    (tester) async {
      var jobsRequests = 0;
      final api = ResourceUploadApi(
        ApiClient(
          baseUri: Uri.parse('https://api.example.com'),
          httpClient: MockClient((request) async {
            switch ('${request.method} ${request.url}') {
              case 'GET https://api.example.com/api/v1/sessions/session-1/materials':
                return _jsonResponse([_materialJson()]);
              case 'GET https://api.example.com/api/v1/sessions/session-1/jobs':
                jobsRequests++;
                return _jsonResponse([
                  _jobJson(type: 'pdf_extract', status: 'queued'),
                  _jobJson(
                    id: 'chunk-running',
                    type: 'chunk_embed',
                    status: 'running',
                  ),
                ]);
            }
            fail('Unexpected request: ${request.method} ${request.url}');
          }),
        ),
      );

      await tester.pumpWidget(_sheet(api));
      await tester.pumpAndSettle();
      expect(jobsRequests, 1);

      await tester.pump(const Duration(seconds: 4));
      await tester.pump();

      expect(jobsRequests, 2);
    },
  );

  testWidgets('does not poll for stale outdated document and indexing jobs', (
    tester,
  ) async {
    var jobsRequests = 0;
    final api = ResourceUploadApi(
      ApiClient(
        baseUri: Uri.parse('https://api.example.com'),
        httpClient: MockClient((request) async {
          switch ('${request.method} ${request.url}') {
            case 'GET https://api.example.com/api/v1/sessions/session-1/materials':
              return _jsonResponse([_materialJson()]);
            case 'GET https://api.example.com/api/v1/sessions/session-1/jobs':
              jobsRequests++;
              return _jsonResponse([
                _jobJson(
                  type: 'pdf_ocr',
                  status: 'outdated',
                  finishedAt: '2026-09-01T00:01:00Z',
                ),
                _jobJson(
                  id: 'chunk-outdated',
                  type: 'chunk_embed',
                  status: 'outdated',
                  finishedAt: '2026-09-01T00:02:00Z',
                ),
              ]);
          }
          fail('Unexpected request: ${request.method} ${request.url}');
        }),
      ),
    );

    await tester.pumpWidget(_sheet(api));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 4));

    expect(jobsRequests, 1);
  });

  testWidgets('keeps failed OCR separate from succeeded indexing', (
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
                _jobJson(
                  type: 'pdf_ocr',
                  status: 'failed',
                  finishedAt: '2026-09-01T00:01:00Z',
                ),
                _jobJson(
                  id: 'chunk-succeeded',
                  type: 'chunk_embed',
                  status: 'succeeded',
                  finishedAt: '2026-09-01T00:02:00Z',
                ),
              ]);
          }
          fail('Unexpected request: ${request.method} ${request.url}');
        }),
      ),
    );

    await tester.pumpWidget(_sheet(api));
    await tester.pumpAndSettle();

    expect(find.text('PDF 분석에 실패했어요. 업로드한 PDF는 열어볼 수 있어요.'), findsOneWidget);
    expect(find.text('AI 콘텐츠 준비가 완료됐어요.'), findsOneWidget);
    expect(find.text('대기 0개 · 진행 0개 · 완료 1개 · 실패 0개'), findsOneWidget);
    expect(find.text('AI 콘텐츠 준비에 실패했어요.'), findsNothing);
  });
}

Widget _sheet(ResourceUploadApi api, {MaterialUrlOpener? openUrl}) {
  return MaterialApp(
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
        openUrl: openUrl,
      ),
    ),
  );
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

Map<String, Object?> _jobJson({
  String id = 'job-1',
  String type = 'chunk_embed',
  required String status,
  String? errorCode,
  bool retryable = false,
  String? finishedAt,
}) {
  return {
    'id': id,
    'type': type,
    'status': status,
    'inputVersion': 1,
    'attemptCount': 1,
    'maxAttempts': 3,
    'errorCode': errorCode,
    'retryable': retryable,
    'createdAt': '2026-09-01T00:00:00Z',
    'finishedAt': finishedAt,
  };
}

http.Response _jsonResponse(Object body) {
  return http.Response.bytes(
    utf8.encode(jsonEncode(body)),
    200,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}
