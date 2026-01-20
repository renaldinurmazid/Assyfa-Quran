// To parse this JSON data, do
//
//     final userForMemberGroup = userForMemberGroupFromJson(jsonString);

import 'dart:convert';

UserForMemberGroup userForMemberGroupFromJson(String str) =>
    UserForMemberGroup.fromJson(json.decode(str));

String userForMemberGroupToJson(UserForMemberGroup data) =>
    json.encode(data.toJson());

class UserForMemberGroup {
  bool status;
  List<Datum> data;

  UserForMemberGroup({required this.status, required this.data});

  factory UserForMemberGroup.fromJson(Map<String, dynamic> json) =>
      UserForMemberGroup(
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
  String profilePicture;

  Datum({required this.id, required this.name, required this.profilePicture});

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    name: json["name"],
    profilePicture: json["profile_picture"] == null
        ? ""
        : json["profile_picture"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "profile_picture": profilePicture,
  };
}
