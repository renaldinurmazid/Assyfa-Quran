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
  };
}
