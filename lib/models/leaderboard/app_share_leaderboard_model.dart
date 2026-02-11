import 'dart:convert';

AppShareLeaderboard appShareLeaderboardFromJson(String str) =>
    AppShareLeaderboard.fromJson(json.decode(str));

String appShareLeaderboardToJson(AppShareLeaderboard data) =>
    json.encode(data.toJson());

class AppShareLeaderboard {
  String status;
  Data data;

  AppShareLeaderboard({required this.status, required this.data});

  factory AppShareLeaderboard.fromJson(Map<String, dynamic> json) =>
      AppShareLeaderboard(
        status: json["status"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"status": status, "data": data.toJson()};
}

class Data {
  List<LeaderboardEntry> leaderboard;
  LeaderboardEntry? myStats;

  Data({required this.leaderboard, this.myStats});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    leaderboard: List<LeaderboardEntry>.from(
      json["leaderboard"].map((x) => LeaderboardEntry.fromJson(x)),
    ),
    myStats: json["my_stats"] == null
        ? null
        : LeaderboardEntry.fromJson(json["my_stats"]),
  );

  Map<String, dynamic> toJson() => {
    "leaderboard": List<dynamic>.from(leaderboard.map((x) => x.toJson())),
    "my_stats": myStats?.toJson(),
  };
}

class LeaderboardEntry {
  int id;
  String name;
  String? profilePicture;
  String referralCode;
  int totalReferral;
  int totalShare;
  int rank;

  LeaderboardEntry({
    required this.id,
    required this.name,
    this.profilePicture,
    required this.referralCode,
    required this.totalReferral,
    required this.totalShare,
    required this.rank,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      LeaderboardEntry(
        id: json["id"],
        name: json["name"],
        profilePicture: json["profile_picture"],
        referralCode: json["referral_code"],
        totalReferral: json["total_referral"],
        totalShare: json["total_share"],
        rank: json["rank"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "profile_picture": profilePicture,
    "referral_code": referralCode,
    "total_referral": totalReferral,
    "total_share": totalShare,
    "rank": rank,
  };
}
