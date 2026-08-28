import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/mulgil_logo.dart';
import 'home/home_screen.dart';
import 'note/note_list_screen.dart';
import 'quiz/quiz_screen.dart';
import 'report/weekly_report_screen.dart';
import 'settings/settings_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _index = 0;

  static const _mobileScreens = <Widget>[HomeScreen(), NoteListScreen(), QuizScreen(), WeeklyReportScreen()];

  static const _tabletScreens = <Widget>[HomeScreen(), NoteListScreen(), QuizScreen(), WeeklyReportScreen(), SettingsScreen()];

  @override
  Widget build(BuildContext context) {
    return context.isTablet ? _buildTabletShell() : _buildMobileShell();
  }

  Widget _buildMobileShell() {
    return Scaffold(
      body: IndexedStack(index: _index, children: _mobileScreens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        selectedItemColor: AppColors.navy,
        unselectedItemColor: AppColors.textLight,
        selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.edit_note_outlined), activeIcon: Icon(Icons.edit_note), label: '필기'),
          BottomNavigationBarItem(icon: Icon(Icons.quiz_outlined), activeIcon: Icon(Icons.quiz), label: '퀴즈'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), activeIcon: Icon(Icons.bar_chart), label: '마이'),
        ],
      ),
    );
  }

  Widget _buildTabletShell() {
    final navItems = [
      {'icon': Icons.home_outlined, 'activeIcon': Icons.home, 'label': '홈'},
      {'icon': Icons.edit_note_outlined, 'activeIcon': Icons.edit_note, 'label': '과목'},
      {'icon': Icons.quiz_outlined, 'activeIcon': Icons.quiz, 'label': '퀴즈'},
      {'icon': Icons.report_outlined, 'activeIcon': Icons.report, 'label': '오답노트'},
      {'icon': Icons.settings_outlined, 'activeIcon': Icons.settings, 'label': '설정'},
    ];

    return Scaffold(
      body: Row(
        children: [
          // Dark sidebar
          Container(
            width: 68,
            color: AppColors.navy,
            child: Column(
              children: [
                const SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: MulgilBubbles(size: 28),
                  ),
                ),
                const SizedBox(height: 8),
                ...navItems.asMap().entries.map((e) {
                  final sel = _index == e.key;
                  return GestureDetector(
                    onTap: () => setState(() => _index = e.key),
                    child: Container(
                      width: 48,
                      height: 48,
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        color: sel ? Colors.white.withValues(alpha: 0.15) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Tooltip(
                        message: e.value['label'] as String,
                        child: Icon(
                          sel ? e.value['activeIcon'] as IconData : e.value['icon'] as IconData,
                          color: sel ? Colors.white : Colors.white.withValues(alpha: 0.5),
                          size: 22,
                        ),
                      ),
                    ),
                  );
                }),
                const Spacer(),
                // Streak badge at bottom
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    children: const [
                      Text('🔥', style: TextStyle(fontSize: 20)),
                      SizedBox(height: 2),
                      Text('12', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: IndexedStack(index: _index, children: _tabletScreens),
          ),
        ],
      ),
    );
  }
}
