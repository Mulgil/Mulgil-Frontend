import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mulgil/data/api_client.dart';
import 'package:mulgil/data/auth_store.dart';
import 'package:mulgil/data/learning_domain_api.dart';
import 'package:mulgil/data/learning_domain_store.dart';
import 'package:mulgil/models/exam.dart';
import 'package:mulgil/screens/exam/exam_list_screen.dart';

void main() {
  tearDown(AuthStore.clear);

  testWidgets('filters exams by courseId from the selected exam', (
    tester,
  ) async {
    AuthStore.saveTokens(accessToken: 'access-token', refreshToken: 'refresh');
    final store = LearningDomainStore(
      _api((request) async {
        switch ('${request.method} ${request.url.path}') {
          case 'GET /api/v1/courses':
            return _jsonResponse([
              _courseJson(id: 'course-1', name: '운영체제'),
              _courseJson(id: 'course-2', name: '운영체제'),
            ], 200);
          case 'GET /api/v1/timetable/slots':
            return _jsonResponse([], 200);
          case 'GET /api/v1/courses/course-1/sessions':
            return _jsonResponse([
              _sessionJson(id: 'session-1', courseId: 'course-1'),
            ], 200);
          case 'GET /api/v1/courses/course-2/sessions':
            return _jsonResponse([
              _sessionJson(id: 'session-2', courseId: 'course-2'),
            ], 200);
          case 'GET /api/v1/courses/course-1/exams':
            return _jsonResponse([
              _examJson(
                id: 'exam-1',
                courseId: 'course-1',
                title: '중간고사',
                sessionIds: ['session-1'],
              ),
            ], 200);
          case 'GET /api/v1/courses/course-2/exams':
            return _jsonResponse([
              _examJson(
                id: 'exam-2',
                courseId: 'course-2',
                title: '기말고사',
                sessionIds: ['session-2'],
              ),
            ], 200);
        }
        fail('Unexpected request: ${request.method} ${request.url}');
      }),
    );

    await tester.pumpWidget(
      MaterialApp(
        onGenerateRoute: (_) => MaterialPageRoute<void>(
          settings: RouteSettings(
            arguments: Exam(
              id: 'selected-exam',
              courseId: 'course-2',
              courseName: '운영체제',
              title: '기말고사',
              examAt: DateTime(2026, 10, 20),
              sessionTitles: const ['1주차'],
            ),
          ),
          builder: (_) => ExamListScreen(store: store),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('기말고사'), findsOneWidget);
    expect(find.text('중간고사'), findsNothing);
  });
}

LearningDomainApi _api(
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

Map<String, Object?> _examJson({
  required String id,
  required String courseId,
  required String title,
  required List<String> sessionIds,
}) {
  return {
    'id': id,
    'courseId': courseId,
    'title': title,
    'examAt': '2026-10-19T15:00:00Z',
    'sessionIds': sessionIds,
    'createdAt': '2026-09-01T00:00:00Z',
    'updatedAt': '2026-09-01T00:00:00Z',
  };
}
