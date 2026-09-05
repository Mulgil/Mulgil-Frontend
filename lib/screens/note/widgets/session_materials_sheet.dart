import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/api_client.dart';
import '../../../data/app_services.dart';
import '../../../data/resource_upload_api.dart';
import '../../../models/lecture.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common_widgets.dart';

typedef MaterialUrlOpener = Future<bool> Function(Uri url);

Future<void> showSessionMaterialsSheet(
  BuildContext context, {
  required Lecture lecture,
  ResourceUploadApi? api,
  MaterialUrlOpener? openUrl,
}) {
  return showMulgilModalScreen<void>(
    context,
    heightFraction: 0.78,
    builder: (_) =>
        SessionMaterialsSheet(lecture: lecture, api: api, openUrl: openUrl),
  );
}

class SessionMaterialsSheet extends StatefulWidget {
  final Lecture lecture;
  final ResourceUploadApi? api;
  final MaterialUrlOpener? openUrl;

  const SessionMaterialsSheet({
    super.key,
    required this.lecture,
    this.api,
    this.openUrl,
  });

  @override
  State<SessionMaterialsSheet> createState() => _SessionMaterialsSheetState();
}

class _SessionMaterialsSheetState extends State<SessionMaterialsSheet> {
  late final ResourceUploadApi _api;
  late final MaterialUrlOpener _openUrl;
  Timer? _pollTimer;
  bool _isLoading = true;
  String? _errorMessage;
  String? _openingMaterialId;
  String? _deletingMaterialId;
  List<SessionMaterial> _materials = const [];
  List<SessionProcessingJob> _jobs = const [];

  @override
  void initState() {
    super.initState();
    _api = widget.api ?? AppServices.resourceUpload;
    _openUrl = widget.openUrl ?? _launchExternalUrl;
    unawaited(_load(showLoading: true));
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _load({bool showLoading = false}) async {
    if (showLoading && mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }
    try {
      final response = await Future.wait([
        _api.listSessionMaterials(widget.lecture.id),
        _api.listSessionJobs(widget.lecture.id),
      ]);
      if (!mounted) return;
      setState(() {
        _materials = (response[0] as List<SessionMaterial>)
            .where((material) => material.isVisible)
            .toList(growable: false);
        _jobs = response[1] as List<SessionProcessingJob>;
        _errorMessage = null;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = error.message);
    } on Exception {
      if (!mounted) return;
      setState(() => _errorMessage = '자료 상태를 불러오지 못했어요.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _schedulePolling();
      }
    }
  }

  void _schedulePolling() {
    _pollTimer?.cancel();
    if (_jobs.any((job) => job.isMaterialPreparation && job.status.isActive)) {
      _pollTimer = Timer(const Duration(seconds: 3), _load);
    }
  }

  Future<void> _openMaterial(SessionMaterial material) async {
    if (!material.isDownloadable ||
        _openingMaterialId != null ||
        _deletingMaterialId != null) {
      return;
    }
    setState(() => _openingMaterialId = material.id);
    try {
      final download = await _api.issueMaterialDownloadUrl(material.id);
      final opened = await _openUrl(download.downloadUrl);
      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF를 열 수 없어요. 다시 시도해주세요.')),
        );
      }
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } on Exception {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF를 열지 못했어요. 다시 시도해주세요.')),
        );
      }
    } finally {
      if (mounted) setState(() => _openingMaterialId = null);
    }
  }

  Future<void> _deleteMaterial(SessionMaterial material) async {
    if (_deletingMaterialId != null || _openingMaterialId != null) return;
    setState(() => _deletingMaterialId = material.id);
    try {
      await _api.deleteMaterial(material.id);
      await _load();
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } on Exception {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('PDF를 삭제하지 못했어요.')));
      }
    } finally {
      if (mounted) setState(() => _deletingMaterialId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('첨부 자료', style: AppTextStyles.h2),
                      const SizedBox(height: 3),
                      Text(
                        '${widget.lecture.week} · ${widget.lecture.title}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.ink60,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: '자료 상태 새로고침',
                  onPressed: _isLoading ? null : () => _load(showLoading: true),
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading && _materials.isEmpty && _errorMessage == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null && _materials.isEmpty) {
      return _LoadError(
        message: _errorMessage!,
        onRetry: () => _load(showLoading: true),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          _DocumentAnalysisStatusCard(
            jobs: _jobs.where((job) => job.isDocumentAnalysis),
          ),
          const SizedBox(height: 10),
          _ContentIndexingStatusCard(
            jobs: _jobs.where((job) => job.isContentIndexing),
          ),
          const SizedBox(height: 16),
          Text(
            'PDF 자료 ${_materials.length}개',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 10),
          if (_materials.isEmpty)
            const _EmptyMaterials()
          else
            ..._materials.map(
              (material) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _MaterialTile(
                  material: material,
                  isOpening: _openingMaterialId == material.id,
                  isDeleting: _deletingMaterialId == material.id,
                  onOpen: () => _openMaterial(material),
                  onDelete: () => _confirmDeleteMaterial(material),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteMaterial(SessionMaterial material) async {
    if (_deletingMaterialId != null || _openingMaterialId != null) return;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('PDF 삭제'),
        content: const Text('이 PDF를 삭제할까요?\n첨부 자료에서 영구 삭제돼요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (shouldDelete == true) {
      await _deleteMaterial(material);
    }
  }
}

Future<bool> _launchExternalUrl(Uri url) {
  return launchUrl(url, webOnlyWindowName: '_blank');
}

class _DocumentAnalysisStatusCard extends StatelessWidget {
  final Iterable<SessionProcessingJob> jobs;

  const _DocumentAnalysisStatusCard({required this.jobs});

  @override
  Widget build(BuildContext context) {
    final status = _JobGroupStatus.from(jobs);
    return _JobStatusCard(
      title: 'PDF 분석 상태',
      status: status,
      message: status.isActive
          ? 'PDF 분석 중이에요.'
          : status.hasFailed
          ? 'PDF 분석에 실패했어요. 업로드한 PDF는 열어볼 수 있어요.'
          : status.succeeded > 0
          ? 'PDF 분석이 완료됐어요.'
          : 'PDF 분석 상태를 확인하고 있어요.',
    );
  }
}

class _ContentIndexingStatusCard extends StatelessWidget {
  final Iterable<SessionProcessingJob> jobs;

  const _ContentIndexingStatusCard({required this.jobs});

  @override
  Widget build(BuildContext context) {
    final status = _JobGroupStatus.from(jobs);
    return _JobStatusCard(
      title: 'AI 콘텐츠 준비 상태',
      status: status,
      message: status.isActive
          ? 'AI 콘텐츠를 준비하고 있어요.'
          : status.hasFailed
          ? 'AI 콘텐츠 준비에 실패했어요.'
          : status.succeeded > 0
          ? 'AI 콘텐츠 준비가 완료됐어요.'
          : 'AI 콘텐츠 준비 상태를 확인하고 있어요.',
      detail:
          '대기 ${status.queued}개 · 진행 ${status.running}개 · 완료 ${status.succeeded}개 · 실패 ${status.failed}개',
      footer: '요약, 마인드맵, 연습 문제, 기출 문제 생성에만 반영돼요.',
    );
  }
}

class _JobStatusCard extends StatelessWidget {
  final String title;
  final _JobGroupStatus status;
  final String message;
  final String? detail;
  final String? footer;

  const _JobStatusCard({
    required this.title,
    required this.status,
    required this.message,
    this.detail,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final icon = status.isActive
        ? Icons.hourglass_top_outlined
        : status.hasFailed
        ? Icons.error_outline
        : Icons.check_circle_outline;
    final color = status.isActive
        ? AppColors.tealDark
        : status.hasFailed
        ? AppColors.coral
        : AppColors.teal;
    return MulgilCard(
      color: AppColors.surfaceAlt,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: const TextStyle(fontSize: 12, color: AppColors.ink60),
          ),
          if (detail != null) ...[
            const SizedBox(height: 4),
            Text(
              detail!,
              style: const TextStyle(fontSize: 12, color: AppColors.ink60),
            ),
          ],
          if (footer != null) ...[
            const SizedBox(height: 4),
            Text(
              footer!,
              style: const TextStyle(fontSize: 12, color: AppColors.ink60),
            ),
          ],
        ],
      ),
    );
  }
}

class _JobGroupStatus {
  final int queued;
  final int running;
  final int succeeded;
  final int failed;

  const _JobGroupStatus({
    required this.queued,
    required this.running,
    required this.succeeded,
    required this.failed,
  });

  factory _JobGroupStatus.from(Iterable<SessionProcessingJob> jobs) {
    var queued = 0;
    var running = 0;
    var succeeded = 0;
    var failed = 0;
    for (final job in jobs) {
      switch (job.status) {
        case ProcessingJobStatus.queued:
          queued++;
        case ProcessingJobStatus.running:
          running++;
        case ProcessingJobStatus.succeeded:
          succeeded++;
        case ProcessingJobStatus.failed:
          failed++;
        case ProcessingJobStatus.outdated:
        case ProcessingJobStatus.cancelled:
        case ProcessingJobStatus.unknown:
          break;
      }
    }
    return _JobGroupStatus(
      queued: queued,
      running: running,
      succeeded: succeeded,
      failed: failed,
    );
  }

  bool get isActive => queued > 0 || running > 0;
  bool get hasFailed => failed > 0;
}

class _MaterialTile extends StatelessWidget {
  final SessionMaterial material;
  final bool isOpening;
  final bool isDeleting;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  const _MaterialTile({
    required this.material,
    required this.isOpening,
    required this.isDeleting,
    required this.onOpen,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final metadata = <String>[
      _materialStatusLabel(material.status),
      material.sourcePhase == MaterialSourcePhase.previewPdf ? '예습' : '복습',
      if (material.pageCount != null) '${material.pageCount}페이지',
      _formatBytes(material.byteSize),
    ];
    return MulgilCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      onTap: material.isDownloadable && !isDeleting ? onOpen : null,
      child: Row(
        children: [
          const Icon(
            Icons.picture_as_pdf_outlined,
            color: AppColors.coral,
            size: 24,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  material.filename,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  metadata.join(' · '),
                  style: const TextStyle(fontSize: 11, color: AppColors.ink60),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: material.isDownloadable ? 'PDF 열기' : '업로드 완료 전 자료',
            onPressed: material.isDownloadable && !isOpening && !isDeleting
                ? onOpen
                : null,
            icon: isOpening
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.open_in_new, size: 20),
          ),
          IconButton(
            tooltip: '첨부 자료에서 삭제',
            onPressed: isDeleting || isOpening ? null : onDelete,
            icon: isDeleting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.close, size: 20),
          ),
        ],
      ),
    );
  }
}

class _EmptyMaterials extends StatelessWidget {
  const _EmptyMaterials();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          Icon(Icons.picture_as_pdf_outlined, color: AppColors.ink40),
          SizedBox(height: 8),
          Text(
            '등록된 PDF 자료가 없어요',
            style: TextStyle(fontSize: 12, color: AppColors.ink60),
          ),
        ],
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _LoadError({required this.message, required this.onRetry});

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

String _formatBytes(int bytes) {
  if (bytes < 1024 * 1024) return '${(bytes / 1024).ceil()}KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
}

String _materialStatusLabel(MaterialUploadStatus status) {
  return switch (status) {
    MaterialUploadStatus.uploaded => '업로드 완료',
    MaterialUploadStatus.created => '업로드 중',
    MaterialUploadStatus.cancelled => '삭제됨',
    MaterialUploadStatus.outdated => '만료됨',
    MaterialUploadStatus.unknown => '상태 확인 필요',
  };
}
