import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

enum _Stage { pickPhase, pickFile, uploading, done }

// Mirrors POST /sessions/{sessionId}/materials/upload-url -> PUT to GCS -> upload-complete.
class PdfUploadScreen extends StatefulWidget {
  const PdfUploadScreen({super.key});

  @override
  State<PdfUploadScreen> createState() => _PdfUploadScreenState();
}

class _PdfUploadScreenState extends State<PdfUploadScreen> {
  _Stage _stage = _Stage.pickPhase;
  String? _sourcePhase;
  String? _fileName;

  Future<void> _pickFile() async {
    setState(() {
      _fileName = '3주차_강의자료.pdf';
      _stage = _Stage.uploading;
    });
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _stage = _Stage.done);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: MaxContentWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      size: 18,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('PDF 자료 업로드', style: AppTextStyles.h2),
                ],
              ),
              const SizedBox(height: 28),
              Expanded(child: _buildStage()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStage() {
    switch (_stage) {
      case _Stage.pickPhase:
        return _PhaseStage(
          onSelect: (phase) => setState(() {
            _sourcePhase = phase;
            _stage = _Stage.pickFile;
          }),
        );
      case _Stage.pickFile:
        return _PickFileStage(sourcePhase: _sourcePhase!, onPick: _pickFile);
      case _Stage.uploading:
        return _UploadingStage(fileName: _fileName!);
      case _Stage.done:
        return _DoneStage(
          fileName: _fileName!,
          onClose: () => Navigator.pop(context),
        );
    }
  }
}

class _PhaseStage extends StatelessWidget {
  final ValueChanged<String> onSelect;
  const _PhaseStage({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '어떤 용도의 자료인가요?',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          '용도에 따라 AI가 미리보기/복습 자료를 다르게 생성해요',
          style: TextStyle(fontSize: 12, color: AppColors.ink60),
        ),
        const SizedBox(height: 20),
        _PhaseOption(
          icon: '📖',
          title: '수업 전 예습용 (preview)',
          desc: '강의 전에 미리 읽어볼 자료예요',
          onTap: () => onSelect('preview_pdf'),
        ),
        const SizedBox(height: 12),
        _PhaseOption(
          icon: '📝',
          title: '수업 후 복습용 (review)',
          desc: '강의가 끝난 뒤 정리·복습할 자료예요',
          onTap: () => onSelect('review_pdf'),
        ),
      ],
    );
  }
}

class _PhaseOption extends StatelessWidget {
  final String icon, title, desc;
  final VoidCallback onTap;
  const _PhaseOption({
    required this.icon,
    required this.title,
    required this.desc,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MulgilCard(
      onTap: onTap,
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 12, color: AppColors.ink60),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 18, color: AppColors.ink40),
        ],
      ),
    );
  }
}

class _PickFileStage extends StatelessWidget {
  final String sourcePhase;
  final VoidCallback onPick;
  const _PickFileStage({required this.sourcePhase, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MulgilCard(
          onTap: onPick,
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: const SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                Icon(
                  Icons.picture_as_pdf_outlined,
                  size: 32,
                  color: AppColors.tealDark,
                ),
                SizedBox(height: 8),
                Text(
                  'PDF 파일 선택',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.tealDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          '최대 50MB · 150페이지 · 세션당 5개까지',
          style: TextStyle(fontSize: 11, color: AppColors.ink40),
        ),
      ],
    );
  }
}

class _UploadingStage extends StatelessWidget {
  final String fileName;
  const _UploadingStage({required this.fileName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            '$fileName 업로드 중...',
            style: const TextStyle(fontSize: 13, color: AppColors.ink60),
          ),
        ],
      ),
    );
  }
}

class _DoneStage extends StatelessWidget {
  final String fileName;
  final VoidCallback onClose;
  const _DoneStage({required this.fileName, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle, size: 48, color: AppColors.teal),
        const SizedBox(height: 12),
        Text(
          '$fileName 업로드가 완료됐어요',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        const Text(
          'AI가 텍스트를 분석하면 알림으로 알려드려요',
          style: TextStyle(fontSize: 12, color: AppColors.ink60),
        ),
        const SizedBox(height: 24),
        MulgilButton(label: '확인', onTap: onClose),
      ],
    );
  }
}
