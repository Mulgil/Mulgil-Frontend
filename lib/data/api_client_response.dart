part of 'api_client.dart';

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

Object? _handleResponse(http.Response response) {
  final isSuccessful = response.statusCode >= 200 && response.statusCode < 300;
  final body = _decodeBody(response, requireJson: isSuccessful);
  if (isSuccessful) return body;

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
    if (!requireJson) return decoded;
    throw ApiException(
      statusCode: response.statusCode,
      code: 'INVALID_RESPONSE',
      message: 'Expected a JSON response.',
      responseBody: decoded,
    );
  }
}

Map<String, Object?> _detailsFrom(Object? value) {
  if (value is! Map) return const <String, Object?>{};
  return value.map((key, detail) => MapEntry(key.toString(), detail));
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
