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
    final checksumSha256 = await _putSignedUpload(upload, file);
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
    final checksumSha256 = await _putSignedUpload(upload, file);
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

  Future<String> _putSignedUpload(UploadUrl upload, UploadFile file) async {
    final headers = _signedUploadHeaders(upload.requiredHeaders, file.mimeType);
    final digestSink = _DigestSink();
    final checksumSink = sha256.startChunkedConversion(digestSink);
    final stream = file.openRead().map((chunk) {
      checksumSink.add(chunk);
      return chunk;
    });
    await _client.putByteStream(
      upload.uploadUrl,
      stream: stream,
      contentLength: file.byteSize,
      headers: headers,
      sourceUri: file.sourceUri,
    );
    checksumSink.close();
    return digestSink.value;
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

class _DigestSink implements Sink<Digest> {
  Digest? _digest;

  @override
  void add(Digest data) {
    _digest = data;
  }

  @override
  void close() {}

  String get value {
    final digest = _digest;
    if (digest == null) {
      throw StateError('Upload checksum was not calculated.');
    }
    return digest.toString();
  }
}
