import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'constants/routes.dart';
import 'screens/shell_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/note/note_list_screen.dart';
import 'screens/note/note_detail_screen.dart';
import 'screens/note/ai_summary_screen.dart';
import 'screens/note/pdf_upload_screen.dart';
import 'screens/quiz/quiz_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/notification/notification_list_screen.dart';
import 'screens/exam/exam_list_screen.dart';
import 'screens/recording/recording_upload_screen.dart';

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
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.onboarding: (_) => const OnboardingScreen(),
        AppRoutes.home: (_) => const ShellScreen(),
        AppRoutes.note: (_) => const NoteListScreen(),
        AppRoutes.noteDetail: (_) => const NoteDetailScreen(),
        AppRoutes.summary: (_) => const AiSummaryScreen(),
        AppRoutes.notePdfUpload: (_) => const PdfUploadScreen(),
        AppRoutes.quiz: (_) => const QuizScreen(),
        AppRoutes.settings: (_) => const SettingsScreen(),
        AppRoutes.notifications: (_) => const NotificationListScreen(),
        AppRoutes.exams: (_) => const ExamListScreen(),
        AppRoutes.recording: (_) => const RecordingUploadScreen(),
      },
    );
  }
}
