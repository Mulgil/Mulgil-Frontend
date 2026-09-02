import '../models/course.dart';
import '../models/exam.dart';
import '../models/lecture.dart';
import '../models/timetable_slot.dart';
import 'api_client.dart';

class LearningDomainApi {
  final ApiClient _client;

  const LearningDomainApi(this._client);

  Future<List<Course>> listCourses() async {
    final body = await _client.getJson('/api/v1/courses');
    return _list(body, 'GET /api/v1/courses').map(_courseFromJson).toList();
  }

  Future<Course> createCourse({
    required String name,
    String? instructor,
    String? term,
  }) async {
    final body = await _client.postJson(
      '/api/v1/courses',
      body: {'name': name, 'instructor': instructor, 'term': term},
    );
    return _courseFromJson(_map(body, 'POST /api/v1/courses'));
  }

  Future<Course> updateCourse(Course course) async {
    final body = await _client.patchJson(
      '/api/v1/courses/${course.id}',
      body: {
        'name': course.name,
        'instructor': course.instructor,
        'term': course.term,
      },
    );
    return _courseFromJson(_map(body, 'PATCH /api/v1/courses/{courseId}'));
  }

  Future<void> deleteCourse(String courseId) async {
    await _client.deleteJson('/api/v1/courses/$courseId');
  }

  Future<List<TimetableSlot>> listTimetableSlots({String? courseId}) async {
    final body = await _client.getJson(
      '/api/v1/timetable/slots',
      queryParameters: {'courseId': courseId},
    );
    return _list(
      body,
      'GET /api/v1/timetable/slots',
    ).map(_slotFromJson).toList();
  }

  Future<TimetableSlot> createTimetableSlot(TimetableSlot slot) async {
    final body = await _client.postJson(
      '/api/v1/timetable/slots',
      body: _slotBody(slot),
    );
    return _slotFromJson(_map(body, 'POST /api/v1/timetable/slots'));
  }

  Future<TimetableSlot> updateTimetableSlot(TimetableSlot slot) async {
    final body = await _client.patchJson(
      '/api/v1/timetable/slots/${slot.id}',
      body: _slotBody(slot),
    );
    return _slotFromJson(_map(body, 'PATCH /api/v1/timetable/slots/{slotId}'));
  }

  Future<void> deleteTimetableSlot(String slotId) async {
    await _client.deleteJson('/api/v1/timetable/slots/$slotId');
  }

  Future<List<Lecture>> listSessions(String courseId) async {
    final body = await _client.getJson('/api/v1/courses/$courseId/sessions');
    return _list(
      body,
      'GET /api/v1/courses/{courseId}/sessions',
    ).map(_sessionFromJson).toList();
  }

  Future<Lecture> createSession({
    required String courseId,
    required int sessionNumber,
    required String title,
    required DateTime sessionDate,
    DateTime? startsAt,
    DateTime? endsAt,
  }) async {
    final body = await _client.postJson(
      '/api/v1/courses/$courseId/sessions',
      body: {
        'sessionNumber': sessionNumber,
        'title': title,
        'sessionDate': _dateOnly(sessionDate),
        if (startsAt != null) 'startsAt': startsAt.toUtc().toIso8601String(),
        if (endsAt != null) 'endsAt': endsAt.toUtc().toIso8601String(),
      },
    );
    return _sessionFromJson(
      _map(body, 'POST /api/v1/courses/{courseId}/sessions'),
    );
  }

  Future<Lecture> getSession(String sessionId) async {
    final body = await _client.getJson('/api/v1/sessions/$sessionId');
    return _sessionFromJson(_map(body, 'GET /api/v1/sessions/{sessionId}'));
  }

  Future<List<Exam>> listExams(
    Course course, {
    List<Lecture> sessions = const [],
  }) async {
    final body = await _client.getJson('/api/v1/courses/${course.id}/exams');
    return _list(body, 'GET /api/v1/courses/{courseId}/exams')
        .map((item) => _examFromJson(item, course: course, sessions: sessions))
        .toList();
  }

  Future<Exam> createExam({
    required Course course,
    required String title,
    required DateTime examAt,
    required List<Lecture> sessions,
  }) async {
    final body = await _client.postJson(
      '/api/v1/courses/${course.id}/exams',
      body: {
        'title': title,
        'examAt': examAt.toUtc().toIso8601String(),
        'sessionIds': sessions.map((session) => session.id).toList(),
      },
    );
    return _examFromJson(
      _map(body, 'POST /api/v1/courses/{courseId}/exams'),
      course: course,
      sessions: sessions,
    );
  }

  Map<String, Object?> _slotBody(TimetableSlot slot) {
    return {
      'courseId': slot.courseId,
      'weekday': slot.weekday,
      'startTime': slot.startTime,
      'endTime': slot.endTime,
      'timezone': slot.timezone,
    };
  }

  Course _courseFromJson(Object? value) {
    final json = _map(value, 'course');
    return Course(
      id: _string(json, 'id'),
      name: _string(json, 'name'),
      instructor: _optionalString(json, 'instructor'),
      term: _optionalString(json, 'term'),
    );
  }

  TimetableSlot _slotFromJson(Object? value) {
    final json = _map(value, 'timetable slot');
    return TimetableSlot(
      id: _string(json, 'id'),
      courseId: _string(json, 'courseId'),
      weekday: _int(json, 'weekday'),
      startTime: _time(json, 'startTime'),
      endTime: _time(json, 'endTime'),
      timezone: _optionalString(json, 'timezone') ?? 'Asia/Seoul',
    );
  }

  Lecture _sessionFromJson(Object? value) {
    final json = _map(value, 'class session');
    final sessionNumber = _int(json, 'sessionNumber');
    final sessionDate = DateTime.parse(_string(json, 'sessionDate'));
    return Lecture(
      id: _string(json, 'id'),
      courseId: _string(json, 'courseId'),
      week: '$sessionNumber주차',
      title: _string(json, 'title'),
      date: '${sessionDate.month}/${sessionDate.day}',
      done: false,
      stars: 0,
    );
  }

  Exam _examFromJson(
    Object? value, {
    required Course course,
    required List<Lecture> sessions,
  }) {
    final json = _map(value, 'exam');
    final sessionIds = _stringList(json['sessionIds']);
    final sessionById = {for (final session in sessions) session.id: session};
    return Exam(
      id: _string(json, 'id'),
      courseId: _string(json, 'courseId'),
      courseName: course.name,
      title: _string(json, 'title'),
      examAt: DateTime.parse(_string(json, 'examAt')).toLocal(),
      sessionIds: sessionIds,
      sessionTitles: sessionIds
          .map((id) => sessionById[id]?.week ?? id)
          .toList(),
    );
  }

  List<Object?> _list(Object? value, String source) {
    if (value is List) return value;
    throw _shapeError(source, 'Expected a list response.', value);
  }

  Map<String, Object?> _map(Object? value, String source) {
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    throw _shapeError(source, 'Expected an object response.', value);
  }

  String _string(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value == null) {
      throw _shapeError(key, 'Missing required field.', json);
    }
    return value.toString();
  }

  String? _optionalString(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value == null) return null;
    final text = value.toString();
    return text.isEmpty ? null : text;
  }

  int _int(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.parse(value);
    throw _shapeError(key, 'Expected an integer field.', json);
  }

  String _time(Map<String, Object?> json, String key) {
    final value = _string(json, key);
    final parts = value.split(':');
    if (parts.length < 2) {
      throw _shapeError(key, 'Expected HH:mm or HH:mm:ss.', json);
    }
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }

  List<String> _stringList(Object? value) {
    if (value is! List) {
      throw _shapeError('sessionIds', 'Expected a list field.', value);
    }
    return value.map((item) => item.toString()).toList();
  }

  String _dateOnly(DateTime value) {
    return '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
  }

  ApiException _shapeError(String source, String message, Object? body) {
    return ApiException(
      statusCode: 200,
      code: 'INVALID_RESPONSE_SHAPE',
      message: '$message ($source)',
      responseBody: body,
    );
  }
}
