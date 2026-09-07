import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mulgil/data/api_client.dart';
import 'package:mulgil/data/learning_domain_api.dart';
import 'package:mulgil/data/resource_upload_api.dart';
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
        home: SummaryDetailScreen(
          course: '운영체제',
          lecture: _lecture,
          api: api,
          jobsApi: _jobsApi([]),
        ),
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
          home: QuizSessionScreen(
            course: '운영체제',
            lecture: _lecture,
            api: api,
            jobsApi: _jobsApi([]),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('AI 콘텐츠를 준비하고 있어요.'), findsOneWidget);
      expect(find.textContaining('provider failure'), findsNothing);
    },
  );

  testWidgets('renders a ready summary while its mindmap is still validating', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final api = _jsonApi('/api/v1/sessions/session-1/summaries', {
      'summary': {
        'items': [
          {'title': '핵심', 'body': '요약은 먼저 읽을 수 있어요.'},
        ],
      },
      'mindmap': null,
    });
    final jobsApi = _jobsApi([
      _job(
        type: 'review_mindmap_generate',
        status: 'running',
        progressStage: 'validating',
      ),
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: SummaryDetailScreen(
          course: '운영체제',
          lecture: _lecture,
          api: api,
          jobsApi: jobsApi,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('요약은 먼저 읽을 수 있어요.'), findsOneWidget);
    await tester.tap(find.text('마인드맵'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('AI 요약 · 운영체제 1주차'), findsOneWidget);
    expect(find.text('예습'), findsOneWidget);
    expect(find.text('복습'), findsOneWidget);
    expect(find.text('요약'), findsOneWidget);
    expect(find.text('원본 필기'), findsOneWidget);
    expect(find.text('마인드맵 생성 중'), findsOneWidget);
    expect(find.text('생성 내용을 확인하고 있어요.'), findsOneWidget);
    expect(find.text('퀴즈 풀기'), findsOneWidget);
    expect(tester.getTopLeft(find.text('마인드맵 생성 중')).dy, lessThan(320));
  });

  testWidgets('shows a safe retryable quiz failure from its own child job', (
    tester,
  ) async {
    final api = _api('/api/v1/sessions/session-1/quiz');
    final jobsApi = _jobsApi([
      _job(
        type: 'review_quiz_generate',
        status: 'failed',
        errorCode: 'PROVIDER_FAILED',
        retryable: true,
      ),
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: QuizSessionScreen(
          course: '운영체제',
          lecture: _lecture,
          api: api,
          jobsApi: jobsApi,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('퀴즈 생성에 실패했어요. 다시 시도해 주세요.'), findsOneWidget);
    expect(find.textContaining('PROVIDER_FAILED'), findsNothing);
    expect(find.textContaining('provider failure'), findsNothing);
  });
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

LearningDomainApi _jsonApi(String expectedPath, Object body) {
  return LearningDomainApi(
    ApiClient(
      baseUri: Uri.parse('https://api.example.com'),
      httpClient: MockClient((request) async {
        expect(request.url.path, expectedPath);
        return http.Response.bytes(
          utf8.encode(jsonEncode(body)),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    ),
  );
}

ResourceUploadApi _jobsApi(List<Map<String, Object?>> jobs) {
  return ResourceUploadApi(
    ApiClient(
      baseUri: Uri.parse('https://api.example.com'),
      httpClient: MockClient((request) async {
        expect(request.url.path, '/api/v1/sessions/session-1/jobs');
        return http.Response.bytes(
          utf8.encode(jsonEncode(jobs)),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    ),
  );
}

Map<String, Object?> _job({
  required String type,
  required String status,
  String? progressStage,
  String? errorCode,
  bool retryable = false,
}) {
  return {
    'id': '$type-job',
    'type': type,
    'status': status,
    'inputVersion': 1,
    'attemptCount': 1,
    'maxAttempts': 3,
    'errorCode': errorCode,
    'retryable': retryable,
    'createdAt': '2026-09-07T01:00:00Z',
    'finishedAt': status == 'failed' ? '2026-09-07T01:02:00Z' : null,
    ...?progressStage == null
        ? null
        : {
            'progressStage': progressStage,
            'progressUpdatedAt': '2026-09-07T01:01:00Z',
          },
  };
}
