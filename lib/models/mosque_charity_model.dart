import 'dart:convert';

MosqueCharity mosqueCharityFromJson(String str) =>
    MosqueCharity.fromJson(json.decode(str));

String mosqueCharityToJson(MosqueCharity data) => json.encode(data.toJson());

class MosqueCharity {
  String status;
  List<MosqueCharityData> data;

  MosqueCharity({required this.status, required this.data});

  factory MosqueCharity.fromJson(Map<String, dynamic> json) => MosqueCharity(
    status: json["status"],
    data: List<MosqueCharityData>.from(
      json["data"].map((x) => MosqueCharityData.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class MosqueCharityData {
  int id;
  String name;
  String coverImage;
  String address;
  String city;
  String? description;
  String? targetAmount;
  String? latitude;
  String? longitude;
  int currentAmount;
  List<MosqueCharityUpdate> updates;
  String? shareUrl;

  MosqueCharityData({
    required this.id,
    required this.name,
    required this.coverImage,
    required this.address,
    required this.city,
    this.description,
    this.targetAmount,
    this.latitude,
    this.longitude,
    required this.currentAmount,
    required this.updates,
    this.shareUrl,
  });

  factory MosqueCharityData.fromJson(Map<String, dynamic> json) =>
      MosqueCharityData(
        id: json["id"],
        name: json["name"],
        coverImage: json["cover_image"],
        address: json["address"],
        city: json["city"],
        description: json["description"],
        targetAmount: json["target_amount"],
        latitude: json["latitude"]?.toString(),
        longitude: json["longitude"]?.toString(),
        currentAmount: json["current_amount"] is String
            ? (int.tryParse(
                    json["current_amount"].replaceAll(RegExp(r'[^0-9]'), ''),
                  ) ??
                  0)
            : (json["current_amount"] ?? 0),
        updates: json["updates"] != null
            ? List<MosqueCharityUpdate>.from(
                json["updates"].map((x) => MosqueCharityUpdate.fromJson(x)),
              )
            : [],
        shareUrl: json["share_url"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "cover_image": coverImage,
    "address": address,
    "city": city,
    "description": description,
    "target_amount": targetAmount,
    "latitude": latitude,
    "longitude": longitude,
    "current_amount": currentAmount,
    "updates": List<dynamic>.from(updates.map((x) => x.toJson())),
    "share_url": shareUrl,
  };
}

class MosqueCharityUpdate {
  int id;
  int mosqueCharityId;
  String title;
  String content;
  DateTime date;
  DateTime createdAt;
  DateTime updatedAt;
  String createdAtFormatted;

  MosqueCharityUpdate({
    required this.id,
    required this.mosqueCharityId,
    required this.title,
    required this.content,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    required this.createdAtFormatted,
  });

  factory MosqueCharityUpdate.fromJson(Map<String, dynamic> json) =>
      MosqueCharityUpdate(
        id: json["id"],
        mosqueCharityId: json["mosque_charity_id"],
        title: json["title"],
        content: json["content"],
        date: DateTime.parse(json["date"]),
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        createdAtFormatted: json["created_at_formatted"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "mosque_charity_id": mosqueCharityId,
    "title": title,
    "content": content,
    "date": date.toIso8601String(),
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "created_at_formatted": createdAtFormatted,
  };
}
