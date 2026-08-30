enum AiJobStatus { none, queued, running, succeeded, failed }

class Exam {
  final String id;
  final String courseName;
  final String title;
  final DateTime examAt;
  final List<String> sessionTitles;
  final bool hasPastExamAttached;
  final AiJobStatus summaryStatus;
  final AiJobStatus quizStatus;

  const Exam({
    required this.id,
    required this.courseName,
    required this.title,
    required this.examAt,
    required this.sessionTitles,
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
      courseName: courseName,
      title: title,
      examAt: examAt,
      sessionTitles: sessionTitles,
      hasPastExamAttached: hasPastExamAttached ?? this.hasPastExamAttached,
      summaryStatus: summaryStatus ?? this.summaryStatus,
      quizStatus: quizStatus ?? this.quizStatus,
    );
  }
}
