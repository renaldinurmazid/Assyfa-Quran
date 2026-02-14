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
  String collectedAmount;
  int percentage;
  String? latitude;
  String? longitude;
  String currentAmount;
  int donaturCount;
  int fundraiserCount;
  List<MosqueCharityUpdate> updates;
  List<MosqueCharityFundraiser> fundraisers;
  String? shareUrl;

  MosqueCharityData({
    required this.id,
    required this.name,
    required this.coverImage,
    required this.address,
    required this.city,
    this.description,
    this.targetAmount,
    required this.collectedAmount,
    required this.percentage,
    this.latitude,
    this.longitude,
    required this.currentAmount,
    required this.donaturCount,
    required this.fundraiserCount,
    required this.updates,
    required this.fundraisers,
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
        collectedAmount: json["collected_amount"] ?? 'Rp0',
        percentage: json["percentage"] ?? 0,
        latitude: json["latitude"]?.toString(),
        longitude: json["longitude"]?.toString(),
        currentAmount: json["current_amount"] ?? 'Rp0',
        donaturCount: json["donatur_count"] ?? 0,
        fundraiserCount: json["fundraiser_count"] ?? 0,
        updates: json["updates"] != null
            ? List<MosqueCharityUpdate>.from(
                json["updates"].map((x) => MosqueCharityUpdate.fromJson(x)),
              )
            : [],
        fundraisers: json["fundraisers"] != null
            ? List<MosqueCharityFundraiser>.from(
                json["fundraisers"].map(
                  (x) => MosqueCharityFundraiser.fromJson(x),
                ),
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
    "collected_amount": collectedAmount,
    "percentage": percentage,
    "latitude": latitude,
    "longitude": longitude,
    "current_amount": currentAmount,
    "donatur_count": donaturCount,
    "fundraiser_count": fundraiserCount,
    "updates": List<dynamic>.from(updates.map((x) => x.toJson())),
    "fundraisers": List<dynamic>.from(fundraisers.map((x) => x.toJson())),
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

class MosqueCharityFundraiser {
  int id;
  String name;
  int totalReferral;
  String totalCollected;

  MosqueCharityFundraiser({
    required this.id,
    required this.name,
    required this.totalReferral,
    required this.totalCollected,
  });

  factory MosqueCharityFundraiser.fromJson(Map<String, dynamic> json) =>
      MosqueCharityFundraiser(
        id: json["id"],
        name: json["name"] ?? 'Anonim',
        totalReferral: json["total_referral"] ?? 0,
        totalCollected: json["total_collected"] ?? 'Rp0',
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "total_referral": totalReferral,
    "total_collected": totalCollected,
  };
}
