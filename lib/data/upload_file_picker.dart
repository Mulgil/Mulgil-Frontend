import 'package:file_picker/file_picker.dart';

import 'api_client.dart';
import 'resource_upload_api.dart';

abstract final class UploadFileLimits {
  static const maxPdfBytes = 50 * 1024 * 1024;
  static const maxRecordingBytes = 200 * 1024 * 1024;
}

abstract final class UploadFilePicker {
  static Future<UploadFile?> pickPdf() {
    return _pick(
      allowedExtensions: const ['pdf'],
      mimeTypesByExtension: const {'pdf': 'application/pdf'},
      maxBytes: UploadFileLimits.maxPdfBytes,
      tooLargeMessage: 'PDF는 최대 50MB까지 업로드할 수 있어요.',
    );
  }

  static Future<UploadFile?> pickRecording() {
    return _pick(
      allowedExtensions: const ['m4a', 'mp4'],
      mimeTypesByExtension: const {'m4a': 'audio/m4a', 'mp4': 'audio/mp4'},
      maxBytes: UploadFileLimits.maxRecordingBytes,
      tooLargeMessage: '녹음 파일은 최대 200MB까지 업로드할 수 있어요.',
    );
  }

  static Future<UploadFile?> _pick({
    required List<String> allowedExtensions,
    required Map<String, String> mimeTypesByExtension,
    required int maxBytes,
    required String tooLargeMessage,
  }) async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
    );
    if (file == null) return null;
    final extension = (file.extension ?? '').toLowerCase();
    final mimeType = mimeTypesByExtension[extension];
    if (mimeType == null) {
      throw const ApiException(
        statusCode: 415,
        code: 'UNSUPPORTED_MEDIA_TYPE',
        message: '지원하지 않는 파일 형식이에요.',
      );
    }
    final byteSize = await file.length();
    if (byteSize > maxBytes) {
      throw ApiException(
        statusCode: 413,
        code: 'FILE_TOO_LARGE',
        message: tooLargeMessage,
      );
    }
    return UploadFile.stream(
      filename: file.name,
      mimeType: mimeType,
      byteSize: byteSize,
      openRead: () => file.readAsByteStream(),
      sourceUri: file.uri,
    );
  }
}
