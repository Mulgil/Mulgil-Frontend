import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../app_routes_map.dart';
import '../widgets/mulgil_logo.dart';
import 'home/home_screen.dart';
import 'note/note_list_screen.dart';
import 'note/ai_summary_screen.dart';
import 'quiz/quiz_screen.dart';
import 'settings/settings_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _index = 0;

  void _goToTab(int index) => setState(() => _index = index);

  // Home owns a nested Navigator so tapping a subject to open 필기/퀴즈/요약
  // pushes within Home's own slot instead of the app's root Navigator —
  // otherwise that push would cover the tablet sidebar / mobile bottom bar.
  Widget _homeTab() => Navigator(
    onGenerateRoute: (settings) {
      // The nested navigator's own root page is Home; anything else
      // (noteDetail, exams, quiz, ...) falls through to the shared route
      // table so pushNamed still resolves to the right screen with its
      // arguments intact, instead of re-rendering Home for every route.
      if (settings.name == Navigator.defaultRouteName) {
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => HomeScreen(onOpenSettings: () => _goToTab(4)),
        );
      }
      return generateAppRoute(settings);
    },
  );

  List<Widget> get _mobileScreens => [
    _homeTab(),
    const NoteListScreen(),
    const AiSummaryScreen(),
    const QuizScreen(),
    const SettingsScreen(),
  ];

  List<Widget> get _tabletScreens => [
    _homeTab(),
    const NoteListScreen(),
    const AiSummaryScreen(),
    const QuizScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return context.isTablet ? _buildTabletShell() : _buildMobileShell();
  }

  static const _mobileNavItems = [
    (icon: Icons.home_outlined, activeIcon: Icons.home, label: '홈'),
    (icon: Icons.edit_note_outlined, activeIcon: Icons.edit_note, label: '필기'),
    (
      icon: Icons.auto_awesome_outlined,
      activeIcon: Icons.auto_awesome,
      label: '요약',
    ),
    (icon: Icons.quiz_outlined, activeIcon: Icons.quiz, label: '퀴즈'),
    (icon: Icons.person_outline, activeIcon: Icons.person, label: '마이'),
  ];

  Widget _buildMobileShell() {
    final screens = _mobileScreens;
    // The tablet sidebar has more tabs than the mobile bottom bar, so resizing
    // across the breakpoint can leave _index pointing past the mobile list.
    final safeIndex = _index < screens.length ? _index : 0;
    return Scaffold(
      body: IndexedStack(index: safeIndex, children: screens),
      bottomNavigationBar: _FloatingNavBar(
        currentIndex: safeIndex,
        onTap: _goToTab,
        items: _mobileNavItems,
      ),
    );
  }

  Widget _buildTabletShell() {
    final screens = _tabletScreens;
    final safeIndex = _index < screens.length ? _index : 0;
    final navItems = [
      {'icon': Icons.home_outlined, 'activeIcon': Icons.home, 'label': '홈'},
      {
        'icon': Icons.edit_note_outlined,
        'activeIcon': Icons.edit_note,
        'label': '필기',
      },
      {
        'icon': Icons.auto_awesome_outlined,
        'activeIcon': Icons.auto_awesome,
        'label': '요약',
      },
      {'icon': Icons.quiz_outlined, 'activeIcon': Icons.quiz, 'label': '퀴즈'},
      {
        'icon': Icons.settings_outlined,
        'activeIcon': Icons.settings,
        'label': '설정',
      },
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
                  final sel = safeIndex == e.key;
                  return GestureDetector(
                    onTap: () => _goToTab(e.key),
                    child: Container(
                      width: 48,
                      height: 48,
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        color: sel
                            ? Colors.white.withValues(alpha: 0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Tooltip(
                        message: e.value['label'] as String,
                        child: Icon(
                          sel
                              ? e.value['activeIcon'] as IconData
                              : e.value['icon'] as IconData,
                          color: sel
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.5),
                          size: 22,
                        ),
                      ),
                    ),
                  );
                }),
                const Spacer(),
                // Streak badge at bottom
                const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Column(
                    children: [
                      Text('🔥', style: TextStyle(fontSize: 20)),
                      SizedBox(height: 2),
                      Text(
                        '12',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: IndexedStack(index: safeIndex, children: screens),
          ),
        ],
      ),
    );
  }
}

typedef _NavItem = ({IconData icon, IconData activeIcon, String label});

// Floating pill-shaped bottom nav (blurred translucent bar, active tab gets a
// soft rounded highlight) instead of a bar docked flush to the screen edge.
class _FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<_NavItem> items;

  const _FloatingNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ink.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(child: _navButton(i, items[i])),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navButton(int index, _NavItem item) {
    final on = index == currentIndex;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: on ? AppColors.tealSoft : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              on ? item.activeIcon : item.icon,
              size: 22,
              color: on ? AppColors.navy : AppColors.ink40,
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: on ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: -0.2,
                color: on ? AppColors.navy : AppColors.ink40,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
