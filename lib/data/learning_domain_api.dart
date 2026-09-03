import '../models/app_notification.dart';
import '../models/course.dart';
import '../models/exam.dart';
import '../models/lecture.dart';
import '../models/quiz_attempt_result.dart';
import '../models/quiz_question.dart';
import '../models/source_ref.dart';
import '../models/summary_item.dart';
import '../models/timetable_slot.dart';
import 'api_client.dart';

class SessionSummary {
  final List<SummaryItem> items;
  final List<String> mindmapNodeLabels;

  const SessionSummary({
    required this.items,
    this.mindmapNodeLabels = const [],
  });
}

class LearningDomainApi {
  static const _seoulOffset = Duration(hours: 9);

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
    required List<Lecture> sessions,
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
        'examAt': _seoulDateToInstant(examAt),
        'sessionIds': sessions.map((session) => session.id).toList(),
      },
    );
    return _examFromJson(
      _map(body, 'POST /api/v1/courses/{courseId}/exams'),
      course: course,
      sessions: sessions,
    );
  }

  Future<SessionSummary> getSessionSummary(
    String sessionId, {
    String type = 'review',
  }) async {
    final body = await _client.getJson(
      '/api/v1/sessions/$sessionId/summaries',
      queryParameters: {'type': type},
    );
    final json = _map(body, 'GET /api/v1/sessions/{sessionId}/summaries');
    return _sessionSummaryFromJson(json);
  }

  Future<List<QuizQuestion>> listSessionQuiz(String sessionId) async {
    final body = await _client.getJson('/api/v1/sessions/$sessionId/quiz');
    return _list(
      body,
      'GET /api/v1/sessions/{sessionId}/quiz',
    ).map(_quizQuestionFromJson).toList();
  }

  Future<QuizAttemptResult> submitQuizAttempt({
    required String questionId,
    required Object answer,
  }) async {
    final body = await _client.postJson(
      '/api/v1/quiz/questions/$questionId/attempts',
      body: {'answer': answer},
    );
    return _quizAttemptFromJson(
      _map(body, 'POST /api/v1/quiz/questions/{questionId}/attempts'),
    );
  }

  Future<List<AppNotification>> listNotifications({
    bool unreadOnly = false,
  }) async {
    final body = await _client.getJson(
      '/api/v1/notifications',
      queryParameters: {'unreadOnly': unreadOnly},
    );
    return _list(
      body,
      'GET /api/v1/notifications',
    ).map(_notificationFromJson).toList();
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
      examAt: _seoulDateFromInstant(_string(json, 'examAt')),
      sessionIds: sessionIds,
      sessionTitles: sessionIds
          .map((id) => sessionById[id]?.week)
          .whereType<String>()
          .toList(),
    );
  }

  SessionSummary _sessionSummaryFromJson(Map<String, Object?> json) {
    final summary = _map(json['summary'], 'summary');
    final items = _list(summary['items'], 'summary.items')
        .asMap()
        .entries
        .map((entry) => _summaryItemFromJson(entry.value, entry.key))
        .whereType<SummaryItem>()
        .toList();
    final mindmap = json['mindmap'] is Map
        ? _map(json['mindmap'], 'mindmap')
        : const <String, Object?>{};
    return SessionSummary(
      items: items,
      mindmapNodeLabels: _mindmapLabels(mindmap['nodes']),
    );
  }

  SummaryItem? _summaryItemFromJson(Object? value, int index) {
    final json = _map(value, 'summary item');
    final body =
        _optionalString(json, 'body') ??
        _optionalString(json, 'text') ??
        _optionalString(json, 'content');
    if (body == null) return null;
    final explicitTitle = _optionalString(json, 'title');
    return SummaryItem(
      title: explicitTitle ?? '요약 ${index + 1}',
      body: body,
      isEmphasis: json['isEmphasis'] == true || json['emphasis'] == true,
    );
  }

  List<String> _mindmapLabels(Object? value) {
    if (value is! List) return const [];
    return value
        .map((node) {
          if (node is Map) {
            final json = node.map(
              (key, value) => MapEntry(key.toString(), value),
            );
            return _optionalString(json, 'label') ??
                _optionalString(json, 'text') ??
                _optionalString(json, 'title') ??
                _optionalString(json, 'id');
          }
          return node?.toString();
        })
        .whereType<String>()
        .where((label) => label.trim().isNotEmpty)
        .toList();
  }

  QuizQuestion _quizQuestionFromJson(Object? value) {
    final json = _map(value, 'quiz question');
    final type = _quizType(_string(json, 'type'));
    return QuizQuestion(
      id: _string(json, 'id'),
      type: type,
      prompt: _string(json, 'prompt'),
      options: type == QuizType.multipleChoice
          ? _stringList(json['options'])
          : null,
      sourceRefs: _sourceRefs(json['sourceRefs']),
    );
  }

  QuizAttemptResult _quizAttemptFromJson(Map<String, Object?> json) {
    final answer = _map(json['answer'], 'quiz attempt answer');
    final explanation = _map(json['explanation'], 'quiz attempt explanation');
    final progress = _map(json['progress'], 'quiz attempt progress');
    return QuizAttemptResult(
      attemptId: _string(json, 'attemptId'),
      isCorrect: json['isCorrect'] == true,
      answer: QuizAnswerFact(
        value: answer['value'] as Object,
        sourceRefs: _sourceRefs(answer['sourceRefs']),
      ),
      explanation: QuizExplanation(
        text: _string(explanation, 'text'),
        sourceRefs: _sourceRefs(explanation['sourceRefs']),
      ),
      progress: QuizProgress(
        sessionId: _string(progress, 'scopeId'),
        correctCount: _int(progress, 'correctCount'),
        incorrectCount: _int(progress, 'incorrectCount'),
        lastAttemptAt: DateTime.parse(_string(progress, 'lastAttemptAt')),
        updatedAt: DateTime.parse(_string(progress, 'updatedAt')),
      ),
    );
  }

  AppNotification _notificationFromJson(Object? value) {
    final json = _map(value, 'notification');
    return AppNotification(
      id: _string(json, 'id'),
      type: _notificationType(_string(json, 'type')),
      title: _string(json, 'title'),
      body: _string(json, 'body'),
      deepLink: _string(json, 'deepLink'),
      status: _notificationStatus(_string(json, 'status')),
      scheduledAt: DateTime.parse(_string(json, 'scheduledAt')),
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

  QuizType _quizType(String value) {
    return switch (_normalized(value)) {
      'truefalse' => QuizType.trueFalse,
      'multiplechoice' => QuizType.multipleChoice,
      _ => throw _shapeError('type', 'Unknown quiz type.', value),
    };
  }

  NotificationType _notificationType(String value) {
    return switch (_normalized(value)) {
      'postclassreminder' => NotificationType.postClassReminder,
      'processingcomplete' => NotificationType.processingComplete,
      'examreminder' => NotificationType.examReminder,
      _ => throw _shapeError('type', 'Unknown notification type.', value),
    };
  }

  NotificationStatus _notificationStatus(String value) {
    return switch (_normalized(value)) {
      'scheduled' => NotificationStatus.scheduled,
      'sent' => NotificationStatus.sent,
      'failed' => NotificationStatus.failed,
      'cancelled' => NotificationStatus.cancelled,
      _ => throw _shapeError('status', 'Unknown notification status.', value),
    };
  }

  List<SourceRef> _sourceRefs(Object? value) {
    if (value is! List) return const [];
    return value.map(_sourceRefFromJson).whereType<SourceRef>().toList();
  }

  SourceRef? _sourceRefFromJson(Object? value) {
    if (value is! Map) return null;
    final json = value.map((key, detail) => MapEntry(key.toString(), detail));
    final type = _sourceRefType(json['sourceType']);
    if (type == null) return null;
    return SourceRef(
      sourceType: type,
      materialId: _optionalString(json, 'materialId'),
      examResourceId: _optionalString(json, 'examResourceId'),
      contentBlockId: _optionalString(json, 'contentBlockId'),
      pageNumber: _optionalInt(json, 'pageNumber'),
      bboxNorm: _bboxNorm(json['bboxNorm']),
      handwritingBlockId: _optionalString(json, 'handwritingBlockId'),
      noteId: _optionalString(json, 'noteId'),
      paragraphOffset: _optionalInt(json, 'paragraphOffset'),
      recordingId: _optionalString(json, 'recordingId'),
      transcriptSegmentId: _optionalString(json, 'transcriptSegmentId'),
      startMs: _optionalInt(json, 'startMs'),
      endMs: _optionalInt(json, 'endMs'),
    );
  }

  SourceRefType? _sourceRefType(Object? value) {
    if (value == null) return null;
    return switch (_normalized(value.toString())) {
      'pdftext' => SourceRefType.pdfText,
      'handwriting' => SourceRefType.handwriting,
      'note' => SourceRefType.note,
      'transcript' => SourceRefType.transcript,
      'pastexam' => SourceRefType.pastExam,
      'table' => SourceRefType.table,
      _ => null,
    };
  }

  BboxNorm? _bboxNorm(Object? value) {
    if (value is! Map) return null;
    final json = value.map((key, detail) => MapEntry(key.toString(), detail));
    return BboxNorm(
      x: _double(json, 'x'),
      y: _double(json, 'y'),
      width: _double(json, 'width'),
      height: _double(json, 'height'),
    );
  }

  int? _optionalInt(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String && value.trim().isNotEmpty) return int.parse(value);
    return null;
  }

  double _double(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is num) return value.toDouble();
    if (value is String) return double.parse(value);
    throw _shapeError(key, 'Expected a number field.', json);
  }

  String _normalized(String value) =>
      value.replaceAll(RegExp(r'[_\-\s]'), '').toLowerCase();

  String _dateOnly(DateTime value) {
    return '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
  }

  String _seoulDateToInstant(DateTime value) {
    final seoulMidnight = DateTime.utc(value.year, value.month, value.day);
    return seoulMidnight.subtract(_seoulOffset).toIso8601String();
  }

  DateTime _seoulDateFromInstant(String value) {
    final seoulTime = DateTime.parse(value).toUtc().add(_seoulOffset);
    return DateTime(seoulTime.year, seoulTime.month, seoulTime.day);
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
