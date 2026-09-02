import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mulgil/data/api_client.dart';
import 'package:mulgil/data/learning_domain_api.dart';
import 'package:mulgil/models/course.dart';
import 'package:mulgil/models/lecture.dart';
import 'package:mulgil/models/timetable_slot.dart';

void main() {
  group('LearningDomainApi', () {
    test('lists courses from backend payloads', () async {
      final api = _api((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/api/v1/courses');
        expect(_header(request, 'authorization'), 'Bearer access-token');

        return _jsonResponse([
          {
            'id': 'course-1',
            'name': '운영체제',
            'instructor': '김민수 교수님',
            'term': '2026-2',
            'createdAt': '2026-09-01T00:00:00Z',
            'updatedAt': '2026-09-01T00:00:00Z',
          },
        ], 200);
      });

      final courses = await api.listCourses();

      expect(courses, hasLength(1));
      expect(courses.single.id, 'course-1');
      expect(courses.single.name, '운영체제');
      expect(courses.single.instructor, '김민수 교수님');
      expect(courses.single.term, '2026-2');
    });

    test('creates courses with backend request shape', () async {
      final api = _api((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/v1/courses');
        expect(jsonDecode(request.body), {
          'name': '자료구조',
          'instructor': '이하나 교수님',
          'term': '2026-2',
        });

        return _jsonResponse({
          'id': 'course-2',
          'name': '자료구조',
          'instructor': '이하나 교수님',
          'term': '2026-2',
          'createdAt': '2026-09-01T00:00:00Z',
          'updatedAt': '2026-09-01T00:00:00Z',
        }, 201);
      });

      final course = await api.createCourse(
        name: '자료구조',
        instructor: '이하나 교수님',
        term: '2026-2',
      );

      expect(course.id, 'course-2');
      expect(course.name, '자료구조');
    });

    test('lists timetable slots with optional courseId filter', () async {
      final api = _api((request) async {
        expect(request.method, 'GET');
        expect(
          request.url.toString(),
          'https://api.example.com/api/v1/timetable/slots?courseId=course-1',
        );

        return _jsonResponse([
          {
            'id': 'slot-1',
            'courseId': 'course-1',
            'weekday': 1,
            'startTime': '09:00:00',
            'endTime': '10:15:00',
            'timezone': 'Asia/Seoul',
            'createdAt': '2026-09-01T00:00:00Z',
            'updatedAt': '2026-09-01T00:00:00Z',
          },
        ], 200);
      });

      final slots = await api.listTimetableSlots(courseId: 'course-1');

      expect(slots.single.startTime, '09:00');
      expect(slots.single.endTime, '10:15');
      expect(slots.single.weekdayLabel, '월');
    });

    test(
      'creates timetable slots with courseId and local time fields',
      () async {
        final api = _api((request) async {
          expect(request.method, 'POST');
          expect(request.url.path, '/api/v1/timetable/slots');
          expect(jsonDecode(request.body), {
            'courseId': 'course-1',
            'weekday': 4,
            'startTime': '13:00',
            'endTime': '14:15',
            'timezone': 'Asia/Seoul',
          });

          return _jsonResponse({
            'id': 'slot-4',
            'courseId': 'course-1',
            'weekday': 4,
            'startTime': '13:00',
            'endTime': '14:15',
            'timezone': 'Asia/Seoul',
            'createdAt': '2026-09-01T00:00:00Z',
            'updatedAt': '2026-09-01T00:00:00Z',
          }, 201);
        });

        final slot = await api.createTimetableSlot(
          const TimetableSlot(
            id: 'local-temp',
            courseId: 'course-1',
            weekday: 4,
            startTime: '13:00',
            endTime: '14:15',
          ),
        );

        expect(slot.id, 'slot-4');
      },
    );

    test('maps sessions to lecture labels used by current screens', () async {
      final api = _api((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/api/v1/courses/course-1/sessions');

        return _jsonResponse([
          {
            'id': 'session-1',
            'courseId': 'course-1',
            'sessionNumber': 3,
            'title': '스레드와 동기화',
            'sessionDate': '2026-09-15',
            'startsAt': null,
            'endsAt': null,
            'createdAt': '2026-09-01T00:00:00Z',
            'updatedAt': '2026-09-01T00:00:00Z',
          },
        ], 200);
      });

      final sessions = await api.listSessions('course-1');

      expect(sessions.single.id, 'session-1');
      expect(sessions.single.week, '3주차');
      expect(sessions.single.date, '9/15');
    });

    test(
      'lists exams by courseId and maps session titles from sessions',
      () async {
        const course = Course(id: 'course-1', name: '운영체제');
        const sessions = [
          Lecture(
            id: 'session-1',
            courseId: 'course-1',
            week: '1주차',
            title: '컴퓨터 구조 개요',
            done: false,
            stars: 0,
          ),
        ];
        final api = _api((request) async {
          expect(request.method, 'GET');
          expect(request.url.path, '/api/v1/courses/course-1/exams');

          return _jsonResponse([
            {
              'id': 'exam-1',
              'courseId': 'course-1',
              'title': '중간고사',
              'examAt': '2026-10-19T15:00:00Z',
              'sessionIds': ['session-1', 'deleted-session'],
              'createdAt': '2026-09-01T00:00:00Z',
              'updatedAt': '2026-09-01T00:00:00Z',
            },
          ], 200);
        });

        final exams = await api.listExams(course, sessions: sessions);

        expect(exams.single.courseId, 'course-1');
        expect(exams.single.courseName, '운영체제');
        expect(exams.single.sessionIds, ['session-1', 'deleted-session']);
        expect(exams.single.sessionTitles, ['1주차']);
        expect(exams.single.examAt.year, 2026);
        expect(exams.single.examAt.month, 10);
        expect(exams.single.examAt.day, 20);
      },
    );

    test('creates exams under courseId with sessionIds', () async {
      const course = Course(id: 'course-1', name: '운영체제');
      const sessions = [
        Lecture(
          id: 'session-1',
          courseId: 'course-1',
          week: '1주차',
          title: '컴퓨터 구조 개요',
          done: false,
          stars: 0,
        ),
        Lecture(
          id: 'session-2',
          courseId: 'course-1',
          week: '2주차',
          title: '프로세스',
          done: false,
          stars: 0,
        ),
      ];
      final api = _api((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/v1/courses/course-1/exams');
        expect(jsonDecode(request.body), {
          'title': '중간고사',
          'examAt': '2026-10-19T15:00:00.000Z',
          'sessionIds': ['session-1', 'session-2'],
        });

        return _jsonResponse({
          'id': 'exam-1',
          'courseId': 'course-1',
          'title': '중간고사',
          'examAt': '2026-10-19T15:00:00Z',
          'sessionIds': ['session-1', 'session-2'],
          'createdAt': '2026-09-01T00:00:00Z',
          'updatedAt': '2026-09-01T00:00:00Z',
        }, 201);
      });

      final exam = await api.createExam(
        course: course,
        title: '중간고사',
        examAt: DateTime(2026, 10, 20),
        sessions: sessions,
      );

      expect(exam.id, 'exam-1');
      expect(exam.courseId, 'course-1');
      expect(exam.courseName, '운영체제');
      expect(exam.sessionIds, ['session-1', 'session-2']);
      expect(exam.sessionTitles, ['1주차', '2주차']);
      expect(exam.examAt.year, 2026);
      expect(exam.examAt.month, 10);
      expect(exam.examAt.day, 20);
    });
  });
}

http.Response _jsonResponse(Object body, int statusCode) {
  return http.Response.bytes(
    utf8.encode(jsonEncode(body)),
    statusCode,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}

LearningDomainApi _api(
  Future<http.Response> Function(http.Request request) handler,
) {
  final client = ApiClient(
    baseUri: Uri.parse('https://api.example.com'),
    accessTokenProvider: () => 'access-token',
    httpClient: MockClient(handler),
  );
  return LearningDomainApi(client);
}

String? _header(http.BaseRequest request, String name) {
  for (final entry in request.headers.entries) {
    if (entry.key.toLowerCase() == name.toLowerCase()) {
      return entry.value;
    }
  }
  return null;
}
