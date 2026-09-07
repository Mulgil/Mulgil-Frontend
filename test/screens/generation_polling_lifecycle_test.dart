import 'dart:async';
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
  group('SummaryDetailScreen generation polling', () {
    testWidgets('active generation starts three-second polling', (
      tester,
    ) async {
      var jobRequests = 0;
      final jobsApi = _jobsApi((request) async {
        jobRequests++;
        return _jsonResponse([
          _job(
            id: 'mindmap-$jobRequests',
            type: 'review_mindmap_generate',
            status: jobRequests == 1 ? 'running' : 'succeeded',
          ),
        ]);
      });

      await tester.pumpWidget(_summaryScreen(jobsApi: jobsApi));
      await _flush(tester);
      expect(jobRequests, 1);

      await tester.pump(const Duration(seconds: 3));
      await _flush(tester);

      expect(jobRequests, 2);
    });

    testWidgets('reloads the mindmap once after its job succeeds', (
      tester,
    ) async {
      var summaryRequests = 0;
      var jobRequests = 0;
      final jobsApi = _jobsApi((request) async {
        jobRequests++;
        return _jsonResponse([
          _job(
            id: 'mindmap-1',
            type: 'review_mindmap_generate',
            status: jobRequests == 1 ? 'running' : 'succeeded',
          ),
        ]);
      });

      await tester.pumpWidget(
        _summaryScreen(
          jobsApi: jobsApi,
          api: _summaryApi((request) async {
            summaryRequests++;
            return _jsonResponse({
              'summary': {
                'items': [
                  {'title': '핵심', 'body': '요약은 먼저 읽을 수 있어요.'},
                ],
              },
              'mindmap': summaryRequests == 1
                  ? null
                  : {
                      'nodes': ['프로세스', '스레드', '스케줄링', '동기화'],
                    },
            });
          }),
        ),
      );
      await _flush(tester);
      await tester.tap(find.text('마인드맵'));
      await _flush(tester);

      await tester.pump(const Duration(seconds: 3));
      await _flush(tester);

      expect(summaryRequests, 2);
      expect(find.text('마인드맵이 아직 없어요'), findsNothing);
    });

    testWidgets('older job response cannot replace a newer source state', (
      tester,
    ) async {
      final firstResponse = Completer<http.Response>();
      var jobRequests = 0;
      final jobsApi = _jobsApi((request) {
        jobRequests++;
        if (jobRequests == 1) return firstResponse.future;
        return Future.value(
          _jsonResponse([
            _job(
              id: 'preview-failed',
              type: 'preview_mindmap_generate',
              status: 'failed',
              retryable: true,
            ),
          ]),
        );
      });

      await tester.pumpWidget(_summaryScreen(jobsApi: jobsApi));
      await _flush(tester);
      await tester.tap(find.text('예습'));
      await _flush(tester);
      expect(jobRequests, 2);

      await tester.tap(find.text('마인드맵'));
      await _flush(tester);
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('마인드맵 생성에 실패했어요.'), findsOneWidget);

      firstResponse.complete(
        _jsonResponse([
          _job(
            id: 'review-running',
            type: 'review_mindmap_generate',
            status: 'running',
            progressStage: 'validating',
          ),
        ]),
      );
      await _flush(tester);

      expect(find.text('마인드맵 생성에 실패했어요.'), findsOneWidget);
      expect(find.text('마인드맵 생성 중'), findsNothing);
    });

    testWidgets('dispose ignores a pending poll and prevents another poll', (
      tester,
    ) async {
      final pendingPoll = Completer<http.Response>();
      var jobRequests = 0;
      final jobsApi = _jobsApi((request) {
        jobRequests++;
        if (jobRequests == 1) {
          return Future.value(
            _jsonResponse([
              _job(
                id: 'review-running',
                type: 'review_mindmap_generate',
                status: 'running',
              ),
            ]),
          );
        }
        return pendingPoll.future;
      });

      await tester.pumpWidget(_summaryScreen(jobsApi: jobsApi));
      await _flush(tester);
      await tester.pump(const Duration(seconds: 3));
      await tester.pump();
      expect(jobRequests, 2);

      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      pendingPoll.complete(
        _jsonResponse([
          _job(
            id: 'late-running',
            type: 'review_mindmap_generate',
            status: 'running',
          ),
        ]),
      );
      await _flush(tester);
      await tester.pump(const Duration(seconds: 4));

      expect(jobRequests, 2);
      expect(tester.takeException(), isNull);
    });
  });

  group('QuizSessionScreen generation polling', () {
    testWidgets('active generation starts three-second polling', (
      tester,
    ) async {
      var jobRequests = 0;
      final jobsApi = _jobsApi((request) async {
        jobRequests++;
        return _jsonResponse([
          _job(
            id: 'quiz-$jobRequests',
            type: 'review_quiz_generate',
            status: jobRequests == 1 ? 'running' : 'succeeded',
          ),
        ]);
      });

      await tester.pumpWidget(_quizScreen(jobsApi: jobsApi));
      await _flush(tester);
      expect(find.textContaining('퀴즈 생성 중'), findsWidgets);
      expect(jobRequests, 1);

      await tester.pump(const Duration(seconds: 3));
      await _flush(tester);

      expect(jobRequests, 2);
    });

    testWidgets('reloads questions once after its job succeeds', (
      tester,
    ) async {
      var questionRequests = 0;
      var jobRequests = 0;
      final jobsApi = _jobsApi((request) async {
        jobRequests++;
        return _jsonResponse([
          _job(
            id: 'quiz-1',
            type: 'review_quiz_generate',
            status: jobRequests == 1 ? 'running' : 'succeeded',
          ),
        ]);
      });

      await tester.pumpWidget(
        _quizScreen(
          jobsApi: jobsApi,
          api: _quizApi((request) async {
            questionRequests++;
            return _jsonResponse(
              questionRequests < 3
                  ? []
                  : [
                      {
                        'id': 'question-1',
                        'type': 'multiple_choice',
                        'prompt': '정답은 무엇인가요?',
                        'options': ['A', 'B', 'C', 'D'],
                        'sourceRefs': [],
                      },
                    ],
            );
          }),
        ),
      );
      await _flush(tester);
      expect(find.textContaining('퀴즈 생성 중'), findsWidgets);

      await tester.pump(const Duration(seconds: 3));
      await _flush(tester);

      expect(questionRequests, 3);
      expect(find.text('정답은 무엇인가요?'), findsOneWidget);
    });

    testWidgets('older poll response cannot replace a newer retry state', (
      tester,
    ) async {
      final olderPoll = Completer<http.Response>();
      var jobRequests = 0;
      final jobsApi = _jobsApi((request) {
        jobRequests++;
        return switch (jobRequests) {
          1 => Future.value(
            _jsonResponse([
              _job(
                id: 'quiz-running-1',
                type: 'review_quiz_generate',
                status: 'running',
              ),
            ]),
          ),
          2 => olderPoll.future,
          _ => Future.value(
            _jsonResponse([
              _job(
                id: 'quiz-failed-newer',
                type: 'review_quiz_generate',
                status: 'failed',
                retryable: true,
              ),
            ]),
          ),
        };
      });

      await tester.pumpWidget(_quizScreen(jobsApi: jobsApi));
      await _flush(tester);
      await tester.pump(const Duration(seconds: 3));
      await tester.pump();
      expect(jobRequests, 2);

      await tester.tap(find.text('다시 시도'));
      await _flush(tester);
      expect(jobRequests, 3);
      expect(find.text('퀴즈 생성에 실패했어요. 다시 시도해 주세요.'), findsOneWidget);

      olderPoll.complete(
        _jsonResponse([
          _job(
            id: 'quiz-running-old',
            type: 'review_quiz_generate',
            status: 'running',
            progressStage: 'validating',
          ),
        ]),
      );
      await _flush(tester);

      expect(find.text('퀴즈 생성에 실패했어요. 다시 시도해 주세요.'), findsOneWidget);
      expect(find.textContaining('퀴즈 생성 중'), findsNothing);
    });

    testWidgets('dispose ignores a pending poll and prevents another poll', (
      tester,
    ) async {
      final pendingPoll = Completer<http.Response>();
      var jobRequests = 0;
      final jobsApi = _jobsApi((request) {
        jobRequests++;
        if (jobRequests == 1) {
          return Future.value(
            _jsonResponse([
              _job(
                id: 'quiz-running',
                type: 'review_quiz_generate',
                status: 'running',
              ),
            ]),
          );
        }
        return pendingPoll.future;
      });

      await tester.pumpWidget(_quizScreen(jobsApi: jobsApi));
      await _flush(tester);
      await tester.pump(const Duration(seconds: 3));
      await tester.pump();
      expect(jobRequests, 2);

      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      pendingPoll.complete(
        _jsonResponse([
          _job(
            id: 'quiz-late',
            type: 'review_quiz_generate',
            status: 'running',
          ),
        ]),
      );
      await _flush(tester);
      await tester.pump(const Duration(seconds: 4));

      expect(jobRequests, 2);
      expect(tester.takeException(), isNull);
    });
  });
}

Widget _summaryScreen({
  required ResourceUploadApi jobsApi,
  LearningDomainApi? api,
}) {
  return MaterialApp(
    home: SummaryDetailScreen(
      course: '운영체제',
      lecture: _lecture,
      api: api ?? _summaryApi(),
      jobsApi: jobsApi,
    ),
  );
}

Widget _quizScreen({
  required ResourceUploadApi jobsApi,
  LearningDomainApi? api,
}) {
  return MaterialApp(
    home: QuizSessionScreen(
      course: '운영체제',
      lecture: _lecture,
      api: api ?? _quizApi(),
      jobsApi: jobsApi,
    ),
  );
}

LearningDomainApi _summaryApi([
  Future<http.Response> Function(http.Request request)? handler,
]) {
  return LearningDomainApi(
    ApiClient(
      baseUri: Uri.parse('https://api.example.com'),
      httpClient: MockClient((request) async {
        expect(request.url.path, '/api/v1/sessions/session-1/summaries');
        if (handler != null) return handler(request);
        return _jsonResponse({
          'summary': {
            'items': [
              {'title': '핵심', 'body': '요약은 먼저 읽을 수 있어요.'},
            ],
          },
          'mindmap': null,
        });
      }),
    ),
  );
}

LearningDomainApi _quizApi([
  Future<http.Response> Function(http.Request request)? handler,
]) {
  return LearningDomainApi(
    ApiClient(
      baseUri: Uri.parse('https://api.example.com'),
      httpClient: MockClient((request) async {
        expect(request.url.path, '/api/v1/sessions/session-1/quiz');
        return handler?.call(request) ?? _jsonResponse([]);
      }),
    ),
  );
}

ResourceUploadApi _jobsApi(
  Future<http.Response> Function(http.Request request) handler,
) {
  return ResourceUploadApi(
    ApiClient(
      baseUri: Uri.parse('https://api.example.com'),
      httpClient: MockClient((request) {
        expect(request.url.path, '/api/v1/sessions/session-1/jobs');
        return handler(request);
      }),
    ),
  );
}

Future<void> _flush(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
  await tester.pump();
}

http.Response _jsonResponse(Object body) {
  return http.Response.bytes(
    utf8.encode(jsonEncode(body)),
    200,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}

Map<String, Object?> _job({
  required String id,
  required String type,
  required String status,
  String? progressStage,
  bool retryable = false,
}) {
  return {
    'id': id,
    'type': type,
    'status': status,
    'inputVersion': 1,
    'attemptCount': 1,
    'maxAttempts': 3,
    'errorCode': status == 'failed' ? 'PROVIDER_FAILED' : null,
    'retryable': retryable,
    'createdAt': '2026-09-07T01:00:00Z',
    'finishedAt': status == 'failed' || status == 'succeeded'
        ? '2026-09-07T01:01:00Z'
        : null,
    if (progressStage != null) ...{
      'progressStage': progressStage,
      'progressUpdatedAt': '2026-09-07T01:00:30Z',
    },
  };
}

const _lecture = Lecture(
  id: 'session-1',
  courseId: 'course-1',
  week: '1주차',
  title: '1차시',
  done: false,
  stars: 0,
);
