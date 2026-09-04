import 'package:flutter/material.dart';

import '../models/lecture.dart';
import '../theme/app_theme.dart';
import '../utils/academic_calendar.dart';
import 'common_widgets.dart';

class SessionWeekList extends StatelessWidget {
  final List<Lecture> sessions;
  final Widget Function(BuildContext context, Lecture session) itemBuilder;

  const SessionWeekList({
    super.key,
    required this.sessions,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final groups = groupSessionsByWeek(sessions);
    return ListView.builder(
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 2, bottom: 8),
                child: Row(
                  children: [
                    Text(
                      group.label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink60,
                      ),
                    ),
                    if (group.label == AcademicCalendar.currentWeekLabel()) ...[
                      const SizedBox(width: 6),
                      const CurrentWeekBadge(),
                    ],
                  ],
                ),
              ),
              ...group.sessions.map(
                (session) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: itemBuilder(context, session),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

List<SessionWeekGroup> groupSessionsByWeek(Iterable<Lecture> sessions) {
  final sorted = sessions.toList()
    ..sort((a, b) {
      final weekOrder = (a.weekNumber ?? 999).compareTo(b.weekNumber ?? 999);
      if (weekOrder != 0) return weekOrder;
      return (a.sessionNumber ?? 999).compareTo(b.sessionNumber ?? 999);
    });
  final grouped = <String, List<Lecture>>{};
  for (final session in sorted) {
    grouped.putIfAbsent(session.week, () => []).add(session);
  }
  return grouped.entries
      .map(
        (entry) => SessionWeekGroup(
          label: entry.key,
          sessions: List<Lecture>.unmodifiable(entry.value),
        ),
      )
      .toList(growable: false);
}

class SessionWeekGroup {
  final String label;
  final List<Lecture> sessions;

  const SessionWeekGroup({required this.label, required this.sessions});
}
