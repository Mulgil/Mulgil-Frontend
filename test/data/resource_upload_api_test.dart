import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mulgil/data/api_client.dart';
import 'package:mulgil/data/auth_store.dart';
import 'package:mulgil/data/resource_upload_api.dart';

void main() {
  tearDown(AuthStore.clear);

  group('ResourceUploadApi', () {
    test('uploads session PDFs through signed URL flow', () async {
      AuthStore.saveTokens(
        accessToken: 'access-token',
        refreshToken: 'refresh',
      );
      final requests = <String>[];
      var openReadCount = 0;
      final api = _api((request) async {
        requests.add('${request.method} ${request.url}');
        switch ('${request.method} ${request.url}') {
          case 'POST https://api.example.com/api/v1/sessions/session-1/materials/upload-url':
            expect(_header(request, 'authorization'), 'Bearer access-token');
            expect(jsonDecode(request.body), {
              'filename': 'week-1.pdf',
              'mimeType': 'application/pdf',
              'byteSize': 3,
              'sourcePhase': 'preview_pdf',
            });
            return _jsonResponse({
              'id': 'material-1',
              'uploadUrl': 'https://storage.example.com/material-1',
              'expiresAt': '2026-09-01T00:10:00Z',
              'requiredHeaders': {
                'Content-Type': 'application/pdf',
                'Content-Length': '3',
              },
            }, 201);
          case 'PUT https://storage.example.com/material-1':
            expect(_header(request, 'authorization'), isNull);
            expect(_header(request, 'content-type'), 'application/pdf');
            expect(request.contentLength, 3);
            expect(request.bodyBytes, [1, 2, 3]);
            return http.Response('', 200);
          case 'POST https://api.example.com/api/v1/materials/material-1/upload-complete':
            expect(jsonDecode(request.body), {
              'checksumSha256':
                  '039058c6f2c0cb492c533b0a4d14ef77cc0f78abccced5287d84a1a2011cfb81',
            });
            return _jsonResponse({'jobId': 'job-1', 'status': 'queued'}, 202);
        }
        fail('Unexpected request: ${request.method} ${request.url}');
      });

      final result = await api.uploadSessionMaterial(
        sessionId: 'session-1',
        file: UploadFile.stream(
          filename: 'week-1.pdf',
          mimeType: 'application/pdf',
          byteSize: 3,
          openRead: () {
            openReadCount++;
            return Stream<List<int>>.value([1, 2, 3]);
          },
        ),
        sourcePhase: MaterialSourcePhase.previewPdf,
      );

      expect(result.materialId, 'material-1');
      expect(result.job.jobId, 'job-1');
      expect(openReadCount, 2);
      expect(requests, [
        'POST https://api.example.com/api/v1/sessions/session-1/materials/upload-url',
        'PUT https://storage.example.com/material-1',
        'POST https://api.example.com/api/v1/materials/material-1/upload-complete',
      ]);
    });

    test('lists session materials and issues a download URL', () async {
      final api = _api((request) async {
        switch ('${request.method} ${request.url}') {
          case 'GET https://api.example.com/api/v1/sessions/session-1/materials':
            return _jsonResponse([
              {
                'id': 'material-1',
                'sessionId': 'session-1',
                'filename': 'week-1.pdf',
                'mimeType': 'application/pdf',
                'byteSize': 1024,
                'pageCount': 12,
                'sourcePhase': 'preview_pdf',
                'version': 1,
                'status': 'uploaded',
              },
            ], 200);
          case 'GET https://api.example.com/api/v1/materials/material-1/download-url':
            return _jsonResponse({
              'downloadUrl': 'https://storage.example.com/material-1',
              'expiresAt': '2026-09-01T00:10:00Z',
            }, 200);
        }
        fail('Unexpected request: ${request.method} ${request.url}');
      });

      final materials = await api.listSessionMaterials('session-1');
      final download = await api.issueMaterialDownloadUrl(materials.single.id);

      expect(materials.single.filename, 'week-1.pdf');
      expect(materials.single.pageCount, 12);
      expect(materials.single.sourcePhase, MaterialSourcePhase.previewPdf);
      expect(materials.single.isDownloadable, isTrue);
      expect(
        download.downloadUrl,
        Uri.parse('https://storage.example.com/material-1'),
      );
    });

    test('lists, gets, and retries session processing jobs', () async {
      final queuedJob = {
        'id': 'job-1',
        'type': 'pdf_extract',
        'status': 'queued',
        'inputVersion': 1,
        'attemptCount': 0,
        'maxAttempts': 3,
        'errorCode': null,
        'createdAt': '2026-09-01T00:00:00Z',
        'finishedAt': null,
      };
      final api = _api((request) async {
        switch ('${request.method} ${request.url}') {
          case 'GET https://api.example.com/api/v1/sessions/session-1/jobs':
            return _jsonResponse([queuedJob], 200);
          case 'GET https://api.example.com/api/v1/jobs/job-1':
            return _jsonResponse({...queuedJob, 'status': 'failed'}, 200);
          case 'POST https://api.example.com/api/v1/jobs/job-1/retry':
            return _jsonResponse(queuedJob, 202);
        }
        fail('Unexpected request: ${request.method} ${request.url}');
      });

      final jobs = await api.listSessionJobs('session-1');
      final failedJob = await api.getJob('job-1');
      final retriedJob = await api.retryJob('job-1');

      expect(jobs.single.status, ProcessingJobStatus.queued);
      expect(jobs.single.status.isActive, isTrue);
      expect(failedJob.canRetry, isTrue);
      expect(retriedJob.status, ProcessingJobStatus.queued);
    });

    test('uploads recordings and confirms server candidate mapping', () async {
      AuthStore.saveTokens(
        accessToken: 'access-token',
        refreshToken: 'refresh',
      );
      final requests = <String>[];
      final api = _api((request) async {
        requests.add('${request.method} ${request.url}');
        switch ('${request.method} ${request.url}') {
          case 'POST https://api.example.com/api/v1/recordings/upload-url':
            expect(jsonDecode(request.body), {
              'filename': 'lecture.m4a',
              'mimeType': 'audio/m4a',
              'byteSize': 2,
              'startedAt': '2026-09-01T00:00:00.000Z',
            });
            return _jsonResponse({
              'id': 'recording-1',
              'uploadUrl': 'https://storage.example.com/recording-1',
              'expiresAt': '2026-09-01T00:10:00Z',
              'requiredHeaders': {'Content-Type': 'audio/m4a'},
            }, 201);
          case 'PUT https://storage.example.com/recording-1':
            expect(_header(request, 'authorization'), isNull);
            expect(_header(request, 'content-type'), 'audio/m4a');
            expect(request.bodyBytes, [4, 5]);
            return http.Response('', 200);
          case 'POST https://api.example.com/api/v1/recordings/recording-1/upload-complete':
            return _jsonResponse({
              'recordingId': 'recording-1',
              'durationSeconds': 3600,
              'candidateSessions': [
                {'sessionId': 'session-1', 'title': '1주차', 'overlapScore': 1.0},
              ],
            }, 200);
          case 'POST https://api.example.com/api/v1/recordings/recording-1/confirm-mapping':
            expect(jsonDecode(request.body), {'sessionId': 'session-1'});
            return _jsonResponse({'jobId': 'job-1', 'status': 'queued'}, 202);
        }
        fail('Unexpected request: ${request.method} ${request.url}');
      });

      final result = await api.uploadRecording(
        file: _file(
          filename: 'lecture.m4a',
          mimeType: 'audio/m4a',
          bytes: [4, 5],
        ),
        startedAt: DateTime.utc(2026, 9, 1),
      );
      final job = await api.confirmRecordingMapping(
        recordingId: result.recordingId,
        sessionId: result.candidateSessions.single.id,
      );

      expect(result.recordingId, 'recording-1');
      expect(result.durationSeconds, 3600);
      expect(result.candidateSessions.single.title, '1주차');
      expect(job.status, 'queued');
      expect(requests, [
        'POST https://api.example.com/api/v1/recordings/upload-url',
        'PUT https://storage.example.com/recording-1',
        'POST https://api.example.com/api/v1/recordings/recording-1/upload-complete',
        'POST https://api.example.com/api/v1/recordings/recording-1/confirm-mapping',
      ]);
    });
  });
}

ResourceUploadApi _api(
  Future<http.Response> Function(http.Request request) handler,
) {
  return ResourceUploadApi(
    ApiClient(
      baseUri: Uri.parse('https://api.example.com'),
      accessTokenProvider: AuthStore.accessTokenProvider,
      httpClient: MockClient(handler),
    ),
  );
}

UploadFile _file({
  required String filename,
  required String mimeType,
  required List<int> bytes,
}) {
  return UploadFile.memory(
    filename: filename,
    mimeType: mimeType,
    bytes: bytes,
  );
}

http.Response _jsonResponse(Object? body, int statusCode) {
  return http.Response.bytes(
    utf8.encode(jsonEncode(body)),
    statusCode,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}

String? _header(http.BaseRequest request, String name) {
  for (final entry in request.headers.entries) {
    if (entry.key.toLowerCase() == name.toLowerCase()) {
      return entry.value;
    }
  }
  return null;
}
