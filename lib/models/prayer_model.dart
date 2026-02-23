import 'dart:convert';

class PrayerResponse {
  final String? status;
  final List<PrayerItem>? data;

  PrayerResponse({this.status, this.data});

  factory PrayerResponse.fromRawJson(String str) =>
      PrayerResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PrayerResponse.fromJson(Map<String, dynamic> json) => PrayerResponse(
    status: json["status"],
    data: json["data"] == null
        ? []
        : List<PrayerItem>.from(
            json["data"].map((x) => PrayerItem.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class PrayerItem {
  final int? id;
  final String? content;
  final bool? isAnonymous;
  final String? userName;
  final String? userProfile;
  final String? publishedAt;
  final int? amensCount;
  final List<AmenUser>? latestAmens;
  final List<AmenUser>? amens;
  final bool? isAmened;
  final bool? isMyPrayer;

  PrayerItem({
    this.id,
    this.content,
    this.isAnonymous,
    this.userName,
    this.userProfile,
    this.publishedAt,
    this.amensCount,
    this.latestAmens,
    this.amens,
    this.isAmened,
    this.isMyPrayer,
  });

  factory PrayerItem.fromRawJson(String str) =>
      PrayerItem.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PrayerItem.fromJson(Map<String, dynamic> json) => PrayerItem(
    id: json["id"],
    content: json["content"],
    isAnonymous: json["is_anonymous"],
    userName: json["user_name"],
    userProfile: json["user_profile"],
    publishedAt: json["published_at"],
    amensCount: json["amens_count"],
    latestAmens: json["latest_amens"] == null
        ? []
        : List<AmenUser>.from(
            json["latest_amens"].map((x) => AmenUser.fromJson(x)),
          ),
    amens: json["amens"] == null
        ? []
        : List<AmenUser>.from(json["amens"].map((x) => AmenUser.fromJson(x))),
    isAmened: json["is_amened"],
    isMyPrayer: json["is_my_prayer"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "content": content,
    "is_anonymous": isAnonymous,
    "user_name": userName,
    "user_profile": userProfile,
    "published_at": publishedAt,
    "amens_count": amensCount,
    "latest_amens": latestAmens == null
        ? []
        : List<dynamic>.from(latestAmens!.map((x) => x.toJson())),
    "amens": amens == null
        ? []
        : List<dynamic>.from(amens!.map((x) => x.toJson())),
    "is_amened": isAmened,
    "is_my_prayer": isMyPrayer,
  };
}

class PrayerDetailResponse {
  final String? status;
  final PrayerItem? data;

  PrayerDetailResponse({this.status, this.data});

  factory PrayerDetailResponse.fromRawJson(String str) =>
      PrayerDetailResponse.fromJson(json.decode(str));

  factory PrayerDetailResponse.fromJson(Map<String, dynamic> json) =>
      PrayerDetailResponse(
        status: json["status"],
        data: json["data"] == null ? null : PrayerItem.fromJson(json["data"]),
      );
}

class AmenUser {
  final String? userName;
  final String? userProfile;

  AmenUser({this.userName, this.userProfile});

  factory AmenUser.fromRawJson(String str) =>
      AmenUser.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AmenUser.fromJson(Map<String, dynamic> json) =>
      AmenUser(userName: json["user_name"], userProfile: json["user_profile"]);

  Map<String, dynamic> toJson() => {
    "user_name": userName,
    "user_profile": userProfile,
  };
}
