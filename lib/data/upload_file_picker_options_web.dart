import 'package:file_picker_web/file_picker_web.dart';

FilePickerWebOptions uploadPickerWebOptions() {
  return const FilePickerWebOptions(withData: false, withReadStream: true);
}
