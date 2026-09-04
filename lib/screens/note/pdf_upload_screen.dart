import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/api_client.dart';
import '../../data/app_services.dart';
import '../../data/learning_domain_store.dart';
import '../../data/resource_upload_api.dart';
import '../../data/upload_file_picker.dart';
import '../../models/course.dart';
import '../../models/lecture.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

enum _Stage { pickSession, pickPhase, pickFile, uploading, done }

class PdfUploadOutcome {
  final Lecture lecture;
  final String fileName;
  final MaterialUploadResult uploadResult;

  const PdfUploadOutcome({
    required this.lecture,
    required this.fileName,
    required this.uploadResult,
  });
}

class PdfUploadScreen extends StatefulWidget {
  final LearningDomainStore? store;
  final ResourceUploadApi? api;

  const PdfUploadScreen({super.key, this.store, this.api});

  @override
  State<PdfUploadScreen> createState() => _PdfUploadScreenState();
}

class _PdfUploadScreenState extends State<PdfUploadScreen> {
  late final LearningDomainStore _learningStore;
  late final ResourceUploadApi _api;
  _Stage _stage = _Stage.pickSession;
  _UploadSession? _session;
  MaterialSourcePhase? _sourcePhase;
  String? _fileName;
  String? _errorMessage;
  PdfUploadOutcome? _uploadOutcome;

  @override
  void initState() {
    super.initState();
    _learningStore = widget.store ?? LearningDomainStore.instance;
    _api = widget.api ?? AppServices.resourceUpload;
    unawaited(_learningStore.load());
  }

  List<_UploadSession> get _sessions {
    final sessions = <_UploadSession>[];
    for (final course in _learningStore.courses) {
      for (final lecture in _learningStore.sessionsFor(course.id)) {
        sessions.add(_UploadSession(course: course, lecture: lecture));
      }
    }
    return sessions;
  }

  Future<void> _pickFile() async {
    final session = _session;
    final sourcePhase = _sourcePhase;
    if (session == null || sourcePhase == null) return;

    try {
      final file = await UploadFilePicker.pickPdf();
      if (file == null) return;
      setState(() {
        _fileName = file.filename;
        _errorMessage = null;
        _stage = _Stage.uploading;
      });
      final result = await _api.uploadSessionMaterial(
        sessionId: session.lecture.id,
        file: file,
        sourcePhase: sourcePhase,
      );
      if (!mounted) return;
      setState(() {
        _uploadOutcome = PdfUploadOutcome(
          lecture: session.lecture,
          fileName: file.filename,
          uploadResult: result,
        );
        _stage = _Stage.done;
      });
    } on Exception catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _messageFor(error);
        _stage = _Stage.pickFile;
      });
    }
  }

  String _messageFor(Object error) {
    if (error is ApiException) return error.message;
    return 'PDF 업로드에 실패했어요.';
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
      case _Stage.pickSession:
        return ListenableBuilder(
          listenable: _learningStore,
          builder: (context, _) {
            if (_learningStore.isLoading && !_learningStore.hasLoaded) {
              return const Center(child: CircularProgressIndicator());
            }
            if (_learningStore.needsAuthentication ||
                _learningStore.errorMessage != null) {
              return _StatusNotice(
                message:
                    _learningStore.errorMessage ??
                    'Google 로그인 토큰이 연결되면 업로드할 차시를 불러와요.',
                onRetry: _learningStore.refresh,
              );
            }
            return _SessionStage(
              sessions: _sessions,
              onSelect: (session) => setState(() {
                _session = session;
                _stage = _Stage.pickPhase;
              }),
            );
          },
        );
      case _Stage.pickPhase:
        return _PhaseStage(
          session: _session!,
          onSelect: (phase) => setState(() {
            _sourcePhase = phase;
            _stage = _Stage.pickFile;
          }),
        );
      case _Stage.pickFile:
        return _PickFileStage(
          session: _session!,
          sourcePhase: _sourcePhase!,
          errorMessage: _errorMessage,
          onPick: _pickFile,
        );
      case _Stage.uploading:
        return _UploadingStage(fileName: _fileName!);
      case _Stage.done:
        return _DoneStage(
          fileName: _fileName!,
          onViewMaterials: () => Navigator.pop(context, _uploadOutcome),
          onClose: () => Navigator.pop(context),
        );
    }
  }
}

class _UploadSession {
  final Course course;
  final Lecture lecture;

  const _UploadSession({required this.course, required this.lecture});

  String get label => '${course.name} · ${lecture.week} ${lecture.title}';
}

class _SessionStage extends StatelessWidget {
  final List<_UploadSession> sessions;
  final ValueChanged<_UploadSession> onSelect;

  const _SessionStage({required this.sessions, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return const Center(
        child: Text(
          '업로드할 차시가 없어요',
          style: TextStyle(fontSize: 13, color: AppColors.ink60),
        ),
      );
    }
    return ListView.separated(
      itemCount: sessions.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, index) {
        final session = sessions[index];
        return MulgilCard(
          onTap: () => onSelect(session),
          child: Row(
            children: [
              const Icon(
                Icons.menu_book_outlined,
                size: 20,
                color: AppColors.tealDark,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  session.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, size: 18, color: AppColors.ink40),
            ],
          ),
        );
      },
    );
  }
}

class _PhaseStage extends StatelessWidget {
  final _UploadSession session;
  final ValueChanged<MaterialSourcePhase> onSelect;

  const _PhaseStage({required this.session, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          session.label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.tealDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 20),
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
          icon: Icons.visibility_outlined,
          title: '수업 전 예습용',
          desc: '강의 전에 미리 읽어볼 자료예요',
          onTap: () => onSelect(MaterialSourcePhase.previewPdf),
        ),
        const SizedBox(height: 12),
        _PhaseOption(
          icon: Icons.edit_note_outlined,
          title: '수업 후 복습용',
          desc: '강의가 끝난 뒤 정리·복습할 자료예요',
          onTap: () => onSelect(MaterialSourcePhase.reviewPdf),
        ),
      ],
    );
  }
}

class _PhaseOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
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
          Icon(icon, size: 22, color: AppColors.tealDark),
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
  final _UploadSession session;
  final MaterialSourcePhase sourcePhase;
  final String? errorMessage;
  final VoidCallback onPick;

  const _PickFileStage({
    required this.session,
    required this.sourcePhase,
    required this.errorMessage,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final phaseLabel = sourcePhase == MaterialSourcePhase.previewPdf
        ? '수업 전 예습용'
        : '수업 후 복습용';
    return Column(
      children: [
        _ContextLine(label: session.label, sublabel: phaseLabel),
        const SizedBox(height: 16),
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
        if (errorMessage != null) ...[
          const SizedBox(height: 12),
          _InlineError(message: errorMessage!),
        ],
      ],
    );
  }
}

class _ContextLine extends StatelessWidget {
  final String label;
  final String sublabel;

  const _ContextLine({required this.label, required this.sublabel});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sublabel,
            style: const TextStyle(fontSize: 12, color: AppColors.ink60),
          ),
        ],
      ),
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
  final VoidCallback onViewMaterials;
  final VoidCallback onClose;

  const _DoneStage({
    required this.fileName,
    required this.onViewMaterials,
    required this.onClose,
  });

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
          '차시 자료에서 처리 상태와 PDF를 확인할 수 있어요',
          style: TextStyle(fontSize: 12, color: AppColors.ink60),
        ),
        const SizedBox(height: 24),
        MulgilButton(label: '첨부 자료 확인', onTap: onViewMaterials),
        const SizedBox(height: 8),
        TextButton(onPressed: onClose, child: const Text('닫기')),
      ],
    );
  }
}

class _StatusNotice extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _StatusNotice({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: const TextStyle(fontSize: 13, color: AppColors.ink60),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: const Text('다시 시도')),
        ],
      ),
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
