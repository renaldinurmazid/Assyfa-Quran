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
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    name: json["name"],
    code: json["code"],
    coverImage: json["cover_image"],
    isPrivate: json["is_private"],
    userId: json["user_id"],
    createdAt: DateTime.parse(json["created_at"]),
    isMyGroup: json["is_my_group"],
    weeklyHistory: WeeklyHistory.fromJson(json["weekly_history"]),
    createdBy: CreatedBy.fromJson(json["created_by"]),
    groupUser: List<GroupUser>.from(
      json["group_user"].map((x) => GroupUser.fromJson(x)),
    ),
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
  };
}

class WeeklyHistory {
  List<Summary> summary;
  int totalPages;

  WeeklyHistory({required this.summary, required this.totalPages});

  factory WeeklyHistory.fromJson(Map<String, dynamic> json) => WeeklyHistory(
    summary: List<Summary>.from(
      json["summary"].map((x) => Summary.fromJson(x)),
    ),
    totalPages: json["total_pages"],
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
      Summary(day: json["day"], totalPages: json["total_pages"]);

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
    id: json["id"],
    name: json["name"],
    profilePicture: json["profile_picture"],
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
    id: json["id"],
    groupId: json["group_id"],
    userId: json["user_id"],
    user: CreatedBy.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "group_id": groupId,
    "user_id": userId,
    "user": user.toJson(),
  };
}
