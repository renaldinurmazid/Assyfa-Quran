// To parse this JSON data, do
//
//     final memberGroupTilawah = memberGroupTilawahFromJson(jsonString);

import 'dart:convert';

MemberGroupTilawah memberGroupTilawahFromJson(String str) =>
    MemberGroupTilawah.fromJson(json.decode(str));

String memberGroupTilawahToJson(MemberGroupTilawah data) =>
    json.encode(data.toJson());

class MemberGroupTilawah {
  bool status;
  Data data;

  MemberGroupTilawah({required this.status, required this.data});

  factory MemberGroupTilawah.fromJson(Map<String, dynamic> json) =>
      MemberGroupTilawah(
        status: json["status"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"status": status, "data": data.toJson()};
}

class Data {
  int id;
  String name;
  int memberCount;
  List<GroupUser> groupUser;

  Data({
    required this.id,
    required this.name,
    required this.memberCount,
    required this.groupUser,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    name: json["name"],
    memberCount: json["member_count"],
    groupUser: List<GroupUser>.from(
      json["group_user"].map((x) => GroupUser.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "member_count": memberCount,
    "group_user": List<dynamic>.from(groupUser.map((x) => x.toJson())),
  };
}

class GroupUser {
  int id;
  int groupId;
  int userId;
  int totalPages;
  int rank;
  User user;

  GroupUser({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.totalPages,
    required this.rank,
    required this.user,
  });

  factory GroupUser.fromJson(Map<String, dynamic> json) => GroupUser(
    id: json["id"],
    groupId: json["group_id"],
    userId: json["user_id"],
    totalPages: json["total_pages"],
    rank: json["rank"],
    user: User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "group_id": groupId,
    "user_id": userId,
    "total_pages": totalPages,
    "rank": rank,
    "user": user.toJson(),
  };
}

class User {
  int id;
  String name;
  String profilePicture;

  User({required this.id, required this.name, required this.profilePicture});

  factory User.fromJson(Map<String, dynamic> json) => User(
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
