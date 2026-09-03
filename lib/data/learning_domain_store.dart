import 'package:flutter/foundation.dart';

import '../models/course.dart';
import '../models/exam.dart';
import '../models/lecture.dart';
import '../models/timetable_slot.dart';
import 'api_client.dart';
import 'app_services.dart';
import 'auth_store.dart';
import 'learning_domain_api.dart';

class LearningDomainStore extends ChangeNotifier {
  static final instance = LearningDomainStore(AppServices.learningDomain);

  final LearningDomainApi _api;

  LearningDomainStore(this._api);

  bool _isLoading = false;
  bool _hasLoaded = false;
  bool _needsAuthentication = false;
  Future<void>? _activeLoad;
  Future<void>? _queuedRefresh;
  String? _errorMessage;
  List<Course> _courses = const [];
  List<TimetableSlot> _timetableSlots = const [];
  Map<String, List<Lecture>> _sessionsByCourseId = const {};
  List<Exam> _exams = const [];

  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  bool get needsAuthentication => _needsAuthentication;
  String? get errorMessage => _errorMessage;
  List<Course> get courses => List<Course>.unmodifiable(_courses);
  List<TimetableSlot> get timetableSlots =>
      List<TimetableSlot>.unmodifiable(_timetableSlots);
  List<Exam> get exams => List<Exam>.unmodifiable(_exams);
  List<Lecture> get sessions => List<Lecture>.unmodifiable(
    _sessionsByCourseId.values.expand((sessions) => sessions),
  );
  List<String> get courseNames =>
      _courses.map((course) => course.name).toList();

  List<Lecture> sessionsFor(String courseId) {
    return List<Lecture>.unmodifiable(
      _sessionsByCourseId[courseId] ?? const [],
    );
  }

  Course? courseById(String id) {
    for (final course in _courses) {
      if (course.id == id) return course;
    }
    return null;
  }

  Course? courseByName(String name) {
    for (final course in _courses) {
      if (course.name == name) return course;
    }
    return null;
  }

  Future<void> load({bool force = false}) {
    final activeLoad = _activeLoad;
    if (activeLoad != null) {
      if (!force) return activeLoad;
      return _queuedRefresh ??= activeLoad.whenComplete(() {
        _queuedRefresh = null;
        return load(force: true);
      });
    }
    final currentNeedsAuthentication = !AuthStore.hasAccessToken;
    if (_hasLoaded &&
        !force &&
        _needsAuthentication == currentNeedsAuthentication) {
      return Future<void>.value();
    }

    _activeLoad = _loadNow().whenComplete(() => _activeLoad = null);
    return _activeLoad!;
  }

  Future<void> refresh({bool requireSuccess = false}) async {
    await load(force: true);
    if (requireSuccess && _errorMessage != null) {
      throw ApiException(
        statusCode: 0,
        code: 'REFRESH_FAILED',
        message: _errorMessage!,
      );
    }
  }

  Future<void> _loadNow() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (!AuthStore.hasAccessToken) {
      _setState(
        courses: const [],
        timetableSlots: const [],
        sessionsByCourseId: const {},
        exams: const [],
        needsAuthentication: true,
      );
      return;
    }

    try {
      final courses = await _api.listCourses();
      final timetableSlots = await _api.listTimetableSlots();
      final sessionsByCourseId = <String, List<Lecture>>{};
      final exams = <Exam>[];

      for (final course in courses) {
        final sessions = await _api.listSessions(course.id);
        sessionsByCourseId[course.id] = sessions;
        exams.addAll(await _api.listExams(course, sessions: sessions));
      }

      _setState(
        courses: courses,
        timetableSlots: timetableSlots,
        sessionsByCourseId: sessionsByCourseId,
        exams: exams,
      );
    } on Exception catch (error) {
      _setError(error);
    }
  }

  Future<void> createCourseWithSlots(
    Course course,
    List<TimetableSlot> slots,
  ) async {
    _ensureAuthenticated();
    final created = await _api.createCourse(
      name: course.name,
      instructor: course.instructor,
      term: course.term,
    );
    try {
      for (final slot in slots) {
        await _api.createTimetableSlot(
          TimetableSlot(
            id: slot.id,
            courseId: created.id,
            weekday: slot.weekday,
            startTime: slot.startTime,
            endTime: slot.endTime,
            timezone: slot.timezone,
          ),
        );
      }
    } on Exception {
      await _deletePartialCourse(created.id);
      await refresh();
      rethrow;
    }
    await refresh(requireSuccess: true);
  }

  Future<void> deleteCourse(Course course) async {
    _ensureAuthenticated();
    await _api.deleteCourse(course.id);
    await refresh(requireSuccess: true);
  }

  void clear() {
    _setState(
      courses: const [],
      timetableSlots: const [],
      sessionsByCourseId: const {},
      exams: const [],
      needsAuthentication: !AuthStore.hasAccessToken,
    );
  }

  void _setState({
    required List<Course> courses,
    required List<TimetableSlot> timetableSlots,
    required Map<String, List<Lecture>> sessionsByCourseId,
    required List<Exam> exams,
    bool needsAuthentication = false,
  }) {
    _courses = List<Course>.unmodifiable(courses);
    _timetableSlots = List<TimetableSlot>.unmodifiable(timetableSlots);
    _sessionsByCourseId = Map<String, List<Lecture>>.unmodifiable({
      for (final entry in sessionsByCourseId.entries)
        entry.key: List<Lecture>.unmodifiable(entry.value),
    });
    _exams = List<Exam>.unmodifiable(exams);
    _needsAuthentication = needsAuthentication;
    _errorMessage = null;
    _hasLoaded = true;
    _isLoading = false;
    notifyListeners();
  }

  void _setError(Object error) {
    _isLoading = false;
    _hasLoaded = true;
    _needsAuthentication = error is ApiException && error.statusCode == 401;
    _errorMessage = _messageFor(error);
    if (_needsAuthentication) {
      _courses = const [];
      _timetableSlots = const [];
      _sessionsByCourseId = const {};
      _exams = const [];
    }
    notifyListeners();
  }

  void _ensureAuthenticated() {
    if (AuthStore.hasAccessToken) return;
    throw const ApiException(
      statusCode: 401,
      code: 'AUTH_REQUIRED',
      message: 'Google 로그인 연결 후 서버에 저장할 수 있어요.',
    );
  }

  Future<void> _deletePartialCourse(String courseId) async {
    try {
      await _api.deleteCourse(courseId);
    } on Exception {
      // Keep the original slot creation error for the caller.
    }
  }

  String _messageFor(Object error) {
    if (error is ApiException) {
      if (error.statusCode == 401) {
        return '로그인 세션이 필요해요.';
      }
      return error.message;
    }
    return '학습 정보를 불러오지 못했어요.';
  }
}
