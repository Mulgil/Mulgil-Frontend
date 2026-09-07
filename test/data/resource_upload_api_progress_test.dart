import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mulgil/data/api_client.dart';
import 'package:mulgil/data/resource_upload_api.dart';

void main() {
  test('parses optional generation progress fields additively', () async {
    final api = _api([
      _job(
        progressStage: 'validating',
        progressUpdatedAt: '2026-09-07T01:02:03Z',
      ),
      _job(id: 'legacy-job'),
      _job(id: 'future-job', progressStage: 'future_stage'),
    ]);

    final jobs = await api.listSessionJobs('session-1');

    expect(jobs[0].progressStage, GenerationProgressStage.validating);
    expect(jobs[0].progressUpdatedAt, DateTime.utc(2026, 9, 7, 1, 2, 3));
    expect(jobs[1].progressStage, isNull);
    expect(jobs[1].progressUpdatedAt, isNull);
    expect(jobs[2].progressStage, GenerationProgressStage.unknown);
    expect(jobs[2].safeProgressMessage, '생성 작업을 진행하고 있어요.');
  });
}

ResourceUploadApi _api(Object body) {
  return ResourceUploadApi(
    ApiClient(
      baseUri: Uri.parse('https://api.example.com'),
      httpClient: MockClient((request) async {
        expect(request.url.path, '/api/v1/sessions/session-1/jobs');
        return http.Response.bytes(
          utf8.encode(jsonEncode(body)),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    ),
  );
}

Map<String, Object?> _job({
  String id = 'job-1',
  String? progressStage,
  String? progressUpdatedAt,
}) {
  return {
    'id': id,
    'type': 'review_mindmap_generate',
    'status': 'running',
    'inputVersion': 1,
    'attemptCount': 1,
    'maxAttempts': 3,
    'errorCode': null,
    'retryable': false,
    'createdAt': '2026-09-07T01:00:00Z',
    'finishedAt': null,
    ...?progressStage == null ? null : {'progressStage': progressStage},
    ...?progressUpdatedAt == null
        ? null
        : {'progressUpdatedAt': progressUpdatedAt},
  };
}
