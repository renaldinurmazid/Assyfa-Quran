class ReferredUserModel {
  final int id;
  final String name;
  final String? profilePicture;
  final DateTime? createdAt;

  ReferredUserModel({
    required this.id,
    required this.name,
    this.profilePicture,
    this.createdAt,
  });

  factory ReferredUserModel.fromJson(Map<String, dynamic> json) {
    return ReferredUserModel(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) ?? 0 : 0,
      name: json['name'] ?? 'Unknown User',
      profilePicture: json['profile_picture'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']).toLocal() : null,
    );
  }
}
