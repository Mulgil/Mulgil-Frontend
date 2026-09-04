import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mulgil/data/api_client.dart';
import 'package:mulgil/data/resource_upload_api.dart';
import 'package:mulgil/models/lecture.dart';
import 'package:mulgil/screens/note/widgets/session_materials_sheet.dart';

void main() {
  testWidgets('shows uploaded PDFs and opens a newly issued download URL', (
    tester,
  ) async {
    Uri? openedUrl;
    final api = ResourceUploadApi(
      ApiClient(
        baseUri: Uri.parse('https://api.example.com'),
        httpClient: MockClient((request) async {
          switch ('${request.method} ${request.url}') {
            case 'GET https://api.example.com/api/v1/sessions/session-1/materials':
              return _jsonResponse([
                {
                  'id': 'material-1',
                  'sessionId': 'session-1',
                  'filename': 'week-1.pdf',
                  'mimeType': 'application/pdf',
                  'byteSize': 2048,
                  'pageCount': 2,
                  'sourcePhase': 'preview_pdf',
                  'version': 1,
                  'status': 'uploaded',
                },
              ]);
            case 'GET https://api.example.com/api/v1/sessions/session-1/jobs':
              return _jsonResponse([]);
            case 'GET https://api.example.com/api/v1/materials/material-1/download-url':
              return _jsonResponse({
                'downloadUrl': 'https://storage.example.com/material-1',
                'expiresAt': '2026-09-01T00:10:00Z',
              });
          }
          fail('Unexpected request: ${request.method} ${request.url}');
        }),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SessionMaterialsSheet(
            lecture: const Lecture(
              id: 'session-1',
              courseId: 'course-1',
              week: '1주차',
              title: '1차시',
              done: false,
              stars: 0,
            ),
            api: api,
            openUrl: (url) async {
              openedUrl = url;
              return true;
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('week-1.pdf'), findsOneWidget);
    expect(find.text('예습 · 2페이지 · 2KB'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.open_in_new));
    await tester.pumpAndSettle();

    expect(openedUrl, Uri.parse('https://storage.example.com/material-1'));
  });
}

http.Response _jsonResponse(Object body) {
  return http.Response.bytes(
    utf8.encode(jsonEncode(body)),
    200,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}
