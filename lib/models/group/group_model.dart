// To parse this JSON data, do
//
//     final groups = groupsFromJson(jsonString);

import 'dart:convert';

Groups groupsFromJson(String str) => Groups.fromJson(json.decode(str));

String groupsToJson(Groups data) => json.encode(data.toJson());

class Groups {
  bool status;
  List<Datum> data;

  Groups({required this.status, required this.data});

  factory Groups.fromJson(Map<String, dynamic> json) => Groups(
    status: json["status"],
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  int id;
  String name;
  dynamic coverImage;
  int userId;
  int memberCount;
  Pivot pivot;
  CreatedBy createdBy;

  Datum({
    required this.id,
    required this.name,
    required this.coverImage,
    required this.userId,
    required this.memberCount,
    required this.pivot,
    required this.createdBy,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    name: json["name"],
    coverImage: json["cover_image"],
    userId: json["user_id"],
    memberCount: json["member_count"],
    pivot: Pivot.fromJson(json["pivot"]),
    createdBy: CreatedBy.fromJson(json["created_by"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "cover_image": coverImage,
    "user_id": userId,
    "member_count": memberCount,
    "pivot": pivot.toJson(),
    "created_by": createdBy.toJson(),
  };
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

class Pivot {
  int userId;
  int groupId;

  Pivot({required this.userId, required this.groupId});

  factory Pivot.fromJson(Map<String, dynamic> json) =>
      Pivot(userId: json["user_id"], groupId: json["group_id"]);

  Map<String, dynamic> toJson() => {"user_id": userId, "group_id": groupId};
}
