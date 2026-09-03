import 'dart:async';
import 'dart:js_interop';

import 'package:http/http.dart' as http;
import 'package:web/web.dart' as web;

Future<http.Response> putSignedUpload({
  required http.Client httpClient,
  required Uri uploadUri,
  required Stream<List<int>> stream,
  required int contentLength,
  required Map<String, String> headers,
  Uri? sourceUri,
}) async {
  if (sourceUri == null || sourceUri.scheme != 'blob') {
    return _putStream(
      httpClient: httpClient,
      uploadUri: uploadUri,
      stream: stream,
      contentLength: contentLength,
      headers: headers,
    );
  }

  final blob = await _loadBlob(sourceUri);
  return _putBlob(uploadUri: uploadUri, blob: blob, headers: headers);
}

Future<http.Response> _putStream({
  required http.Client httpClient,
  required Uri uploadUri,
  required Stream<List<int>> stream,
  required int contentLength,
  required Map<String, String> headers,
}) async {
  final request = http.StreamedRequest('PUT', uploadUri)
    ..contentLength = contentLength;
  request.headers.addAll(headers);

  final responseFuture = httpClient.send(request);
  await stream.pipe(request.sink);
  return http.Response.fromStream(await responseFuture);
}

Future<web.Blob> _loadBlob(Uri sourceUri) {
  final completer = Completer<web.Blob>();
  final request = web.XMLHttpRequest()
    ..open('GET', sourceUri.toString(), true)
    ..responseType = 'blob';

  request.onload = ((web.Event _) {
    final response = request.response;
    if (request.status >= 200 && request.status < 300 && response != null) {
      completer.complete(response as web.Blob);
      return;
    }
    completer.completeError(
      http.ClientException('Failed to read selected file blob.', sourceUri),
    );
  }).toJS;
  request.onerror = ((web.Event _) {
    completer.completeError(
      http.ClientException('Failed to read selected file blob.', sourceUri),
    );
  }).toJS;

  request.send();
  return completer.future;
}

Future<http.Response> _putBlob({
  required Uri uploadUri,
  required web.Blob blob,
  required Map<String, String> headers,
}) {
  final completer = Completer<http.Response>();
  final request = web.XMLHttpRequest()
    ..open('PUT', uploadUri.toString(), true)
    ..responseType = 'text';

  for (final entry in headers.entries) {
    if (entry.key.toLowerCase() == 'content-length') continue;
    request.setRequestHeader(entry.key, entry.value);
  }

  request.onload = ((web.Event _) {
    completer.complete(
      http.Response(
        request.responseText,
        request.status,
        reasonPhrase: request.statusText,
      ),
    );
  }).toJS;
  request.onerror = ((web.Event _) {
    completer.completeError(
      http.ClientException('Signed upload request failed.', uploadUri),
    );
  }).toJS;

  request.send(blob);
  return completer.future;
}
