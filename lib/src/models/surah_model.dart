class SurahModel implements Comparable<SurahModel> {
  int id;
  String? name;
  int? startPage;
  int? endPage;
  int? makkia;

  SurahModel({
    required this.id,
    this.name,
    this.startPage,
    this.endPage,
    this.makkia,
  });

  @override
  int compareTo(SurahModel other) {
    return id.compareTo(other.id);
  }

  factory SurahModel.fromMap(Map<String, dynamic> json) {
    return SurahModel(
      id: json['id'],
      name: json['name'] == 'La génisse' ? 'La vache' : json['name'],
      startPage: json['start_page'],
      endPage: json['end_page'],
      makkia: json['makkia'],
    );
  }

  SurahModel copyWith({
    int? id,
    String? name,
    int? startPage,
    int? endPage,
    int? makkia,
  }) {
    return SurahModel(
      id: id ?? this.id,
      name: name ?? this.name,
      startPage: startPage ?? this.startPage,
      endPage: endPage ?? this.endPage,
      makkia: makkia ?? this.makkia,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'start_page': startPage,
      'end_page': endPage,
      'makkia': makkia,
    };
  }
}
