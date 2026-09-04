import 'dart:async';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import '../models/recording_candidate.dart';
import 'api_client.dart';

enum MaterialSourcePhase {
  previewPdf('preview_pdf'),
  reviewPdf('review_pdf');

  final String wireName;

  const MaterialSourcePhase(this.wireName);

  static MaterialSourcePhase fromWireName(String value) {
    return MaterialSourcePhase.values.firstWhere(
      (phase) => phase.wireName == value,
      orElse: () =>
          throw FormatException('Unknown material source phase: $value'),
    );
  }
}

enum MaterialUploadStatus {
  created('created'),
  uploaded('uploaded'),
  cancelled('cancelled'),
  outdated('outdated'),
  unknown('unknown');

  final String wireName;

  const MaterialUploadStatus(this.wireName);

  static MaterialUploadStatus fromWireName(String value) {
    return MaterialUploadStatus.values.firstWhere(
      (status) => status.wireName == value,
      orElse: () => MaterialUploadStatus.unknown,
    );
  }

  bool get isUploaded => this == uploaded;
  bool get isPending => this == created;
  bool get isFailed => this == cancelled || this == outdated;
  bool get isVisible => this != cancelled && this != outdated;
}

enum ProcessingJobStatus {
  queued,
  running,
  succeeded,
  failed,
  outdated,
  cancelled,
  unknown;

  static ProcessingJobStatus fromWireName(String value) {
    return ProcessingJobStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => ProcessingJobStatus.unknown,
    );
  }

  bool get isActive => this == queued || this == running;
  bool get isTerminal => !isActive && this != unknown;
}

class SessionMaterial {
  final String id;
  final String sessionId;
  final String filename;
  final String mimeType;
  final int byteSize;
  final int? pageCount;
  final MaterialSourcePhase sourcePhase;
  final int version;
  final MaterialUploadStatus status;

  const SessionMaterial({
    required this.id,
    required this.sessionId,
    required this.filename,
    required this.mimeType,
    required this.byteSize,
    required this.pageCount,
    required this.sourcePhase,
    required this.version,
    required this.status,
  });

  bool get isVisible => status.isVisible;
  bool get isDownloadable => status.isUploaded;
}

class MaterialDownloadUrl {
  final Uri downloadUrl;
  final DateTime expiresAt;

  const MaterialDownloadUrl({
    required this.downloadUrl,
    required this.expiresAt,
  });
}

class SessionProcessingJob {
  final String id;
  final String type;
  final ProcessingJobStatus status;
  final int inputVersion;
  final int attemptCount;
  final int maxAttempts;
  final String? errorCode;
  final bool retryable;
  final DateTime createdAt;
  final DateTime? finishedAt;
  final String? materialId;

  const SessionProcessingJob({
    required this.id,
    required this.type,
    required this.status,
    required this.inputVersion,
    required this.attemptCount,
    required this.maxAttempts,
    required this.errorCode,
    this.retryable = false,
    required this.createdAt,
    required this.finishedAt,
    this.materialId,
  });
}

class UploadFile {
  final String filename;
  final String mimeType;
  final int byteSize;
  final Uri? sourceUri;
  final Stream<List<int>> Function() _openRead;

  const UploadFile.stream({
    required this.filename,
    required this.mimeType,
    required this.byteSize,
    required Stream<List<int>> Function() openRead,
    this.sourceUri,
    // ignore: prefer_initializing_formals
  }) : _openRead = openRead;

  factory UploadFile.memory({
    required String filename,
    required String mimeType,
    required List<int> bytes,
  }) {
    final data = Uint8List.fromList(bytes);
    return UploadFile.stream(
      filename: filename,
      mimeType: mimeType,
      byteSize: data.length,
      openRead: () => Stream<List<int>>.value(data),
    );
  }

  Stream<List<int>> openRead() => _openRead();
}

class UploadUrl {
  final String id;
  final Uri uploadUrl;
  final DateTime expiresAt;
  final Map<String, String> requiredHeaders;

  const UploadUrl({
    required this.id,
    required this.uploadUrl,
    required this.expiresAt,
    required this.requiredHeaders,
  });
}

class JobAccepted {
  final String jobId;
  final String status;

  const JobAccepted({required this.jobId, required this.status});
}

class MaterialUploadResult {
  final String materialId;
  final JobAccepted job;

  const MaterialUploadResult({required this.materialId, required this.job});
}

class RecordingUploadResult {
  final String recordingId;
  final int durationSeconds;
  final List<RecordingCandidate> candidateSessions;

  const RecordingUploadResult({
    required this.recordingId,
    required this.durationSeconds,
    required this.candidateSessions,
  });
}

class ResourceUploadApi {
  final ApiClient _client;

  const ResourceUploadApi(this._client);

  Future<MaterialUploadResult> uploadSessionMaterial({
    required String sessionId,
    required UploadFile file,
    required MaterialSourcePhase sourcePhase,
  }) async {
    final upload = await issueMaterialUploadUrl(
      sessionId: sessionId,
      file: file,
      sourcePhase: sourcePhase,
    );
    final checksumSha256 = await _checksumSha256(file);
    await _putSignedUpload(upload, file);
    final job = await completeMaterialUpload(
      materialId: upload.id,
      checksumSha256: checksumSha256,
    );
    return MaterialUploadResult(materialId: upload.id, job: job);
  }

  Future<RecordingUploadResult> uploadRecording({
    required UploadFile file,
    required DateTime startedAt,
  }) async {
    final upload = await issueRecordingUploadUrl(
      file: file,
      startedAt: startedAt,
    );
    final checksumSha256 = await _checksumSha256(file);
    await _putSignedUpload(upload, file);
    return completeRecordingUpload(
      recordingId: upload.id,
      checksumSha256: checksumSha256,
    );
  }

  Future<UploadUrl> issueMaterialUploadUrl({
    required String sessionId,
    required UploadFile file,
    required MaterialSourcePhase sourcePhase,
  }) async {
    final body = await _client.postJson(
      '/api/v1/sessions/$sessionId/materials/upload-url',
      body: {
        'filename': file.filename,
        'mimeType': file.mimeType,
        'byteSize': file.byteSize,
        'sourcePhase': sourcePhase.wireName,
      },
    );
    return _uploadUrlFromJson(
      body,
      'POST /api/v1/sessions/{sessionId}/materials/upload-url',
    );
  }

  Future<JobAccepted> completeMaterialUpload({
    required String materialId,
    required String checksumSha256,
  }) async {
    final body = await _client.postJson(
      '/api/v1/materials/$materialId/upload-complete',
      body: {'checksumSha256': checksumSha256},
    );
    return _jobAcceptedFromJson(
      body,
      'POST /api/v1/materials/{materialId}/upload-complete',
    );
  }

  Future<List<SessionMaterial>> listSessionMaterials(String sessionId) async {
    final body = await _client.getJson('/api/v1/sessions/$sessionId/materials');
    return _list(
      body,
      'GET /api/v1/sessions/{sessionId}/materials',
    ).map(_sessionMaterialFromJson).toList(growable: false);
  }

  Future<MaterialDownloadUrl> issueMaterialDownloadUrl(
    String materialId,
  ) async {
    final body = await _client.getJson(
      '/api/v1/materials/$materialId/download-url',
    );
    final json = _map(body, 'GET /api/v1/materials/{materialId}/download-url');
    return MaterialDownloadUrl(
      downloadUrl: Uri.parse(_string(json, 'downloadUrl')),
      expiresAt: DateTime.parse(_string(json, 'expiresAt')),
    );
  }

  Future<void> deleteMaterial(String materialId) async {
    await _client.deleteJson('/api/v1/materials/$materialId');
  }

  Future<List<SessionProcessingJob>> listSessionJobs(String sessionId) async {
    final body = await _client.getJson('/api/v1/sessions/$sessionId/jobs');
    return _list(
      body,
      'GET /api/v1/sessions/{sessionId}/jobs',
    ).map(_sessionProcessingJobFromJson).toList(growable: false);
  }

  Future<SessionProcessingJob> getJob(String jobId) async {
    final body = await _client.getJson('/api/v1/jobs/$jobId');
    return _sessionProcessingJobFromJson(body);
  }

  Future<UploadUrl> issueRecordingUploadUrl({
    required UploadFile file,
    required DateTime startedAt,
  }) async {
    final body = await _client.postJson(
      '/api/v1/recordings/upload-url',
      body: {
        'filename': file.filename,
        'mimeType': file.mimeType,
        'byteSize': file.byteSize,
        'startedAt': startedAt.toUtc().toIso8601String(),
      },
    );
    return _uploadUrlFromJson(body, 'POST /api/v1/recordings/upload-url');
  }

  Future<RecordingUploadResult> completeRecordingUpload({
    required String recordingId,
    required String checksumSha256,
  }) async {
    final body = await _client.postJson(
      '/api/v1/recordings/$recordingId/upload-complete',
      body: {'checksumSha256': checksumSha256},
    );
    final json = _map(
      body,
      'POST /api/v1/recordings/{recordingId}/upload-complete',
    );
    final candidates = _list(
      json['candidateSessions'],
      'candidateSessions',
    ).map(_recordingCandidateFromJson).toList();
    return RecordingUploadResult(
      recordingId: _string(json, 'recordingId'),
      durationSeconds: _int(json, 'durationSeconds'),
      candidateSessions: candidates,
    );
  }

  Future<JobAccepted> confirmRecordingMapping({
    required String recordingId,
    required String sessionId,
  }) async {
    final body = await _client.postJson(
      '/api/v1/recordings/$recordingId/confirm-mapping',
      body: {'sessionId': sessionId},
    );
    return _jobAcceptedFromJson(
      body,
      'POST /api/v1/recordings/{recordingId}/confirm-mapping',
    );
  }

  Future<void> _putSignedUpload(UploadUrl upload, UploadFile file) async {
    final headers = _signedUploadHeaders(upload.requiredHeaders, file.mimeType);
    await _client.putByteStream(
      upload.uploadUrl,
      stream: file.openRead(),
      contentLength: file.byteSize,
      headers: headers,
      sourceUri: file.sourceUri,
    );
  }

  Future<String> _checksumSha256(UploadFile file) async {
    return (await sha256.bind(file.openRead()).first).toString();
  }

  Map<String, String> _signedUploadHeaders(
    Map<String, String> requiredHeaders,
    String mimeType,
  ) {
    final headers = Map<String, String>.of(requiredHeaders)
      ..removeWhere((key, _) => key.toLowerCase() == 'content-length');
    final hasContentType = headers.keys.any(
      (key) => key.toLowerCase() == 'content-type',
    );
    if (!hasContentType) headers['Content-Type'] = mimeType;
    return headers;
  }

  UploadUrl _uploadUrlFromJson(Object? value, String source) {
    final json = _map(value, source);
    return UploadUrl(
      id: _string(json, 'id'),
      uploadUrl: Uri.parse(_string(json, 'uploadUrl')),
      expiresAt: DateTime.parse(_string(json, 'expiresAt')),
      requiredHeaders: _stringMap(json['requiredHeaders']),
    );
  }

  JobAccepted _jobAcceptedFromJson(Object? value, String source) {
    final json = _map(value, source);
    return JobAccepted(
      jobId: _string(json, 'jobId'),
      status: _string(json, 'status'),
    );
  }

  RecordingCandidate _recordingCandidateFromJson(Object? value) {
    final json = _map(value, 'candidateSessions');
    return RecordingCandidate(
      id: _string(json, 'sessionId'),
      title: _string(json, 'title'),
      overlapScore: _double(json, 'overlapScore'),
    );
  }

  SessionMaterial _sessionMaterialFromJson(Object? value) {
    final json = _map(value, 'material');
    try {
      return SessionMaterial(
        id: _string(json, 'id'),
        sessionId: _string(json, 'sessionId'),
        filename: _string(json, 'filename'),
        mimeType: _string(json, 'mimeType'),
        byteSize: _int(json, 'byteSize'),
        pageCount: _optionalInt(json, 'pageCount'),
        sourcePhase: MaterialSourcePhase.fromWireName(
          _string(json, 'sourcePhase'),
        ),
        version: _int(json, 'version'),
        status: MaterialUploadStatus.fromWireName(_string(json, 'status')),
      );
    } on FormatException catch (error) {
      throw _shapeError('material', error.message, json);
    }
  }

  SessionProcessingJob _sessionProcessingJobFromJson(Object? value) {
    final json = _map(value, 'AI job');
    return SessionProcessingJob(
      id: _string(json, 'id'),
      type: _string(json, 'type'),
      status: ProcessingJobStatus.fromWireName(_string(json, 'status')),
      inputVersion: _int(json, 'inputVersion'),
      attemptCount: _int(json, 'attemptCount'),
      maxAttempts: _int(json, 'maxAttempts'),
      errorCode: _optionalString(json, 'errorCode'),
      retryable: json['retryable'] == true,
      createdAt: DateTime.parse(_string(json, 'createdAt')),
      finishedAt: _optionalDateTime(json, 'finishedAt'),
      materialId: _optionalString(json, 'materialId'),
    );
  }

  List<Object?> _list(Object? value, String source) {
    if (value is List) return value;
    throw _shapeError(source, 'Expected a list field.', value);
  }

  Map<String, Object?> _map(Object? value, String source) {
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    throw _shapeError(source, 'Expected an object response.', value);
  }

  Map<String, String> _stringMap(Object? value) {
    if (value is! Map) return const {};
    return value.map(
      (key, value) => MapEntry(key.toString(), value.toString()),
    );
  }

  String _string(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value == null) throw _shapeError(key, 'Missing required field.', json);
    return value.toString();
  }

  int _int(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.parse(value);
    throw _shapeError(key, 'Expected an integer field.', json);
  }

  int? _optionalInt(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.parse(value);
    throw _shapeError(key, 'Expected an integer field.', json);
  }

  String? _optionalString(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value == null) return null;
    return value.toString();
  }

  DateTime? _optionalDateTime(Map<String, Object?> json, String key) {
    final value = _optionalString(json, key);
    return value == null ? null : DateTime.parse(value);
  }

  double _double(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.parse(value);
    throw _shapeError(key, 'Expected a number field.', json);
  }

  ApiException _shapeError(String source, String message, Object? body) {
    return ApiException(
      statusCode: 200,
      code: 'INVALID_RESPONSE_SHAPE',
      message: '$message ($source)',
      responseBody: body,
    );
  }
}
