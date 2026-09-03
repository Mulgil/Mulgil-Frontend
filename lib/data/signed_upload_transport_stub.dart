import 'package:http/http.dart' as http;

Future<http.Response> putSignedUpload({
  required http.Client httpClient,
  required Uri uploadUri,
  required Stream<List<int>> stream,
  required int contentLength,
  required Map<String, String> headers,
  Uri? sourceUri,
}) async {
  final request = http.StreamedRequest('PUT', uploadUri)
    ..contentLength = contentLength;
  request.headers.addAll(headers);

  final responseFuture = httpClient.send(request);
  await stream.pipe(request.sink);
  return http.Response.fromStream(await responseFuture);
}
