// Mirrors the source_ref common object — a pointer back to the original
// material/note/transcript a generated claim (or quiz answer/explanation)
// was drawn from. Only sourceType's applicable fields are populated.
enum SourceRefType { pdfText, handwriting, note, transcript, pastExam, table }

class BboxNorm {
  final double x;
  final double y;
  final double width;
  final double height;

  const BboxNorm({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });
}

class SourceRef {
  final SourceRefType sourceType;
  final String? materialId;
  final String? examResourceId;
  final String? contentBlockId;
  final int? pageNumber;
  final BboxNorm? bboxNorm;
  final String? handwritingBlockId;
  final String? noteId;
  final int? paragraphOffset;
  final String? recordingId;
  final String? transcriptSegmentId;
  final int? startMs;
  final int? endMs;

  const SourceRef({
    required this.sourceType,
    this.materialId,
    this.examResourceId,
    this.contentBlockId,
    this.pageNumber,
    this.bboxNorm,
    this.handwritingBlockId,
    this.noteId,
    this.paragraphOffset,
    this.recordingId,
    this.transcriptSegmentId,
    this.startMs,
    this.endMs,
  });
}
