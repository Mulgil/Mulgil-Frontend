import '../models/lecture.dart';
import '../models/quiz_question.dart';
import '../models/wrong_answer.dart';
import '../models/summary_item.dart';
import '../models/report.dart';
import '../theme/app_theme.dart';

// Replace each field with an API call when the backend is ready.
// e.g. MockData.lectures → await ApiService.getLectures(subjectId)
abstract final class MockData {
  static const lectures = [
    Lecture(week: '1주차', title: '컴퓨터 구조 개요', date: '3/1', done: true, quiz: '8/10', stars: 2),
    Lecture(week: '2주차', title: '프로세스', date: '3/8', done: true, quiz: '4/10', stars: 3),
    Lecture(week: '3주차', title: '스레드와 동기화', done: false, stars: 0),
    Lecture(week: '4주차', title: '데드락', done: false, stars: 0),
  ];

  static const quizQuestions = [
    QuizQuestion(question: '프로세스와 스레드는 같은 개념이다.', answer: 1, explanation: '프로세스는 실행 중인 프로그램, 스레드는 실행 단위입니다.'),
    QuizQuestion(question: '세마포어는 이진값만 가질 수 있다.', answer: 0, explanation: '세마포어는 0 이상의 정수값을 가질 수 있습니다.'),
    QuizQuestion(question: '컨텍스트 스위칭 비용은 무시할 수 있다.', answer: 1, explanation: '컨텍스트 스위칭은 오버헤드가 발생합니다.'),
  ];

  static const wrongAnswers = [
    WrongAnswer(question: '"세마포어는 이진값만 가질 수 있다."', myAnswer: 'X', correct: 'O', isProfEmphasis: true),
    WrongAnswer(question: '"컨텍스트 스위칭 비용은 무시할 수 있다."', myAnswer: 'O', correct: 'X', isProfEmphasis: false),
    WrongAnswer(question: '"라운드로빈은 우선순위 기반 스케줄링이다."', myAnswer: 'O', correct: 'X', isProfEmphasis: false),
  ];

  static const summaryItems = [
    SummaryItem(title: '프로세스와 스레드', body: '프로세스는 실행 중인 프로그램의 인스턴스이며, 독립적인 메모리 공간을 가집니다. 스레드는 프로세스 내에서 실행되는 단위로, 같은 메모리를 공유합니다.', isEmphasis: true),
    SummaryItem(title: '컨텍스트 스위칭', body: 'CPU가 현재 작업을 중지하고 다른 작업을 시작할 때 발생합니다. 레지스터 상태 저장/복원 비용이 따릅니다.', isEmphasis: false),
    SummaryItem(title: '스케줄링 알고리즘', body: 'FCFS, SJF, Round Robin, Priority Scheduling 등이 있으며 각각 장단점이 있습니다.', isEmphasis: false),
  ];

  static const studyDays = ['월', '화', '수', '목', '금', '토', '일'];
  static const studyHours = [2.5, 3.0, 1.5, 4.0, 2.0, 3.5, 2.2];

  static const subjectRecords = [
    SubjectRecord(name: '운영체제', hours: 7.5, color: AppColors.teal),
    SubjectRecord(name: '자료구조', hours: 5.2, color: AppColors.navy),
    SubjectRecord(name: '데이터베이스', hours: 4.0, color: AppColors.coral),
    SubjectRecord(name: '알고리즘', hours: 2.0, color: AppColors.yellow),
  ];
  static const totalStudyHours = 18.7;

  static const achievements = [
    Achievement(icon: '🔥', label: '12일 연속', desc: '연속 학습 달성'),
    Achievement(icon: '🎯', label: '74% 정답률', desc: '이번 주 퀴즈'),
    Achievement(icon: '📝', label: '23개 강의', desc: '필기 완료'),
  ];
}
