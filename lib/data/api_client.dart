import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'signed_upload_transport.dart';

typedef AccessTokenProvider = FutureOr<String?> Function();

abstract final class ApiConfig {
  static const defaultBaseUrl = 'https://api.mulgil.app';
  static const baseUrl = String.fromEnvironment(
    'MULGIL_API_BASE_URL',
    defaultValue: defaultBaseUrl,
  );

  static Uri get baseUri => Uri.parse(baseUrl);
}

class ApiClient {
  final Uri baseUri;
  final http.Client _http;
  final AccessTokenProvider? _accessTokenProvider;
  final bool _ownsHttpClient;

  // Keep the public parameter name stable for callers.
  ApiClient({
    Uri? baseUri,
    http.Client? httpClient,
    AccessTokenProvider? accessTokenProvider,
  }) : baseUri = _normalizeBaseUri(baseUri ?? ApiConfig.baseUri),
       _http = httpClient ?? http.Client(),
       // ignore: prefer_initializing_formals
       _accessTokenProvider = accessTokenProvider,
       _ownsHttpClient = httpClient == null;

  Future<Object?> getJson(
    String path, {
    Map<String, Object?> queryParameters = const {},
    Map<String, String> headers = const {},
  }) {
    return _sendJson(
      'GET',
      path,
      queryParameters: queryParameters,
      headers: headers,
    );
  }

  Future<Object?> postJson(
    String path, {
    Object? body,
    Map<String, Object?> queryParameters = const {},
    Map<String, String> headers = const {},
  }) {
    return _sendJson(
      'POST',
      path,
      body: body,
      queryParameters: queryParameters,
      headers: headers,
    );
  }

  Future<Object?> patchJson(
    String path, {
    Object? body,
    Map<String, Object?> queryParameters = const {},
    Map<String, String> headers = const {},
  }) {
    return _sendJson(
      'PATCH',
      path,
      body: body,
      queryParameters: queryParameters,
      headers: headers,
    );
  }

  Future<Object?> deleteJson(
    String path, {
    Object? body,
    Map<String, Object?> queryParameters = const {},
    Map<String, String> headers = const {},
  }) {
    return _sendJson(
      'DELETE',
      path,
      body: body,
      queryParameters: queryParameters,
      headers: headers,
    );
  }

  Future<void> putBytes(
    Uri uri, {
    required List<int> bytes,
    Map<String, String> headers = const {},
  }) {
    return putByteStream(
      uri,
      stream: Stream<List<int>>.value(bytes),
      contentLength: bytes.length,
      headers: headers,
    );
  }

  Future<void> putByteStream(
    Uri uri, {
    required Stream<List<int>> stream,
    required int contentLength,
    Map<String, String> headers = const {},
    Uri? sourceUri,
  }) async {
    final response = await putSignedUpload(
      httpClient: _http,
      uploadUri: uri,
      stream: stream,
      contentLength: contentLength,
      headers: headers,
      sourceUri: sourceUri,
    );
    _handleUploadResponse(response);
  }

  void close() {
    if (_ownsHttpClient) {
      _http.close();
    }
  }

  Future<Object?> _sendJson(
    String method,
    String path, {
    Object? body,
    Map<String, Object?> queryParameters = const {},
    Map<String, String> headers = const {},
  }) async {
    final request = http.Request(method, _uri(path, queryParameters));
    request.headers.addAll(
      await _requestHeaders(hasBody: body != null, headers: headers),
    );
    if (body != null) {
      request.body = jsonEncode(body);
    }

    final streamed = await _http.send(request);
    final response = await http.Response.fromStream(streamed);
    return _handleResponse(response);
  }

  void _handleUploadResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;

    final body = _decodeBody(response, requireJson: false);
    throw ApiException(
      statusCode: response.statusCode,
      code: 'UPLOAD_FAILED',
      message: response.reasonPhrase ?? 'Upload failed.',
      responseBody: body,
    );
  }

  Future<Map<String, String>> _requestHeaders({
    required bool hasBody,
    required Map<String, String> headers,
  }) async {
    final accessToken = (await _accessTokenProvider?.call())?.trim();
    return {
      'Accept': 'application/json',
      if (hasBody) 'Content-Type': 'application/json; charset=utf-8',
      if (accessToken != null && accessToken.isNotEmpty)
        'Authorization': 'Bearer $accessToken',
      ...headers,
    };
  }

  Object? _handleResponse(http.Response response) {
    final isSuccessful =
        response.statusCode >= 200 && response.statusCode < 300;
    final body = _decodeBody(response, requireJson: isSuccessful);
    if (isSuccessful) {
      return body;
    }

    final error = body is Map ? body : const <String, Object?>{};
    throw ApiException(
      statusCode: response.statusCode,
      code: error['code']?.toString() ?? 'HTTP_${response.statusCode}',
      message:
          error['message']?.toString() ??
          response.reasonPhrase ??
          'Request failed.',
      details: _detailsFrom(error['details']),
      responseBody: body,
    );
  }

  Object? _decodeBody(http.Response response, {required bool requireJson}) {
    if (response.bodyBytes.isEmpty) return null;
    final decoded = utf8.decode(response.bodyBytes, allowMalformed: true);
    try {
      return jsonDecode(decoded);
    } on FormatException {
      if (!requireJson) {
        return decoded;
      }
      throw ApiException(
        statusCode: response.statusCode,
        code: 'INVALID_RESPONSE',
        message: 'Expected a JSON response.',
        responseBody: decoded,
      );
    }
  }

  Uri _uri(String path, Map<String, Object?> queryParameters) {
    final requestPath = path.startsWith('/') ? path : '/$path';
    final basePath = baseUri.path == '/'
        ? ''
        : _trimTrailingSlash(baseUri.path);
    return baseUri.replace(
      path: '$basePath$requestPath',
      queryParameters: _queryParameters(queryParameters),
    );
  }

  static Uri _normalizeBaseUri(Uri uri) {
    if (uri.path == '/') return uri.replace(path: '');
    return uri.replace(path: _trimTrailingSlash(uri.path));
  }

  static String _trimTrailingSlash(String value) {
    if (!value.endsWith('/')) return value;
    return value.substring(0, value.length - 1);
  }

  static Map<String, dynamic>? _queryParameters(
    Map<String, Object?> parameters,
  ) {
    final query = <String, dynamic>{};
    for (final entry in parameters.entries) {
      final value = entry.value;
      if (value == null) continue;
      if (value is Iterable) {
        final values = value
            .where((item) => item != null)
            .map((item) => item.toString())
            .toList();
        if (values.isNotEmpty) {
          query[entry.key] = values;
        }
      } else {
        query[entry.key] = value.toString();
      }
    }
    return query.isEmpty ? null : query;
  }

  static Map<String, Object?> _detailsFrom(Object? value) {
    if (value is! Map) return const <String, Object?>{};
    return value.map((key, detail) => MapEntry(key.toString(), detail));
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String code;
  final String message;
  final Map<String, Object?> details;
  final Object? responseBody;

  const ApiException({
    required this.statusCode,
    required this.code,
    required this.message,
    this.details = const {},
    this.responseBody,
  });

  @override
  String toString() {
    return 'ApiException($statusCode, $code, $message)';
  }
}
