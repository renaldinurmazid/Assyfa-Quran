/// `/api/arabic-learning/leaderboard`: learners ranked by XP, paginated.
class ArabicLeaderboardEntry {
  final int? rank; // null while the user has no XP yet
  final int userId;
  final String name;
  final String? profilePicture;
  final int totalXp;

  ArabicLeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.name,
    this.profilePicture,
    required this.totalXp,
  });

  factory ArabicLeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return ArabicLeaderboardEntry(
      rank: json['rank'],
      userId: json['user_id'] ?? 0,
      name: json['name'] ?? '',
      profilePicture: json['profile_picture'],
      totalXp: json['total_xp'] ?? 0,
    );
  }
}

class ArabicLeaderboardPage {
  final List<ArabicLeaderboardEntry> entries;
  final int currentPage;
  final int lastPage;
  final int total;
  final ArabicLeaderboardEntry? myStat;

  ArabicLeaderboardPage({
    required this.entries,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    this.myStat,
  });

  factory ArabicLeaderboardPage.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] as Map<String, dynamic>? ?? const {};
    return ArabicLeaderboardPage(
      entries: (json['data'] as List? ?? [])
          .map((e) => ArabicLeaderboardEntry.fromJson(e))
          .toList(),
      currentPage: meta['current_page'] ?? 1,
      lastPage: meta['last_page'] ?? 1,
      total: meta['total'] ?? 0,
      myStat: json['my_stat'] == null
          ? null
          : ArabicLeaderboardEntry.fromJson(json['my_stat']),
    );
  }
}
