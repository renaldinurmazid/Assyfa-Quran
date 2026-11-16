class DoaModel {
  final int id;
  final String grup;
  final String nama;
  final String ar;
  final String tr;
  final String idn;
  final String tentang;
  final List<String> tag;

  DoaModel({
    required this.id,
    required this.grup,
    required this.nama,
    required this.ar,
    required this.tr,
    required this.idn,
    required this.tentang,
    required this.tag,
  });

  factory DoaModel.fromJson(Map<String, dynamic> json) {
    return DoaModel(
      id: json['id'] ?? 0,
      grup: json['grup'] ?? '',
      nama: json['nama'] ?? '',
      ar: json['ar'] ?? '',
      tr: json['tr'] ?? '',
      idn: json['idn'] ?? '',
      tentang: json['tentang'] ?? '',
      tag: json['tag'] != null ? List<String>.from(json['tag']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'grup': grup,
      'nama': nama,
      'ar': ar,
      'tr': tr,
      'idn': idn,
      'tentang': tentang,
      'tag': tag,
    };
  }
}
