import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'signed_upload_transport.dart';

part 'api_client_response.dart';

typedef AccessTokenProvider = FutureOr<String?> Function();
typedef UnauthorizedHandler = FutureOr<void> Function();

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
  final UnauthorizedHandler? _onUnauthorized;
  final bool _ownsHttpClient;
  Future<void>? _activeRefresh;

  // Keep the public parameter name stable for callers.
  ApiClient({
    Uri? baseUri,
    http.Client? httpClient,
    AccessTokenProvider? accessTokenProvider,
    UnauthorizedHandler? onUnauthorized,
  }) : baseUri = _normalizeBaseUri(baseUri ?? ApiConfig.baseUri),
       _http = httpClient ?? http.Client(),
       // ignore: prefer_initializing_formals
       _accessTokenProvider = accessTokenProvider,
       // ignore: prefer_initializing_formals
       _onUnauthorized = onUnauthorized,
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
    bool authenticated = true,
  }) {
    return _sendJson(
      'POST',
      path,
      body: body,
      queryParameters: queryParameters,
      headers: headers,
      authenticated: authenticated,
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
    bool authenticated = true,
    bool canRefresh = true,
  }) async {
    final request = http.Request(method, _uri(path, queryParameters));
    request.headers.addAll(
      await _requestHeaders(
        hasBody: body != null,
        headers: headers,
        authenticated: authenticated,
      ),
    );
    if (body != null) {
      request.body = jsonEncode(body);
    }

    final streamed = await _http.send(request);
    final response = await http.Response.fromStream(streamed);
    final onUnauthorized = _onUnauthorized;
    if (response.statusCode == 401 &&
        authenticated &&
        canRefresh &&
        onUnauthorized != null) {
      final failedAuthorization = request.headers['Authorization'];
      final currentToken = (await _accessTokenProvider?.call())?.trim();
      if (failedAuthorization == 'Bearer $currentToken') {
        await _refreshAccessToken(onUnauthorized);
      }
      return _sendJson(
        method,
        path,
        body: body,
        queryParameters: queryParameters,
        headers: headers,
        authenticated: authenticated,
        canRefresh: false,
      );
    }
    return _handleResponse(response);
  }

  Future<void> _refreshAccessToken(UnauthorizedHandler onUnauthorized) {
    final activeRefresh = _activeRefresh;
    if (activeRefresh != null) return activeRefresh;
    final refresh = Future.sync(onUnauthorized);
    _activeRefresh = refresh;
    return refresh.whenComplete(() => _activeRefresh = null);
  }

  Future<Map<String, String>> _requestHeaders({
    required bool hasBody,
    required Map<String, String> headers,
    required bool authenticated,
  }) async {
    final accessToken = authenticated
        ? (await _accessTokenProvider?.call())?.trim()
        : null;
    return {
      'Accept': 'application/json',
      if (hasBody) 'Content-Type': 'application/json; charset=utf-8',
      if (accessToken != null && accessToken.isNotEmpty)
        'Authorization': 'Bearer $accessToken',
      ...headers,
    };
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
}
