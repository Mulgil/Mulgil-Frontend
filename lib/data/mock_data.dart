import '../models/lecture.dart';
import '../models/quiz_question.dart';
import '../models/wrong_answer.dart';
import '../models/summary_item.dart';
import '../models/report.dart';
import '../models/app_notification.dart';
import '../models/exam.dart';
import '../models/course.dart';
import '../models/timetable_slot.dart';
import '../models/user_profile.dart';
import '../models/recording_candidate.dart';
import '../theme/app_theme.dart';

// Shared by every screen that mutates a MockData list item in place (exams,
// notifications, ...) so the "item may have been deleted elsewhere" guard
// only has to be written once instead of copy-pasted per call site.
extension ReplaceById<T> on List<T> {
  /// Replaces the first element for which [test] returns true with
  /// [replacement]. Returns false (no-op) instead of throwing if nothing
  /// matches — e.g. the item was deleted in the meantime.
  bool replaceWhere(bool Function(T) test, T replacement) {
    final i = indexWhere(test);
    if (i == -1) return false;
    this[i] = replacement;
    return true;
  }
}

// Replace each field with an API call when the backend is ready.
// e.g. MockData.lectures → await ApiService.getLectures(subjectId)
abstract final class MockData {
  static const currentUser = UserProfile(
    name: '지민',
    school: '숭실대학교',
    department: '소프트웨어학부',
    year: 3,
    avatarInitial: '유',
  );

  static const lectures = [
    Lecture(
      id: 'l1',
      courseId: 'c1',
      week: '1주차',
      title: '컴퓨터 구조 개요',
      date: '3/1',
      done: true,
      quiz: '8/10',
      stars: 2,
    ),
    Lecture(
      id: 'l2',
      courseId: 'c1',
      week: '2주차',
      title: '프로세스',
      date: '3/8',
      done: true,
      quiz: '4/10',
      stars: 3,
    ),
    Lecture(
      id: 'l3',
      courseId: 'c1',
      week: '3주차',
      title: '스레드와 동기화',
      done: false,
      stars: 0,
    ),
    Lecture(
      id: 'l4',
      courseId: 'c1',
      week: '4주차',
      title: '데드락',
      done: false,
      stars: 0,
    ),
    Lecture(
      id: 'l5',
      courseId: 'c2',
      week: '1주차',
      title: '배열과 연결 리스트',
      date: '9/1',
      done: true,
      quiz: '7/10',
      stars: 2,
    ),
    Lecture(
      id: 'l6',
      courseId: 'c2',
      week: '2주차',
      title: '스택과 큐',
      date: '9/8',
      done: true,
      stars: 1,
    ),
    Lecture(
      id: 'l7',
      courseId: 'c2',
      week: '3주차',
      title: '트리와 이진 탐색 트리',
      done: false,
      stars: 0,
    ),
    Lecture(
      id: 'l8',
      courseId: 'c3',
      week: '1주차',
      title: '관계형 모델과 정규화',
      date: '9/1',
      done: true,
      quiz: '6/10',
      stars: 2,
    ),
    Lecture(
      id: 'l9',
      courseId: 'c3',
      week: '2주차',
      title: 'SQL 기초',
      date: '9/8',
      done: true,
      stars: 0,
    ),
    Lecture(
      id: 'l10',
      courseId: 'c3',
      week: '3주차',
      title: '트랜잭션과 동시성 제어',
      done: false,
      stars: 0,
    ),
  ];

  static const quizQuestions = [
    QuizQuestion(
      question: '프로세스와 스레드는 같은 개념이다.',
      answer: 1,
      explanation: '프로세스는 실행 중인 프로그램, 스레드는 실행 단위입니다.',
    ),
    QuizQuestion(
      question: '세마포어는 이진값만 가질 수 있다.',
      answer: 0,
      explanation: '세마포어는 0 이상의 정수값을 가질 수 있습니다.',
    ),
    QuizQuestion(
      question: '컨텍스트 스위칭 비용은 무시할 수 있다.',
      answer: 1,
      explanation: '컨텍스트 스위칭은 오버헤드가 발생합니다.',
    ),
    QuizQuestion(
      type: QuizType.multipleChoice,
      question: '실행 시간이 가장 짧은 작업을 우선 처리하는 스케줄링 기법은?',
      options: ['FCFS', 'SJF', 'Round Robin', 'Priority Scheduling'],
      answer: 1,
      explanation: 'SJF(Shortest Job First)는 실행 시간이 짧은 작업을 우선 처리합니다.',
    ),
    QuizQuestion(
      type: QuizType.multipleChoice,
      question: '교착상태(deadlock)의 필요조건이 아닌 것은?',
      options: ['상호 배제', '점유와 대기', '선점 가능', '순환 대기'],
      answer: 2,
      explanation: '교착상태 발생 조건은 상호 배제, 점유와 대기, 비선점, 순환 대기입니다.',
    ),
  ];

  static const wrongAnswers = [
    WrongAnswer(
      courseName: '운영체제',
      week: '2주차',
      question: '"세마포어는 이진값만 가질 수 있다."',
      myAnswer: 'X',
      correct: 'O',
      isProfEmphasis: true,
    ),
    WrongAnswer(
      courseName: '운영체제',
      week: '2주차',
      question: '"컨텍스트 스위칭 비용은 무시할 수 있다."',
      myAnswer: 'O',
      correct: 'X',
      isProfEmphasis: false,
    ),
    WrongAnswer(
      courseName: '운영체제',
      week: '2주차',
      question: '"라운드로빈은 우선순위 기반 스케줄링이다."',
      myAnswer: 'O',
      correct: 'X',
      isProfEmphasis: false,
    ),
    WrongAnswer(
      courseName: '운영체제',
      week: '2주차',
      question: '실행 시간이 가장 짧은 작업을 우선 처리하는 스케줄링 기법은?',
      myAnswer: 'FCFS',
      correct: 'SJF',
      isProfEmphasis: true,
    ),
    WrongAnswer(
      courseName: '자료구조',
      week: '1주차',
      question: '"이진 탐색 트리는 항상 균형을 이룬다."',
      myAnswer: 'O',
      correct: 'X',
      isProfEmphasis: true,
    ),
    WrongAnswer(
      courseName: '자료구조',
      week: '1주차',
      question: '"연결 리스트의 임의 위치 접근은 O(1)이다."',
      myAnswer: 'O',
      correct: 'X',
      isProfEmphasis: false,
    ),
    WrongAnswer(
      courseName: '데이터베이스',
      week: '1주차',
      question: '"제3정규형을 만족하면 자동으로 BCNF도 만족한다."',
      myAnswer: 'O',
      correct: 'X',
      isProfEmphasis: false,
    ),
    WrongAnswer(
      courseName: '데이터베이스',
      week: '1주차',
      question: '"인덱스를 추가해도 조회 성능에는 영향이 없다."',
      myAnswer: 'O',
      correct: 'X',
      isProfEmphasis: true,
    ),
  ];

  static const summaryItems = [
    SummaryItem(
      title: '프로세스와 스레드',
      body:
          '프로세스는 실행 중인 프로그램의 인스턴스이며, 독립적인 메모리 공간을 가집니다. 스레드는 프로세스 내에서 실행되는 단위로, 같은 메모리를 공유합니다.',
      isEmphasis: true,
    ),
    SummaryItem(
      title: '컨텍스트 스위칭',
      body: 'CPU가 현재 작업을 중지하고 다른 작업을 시작할 때 발생합니다. 레지스터 상태 저장/복원 비용이 따릅니다.',
      isEmphasis: false,
    ),
    SummaryItem(
      title: '스케줄링 알고리즘',
      body: 'FCFS, SJF, Round Robin, Priority Scheduling 등이 있으며 각각 장단점이 있습니다.',
      isEmphasis: false,
    ),
  ];

  static const profEmphasisPoint = SummaryItem(
    title: '세마포어의 P(wait) / V(signal) 연산',
    body: '세마포어는 공유 자원 접근을 제어하는 정수형 변수로, 이진/계수 세마포어로 나뉜다.',
    isEmphasis: true,
  );

  static const mindmapCenterLabel = '운영체제';
  static const mindmapNodeLabels = ['프로세스', '스레드', '스케줄링', '동기화'];

  static const originalNoteParagraphs = [
    '세마포어는 공유 자원에 대한 접근을 제어하는 동기화 도구로, 초기값과 P/V 연산으로 동작한다.',
    '뮤텍스는 세마포어의 특수한 형태로, 값이 0 또는 1만 가지는 이진 세마포어에 해당한다.',
    '모니터는 상호 배제와 조건 변수를 결합한 고수준 동기화 기법이다.',
  ];

  static const quizReferenceTitle = '프로세스 스케줄링';

  static const pendingHandwritingGuess = '세마포어는 P/V 연산으로 제어된다';
  static const mentionFrequencyLabel = '언급 빈도 +1 · ⭐⭐';

  static const weeklyTotalStudy = '18h 42m';
  static const weeklyQuizAccuracy = '74%';
  static const currentStreak = '12일';
  static const weeklyNotesCompleted = '23개';

  static const recordingCandidates = [
    RecordingCandidate(id: 's1', title: '운영체제 · 3주차', overlapScore: 0.92),
    RecordingCandidate(id: 's2', title: '운영체제 · 4주차', overlapScore: 0.41),
  ];

  // Course and TimetableSlot are separate resources per the API (POST /courses vs POST /timetable/slots).
  static final List<Course> courses = [
    const Course(id: 'c1', name: '운영체제', instructor: '김민수 교수님', term: '2026-2'),
    const Course(id: 'c2', name: '자료구조', instructor: '이하나 교수님', term: '2026-2'),
    const Course(
      id: 'c3',
      name: '데이터베이스',
      instructor: '박철수 교수님',
      term: '2026-2',
    ),
  ];

  static final List<TimetableSlot> timetableSlots = [
    const TimetableSlot(
      id: 't1',
      courseId: 'c1',
      weekday: 1,
      startTime: '09:00',
      endTime: '10:15',
    ),
    const TimetableSlot(
      id: 't2',
      courseId: 'c1',
      weekday: 4,
      startTime: '09:00',
      endTime: '10:15',
    ),
    const TimetableSlot(
      id: 't3',
      courseId: 'c2',
      weekday: 2,
      startTime: '10:30',
      endTime: '11:45',
    ),
    const TimetableSlot(
      id: 't4',
      courseId: 'c2',
      weekday: 5,
      startTime: '10:30',
      endTime: '11:45',
    ),
    const TimetableSlot(
      id: 't5',
      courseId: 'c3',
      weekday: 3,
      startTime: '13:00',
      endTime: '14:15',
    ),
    const TimetableSlot(
      id: 't6',
      courseId: 'c3',
      weekday: 5,
      startTime: '15:00',
      endTime: '16:15',
    ),
  ];

  static List<String> get courseNames => courses.map((c) => c.name).toList();

  // Removes the given courses along with everything keyed off them — their
  // timetable slots and their exams — so callers can't cascade only partway
  // (e.g. dropping a course's slots but leaving its exams orphaned).
  static Map<String, String> get courseProfessors => {
    for (final c in courses) c.name: c.instructor ?? '',
  };

  static List<TimetableSlot> slotsFor(String courseId) =>
      timetableSlots.where((s) => s.courseId == courseId).toList();

  static String slotsSummary(String courseId) {
    final slots = slotsFor(courseId);
    if (slots.isEmpty) return '시간표 없음';
    return slots.map((s) => '${s.weekdayLabel} ${s.startTime}').join(', ');
  }

  // Cross-references the weekly timetable against today's weekday (time of
  // day isn't checked — any class scheduled today counts) and returns the
  // earliest one, if any.
  static TimetableSlot? todaysSlot([DateTime? now]) {
    final n = now ?? DateTime.now();
    final todays = timetableSlots.where((s) => s.weekday == n.weekday).toList()
      ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
    return todays.isEmpty ? null : todays.first;
  }

  // 1학기는 3/2, 2학기는 9/1 개강 기준으로 오늘이 몇 주차인지 계산 — 필기/퀴즈/요약 리스트에서
  // "이번 주" 배지를 붙이는 데 쓴다. 개강 전이면 직전 학기(작년 2학기)가 아직 진행 중인 것으로 본다.
  static int currentWeekNumber([DateTime? now]) {
    final n = now ?? DateTime.now();
    final springStart = DateTime(n.year, 3, 2);
    final fallStart = DateTime(n.year, 9, 1);
    final DateTime start;
    if (n.isBefore(springStart)) {
      start = DateTime(n.year - 1, 9, 1);
    } else if (n.isBefore(fallStart)) {
      start = springStart;
    } else {
      start = fallStart;
    }
    return (n.difference(start).inDays ~/ 7) + 1;
  }

  static String get currentWeekLabel => '${currentWeekNumber()}주차';

  // Nullable rather than throwing — once this is backed by a real API, a
  // courseId that doesn't resolve (deleted course, stale reference) is an
  // expected case callers need to handle, not a crash.
  static Course? courseById(String id) {
    for (final c in courses) {
      if (c.id == id) return c;
    }
    return null;
  }

  static Course? courseByName(String name) {
    for (final c in courses) {
      if (c.name == name) return c;
    }
    return null;
  }

  static int? nextExamDDay(String courseName) {
    final dDays = exams
        .where((e) => e.courseName == courseName)
        .map((e) => e.examAt.difference(DateTime.now()).inDays)
        .where((d) => d >= 0);
    return dDays.isEmpty ? null : dDays.reduce((a, b) => a < b ? a : b);
  }

  static const studyDays = ['월', '화', '수', '목', '금', '토', '일'];
  static const studyHours = [2.5, 3.0, 1.5, 4.0, 2.0, 3.5, 2.2];

  static const subjectRecords = [
    SubjectRecord(name: '운영체제', hours: 7.5, color: AppColors.teal),
    SubjectRecord(name: '자료구조', hours: 5.2, color: AppColors.navy),
    SubjectRecord(name: '데이터베이스', hours: 4.0, color: AppColors.coral),
    SubjectRecord(name: '알고리즘', hours: 2.0, color: AppColors.yellow),
  ];
  static const totalStudyHours = 18.7;

  static final notifications = [
    AppNotification(
      id: 'n1',
      type: NotificationType.processingComplete,
      title: 'AI 요약이 준비됐어요',
      body: '운영체제 2주차 요약본을 확인해보세요',
      deepLink: 'mulgil://sessions/1/summary/review',
      status: NotificationStatus.sent,
      scheduledAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    AppNotification(
      id: 'n2',
      type: NotificationType.examReminder,
      title: '시험이 4일 남았어요',
      body: '운영체제 중간고사 대비 복습을 시작해보세요',
      deepLink: 'mulgil://exams/1',
      status: NotificationStatus.sent,
      scheduledAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    AppNotification(
      id: 'n3',
      type: NotificationType.postClassReminder,
      title: '방금 들은 강의, 필기 남기셨나요?',
      body: '자료구조 5주차가 끝났어요',
      deepLink: 'mulgil://sessions/5/notes',
      status: NotificationStatus.sent,
      scheduledAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  static final exams = [
    Exam(
      id: 'e1',
      courseName: '운영체제',
      title: '중간고사',
      examAt: DateTime.now().add(const Duration(days: 4)),
      sessionTitles: const ['1주차', '2주차', '3주차'],
      hasPastExamAttached: true,
      summaryStatus: AiJobStatus.succeeded,
      quizStatus: AiJobStatus.failed,
    ),
    Exam(
      id: 'e2',
      courseName: '자료구조',
      title: '기말고사',
      examAt: DateTime.now().add(const Duration(days: 16)),
      sessionTitles: const ['4주차', '5주차'],
      hasPastExamAttached: false,
      summaryStatus: AiJobStatus.none,
      quizStatus: AiJobStatus.none,
    ),
  ];
}
