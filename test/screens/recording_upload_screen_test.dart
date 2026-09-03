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
import 'package:mulgil/models/recording_candidate.dart';
import 'package:mulgil/screens/recording/recording_upload_screen.dart';

void main() {
  tearDown(AuthStore.clear);

  testWidgets(
    'falls back to manual session mapping when no candidate matches',
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
                _courseJson(id: 'course-1', name: '운영체제'),
              ], 200);
            case 'GET /api/v1/timetable/slots':
              return _jsonResponse([], 200);
            case 'GET /api/v1/courses/course-1/sessions':
              return _jsonResponse([
                _sessionJson(id: 'session-1', courseId: 'course-1'),
              ], 200);
            case 'GET /api/v1/courses/course-1/exams':
              return _jsonResponse([], 200);
          }
          fail('Unexpected request: ${request.method} ${request.url}');
        }),
      );
      await store.load();
      final uploadApi = _FakeResourceUploadApi();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecordingUploadScreen(
              api: uploadApi,
              store: store,
              pickRecordingFile: () async => UploadFile.memory(
                filename: 'lecture.m4a',
                mimeType: 'audio/m4a',
                bytes: [1, 2, 3],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('녹음 파일 선택 (m4a / mp4)'));
      await tester.pumpAndSettle();

      expect(find.text('차시를 직접 선택해주세요'), findsOneWidget);
      expect(find.text('운영체제 · 1주차 컴퓨터 구조 개요'), findsOneWidget);

      await tester.tap(find.text('운영체제 · 1주차 컴퓨터 구조 개요'));
      await tester.pump();
      await tester.tap(find.text('차시 확정'));
      await tester.pumpAndSettle();

      expect(uploadApi.confirmedSessionIds, ['session-1']);
      expect(find.text('업로드가 완료됐어요'), findsOneWidget);
    },
  );
}

class _FakeResourceUploadApi extends ResourceUploadApi {
  final confirmedSessionIds = <String>[];

  _FakeResourceUploadApi()
    : super(
        ApiClient(
          baseUri: Uri.parse('https://api.example.com'),
          httpClient: MockClient((request) async => http.Response('', 500)),
        ),
      );

  @override
  Future<RecordingUploadResult> uploadRecording({
    required UploadFile file,
    required DateTime startedAt,
  }) async {
    return const RecordingUploadResult(
      recordingId: 'recording-1',
      durationSeconds: 1200,
      candidateSessions: <RecordingCandidate>[],
    );
  }

  @override
  Future<JobAccepted> confirmRecordingMapping({
    required String recordingId,
    required String sessionId,
  }) async {
    confirmedSessionIds.add(sessionId);
    return const JobAccepted(jobId: 'job-1', status: 'queued');
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

http.Response _jsonResponse(Object? body, int statusCode) {
  return http.Response.bytes(
    utf8.encode(jsonEncode(body)),
    statusCode,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}

Map<String, Object?> _courseJson({required String id, required String name}) {
  return {
    'id': id,
    'name': name,
    'instructor': null,
    'term': '2026-2',
    'createdAt': '2026-09-01T00:00:00Z',
    'updatedAt': '2026-09-01T00:00:00Z',
  };
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
    'createdAt': '2026-09-01T00:00:00Z',
    'updatedAt': '2026-09-01T00:00:00Z',
  };
}
