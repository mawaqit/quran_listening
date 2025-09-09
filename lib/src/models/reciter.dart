class Reciter {
  int id;
  int? mainReciterId;
  String reciterName;
  List<Mushaf> mushaf;
  String? serverUrl;
  String? style;
  int? totalSurah;
  List<String>? surahsList;

  Reciter({
    required this.mainReciterId,
    required this.id,
    required this.reciterName,
    required this.mushaf,
    this.serverUrl,
    this.style,
    this.totalSurah,
    this.surahsList,
  });

  factory Reciter.fromMap(Map<String, dynamic> json) {
    return Reciter(
      id: json['id'],
      mainReciterId: json['main_reciter_id'],
      reciterName: json['name'],
      mushaf: json['moshaf'].map<Mushaf>((e) => Mushaf.fromMap(e)).toList(),
      serverUrl:
          json['id'] == 107
              ? 'https://download.quranplayermp3.com/quran/Muhammad-Al-Luhaidan/'
              : json['server'],
      style: json['style'],
      totalSurah: json['total_surah'],
      surahsList:
          json['surahs_list'] is List<String>
              ? json['surahs_list']
              : List<String>.from(json['surahs_list'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'main_reciter_id': mainReciterId,
      'name': reciterName,
      'moshaf': mushaf.map((e) => e.toMap()).toList(),
      'server': serverUrl ?? '',
      'style': style ?? '',
      'total_surah': totalSurah ?? 0,
      'surahs_list': surahsList ?? [],
    };
  }

  Reciter copyWith({
    int? id,
    int? mainReciterId,
    String? reciterName,
    List<Mushaf>? mushaf,
    String? serverUrl,
    String? style,
    int? totalSurah,
    List<String>? surahsList,
  }) {
    return Reciter(
      id: id ?? this.id,
      mainReciterId: mainReciterId ?? this.mainReciterId,
      reciterName: reciterName ?? this.reciterName,
      mushaf: mushaf ?? this.mushaf,
      serverUrl: serverUrl ?? this.serverUrl,
      style: style ?? this.style,
      totalSurah: totalSurah ?? this.totalSurah,
      surahsList: surahsList ?? this.surahsList,
    );
  }

  @override
  String toString() {
    return 'Reciter(id: $id, reciterName: $reciterName, mushaf: $mushaf, serverUrl: $serverUrl, style: $style, totalSurah: $totalSurah, surahsList: $surahsList), mainReciterId: $mainReciterId';
  }
}

class Mushaf {
  int id;
  String name;
  String server;
  int totalSurah;
  List<String> surahsList;

  Mushaf({
    required this.id,
    required this.name,
    required this.server,
    required this.totalSurah,
    required this.surahsList,
  });

  factory Mushaf.fromMap(Map<String, dynamic> json) {
    return Mushaf(
      id: json['id'],
      name: json['name'],
      server: json['server'],
      totalSurah: json['surah_total'],
      surahsList:
          json['surah_list'] == null && json['surahs_list'] is Iterable
              ? json['surahs_list'].map<String>((e) => e.toString()).toList()
              : json['surah_list'].split(',') as List<String>,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'server': server,
      'surah_total': totalSurah,
      'surahs_list': surahsList,
    };
  }
}
