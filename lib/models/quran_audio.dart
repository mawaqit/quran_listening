/// api =>  https://api.quran.com/api/v4/quran/recitations/1
class AudioQuran {
  final Map<String, dynamic> ayat;

  final String reciterName;
  final String recitationStyle;

  AudioQuran({
    required this.ayat,
    required this.reciterName,
    required this.recitationStyle,
  });

  factory AudioQuran.fromMap(Map<String, dynamic> map) {
    List ayat = map['audio_files'] ?? [];
    Map<String, dynamic> audioAyat = {
      for ( var aya in ayat)
        aya['verse_key']: aya['url']
    };
    return AudioQuran(
      ayat:audioAyat,
      reciterName: map['reciter_name'] ?? '',
      recitationStyle: map['recitation_style'] ?? '',
    );
  }
}
