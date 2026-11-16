import 'dart:convert';

CampaignCategory campaignCategoryFromJson(String str) =>
    CampaignCategory.fromJson(json.decode(str));

String campaignCategoryToJson(CampaignCategory data) =>
    json.encode(data.toJson());

class CampaignCategory {
  String status;
  String message;
  List<CategoryDatum> data;

  CampaignCategory({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CampaignCategory.fromJson(Map<String, dynamic> json) =>
      CampaignCategory(
        status: json["status"],
        message: json["message"],
        data: List<CategoryDatum>.from(
          json["data"].map((x) => CategoryDatum.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class CategoryDatum {
  int id;
  String name;
  String slug;

  CategoryDatum({required this.id, required this.name, required this.slug});

  factory CategoryDatum.fromJson(Map<String, dynamic> json) =>
      CategoryDatum(id: json["id"], name: json["name"], slug: json["slug"]);

  Map<String, dynamic> toJson() => {"id": id, "name": name, "slug": slug};
}
