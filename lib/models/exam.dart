enum AiJobStatus { none, queued, running, succeeded, failed, outdated }

class Exam {
  final String id;
  final String? courseId;
  final String courseName;
  final String title;
  final DateTime examAt;
  final List<String> sessionTitles;
  final List<String> sessionIds;
  final bool hasPastExamAttached;
  final AiJobStatus summaryStatus;
  final AiJobStatus quizStatus;

  const Exam({
    required this.id,
    this.courseId,
    required this.courseName,
    required this.title,
    required this.examAt,
    required this.sessionTitles,
    this.sessionIds = const [],
    this.hasPastExamAttached = false,
    this.summaryStatus = AiJobStatus.none,
    this.quizStatus = AiJobStatus.none,
  });

  Exam copyWith({
    bool? hasPastExamAttached,
    AiJobStatus? summaryStatus,
    AiJobStatus? quizStatus,
  }) {
    return Exam(
      id: id,
      courseId: courseId,
      courseName: courseName,
      title: title,
      examAt: examAt,
      sessionTitles: sessionTitles,
      sessionIds: sessionIds,
      hasPastExamAttached: hasPastExamAttached ?? this.hasPastExamAttached,
      summaryStatus: summaryStatus ?? this.summaryStatus,
      quizStatus: quizStatus ?? this.quizStatus,
    );
  }
}
