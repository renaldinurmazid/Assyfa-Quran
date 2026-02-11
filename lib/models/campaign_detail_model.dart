import 'dart:convert';

CampaignDetailModel campaignDetailModelFromJson(String str) =>
    CampaignDetailModel.fromJson(json.decode(str));

String campaignDetailModelToJson(CampaignDetailModel data) =>
    json.encode(data.toJson());

class CampaignDetailModel {
  String status;
  String message;
  CampaignData data;

  CampaignDetailModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CampaignDetailModel.fromJson(Map<String, dynamic> json) =>
      CampaignDetailModel(
        status: json["status"],
        message: json["message"],
        data: CampaignData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data.toJson(),
  };
}

class CampaignData {
  int id;
  String title;
  String coverImage;
  String? endDate;
  String targetAmount;
  String description;
  String collectedAmount;
  int percentage;
  int donaturCount;
  List<CampaignUpdate> updates;

  CampaignData({
    required this.id,
    required this.title,
    required this.coverImage,
    this.endDate,
    required this.targetAmount,
    required this.description,
    required this.collectedAmount,
    required this.percentage,
    required this.donaturCount,
    required this.updates,
  });

  factory CampaignData.fromJson(Map<String, dynamic> json) => CampaignData(
    id: json["id"],
    title: json["title"],
    coverImage: json["cover_image"],
    endDate: json["end_date"],
    targetAmount: json["target_amount"],
    description: json["description"],
    collectedAmount: json["collected_amount"],
    percentage: json["percentage"],
    donaturCount: json["donatur_count"],
    updates: json["updates"] != null
        ? List<CampaignUpdate>.from(
            json["updates"].map((x) => CampaignUpdate.fromJson(x)),
          )
        : [],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "cover_image": coverImage,
    "end_date": endDate,
    "target_amount": targetAmount,
    "description": description,
    "collected_amount": collectedAmount,
    "percentage": percentage,
    "donatur_count": donaturCount,
    "updates": List<dynamic>.from(updates.map((x) => x.toJson())),
  };
}

class CampaignUpdate {
  int id;
  int campaignId;
  String title;
  String content;
  DateTime date;
  DateTime createdAt;
  DateTime updatedAt;
  String createdAtFormatted;

  CampaignUpdate({
    required this.id,
    required this.campaignId,
    required this.title,
    required this.content,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    required this.createdAtFormatted,
  });

  factory CampaignUpdate.fromJson(Map<String, dynamic> json) => CampaignUpdate(
    id: json["id"],
    campaignId: json["campaign_id"],
    title: json["title"],
    content: json["content"],
    date: DateTime.parse(json["date"]),
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    createdAtFormatted: json["created_at_formatted"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "campaign_id": campaignId,
    "title": title,
    "content": content,
    "date": date.toIso8601String(),
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "created_at_formatted": createdAtFormatted,
  };
}
