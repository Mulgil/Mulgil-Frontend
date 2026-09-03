import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../models/recording_candidate.dart';

enum _Stage { pick, uploading, mapping, done }

// Mirrors POST /recordings/upload-url -> upload-complete -> confirm-mapping.
class RecordingUploadScreen extends StatefulWidget {
  const RecordingUploadScreen({super.key});

  @override
  State<RecordingUploadScreen> createState() => _RecordingUploadScreenState();
}

class _RecordingUploadScreenState extends State<RecordingUploadScreen> {
  _Stage _stage = _Stage.pick;
  String? _selectedSessionId;

  Future<void> _pickAndUpload() async {
    setState(() => _stage = _Stage.uploading);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _stage = _Stage.mapping);
  }

  Future<void> _confirmMapping() async {
    if (_selectedSessionId == null) return;
    await Future.delayed(const Duration(milliseconds: 500));
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
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('강의 녹음 업로드', style: AppTextStyles.h2),
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
      case _Stage.pick:
        return _PickStage(onPick: _pickAndUpload);
      case _Stage.uploading:
        return const _UploadingStage();
      case _Stage.mapping:
        return _MappingStage(
          candidates: const [],
          selectedId: _selectedSessionId,
          onSelect: (id) => setState(() => _selectedSessionId = id),
          onConfirm: _confirmMapping,
        );
      case _Stage.done:
        return _DoneStage(onClose: () => Navigator.pop(context));
    }
  }
}

class _PickStage extends StatelessWidget {
  final VoidCallback onPick;
  const _PickStage({required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: MulgilCard(
            onTap: onPick,
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: const Column(
              children: [
                Icon(Icons.mic_none, size: 32, color: AppColors.tealDark),
                SizedBox(height: 8),
                Text(
                  '녹음 파일 선택 (m4a / mp4)',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.tealDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '최대 3시간까지 업로드할 수 있어요',
                  style: TextStyle(fontSize: 11, color: AppColors.textLight),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _UploadingStage extends StatelessWidget {
  const _UploadingStage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            '업로드 중이에요...',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _MappingStage extends StatelessWidget {
  final List<RecordingCandidate> candidates;
  final String? selectedId;
  final ValueChanged<String> onSelect;
  final VoidCallback onConfirm;
  const _MappingStage({
    required this.candidates,
    required this.selectedId,
    required this.onSelect,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '어느 차시 녹음인가요?',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          '녹음 처리가 끝나면 차시에 연결할 수 있어요',
          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        const SizedBox(height: 16),
        if (candidates.isEmpty)
          const Expanded(
            child: Center(
              child: Text(
                '추천할 차시가 아직 없어요',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
          )
        else
          ...candidates.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => onSelect(c.id),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: selectedId == c.id
                        ? AppColors.tealSoft
                        : AppColors.surfaceAlt,
                    border: Border.all(
                      color: selectedId == c.id
                          ? AppColors.teal
                          : Colors.transparent,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        c.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${(c.overlapScore * 100).round()}% 일치',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.tealDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        const Spacer(),
        MulgilButton(
          label: '차시 확정',
          onTap: selectedId == null ? null : onConfirm,
        ),
      ],
    );
  }
}

class _DoneStage extends StatelessWidget {
  final VoidCallback onClose;
  const _DoneStage({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle, size: 48, color: AppColors.teal),
        const SizedBox(height: 12),
        const Text(
          '업로드가 완료됐어요',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          '음성 인식이 끝나면 알림으로 알려드려요',
          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        const SizedBox(height: 24),
        MulgilButton(label: '확인', onTap: onClose),
      ],
    );
  }
}
