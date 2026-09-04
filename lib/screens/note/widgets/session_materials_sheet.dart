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
    if (_jobs.any((job) => job.status.isActive)) {
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
          if (_jobs.isNotEmpty) ...[
            _ProcessingStatusCard(jobs: _jobs),
            const SizedBox(height: 16),
          ],
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
        content: Text('${material.filename}를 첨부 자료에서 삭제할까요?'),
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

class _ProcessingStatusCard extends StatelessWidget {
  final List<SessionProcessingJob> jobs;

  const _ProcessingStatusCard({required this.jobs});

  @override
  Widget build(BuildContext context) {
    final hasActiveJobs = jobs.any((job) => job.status.isActive);
    final hasFailedJobs = jobs.any(
      (job) => job.status == ProcessingJobStatus.failed,
    );
    final title = hasActiveJobs
        ? 'PDF 분석 중'
        : hasFailedJobs
        ? 'PDF 분석 실패'
        : 'PDF 분석 완료';
    final icon = hasActiveJobs
        ? Icons.hourglass_top_outlined
        : hasFailedJobs
        ? Icons.error_outline
        : Icons.check_circle_outline;
    final color = hasActiveJobs
        ? AppColors.tealDark
        : hasFailedJobs
        ? AppColors.coral
        : AppColors.teal;
    final message = hasActiveJobs
        ? 'AI가 PDF 내용을 읽고 있어요. 분석이 끝나면 요약/퀴즈에 자동으로 반영돼요.'
        : hasFailedJobs
        ? 'PDF는 업로드됐지만, 요약/퀴즈에는 아직 사용할 수 없어요.'
        : '요약/퀴즈에 사용할 준비가 끝났어요.';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
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
        ],
      ),
    );
  }
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
