import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mulgil/data/api_client.dart';
import 'package:mulgil/data/learning_domain_api.dart';
import 'package:mulgil/models/lecture.dart';
import 'package:mulgil/screens/note/summary_detail_screen.dart';
import 'package:mulgil/screens/quiz/quiz_session_screen.dart';

void main() {
  testWidgets('shows a safe waiting state when summary indexing is not ready', (
    tester,
  ) async {
    final api = _api('/api/v1/sessions/session-1/summaries');

    await tester.pumpWidget(
      MaterialApp(
        home: SummaryDetailScreen(course: '운영체제', lecture: _lecture, api: api),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('AI 콘텐츠를 준비하고 있어요.'), findsOneWidget);
    expect(find.textContaining('provider failure'), findsNothing);
  });

  testWidgets(
    'shows a safe waiting state when practice indexing is not ready',
    (tester) async {
      final api = _api('/api/v1/sessions/session-1/quiz');

      await tester.pumpWidget(
        MaterialApp(
          home: QuizSessionScreen(course: '운영체제', lecture: _lecture, api: api),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('AI 콘텐츠를 준비하고 있어요.'), findsOneWidget);
      expect(find.textContaining('provider failure'), findsNothing);
    },
  );
}

const _lecture = Lecture(
  id: 'session-1',
  courseId: 'course-1',
  week: '1주차',
  title: '1차시',
  done: false,
  stars: 0,
);

LearningDomainApi _api(String expectedPath) {
  return LearningDomainApi(
    ApiClient(
      baseUri: Uri.parse('https://api.example.com'),
      httpClient: MockClient((request) async {
        expect(request.url.path, expectedPath);
        return http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'code': 'EMBEDDING_NOT_READY',
              'message': 'provider failure: internal diagnostic',
            }),
          ),
          409,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    ),
  );
}
