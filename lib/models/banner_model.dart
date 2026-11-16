import 'dart:convert';

BannerResponse bannerResponseFromJson(String str) =>
    BannerResponse.fromJson(json.decode(str));

String bannerResponseToJson(BannerResponse data) => json.encode(data.toJson());

class BannerResponse {
  String status;
  List<BannerData> data;

  BannerResponse({required this.status, required this.data});

  factory BannerResponse.fromJson(Map<String, dynamic> json) => BannerResponse(
    status: json["status"],
    data: List<BannerData>.from(
      json["data"].map((x) => BannerData.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class BannerData {
  int id;
  String cover;
  String redirectTo;

  BannerData({required this.id, required this.cover, required this.redirectTo});

  factory BannerData.fromJson(Map<String, dynamic> json) => BannerData(
    id: json["id"],
    cover: json["cover"],
    redirectTo: json["redirect_to"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "cover": cover,
    "redirect_to": redirectTo,
  };
}
