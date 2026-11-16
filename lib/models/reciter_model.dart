class ReciterModel {
  final int id;
  final String name;
  final String code;

  ReciterModel({
    required this.id,
    required this.name,
    required this.code,
  });

  factory ReciterModel.fromJson(Map<String, dynamic> json) {
    return ReciterModel(
      id: json['id'] as int,
      name: json['name'] as String,
      code: json['code'] as String,
    );
  }
}
