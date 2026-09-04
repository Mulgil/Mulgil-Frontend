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
}

http.Response _jsonResponse(Object body, [int statusCode = 200]) {
  return http.Response.bytes(
    utf8.encode(jsonEncode(body)),
    statusCode,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}
