import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
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
      initialRoute: '/splash',
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/onboarding': (_) => const OnboardingScreen(),
        '/': (_) => const ShellScreen(),
        '/note': (_) => const NoteListScreen(),
        '/note/detail': (_) => const NoteDetailScreen(),
        '/summary': (_) => const AiSummaryScreen(),
        '/note/pdf-upload': (_) => const PdfUploadScreen(),
        '/quiz': (_) => const QuizScreen(),
        '/settings': (_) => const SettingsScreen(),
        '/notifications': (_) => const NotificationListScreen(),
        '/exams': (_) => const ExamListScreen(),
        '/recording': (_) => const RecordingUploadScreen(),
      },
    );
  }
}
