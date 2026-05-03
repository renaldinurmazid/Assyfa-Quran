class MemorizeLeaderboard {
  final List<LeaderboardEntry> leaderboard;
  final LeaderboardEntry? myStat;

  MemorizeLeaderboard({
    required this.leaderboard,
    this.myStat,
  });

  factory MemorizeLeaderboard.fromJson(Map<String, dynamic> json) {
    return MemorizeLeaderboard(
      leaderboard: (json['leaderboard'] as List?)
              ?.map((e) => LeaderboardEntry.fromJson(e))
              .toList() ??
          [],
      myStat: json['my_stat'] != null
          ? LeaderboardEntry.fromJson(json['my_stat'])
          : null,
    );
  }
}

class LeaderboardEntry {
  final int id;
  final int userId;
  final int totalWordsMastered;
  final int totalPoints;
  final int? highestLevelId;
  final int? rank;
  final LeaderboardUser? user;
  final LeaderboardLevel? highestLevel;
  final String? createdAt;
  final String? updatedAt;

  LeaderboardEntry({
    required this.id,
    required this.userId,
    required this.totalWordsMastered,
    required this.totalPoints,
    this.highestLevelId,
    this.rank,
    this.user,
    this.highestLevel,
    this.createdAt,
    this.updatedAt,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      totalWordsMastered: json['total_words_mastered'] ?? 0,
      totalPoints: json['total_points'] ?? 0,
      highestLevelId: json['highest_level_id'],
      rank: json['rank'],
      user: json['user'] != null ? LeaderboardUser.fromJson(json['user']) : null,
      highestLevel: json['highest_level'] != null
          ? LeaderboardLevel.fromJson(json['highest_level'])
          : null,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class LeaderboardUser {
  final int id;
  final String name;
  final String? profilePicture;

  LeaderboardUser({
    required this.id,
    required this.name,
    this.profilePicture,
  });

  factory LeaderboardUser.fromJson(Map<String, dynamic> json) {
    return LeaderboardUser(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      profilePicture: json['profile_picture'],
    );
  }
}

class LeaderboardLevel {
  final int id;
  final String title;

  LeaderboardLevel({
    required this.id,
    required this.title,
  });

  factory LeaderboardLevel.fromJson(Map<String, dynamic> json) {
    return LeaderboardLevel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
    );
  }
}
