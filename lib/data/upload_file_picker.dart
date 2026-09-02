import 'package:file_picker/file_picker.dart';

import 'api_client.dart';
import 'resource_upload_api.dart';

abstract final class UploadFilePicker {
  static Future<UploadFile?> pickPdf() {
    return _pick(
      allowedExtensions: const ['pdf'],
      mimeTypesByExtension: const {'pdf': 'application/pdf'},
    );
  }

  static Future<UploadFile?> pickRecording() {
    return _pick(
      allowedExtensions: const ['m4a', 'mp4'],
      mimeTypesByExtension: const {'m4a': 'audio/m4a', 'mp4': 'audio/mp4'},
    );
  }

  static Future<UploadFile?> _pick({
    required List<String> allowedExtensions,
    required Map<String, String> mimeTypesByExtension,
  }) async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
    );
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    final extension = (file.extension ?? '').toLowerCase();
    final mimeType = mimeTypesByExtension[extension];
    if (mimeType == null) {
      throw const ApiException(
        statusCode: 415,
        code: 'UNSUPPORTED_MEDIA_TYPE',
        message: '지원하지 않는 파일 형식이에요.',
      );
    }
    return UploadFile(filename: file.name, mimeType: mimeType, bytes: bytes);
  }
}
