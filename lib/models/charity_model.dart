import 'dart:convert';

Charity charityFromJson(String str) => Charity.fromJson(json.decode(str));

String charityToJson(Charity data) => json.encode(data.toJson());

class Charity {
  String status;
  String message;
  CharityData data;

  Charity({
    required this.status,
    required this.message,
    required this.data,
  });

  factory Charity.fromJson(Map<String, dynamic> json) => Charity(
        status: json["status"],
        message: json["message"],
        data: CharityData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data.toJson(),
      };
}

class CharityData {
  int currentPage;
  List<Datum> data;
  String firstPageUrl;
  int from;
  int lastPage;
  String lastPageUrl;
  List<Link> links;
  dynamic nextPageUrl;
  String path;
  int perPage;
  dynamic prevPageUrl;
  int to;
  int total;

  CharityData({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.links,
    required this.nextPageUrl,
    required this.path,
    required this.perPage,
    required this.prevPageUrl,
    required this.to,
    required this.total,
  });

  factory CharityData.fromJson(Map<String, dynamic> json) => CharityData(
        currentPage: json["current_page"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
        firstPageUrl: json["first_page_url"],
        from: json["from"] ?? 0,
        lastPage: json["last_page"],
        lastPageUrl: json["last_page_url"],
        links: List<Link>.from(json["links"].map((x) => Link.fromJson(x))),
        nextPageUrl: json["next_page_url"],
        path: json["path"],
        perPage: json["per_page"],
        prevPageUrl: json["prev_page_url"],
        to: json["to"] ?? 0,
        total: json["total"],
      );

  Map<String, dynamic> toJson() => {
        "current_page": currentPage,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "first_page_url": firstPageUrl,
        "from": from,
        "last_page": lastPage,
        "last_page_url": lastPageUrl,
        "links": List<dynamic>.from(links.map((x) => x.toJson())),
        "next_page_url": nextPageUrl,
        "path": path,
        "per_page": perPage,
        "prev_page_url": prevPageUrl,
        "to": to,
        "total": total,
      };
}

class Datum {
  int id;
  String title;
  String coverImage;
  dynamic endDate;
  String targetAmount;
  int campaignCategoryId;
  String collectedAmount;
  int percentage;
  int currentAmount;
  Category? category;

  Datum({
    required this.id,
    required this.title,
    required this.coverImage,
    required this.endDate,
    required this.targetAmount,
    required this.campaignCategoryId,
    required this.collectedAmount,
    required this.percentage,
    required this.currentAmount,
    this.category,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        title: json["title"],
        coverImage: json["cover_image"],
        endDate: json["end_date"],
        targetAmount: json["target_amount"],
        campaignCategoryId: json["campaign_category_id"],
        collectedAmount: json["collected_amount"] ?? "Rp0",
        percentage: int.tryParse(json["percentage"].toString()) ??
            (double.tryParse(json["percentage"].toString())?.toInt() ?? 0),
        currentAmount: int.tryParse(json["current_amount"].toString()) ??
            (double.tryParse(json["current_amount"].toString())?.toInt() ?? 0),
        category: json["category"] == null
            ? null
            : Category.fromJson(json["category"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "cover_image": coverImage,
        "end_date": endDate,
        "target_amount": targetAmount,
        "campaign_category_id": campaignCategoryId,
        "collected_amount": collectedAmount,
        "percentage": percentage,
        "current_amount": currentAmount,
        "category": category?.toJson(),
      };
}

class Category {
  int id;
  String name;
  String slug;

  Category({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"],
        name: json["name"],
        slug: json["slug"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "slug": slug,
      };
}

class Link {
  String? url;
  String label;
  bool active;

  Link({
    required this.url,
    required this.label,
    required this.active,
  });

  factory Link.fromJson(Map<String, dynamic> json) => Link(
        url: json["url"],
        label: json["label"],
        active: json["active"],
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "label": label,
        "active": active,
      };
}
