// Mirrors TimetableSlotWriteRequest — a separate resource from Course, one row per weekday.
class TimetableSlot {
  final String id;
  final String courseId;
  final int weekday; // ISO: Monday=1 ... Sunday=7
  final String startTime; // "HH:mm"
  final String endTime; // "HH:mm"
  final String timezone;

  const TimetableSlot({
    required this.id,
    required this.courseId,
    required this.weekday,
    required this.startTime,
    required this.endTime,
    this.timezone = 'Asia/Seoul',
  });

  static const weekdayLabels = ['월', '화', '수', '목', '금', '토', '일'];

  String get weekdayLabel => weekdayLabels[weekday - 1];

  int get startMinutes => _parseMinutes(startTime);
  int get endMinutes => _parseMinutes(endTime);

  static int _parseMinutes(String hhmm) {
    final parts = hhmm.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
}
