import 'package:flutter/foundation.dart';

import '../models/lecture.dart';
import '../models/draw_stroke.dart';
import '../models/prof_mention.dart';

class NoteContent {
  String typedText;
  final List<List<DrawStroke>> pagesStrokes;
  final List<List<ProfMention>> pagesMentions;
  NoteContent({this.typedText = ''}) : pagesStrokes = [], pagesMentions = [];
}

// In-memory store for notes drafted during the current app session.
class NotesStore extends ChangeNotifier {
  NotesStore._internal();

  static final NotesStore instance = NotesStore._internal();

  final List<Lecture> _lectures = [];
  final Map<String, NoteContent> _contents = {};

  static const memoWeekLabel = '메모';

  List<Lecture> get lectures => List.unmodifiable(_lectures);

  NoteContent contentFor(Lecture lecture) =>
      _contents.putIfAbsent(lecture.id, () => NoteContent());

  bool isMemo(Lecture lecture) => lecture.id.startsWith('note-');

  bool hasContent(Lecture lecture) {
    final content = _contents[lecture.id];
    if (content == null) return false;
    return content.pagesStrokes.any((page) => page.isNotEmpty) ||
        content.typedText.trim().isNotEmpty;
  }

  bool hasNotes(Lecture lecture) => lecture.done || hasContent(lecture);

  Lecture createNote({required String title, required String courseId}) {
    final lecture = Lecture(
      id: 'note-${DateTime.now().microsecondsSinceEpoch}',
      courseId: courseId,
      week: memoWeekLabel,
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
    notifyListeners();
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
    notifyListeners();
  }

  List<ProfMention> pageMentions(Lecture lecture, int page) {
    final pages = contentFor(lecture).pagesMentions;
    return page < pages.length ? pages[page] : const [];
  }

  void updatePageMentions(
    Lecture lecture,
    int page,
    List<ProfMention> mentions,
  ) {
    final pages = contentFor(lecture).pagesMentions;
    while (pages.length <= page) {
      pages.add([]);
    }
    pages[page] = mentions;
  }

  String _todayLabel() {
    final now = DateTime.now();
    return '${now.month}/${now.day}';
  }
}
