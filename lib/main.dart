import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/shell_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/note/note_list_screen.dart';
import 'screens/note/note_detail_screen.dart';
import 'screens/note/ai_summary_screen.dart';
import 'screens/quiz/quiz_screen.dart';
import 'screens/review/wrong_answer_screen.dart';
import 'screens/report/weekly_report_screen.dart';
import 'screens/settings/settings_screen.dart';

void main() {
  runApp(const MulgilApp());
}

class MulgilApp extends StatelessWidget {
  const MulgilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mulgil',
      theme: buildAppTheme(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/onboarding',
      routes: {
        '/onboarding': (_) => const OnboardingScreen(),
        '/': (_) => const ShellScreen(),
        '/note': (_) => const NoteListScreen(),
        '/note/detail': (_) => const NoteDetailScreen(),
        '/summary': (_) => const AiSummaryScreen(),
        '/quiz': (_) => const QuizScreen(),
        '/wrong-answers': (_) => const WrongAnswerScreen(),
        '/report': (_) => const WeeklyReportScreen(),
        '/settings': (_) => const SettingsScreen(),
      },
    );
  }
}
