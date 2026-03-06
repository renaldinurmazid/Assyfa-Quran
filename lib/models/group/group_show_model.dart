// To parse this JSON data, do
//
//     final groupShow = groupShowFromJson(jsonString);

import 'dart:convert';

GroupShow groupShowFromJson(String str) => GroupShow.fromJson(json.decode(str));

String groupShowToJson(GroupShow data) => json.encode(data.toJson());

class GroupShow {
  bool status;
  Data data;

  GroupShow({required this.status, required this.data});

  factory GroupShow.fromJson(Map<String, dynamic> json) =>
      GroupShow(status: json["status"], data: Data.fromJson(json["data"]));

  Map<String, dynamic> toJson() => {"status": status, "data": data.toJson()};
}

class Data {
  int id;
  String name;
  String code;
  dynamic coverImage;
  int isPrivate;
  int userId;
  DateTime createdAt;
  bool isMyGroup;
  WeeklyHistory weeklyHistory;
  CreatedBy createdBy;
  List<GroupUser> groupUser;
  String? shareUrl;

  Data({
    required this.id,
    required this.name,
    required this.code,
    required this.coverImage,
    required this.isPrivate,
    required this.userId,
    required this.createdAt,
    required this.isMyGroup,
    required this.weeklyHistory,
    required this.createdBy,
    required this.groupUser,
    this.shareUrl,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"] ?? 0,
    name: json["name"] ?? "",
    code: json["code"] ?? "",
    coverImage: json["cover_image"],
    isPrivate: json["is_private"] ?? 0,
    userId: json["user_id"] ?? 0,
    createdAt: json["created_at"] != null
        ? DateTime.parse(json["created_at"])
        : DateTime.now(),
    isMyGroup: json["is_my_group"] ?? false,
    weeklyHistory: json["weekly_history"] != null
        ? WeeklyHistory.fromJson(json["weekly_history"])
        : WeeklyHistory(summary: [], totalPages: 0),
    createdBy: json["created_by"] != null
        ? CreatedBy.fromJson(json["created_by"])
        : CreatedBy(id: 0, name: "", profilePicture: ""),
    groupUser: json["group_user"] != null
        ? List<GroupUser>.from(
            json["group_user"].map((x) => GroupUser.fromJson(x)),
          )
        : [],
    shareUrl: json["share_url"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "code": code,
    "cover_image": coverImage,
    "is_private": isPrivate,
    "user_id": userId,
    "created_at": createdAt.toIso8601String(),
    "is_my_group": isMyGroup,
    "weekly_history": weeklyHistory.toJson(),
    "created_by": createdBy.toJson(),
    "group_user": List<dynamic>.from(groupUser.map((x) => x.toJson())),
    "share_url": shareUrl,
  };
}

class WeeklyHistory {
  List<Summary> summary;
  int totalPages;

  WeeklyHistory({required this.summary, required this.totalPages});

  factory WeeklyHistory.fromJson(Map<String, dynamic> json) => WeeklyHistory(
    summary: json["summary"] != null
        ? List<Summary>.from(json["summary"].map((x) => Summary.fromJson(x)))
        : [],
    totalPages: json["total_pages"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "summary": List<dynamic>.from(summary.map((x) => x.toJson())),
    "total_pages": totalPages,
  };
}

class Summary {
  String day;
  int totalPages;

  Summary({required this.day, required this.totalPages});

  factory Summary.fromJson(Map<String, dynamic> json) =>
      Summary(day: json["day"] ?? "", totalPages: json["total_pages"] ?? 0);

  Map<String, dynamic> toJson() => {"day": day, "total_pages": totalPages};
}

class CreatedBy {
  int id;
  String name;
  String profilePicture;

  CreatedBy({
    required this.id,
    required this.name,
    required this.profilePicture,
  });

  factory CreatedBy.fromJson(Map<String, dynamic> json) => CreatedBy(
    id: json["id"] ?? 0,
    name: json["name"] ?? "",
    profilePicture: json["profile_picture"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "profile_picture": profilePicture,
  };
}

class GroupUser {
  int id;
  int groupId;
  int userId;
  CreatedBy user;

  GroupUser({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.user,
  });

  factory GroupUser.fromJson(Map<String, dynamic> json) => GroupUser(
    id: json["id"] ?? 0,
    groupId: json["group_id"] ?? 0,
    userId: json["user_id"] ?? 0,
    user: json["user"] != null
        ? CreatedBy.fromJson(json["user"])
        : CreatedBy(id: 0, name: "", profilePicture: ""),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "group_id": groupId,
    "user_id": userId,
    "user": user.toJson(),
  };
}
