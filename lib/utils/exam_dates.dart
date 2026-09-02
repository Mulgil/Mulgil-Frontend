DateTime examCalendarDate(DateTime value) {
  return DateTime.utc(value.year, value.month, value.day);
}

int examDday(DateTime examAt, {DateTime? today}) {
  final from = examCalendarDate(today ?? DateTime.now());
  final target = examCalendarDate(examAt);
  return target.difference(from).inDays;
}

bool isUpcomingExam(DateTime examAt, {DateTime? today}) {
  return examDday(examAt, today: today) >= 0;
}
