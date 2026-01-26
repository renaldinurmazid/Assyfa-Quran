import 'dart:convert';

PublicGroupModel publicGroupModelFromJson(String str) =>
    PublicGroupModel.fromJson(json.decode(str));

class PublicGroupModel {
  bool status;
  String message;
  PublicGroupData data;

  PublicGroupModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory PublicGroupModel.fromJson(Map<String, dynamic> json) =>
      PublicGroupModel(
        status: json["status"],
        message: json["message"],
        data: PublicGroupData.fromJson(json["data"]),
      );
}

class PublicGroupData {
  int currentPage;
  List<PublicGroupItem> data;
  String firstPageUrl;
  int from;
  int lastPage;
  String lastPageUrl;
  List<Link> links;
  String? nextPageUrl;
  String path;
  int perPage;
  String? prevPageUrl;
  int to;
  int total;

  PublicGroupData({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.links,
    this.nextPageUrl,
    required this.path,
    required this.perPage,
    this.prevPageUrl,
    required this.to,
    required this.total,
  });

  factory PublicGroupData.fromJson(Map<String, dynamic> json) =>
      PublicGroupData(
        currentPage: json["current_page"],
        data: List<PublicGroupItem>.from(
          json["data"].map((x) => PublicGroupItem.fromJson(x)),
        ),
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
}

class PublicGroupItem {
  int id;
  String name;
  String? coverImage;
  int userId;
  DateTime createdAt;
  int memberCount;
  CreatedBy createdBy;

  PublicGroupItem({
    required this.id,
    required this.name,
    this.coverImage,
    required this.userId,
    required this.createdAt,
    required this.memberCount,
    required this.createdBy,
  });

  factory PublicGroupItem.fromJson(Map<String, dynamic> json) =>
      PublicGroupItem(
        id: json["id"],
        name: json["name"],
        coverImage: json["cover_image"],
        userId: json["user_id"],
        createdAt: DateTime.parse(json["created_at"]),
        memberCount: json["member_count"],
        createdBy: CreatedBy.fromJson(json["created_by"]),
      );
}

class CreatedBy {
  int id;
  String name;
  String? profilePicture;

  CreatedBy({required this.id, required this.name, this.profilePicture});

  factory CreatedBy.fromJson(Map<String, dynamic> json) => CreatedBy(
    id: json["id"],
    name: json["name"],
    profilePicture: json["profile_picture"],
  );
}

class Link {
  String? url;
  String label;
  bool active;

  Link({this.url, required this.label, required this.active});

  factory Link.fromJson(Map<String, dynamic> json) =>
      Link(url: json["url"], label: json["label"], active: json["active"]);
}
