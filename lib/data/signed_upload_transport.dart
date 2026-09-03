import 'package:http/http.dart' as http;

import 'signed_upload_transport_stub.dart'
    if (dart.library.js_interop) 'signed_upload_transport_web.dart'
    as transport;

Future<http.Response> putSignedUpload({
  required http.Client httpClient,
  required Uri uploadUri,
  required Stream<List<int>> stream,
  required int contentLength,
  required Map<String, String> headers,
  Uri? sourceUri,
}) {
  return transport.putSignedUpload(
    httpClient: httpClient,
    uploadUri: uploadUri,
    stream: stream,
    contentLength: contentLength,
    headers: headers,
    sourceUri: sourceUri,
  );
}
