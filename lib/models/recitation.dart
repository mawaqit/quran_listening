class Recitation {
  int id;
  int chapterId;
  String url;

  Recitation({
    required this.id,
    required this.chapterId,
    required this.url,
  });

  factory Recitation.fromMap(Map<String, dynamic> json) {
    return Recitation(
      id: json['id'],
      chapterId: json['chapter_id'],
      url: json['audio_url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chapter_id': chapterId,
      'audio_url': url,
    };
  }
}
