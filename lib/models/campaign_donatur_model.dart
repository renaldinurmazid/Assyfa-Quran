import 'dart:convert';

CampaignDonaturModel campaignDonaturModelFromJson(String str) =>
    CampaignDonaturModel.fromJson(json.decode(str));

String campaignDonaturModelToJson(CampaignDonaturModel data) =>
    json.encode(data.toJson());

class CampaignDonaturModel {
  String status;
  String message;
  CampaignDonaturData data;

  CampaignDonaturModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CampaignDonaturModel.fromJson(Map<String, dynamic> json) =>
      CampaignDonaturModel(
        status: json["status"],
        message: json["message"],
        data: CampaignDonaturData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data.toJson(),
  };
}

class CampaignDonaturData {
  int currentPage;
  List<DonaturItem> data;
  int lastPage;
  int perPage;
  int total;

  CampaignDonaturData({
    required this.currentPage,
    required this.data,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory CampaignDonaturData.fromJson(Map<String, dynamic> json) =>
      CampaignDonaturData(
        currentPage: json["current_page"],
        data: List<DonaturItem>.from(
          json["data"].map((x) => DonaturItem.fromJson(x)),
        ),
        lastPage: json["last_page"],
        perPage: json["per_page"],
        total: json["total"],
      );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "last_page": lastPage,
    "per_page": perPage,
    "total": total,
  };
}

class DonaturItem {
  String name;
  String amount;
  String time;

  DonaturItem({required this.name, required this.amount, required this.time});

  factory DonaturItem.fromJson(Map<String, dynamic> json) => DonaturItem(
    name: json["name"] ?? 'Hamba Allah',
    amount: json["amount"] ?? 'Rp0',
    time: json["time"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "amount": amount,
    "time": time,
  };

  bool get isAnonymous => name == 'Hamba Allah';
}
