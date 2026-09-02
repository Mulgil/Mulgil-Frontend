import 'package:flutter/material.dart';

import '../../data/api_client.dart';
import '../../data/app_services.dart';
import '../../data/resource_upload_api.dart';
import '../../data/upload_file_picker.dart';
import '../../models/recording_candidate.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

enum _Stage { pick, uploading, mapping, done }

class RecordingUploadScreen extends StatefulWidget {
  final ResourceUploadApi? api;

  const RecordingUploadScreen({super.key, this.api});

  @override
  State<RecordingUploadScreen> createState() => _RecordingUploadScreenState();
}

class _RecordingUploadScreenState extends State<RecordingUploadScreen> {
  late final ResourceUploadApi _api;
  _Stage _stage = _Stage.pick;
  DateTime _startedAt = DateTime.now();
  String? _fileName;
  String? _recordingId;
  String? _selectedSessionId;
  String? _errorMessage;
  bool _isConfirming = false;
  List<RecordingCandidate> _candidates = const [];

  @override
  void initState() {
    super.initState();
    _api = widget.api ?? AppServices.resourceUpload;
  }

  Future<void> _pickAndUpload() async {
    try {
      final file = await UploadFilePicker.pickRecording();
      if (file == null) return;
      setState(() {
        _fileName = file.filename;
        _errorMessage = null;
        _stage = _Stage.uploading;
      });
      final result = await _api.uploadRecording(
        file: file,
        startedAt: _startedAt,
      );
      if (!mounted) return;
      setState(() {
        _recordingId = result.recordingId;
        _candidates = result.candidateSessions;
        _selectedSessionId = result.candidateSessions.isEmpty
            ? null
            : result.candidateSessions.first.id;
        _stage = _Stage.mapping;
      });
    } on Exception catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _messageFor(error);
        _stage = _Stage.pick;
      });
    }
  }

  Future<void> _confirmMapping() async {
    final recordingId = _recordingId;
    final sessionId = _selectedSessionId;
    if (recordingId == null || sessionId == null || _isConfirming) return;

    setState(() {
      _isConfirming = true;
      _errorMessage = null;
    });
    try {
      await _api.confirmRecordingMapping(
        recordingId: recordingId,
        sessionId: sessionId,
      );
      if (!mounted) return;
      setState(() => _stage = _Stage.done);
    } on Exception catch (error) {
      if (!mounted) return;
      setState(() {
        _isConfirming = false;
        _errorMessage = _messageFor(error);
      });
    }
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _startedAt,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (selected == null || !mounted) return;
    setState(() {
      _startedAt = DateTime(
        selected.year,
        selected.month,
        selected.day,
        _startedAt.hour,
        _startedAt.minute,
      );
    });
  }

  Future<void> _pickTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startedAt),
    );
    if (selected == null || !mounted) return;
    setState(() {
      _startedAt = DateTime(
        _startedAt.year,
        _startedAt.month,
        _startedAt.day,
        selected.hour,
        selected.minute,
      );
    });
  }

  String _messageFor(Object error) {
    if (error is ApiException) return error.message;
    return '녹음 업로드에 실패했어요.';
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
        return _PickStage(
          startedAt: _startedAt,
          errorMessage: _errorMessage,
          onPickDate: _pickDate,
          onPickTime: _pickTime,
          onPick: _pickAndUpload,
        );
      case _Stage.uploading:
        return _UploadingStage(fileName: _fileName);
      case _Stage.mapping:
        return _MappingStage(
          candidates: _candidates,
          selectedId: _selectedSessionId,
          errorMessage: _errorMessage,
          isConfirming: _isConfirming,
          onSelect: (id) => setState(() => _selectedSessionId = id),
          onConfirm: _confirmMapping,
        );
      case _Stage.done:
        return _DoneStage(onClose: () => Navigator.pop(context, true));
    }
  }
}

class _PickStage extends StatelessWidget {
  final DateTime startedAt;
  final String? errorMessage;
  final VoidCallback onPickDate;
  final VoidCallback onPickTime;
  final VoidCallback onPick;

  const _PickStage({
    required this.startedAt,
    required this.errorMessage,
    required this.onPickDate,
    required this.onPickTime,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MulgilCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '녹음 시작 시각',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onPickDate,
                      child: Text(_dateLabel(startedAt)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onPickTime,
                      child: Text(_timeLabel(startedAt)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
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
        if (errorMessage != null) ...[
          const SizedBox(height: 12),
          _InlineError(message: errorMessage!),
        ],
      ],
    );
  }

  String _dateLabel(DateTime value) {
    return '${value.year}.${value.month}.${value.day}';
  }

  String _timeLabel(DateTime value) {
    return '${value.hour.toString().padLeft(2, '0')}:'
        '${value.minute.toString().padLeft(2, '0')}';
  }
}

class _UploadingStage extends StatelessWidget {
  final String? fileName;

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
            fileName == null ? '업로드 중이에요...' : '$fileName 업로드 중이에요...',
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _MappingStage extends StatelessWidget {
  final List<RecordingCandidate> candidates;
  final String? selectedId;
  final String? errorMessage;
  final bool isConfirming;
  final ValueChanged<String> onSelect;
  final VoidCallback onConfirm;

  const _MappingStage({
    required this.candidates,
    required this.selectedId,
    required this.errorMessage,
    required this.isConfirming,
    required this.onSelect,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    if (candidates.isEmpty) {
      return const Center(
        child: Text(
          '겹치는 차시를 찾지 못했어요',
          style: TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
      );
    }

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
          '겹치는 시간대를 기준으로 추천했어요',
          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            children: [
              ...candidates.map(
                (candidate) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                    onTap: () => onSelect(candidate.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: selectedId == candidate.id
                            ? AppColors.tealSoft
                            : AppColors.surfaceAlt,
                        border: Border.all(
                          color: selectedId == candidate.id
                              ? AppColors.teal
                              : Colors.transparent,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              candidate.title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${(candidate.overlapScore * 100).round()}% 일치',
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
              if (errorMessage != null) _InlineError(message: errorMessage!),
            ],
          ),
        ),
        const SizedBox(height: 12),
        MulgilButton(
          label: isConfirming ? '확정 중...' : '차시 확정',
          onTap: selectedId == null || isConfirming ? null : onConfirm,
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

class _InlineError extends StatelessWidget {
  final String message;

  const _InlineError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.coralSoft,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Text(
        message,
        style: const TextStyle(fontSize: 12, color: AppColors.coral),
      ),
    );
  }
}
