class SurahModel implements Comparable<SurahModel> {
  int id;
  String? name;
  String? englishName;
  String? frenchName;
  String? arabicName;
  int? startPage;
  int? endPage;
  int? makkia;

  SurahModel({
    required this.id,
    this.name,
    this.englishName,
    this.frenchName,
    this.arabicName,
    this.startPage,
    this.endPage,
    this.makkia,
  });

  @override
  int compareTo(SurahModel other) {
    return id.compareTo(other.id);
  }

  factory SurahModel.fromMap(Map<String, dynamic> json) {
    final rawName = json['name'] as String?;
    final normalizedName = rawName == 'La génisse' ? 'La vache' : rawName;
    return SurahModel(
      id: json['id'],
      name: normalizedName,
      englishName: json['english_name'] ?? json['englishName'],
      frenchName: json['french_name'] ?? json['frenchName'],
      arabicName: json['arabic_name'] ?? json['arabicName'],
      startPage: json['start_page'],
      endPage: json['end_page'],
      makkia: json['makkia'],
    );
  }

  SurahModel copyWith({
    int? id,
    String? name,
    String? englishName,
    String? frenchName,
    String? arabicName,
    int? startPage,
    int? endPage,
    int? makkia,
  }) {
    return SurahModel(
      id: id ?? this.id,
      name: name ?? this.name,
      englishName: englishName ?? this.englishName,
      frenchName: frenchName ?? this.frenchName,
      arabicName: arabicName ?? this.arabicName,
      startPage: startPage ?? this.startPage,
      endPage: endPage ?? this.endPage,
      makkia: makkia ?? this.makkia,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'english_name': englishName,
      'french_name': frenchName,
      'arabic_name': arabicName,
      'start_page': startPage,
      'end_page': endPage,
      'makkia': makkia,
    };
  }
}
