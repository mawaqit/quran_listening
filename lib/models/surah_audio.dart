/// api => https://api.quran.com/api/v4/chapter_recitations/1
class SurahAudio {

  final int id;
  final int chapterId;
  final int fileSize;
  final String format;
  final String audioUrl;

//<editor-fold desc="Data Methods">
  const SurahAudio({
    required this.id,
    required this.chapterId,
    required this.fileSize,
    required this.format,
    required this.audioUrl,
  });


  SurahAudio copyWith({
    int? id,
    int? chapterId,
    int? fileSize,
    String? format,
    String? audioUrl,
  }) {
    return SurahAudio(
      id: id ?? this.id,
      chapterId: chapterId ?? this.chapterId,
      fileSize: fileSize ?? this.fileSize,
      format: format ?? this.format,
      audioUrl: audioUrl ?? this.audioUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chapterId': chapterId,
      'fileSize': fileSize,
      'format': format,
      'audioUrl': audioUrl,
    };
  }

  factory SurahAudio.fromMap(Map<String, dynamic> map) {
    return SurahAudio(
      id: map['id'] ?? 0,
      chapterId: map['chapterId'] ?? 0,
      fileSize: map['fileSize'] ?? 0,
      format: map['format'] ?? '',
      audioUrl: map['audioUrl'] ?? '',
    );
  }

//</editor-fold>
}
