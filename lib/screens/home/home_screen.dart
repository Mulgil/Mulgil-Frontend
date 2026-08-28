import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/mulgil_logo.dart';
import '../../widgets/common_widgets.dart';

String _formatDate(DateTime d) {
  const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
  return '${d.year}년 ${d.month}월 ${d.day}일 ${weekdays[d.weekday - 1]}요일';
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_formatDate(today), style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
              const SizedBox(height: 2),
              const Text('안녕하세요, 지민님', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const SizedBox(height: 14),
              _StreakCard(),
              const SizedBox(height: 12),
              _NextExamCard(),
              const SizedBox(height: 14),
              _QuickActions(),
              const SizedBox(height: 16),
              const SectionHeader(title: '최근 노트'),
              _NoteCard(subject: '운영체제', title: '2주차 - 프로세스', time: '2시간 전', progress: 0.7),
              const SizedBox(height: 10),
              _NoteCard(subject: '자료구조', title: '5주차 - 트리와 그래프', time: '어제', progress: 0.4),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          const MulgilBubbles(size: 28),
          const SizedBox(width: 10),
          const Text('12일 연속 학습 중', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _NextExamCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('다음 시험', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('운영체제', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const ExamDayBadge(dDay: 4),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _ActionTile(icon: '✎', label: '필기', route: '/note')),
        const SizedBox(width: 10),
        Expanded(child: _ActionTile(icon: '◐', label: '퀴즈', route: '/quiz')),
        const SizedBox(width: 10),
        Expanded(child: _ActionTile(icon: '≡', label: '요약', route: '/summary')),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String icon, label, route;
  const _ActionTile({required this.icon, required this.label, required this.route});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(route),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))]),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final String subject, title, time;
  final double progress;
  const _NoteCard({required this.subject, required this.title, required this.time, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(subject, style: const TextStyle(fontSize: 11, color: AppColors.teal, fontWeight: FontWeight.w700)),
              Text(time, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(title, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
          ),
          MulgilProgressBar(value: progress),
        ],
      ),
    );
  }
}

