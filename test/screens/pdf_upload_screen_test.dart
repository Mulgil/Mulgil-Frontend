import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mulgil/data/api_client.dart';
import 'package:mulgil/data/auth_store.dart';
import 'package:mulgil/data/learning_domain_api.dart';
import 'package:mulgil/data/learning_domain_store.dart';
import 'package:mulgil/data/resource_upload_api.dart';
import 'package:mulgil/screens/note/pdf_upload_screen.dart';

void main() {
  tearDown(AuthStore.clear);

  testWidgets('shows generated sessions as selectable PDF upload targets', (
    tester,
  ) async {
    AuthStore.saveTokens(accessToken: 'access-token', refreshToken: 'refresh');
    final client = ApiClient(
      baseUri: Uri.parse('https://api.example.com'),
      accessTokenProvider: AuthStore.accessTokenProvider,
      httpClient: MockClient((request) async {
        switch ('${request.method} ${request.url.path}') {
          case 'GET /api/v1/courses':
            return _jsonResponse([
              {
                'id': 'course-1',
                'name': '운영체제',
                'instructor': '김민수 교수님',
                'term': '2026-2',
              },
            ]);
          case 'GET /api/v1/timetable/slots':
          case 'GET /api/v1/courses/course-1/exams':
            return _jsonResponse([]);
          case 'GET /api/v1/courses/course-1/sessions':
            return _jsonResponse([
              {
                'id': 'session-1',
                'courseId': 'course-1',
                'sessionNumber': 1,
                'title': '1차시',
                'sessionDate': '2026-09-01',
                'startsAt': '2026-09-01T01:30:00Z',
                'endsAt': '2026-09-01T02:45:00Z',
              },
            ]);
        }
        fail('Unexpected request: ${request.method} ${request.url}');
      }),
    );
    final store = LearningDomainStore(
      LearningDomainApi(client),
      now: () => DateTime(2026, 9, 3),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: PdfUploadScreen(store: store, api: ResourceUploadApi(client)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('운영체제 · 1주차 1차시'), findsOneWidget);
    await tester.tap(find.text('운영체제 · 1주차 1차시'));
    await tester.pumpAndSettle();
    expect(find.text('어떤 용도의 자료인가요?'), findsOneWidget);
  });

  testWidgets(
    'uploads a selected PDF after session and source phase selection',
    (tester) async {
      AuthStore.saveTokens(
        accessToken: 'access-token',
        refreshToken: 'refresh',
      );
      final store = LearningDomainStore(
        _learningApi((request) async {
          switch ('${request.method} ${request.url.path}') {
            case 'GET /api/v1/courses':
              return _jsonResponse([
                {
                  'id': 'course-1',
                  'name': '운영체제',
                  'instructor': null,
                  'term': '2026-2',
                },
              ]);
            case 'GET /api/v1/timetable/slots':
            case 'GET /api/v1/courses/course-1/exams':
              return _jsonResponse([]);
            case 'GET /api/v1/courses/course-1/sessions':
              return _jsonResponse([
                _sessionJson(id: 'session-1', courseId: 'course-1'),
              ]);
          }
          fail('Unexpected request: ${request.method} ${request.url}');
        }),
        now: () => DateTime(2026, 9, 3),
      );
      await store.load();
      final uploadApi = _FakeResourceUploadApi();

      await tester.pumpWidget(
        MaterialApp(
          home: PdfUploadScreen(
            store: store,
            api: uploadApi,
            pickPdfFile: () async => UploadFile.memory(
              filename: 'week-1.pdf',
              mimeType: 'application/pdf',
              bytes: [1, 2, 3],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('운영체제 · 1주차 컴퓨터 구조 개요'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('수업 전 예습용'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('PDF 파일 선택'));
      await tester.pumpAndSettle();

      expect(uploadApi.uploadedSessionIds, ['session-1']);
      expect(uploadApi.uploadedSourcePhases, [MaterialSourcePhase.previewPdf]);
      expect(uploadApi.uploadedFileNames, ['week-1.pdf']);
      expect(find.text('week-1.pdf 업로드가 완료됐어요'), findsOneWidget);
      expect(find.text('첨부 자료 확인'), findsOneWidget);
    },
  );

  testWidgets('shows upload failure and stays on file selection', (
    tester,
  ) async {
    AuthStore.saveTokens(accessToken: 'access-token', refreshToken: 'refresh');
    final store = LearningDomainStore(
      _learningApi((request) async {
        switch ('${request.method} ${request.url.path}') {
          case 'GET /api/v1/courses':
            return _jsonResponse([
              {
                'id': 'course-1',
                'name': '운영체제',
                'instructor': null,
                'term': null,
              },
            ]);
          case 'GET /api/v1/timetable/slots':
          case 'GET /api/v1/courses/course-1/exams':
            return _jsonResponse([]);
          case 'GET /api/v1/courses/course-1/sessions':
            return _jsonResponse([
              _sessionJson(id: 'session-1', courseId: 'course-1'),
            ]);
        }
        fail('Unexpected request: ${request.method} ${request.url}');
      }),
      now: () => DateTime(2026, 9, 3),
    );
    await store.load();
    final uploadApi = _FakeResourceUploadApi(
      failure: const ApiException(
        statusCode: 422,
        code: 'UPLOAD_LIMIT_EXCEEDED',
        message: 'Upload limit exceeded.',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: PdfUploadScreen(
          store: store,
          api: uploadApi,
          pickPdfFile: () async => UploadFile.memory(
            filename: 'too-large.pdf',
            mimeType: 'application/pdf',
            bytes: [1, 2, 3],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('운영체제 · 1주차 컴퓨터 구조 개요'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('수업 후 복습용'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('PDF 파일 선택'));
    await tester.pumpAndSettle();

    expect(uploadApi.uploadedSessionIds, ['session-1']);
    expect(uploadApi.uploadedSourcePhases, [MaterialSourcePhase.reviewPdf]);
    expect(find.text('Upload limit exceeded.'), findsOneWidget);
    expect(find.text('PDF 파일 선택'), findsOneWidget);
    expect(find.textContaining('업로드가 완료됐어요'), findsNothing);
  });
}

class _FakeResourceUploadApi extends ResourceUploadApi {
  final Object? failure;
  final uploadedSessionIds = <String>[];
  final uploadedSourcePhases = <MaterialSourcePhase>[];
  final uploadedFileNames = <String>[];

  _FakeResourceUploadApi({this.failure})
    : super(
        ApiClient(
          baseUri: Uri.parse('https://api.example.com'),
          httpClient: MockClient((request) async => http.Response('', 500)),
        ),
      );

  @override
  Future<MaterialUploadResult> uploadSessionMaterial({
    required String sessionId,
    required UploadFile file,
    required MaterialSourcePhase sourcePhase,
  }) async {
    uploadedSessionIds.add(sessionId);
    uploadedSourcePhases.add(sourcePhase);
    uploadedFileNames.add(file.filename);
    final failure = this.failure;
    if (failure != null) throw failure;
    return const MaterialUploadResult(
      materialId: 'material-1',
      job: JobAccepted(jobId: 'job-1', status: 'queued'),
    );
  }
}

LearningDomainApi _learningApi(
  Future<http.Response> Function(http.Request request) handler,
) {
  return LearningDomainApi(
    ApiClient(
      baseUri: Uri.parse('https://api.example.com'),
      accessTokenProvider: AuthStore.accessTokenProvider,
      httpClient: MockClient(handler),
    ),
  );
}

http.Response _jsonResponse(Object body, [int statusCode = 200]) {
  return http.Response.bytes(
    utf8.encode(jsonEncode(body)),
    statusCode,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}

Map<String, Object?> _sessionJson({
  required String id,
  required String courseId,
}) {
  return {
    'id': id,
    'courseId': courseId,
    'sessionNumber': 1,
    'title': '컴퓨터 구조 개요',
    'sessionDate': '2026-09-01',
    'startsAt': null,
    'endsAt': null,
  };
}
