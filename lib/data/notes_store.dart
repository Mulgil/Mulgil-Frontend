import 'package:flutter/foundation.dart';
import '../models/lecture.dart';
import '../models/draw_stroke.dart';
import 'mock_data.dart';

class NoteContent {
  String typedText;
  final List<List<DrawStroke>> pagesStrokes;
  NoteContent({this.typedText = ''}) : pagesStrokes = [];
}

// In-memory store standing in for the notes backend — replace with API calls
// (GET/POST /notes, PATCH /notes/{id}) when the server is ready.
class NotesStore extends ChangeNotifier {
  NotesStore._internal() : _lectures = List.of(MockData.lectures) {
    for (final l in _lectures.where((l) => l.done)) {
      _contents[l.id] = NoteContent(typedText: '# ${l.week} - ${l.title}\n\n');
    }
  }

  static final NotesStore instance = NotesStore._internal();

  final List<Lecture> _lectures;
  final Map<String, NoteContent> _contents = {};
  int _newNoteCount = 0;

  List<Lecture> get lectures => List.unmodifiable(_lectures);

  NoteContent contentFor(Lecture lecture) => _contents.putIfAbsent(lecture.id, () => NoteContent());

  Lecture createNote({required String title}) {
    _newNoteCount++;
    final lecture = Lecture(
      id: 'note-${DateTime.now().microsecondsSinceEpoch}',
      week: '메모 $_newNoteCount',
      title: title,
      date: _todayLabel(),
      done: true,
      stars: 0,
    );
    _lectures.insert(0, lecture);
    _contents[lecture.id] = NoteContent(typedText: '# $title\n\n');
    notifyListeners();
    return lecture;
  }

  void updateTypedText(Lecture lecture, String text) {
    contentFor(lecture).typedText = text;
  }

  List<DrawStroke> pageStrokes(Lecture lecture, int page) {
    final pages = contentFor(lecture).pagesStrokes;
    return page < pages.length ? pages[page] : const [];
  }

  void updatePageStrokes(Lecture lecture, int page, List<DrawStroke> strokes) {
    final pages = contentFor(lecture).pagesStrokes;
    while (pages.length <= page) {
      pages.add([]);
    }
    pages[page] = strokes;
  }

  String _todayLabel() {
    final now = DateTime.now();
    return '${now.month}/${now.day}';
  }
}
