import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

// Placeholder copy — swap in the reviewed legal text before shipping.
class LegalDocumentScreen extends StatelessWidget {
  final String title;
  final String updatedAt;
  final String body;

  const LegalDocumentScreen({super.key, required this.title, required this.updatedAt, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.arrow_back_ios, size: 18, color: AppColors.textPrimary)),
                  const SizedBox(width: 8),
                  Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 26),
                child: Text('시행일 $updatedAt', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(body, style: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary, height: 1.7)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
