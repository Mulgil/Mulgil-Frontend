import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mulgil/data/api_client.dart';
import 'package:mulgil/data/auth_store.dart';
import 'package:mulgil/data/learning_domain_api.dart';
import 'package:mulgil/data/learning_domain_store.dart';
import 'package:mulgil/screens/note/ai_summary_screen.dart';
import 'package:mulgil/screens/quiz/quiz_screen.dart';

void main() {
  tearDown(AuthStore.clear);

  for (final screen in <String, Widget Function(LearningDomainStore)>{
    'AI summary': (store) => AiSummaryScreen(store: store),
    'quiz': (store) => QuizScreen(store: store),
  }.entries) {
    testWidgets('${screen.key} groups sessions by week and session number', (
      tester,
    ) async {
      AuthStore.saveTokens(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
      );
      final store = LearningDomainStore(_learningApi());
      await store.load();

      await tester.pumpWidget(MaterialApp(home: screen.value(store)));
      await tester.pumpAndSettle();

      expect(find.text('1주차'), findsOneWidget);
      expect(find.text('2주차'), findsOneWidget);
      expect(find.text('첫 번째 차시'), findsOneWidget);
      expect(find.text('두 번째 차시'), findsOneWidget);
      expect(find.text('세 번째 차시'), findsOneWidget);

      final firstWeekY = tester.getTopLeft(find.text('1주차')).dy;
      final firstSessionY = tester.getTopLeft(find.text('첫 번째 차시')).dy;
      final secondSessionY = tester.getTopLeft(find.text('두 번째 차시')).dy;
      final secondWeekY = tester.getTopLeft(find.text('2주차')).dy;
      final thirdSessionY = tester.getTopLeft(find.text('세 번째 차시')).dy;

      expect(firstWeekY, lessThan(firstSessionY));
      expect(firstSessionY, lessThan(secondSessionY));
      expect(secondSessionY, lessThan(secondWeekY));
      expect(secondWeekY, lessThan(thirdSessionY));
    });
  }
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
                'instructor': '김민수 교수님',
                'term': '2026-2',
              },
            ]);
          case 'GET /api/v1/timetable/slots':
          case 'GET /api/v1/courses/course-1/exams':
            return _jsonResponse([]);
          case 'GET /api/v1/courses/course-1/sessions':
            return _jsonResponse([
              _sessionJson(
                id: 'session-2',
                sessionNumber: 2,
                title: '두 번째 차시',
                sessionDate: '2026-09-03',
              ),
              _sessionJson(
                id: 'session-3',
                sessionNumber: 3,
                title: '세 번째 차시',
                sessionDate: '2026-09-08',
              ),
              _sessionJson(
                id: 'session-1',
                sessionNumber: 1,
                title: '첫 번째 차시',
                sessionDate: '2026-09-01',
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
  required int sessionNumber,
  required String title,
  required String sessionDate,
}) {
  return {
    'id': id,
    'courseId': 'course-1',
    'sessionNumber': sessionNumber,
    'title': title,
    'sessionDate': sessionDate,
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
