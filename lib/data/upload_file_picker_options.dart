import 'package:file_picker/file_picker.dart';

import 'upload_file_picker_options_stub.dart'
    if (dart.library.js_interop) 'upload_file_picker_options_web.dart'
    as options;

WebOptions uploadPickerWebOptions() => options.uploadPickerWebOptions();
