class DzikirModel {
  final String title;
  final String arab;
  final String latin;
  final String arti;
  final int read;

  DzikirModel({
    required this.title,
    required this.arab,
    required this.latin,
    required this.arti,
    required this.read,
  });

  factory DzikirModel.fromJson(Map<String, dynamic> json) {
    return DzikirModel(
      title: json['title'] ?? '',
      arab: json['arab'] ?? '',
      latin: json['latin'] ?? '',
      arti: json['arti'] ?? '',
      read: json['read'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'arab': arab,
      'latin': latin,
      'arti': arti,
      'read': read,
    };
  }
}
