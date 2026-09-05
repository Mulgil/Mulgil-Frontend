import 'package:flutter_test/flutter_test.dart';
import 'package:mulgil/data/notes_store.dart';

void main() {
  test('notifies listeners when typed text changes', () {
    final store = NotesStore.instance;
    final lecture = store.createNote(title: '텍스트 노트', courseId: 'course-1');
    var notificationCount = 0;
    void listener() => notificationCount += 1;

    store.addListener(listener);
    store.updateTypedText(lecture, '새로운 텍스트');
    store.removeListener(listener);

    expect(notificationCount, 1);
    expect(store.contentFor(lecture).typedText, '새로운 텍스트');
  });
}
