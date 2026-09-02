import 'dart:convert';
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mulgil/data/api_client.dart';
import 'package:mulgil/data/auth_store.dart';
import 'package:mulgil/data/learning_domain_api.dart';
import 'package:mulgil/data/learning_domain_store.dart';
import 'package:mulgil/models/course.dart';
import 'package:mulgil/models/timetable_slot.dart';

void main() {
  tearDown(AuthStore.clear);

  group('LearningDomainStore', () {
    test('does not call the API without an access token', () async {
      final requests = <http.Request>[];
      final store = LearningDomainStore(
        _api((request) async {
          requests.add(request);
          return _jsonResponse([], 200);
        }),
      );

      await store.load();

      expect(requests, isEmpty);
      expect(store.needsAuthentication, isTrue);
      expect(store.courses, isEmpty);
      expect(store.timetableSlots, isEmpty);
      expect(store.exams, isEmpty);
    });

    test('reloads when an access token becomes available', () async {
      final requests = <String>[];
      final store = LearningDomainStore(
        _api((request) async {
          requests.add('${request.method} ${request.url.path}');
          switch ('${request.method} ${request.url.path}') {
            case 'GET /api/v1/courses':
            case 'GET /api/v1/timetable/slots':
              return _jsonResponse([], 200);
          }
          fail('Unexpected request: ${request.method} ${request.url}');
        }),
      );

      await store.load();
      AuthStore.saveTokens(
        accessToken: 'access-token',
        refreshToken: 'refresh',
      );
      await store.load();

      expect(requests, ['GET /api/v1/courses', 'GET /api/v1/timetable/slots']);
      expect(store.needsAuthentication, isFalse);
    });

    test('loads courses, slots, sessions, and exams from the API', () async {
      AuthStore.saveTokens(
        accessToken: 'access-token',
        refreshToken: 'refresh',
      );
      final requests = <String>[];
      final store = LearningDomainStore(
        _api((request) async {
          requests.add('${request.method} ${request.url.path}');
          switch ('${request.method} ${request.url.path}') {
            case 'GET /api/v1/courses':
              return _jsonResponse([
                _courseJson(id: 'course-1', name: '운영체제'),
              ], 200);
            case 'GET /api/v1/timetable/slots':
              return _jsonResponse([
                _slotJson(id: 'slot-1', courseId: 'course-1'),
              ], 200);
            case 'GET /api/v1/courses/course-1/sessions':
              return _jsonResponse([
                _sessionJson(id: 'session-1', courseId: 'course-1'),
              ], 200);
            case 'GET /api/v1/courses/course-1/exams':
              return _jsonResponse([
                _examJson(
                  id: 'exam-1',
                  courseId: 'course-1',
                  sessionIds: ['session-1'],
                ),
              ], 200);
          }
          fail('Unexpected request: ${request.method} ${request.url}');
        }),
      );

      await store.load();

      expect(requests, [
        'GET /api/v1/courses',
        'GET /api/v1/timetable/slots',
        'GET /api/v1/courses/course-1/sessions',
        'GET /api/v1/courses/course-1/exams',
      ]);
      expect(store.needsAuthentication, isFalse);
      expect(store.errorMessage, isNull);
      expect(store.courses.single.name, '운영체제');
      expect(store.timetableSlots.single.courseId, 'course-1');
      expect(store.sessionsFor('course-1').single.id, 'session-1');
      expect(store.exams.single.sessionTitles, ['1주차']);
    });

    test('creates slots with the course id returned by the server', () async {
      AuthStore.saveTokens(
        accessToken: 'access-token',
        refreshToken: 'refresh',
      );
      final requests = <String>[];
      final store = LearningDomainStore(
        _api((request) async {
          requests.add('${request.method} ${request.url.path}');
          switch ('${request.method} ${request.url.path}') {
            case 'POST /api/v1/courses':
              expect(jsonDecode(request.body), {
                'name': '자료구조',
                'instructor': '이하나 교수님',
                'term': null,
              });
              return _jsonResponse(
                _courseJson(id: 'course-server', name: '자료구조'),
                201,
              );
            case 'POST /api/v1/timetable/slots':
              expect(jsonDecode(request.body), {
                'courseId': 'course-server',
                'weekday': 2,
                'startTime': '10:30',
                'endTime': '11:45',
                'timezone': 'Asia/Seoul',
              });
              return _jsonResponse(
                _slotJson(id: 'slot-server', courseId: 'course-server'),
                201,
              );
            case 'GET /api/v1/courses':
              return _jsonResponse([
                _courseJson(id: 'course-server', name: '자료구조'),
              ], 200);
            case 'GET /api/v1/timetable/slots':
              return _jsonResponse([
                _slotJson(id: 'slot-server', courseId: 'course-server'),
              ], 200);
            case 'GET /api/v1/courses/course-server/sessions':
            case 'GET /api/v1/courses/course-server/exams':
              return _jsonResponse([], 200);
          }
          fail('Unexpected request: ${request.method} ${request.url}');
        }),
      );

      await store.createCourseWithSlots(
        const Course(id: 'local-course', name: '자료구조', instructor: '이하나 교수님'),
        const [
          TimetableSlot(
            id: 'local-slot',
            courseId: 'local-course',
            weekday: 2,
            startTime: '10:30',
            endTime: '11:45',
          ),
        ],
      );

      expect(requests, [
        'POST /api/v1/courses',
        'POST /api/v1/timetable/slots',
        'GET /api/v1/courses',
        'GET /api/v1/timetable/slots',
        'GET /api/v1/courses/course-server/sessions',
        'GET /api/v1/courses/course-server/exams',
      ]);
      expect(store.courses.single.id, 'course-server');
      expect(store.timetableSlots.single.courseId, 'course-server');
    });

    test(
      'runs a queued force refresh after the active load completes',
      () async {
        AuthStore.saveTokens(
          accessToken: 'access-token',
          refreshToken: 'refresh',
        );
        final firstCoursesResponse = Completer<http.Response>();
        final requests = <String>[];
        var courseCalls = 0;
        final store = LearningDomainStore(
          _api((request) async {
            requests.add('${request.method} ${request.url.path}');
            switch ('${request.method} ${request.url.path}') {
              case 'GET /api/v1/courses':
                courseCalls += 1;
                if (courseCalls == 1) return firstCoursesResponse.future;
                return _jsonResponse([], 200);
              case 'GET /api/v1/timetable/slots':
                return _jsonResponse([], 200);
            }
            fail('Unexpected request: ${request.method} ${request.url}');
          }),
        );

        final initialLoad = store.load();
        await Future<void>.delayed(Duration.zero);
        final queuedRefresh = store.refresh();

        firstCoursesResponse.complete(_jsonResponse([], 200));
        await initialLoad;
        await queuedRefresh;

        expect(requests, [
          'GET /api/v1/courses',
          'GET /api/v1/timetable/slots',
          'GET /api/v1/courses',
          'GET /api/v1/timetable/slots',
        ]);
      },
    );

    test(
      'throws when mutation refresh fails after a successful delete',
      () async {
        AuthStore.saveTokens(
          accessToken: 'access-token',
          refreshToken: 'refresh',
        );
        final store = LearningDomainStore(
          _api((request) async {
            switch ('${request.method} ${request.url.path}') {
              case 'DELETE /api/v1/courses/course-1':
                return _jsonResponse(null, 204);
              case 'GET /api/v1/courses':
                return _jsonResponse({'message': 'temporary failure'}, 500);
            }
            fail('Unexpected request: ${request.method} ${request.url}');
          }),
        );

        await expectLater(
          store.deleteCourse(const Course(id: 'course-1', name: '운영체제')),
          throwsA(
            isA<ApiException>().having(
              (error) => error.code,
              'code',
              'REFRESH_FAILED',
            ),
          ),
        );
      },
    );

    test(
      'soft deletes a partially created course when slot creation fails',
      () async {
        AuthStore.saveTokens(
          accessToken: 'access-token',
          refreshToken: 'refresh',
        );
        final requests = <String>[];
        var slotCalls = 0;
        final store = LearningDomainStore(
          _api((request) async {
            requests.add('${request.method} ${request.url.path}');
            switch ('${request.method} ${request.url.path}') {
              case 'POST /api/v1/courses':
                return _jsonResponse(
                  _courseJson(id: 'course-server', name: '자료구조'),
                  201,
                );
              case 'POST /api/v1/timetable/slots':
                slotCalls += 1;
                if (slotCalls == 1) {
                  return _jsonResponse(
                    _slotJson(id: 'slot-1', courseId: 'course-server'),
                    201,
                  );
                }
                return _jsonResponse({'message': 'slot conflict'}, 409);
              case 'DELETE /api/v1/courses/course-server':
                return _jsonResponse(null, 204);
              case 'GET /api/v1/courses':
              case 'GET /api/v1/timetable/slots':
                return _jsonResponse([], 200);
            }
            fail('Unexpected request: ${request.method} ${request.url}');
          }),
        );

        await expectLater(
          store.createCourseWithSlots(
            const Course(id: 'local-course', name: '자료구조'),
            const [
              TimetableSlot(
                id: 'slot-a',
                courseId: 'local-course',
                weekday: 1,
                startTime: '09:00',
                endTime: '10:15',
              ),
              TimetableSlot(
                id: 'slot-b',
                courseId: 'local-course',
                weekday: 2,
                startTime: '09:00',
                endTime: '10:15',
              ),
            ],
          ),
          throwsA(isA<ApiException>()),
        );
        expect(requests, contains('DELETE /api/v1/courses/course-server'));
      },
    );
  });
}

LearningDomainApi _api(
  Future<http.Response> Function(http.Request request) handler,
) {
  final client = ApiClient(
    baseUri: Uri.parse('https://api.example.com'),
    accessTokenProvider: AuthStore.accessTokenProvider,
    httpClient: MockClient(handler),
  );
  return LearningDomainApi(client);
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

Map<String, Object?> _slotJson({required String id, required String courseId}) {
  return {
    'id': id,
    'courseId': courseId,
    'weekday': 1,
    'startTime': '09:00:00',
    'endTime': '10:15:00',
    'timezone': 'Asia/Seoul',
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
  required List<String> sessionIds,
}) {
  return {
    'id': id,
    'courseId': courseId,
    'title': '중간고사',
    'examAt': '2026-10-19T15:00:00Z',
    'sessionIds': sessionIds,
    'createdAt': '2026-09-01T00:00:00Z',
    'updatedAt': '2026-09-01T00:00:00Z',
  };
}
