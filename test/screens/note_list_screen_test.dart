import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mulgil/data/api_client.dart';
import 'package:mulgil/data/auth_store.dart';
import 'package:mulgil/data/learning_domain_api.dart';
import 'package:mulgil/data/learning_domain_store.dart';
import 'package:mulgil/screens/note/note_list_screen.dart';

void main() {
  tearDown(AuthStore.clear);

  testWidgets('uses initialCourseId instead of the first course', (
    tester,
  ) async {
    AuthStore.saveTokens(
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
    );
    final store = LearningDomainStore(_learningApi());
    await store.load();

    await tester.pumpWidget(
      MaterialApp(
        home: NoteListScreen(store: store, initialCourseId: 'course-2'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('자료구조'), findsOneWidget);
    expect(find.text('자료구조 차시'), findsOneWidget);
    expect(find.text('운영체제 차시'), findsNothing);
  });

  testWidgets('uses another non-first course id', (tester) async {
    AuthStore.saveTokens(
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
    );
    final store = LearningDomainStore(_learningApi());
    await store.load();

    await tester.pumpWidget(
      MaterialApp(
        home: NoteListScreen(store: store, initialCourseId: 'course-3'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('생명정보과학의이해'), findsOneWidget);
    expect(find.text('생명정보과학 차시'), findsOneWidget);
    expect(find.text('운영체제 차시'), findsNothing);
    expect(find.text('자료구조 차시'), findsNothing);
  });

  testWidgets(
    'does not fall back to the first course for a missing course id',
    (tester) async {
      AuthStore.saveTokens(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
      );
      final store = LearningDomainStore(_learningApi());
      await store.load();

      await tester.pumpWidget(
        MaterialApp(
          home: NoteListScreen(store: store, initialCourseId: 'missing-course'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('선택한 과목을 찾을 수 없어요'), findsOneWidget);
      expect(find.text('운영체제 차시'), findsNothing);
    },
  );

  testWidgets('opens PDF upload with the selected course id', (tester) async {
    AuthStore.saveTokens(
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
    );
    final store = LearningDomainStore(_learningApi());
    await store.load();

    await tester.pumpWidget(
      MaterialApp(
        home: NoteListScreen(store: store, initialCourseId: 'course-3'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('PDF 자료 업로드'));
    await tester.pumpAndSettle();

    expect(find.text('생명정보과학의이해 · 1주차 생명정보과학 차시'), findsOneWidget);
    expect(find.text('운영체제 · 1주차 운영체제 차시'), findsNothing);
    expect(find.text('자료구조 · 1주차 자료구조 차시'), findsNothing);
  });
}

LearningDomainApi _learningApi() {
  return LearningDomainApi(
    ApiClient(
      baseUri: Uri.parse('https://api.example.com'),
      accessTokenProvider: AuthStore.accessTokenProvider,
      httpClient: MockClient((request) async {
        switch ('${request.method} ${request.url.path}') {
          case 'GET /api/v1/courses':
            return _jsonResponse([
              {
                'id': 'course-1',
                'name': '운영체제',
                'instructor': null,
                'term': '2026-2',
              },
              {
                'id': 'course-2',
                'name': '자료구조',
                'instructor': null,
                'term': '2026-2',
              },
              {
                'id': 'course-3',
                'name': '생명정보과학의이해',
                'instructor': null,
                'term': '2026-2',
              },
            ]);
          case 'GET /api/v1/timetable/slots':
          case 'GET /api/v1/courses/course-1/exams':
          case 'GET /api/v1/courses/course-2/exams':
          case 'GET /api/v1/courses/course-3/exams':
            return _jsonResponse([]);
          case 'GET /api/v1/courses/course-1/sessions':
            return _jsonResponse([
              _sessionJson(
                id: 'session-os',
                courseId: 'course-1',
                title: '운영체제 차시',
              ),
            ]);
          case 'GET /api/v1/courses/course-2/sessions':
            return _jsonResponse([
              _sessionJson(
                id: 'session-ds',
                courseId: 'course-2',
                title: '자료구조 차시',
              ),
            ]);
          case 'GET /api/v1/courses/course-3/sessions':
            return _jsonResponse([
              _sessionJson(
                id: 'session-bio',
                courseId: 'course-3',
                title: '생명정보과학 차시',
              ),
            ]);
        }
        fail('Unexpected request: ${request.method} ${request.url}');
      }),
    ),
  );
}

Map<String, Object?> _sessionJson({
  required String id,
  required String courseId,
  required String title,
}) {
  return {
    'id': id,
    'courseId': courseId,
    'sessionNumber': 1,
    'title': title,
    'sessionDate': '2026-09-01',
    'startsAt': null,
    'endsAt': null,
  };
}

http.Response _jsonResponse(Object body) {
  return http.Response.bytes(
    utf8.encode(jsonEncode(body)),
    200,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}
