/// Models for the daily activity checklist (personal or per group).
class DailyActivityItem {
  final int id;
  final String title;
  final String? icon;
  bool checked;

  DailyActivityItem({
    required this.id,
    required this.title,
    this.icon,
    this.checked = false,
  });

  factory DailyActivityItem.fromJson(Map<String, dynamic> json) =>
      DailyActivityItem(
        id: json['id'] as int,
        title: json['title'] as String? ?? '',
        icon: json['icon'] as String?,
        checked: json['checked'] == true,
      );
}

class DailyActivityWeekDay {
  /// yyyy-MM-dd
  final String date;
  final int checked;
  final int total;

  const DailyActivityWeekDay({
    required this.date,
    required this.checked,
    required this.total,
  });

  bool get isComplete => total > 0 && checked >= total;

  factory DailyActivityWeekDay.fromJson(Map<String, dynamic> json) =>
      DailyActivityWeekDay(
        date: json['date'] as String,
        checked: (json['checked'] as num?)?.toInt() ?? 0,
        total: (json['total'] as num?)?.toInt() ?? 0,
      );
}

class DailyActivityMember {
  final int userId;
  final String name;
  final String? profilePicture;
  final int checked;

  const DailyActivityMember({
    required this.userId,
    required this.name,
    this.profilePicture,
    required this.checked,
  });

  factory DailyActivityMember.fromJson(Map<String, dynamic> json) =>
      DailyActivityMember(
        userId: json['user_id'] as int,
        name: json['name'] as String? ?? '-',
        profilePicture: json['profile_picture'] as String?,
        checked: (json['checked'] as num?)?.toInt() ?? 0,
      );
}

class DailyActivityPreset {
  final String key;
  final String title;

  const DailyActivityPreset({required this.key, required this.title});

  factory DailyActivityPreset.fromJson(Map<String, dynamic> json) =>
      DailyActivityPreset(
        key: json['key'] as String,
        title: json['title'] as String,
      );
}

class DailyActivityDay {
  final String date;
  final int? groupId;
  final String? groupName;
  final bool isOwner;
  final List<DailyActivityItem> activities;
  final int totalCount;
  final List<DailyActivityWeekDay> week;
  final List<DailyActivityMember> members;

  DailyActivityDay({
    required this.date,
    this.groupId,
    this.groupName,
    this.isOwner = false,
    required this.activities,
    required this.totalCount,
    required this.week,
    required this.members,
  });

  /// Derived from the items so optimistic toggles update it immediately.
  int get checkedCount => activities.where((a) => a.checked).length;

  /// Personal lists are always managed by their owner; group lists only by the group owner.
  bool get canManage => groupId == null || isOwner;

  factory DailyActivityDay.fromJson(Map<String, dynamic> json) {
    final group = json['group'] as Map<String, dynamic>?;
    return DailyActivityDay(
      date: json['date'] as String,
      groupId: group?['id'] as int?,
      groupName: group?['name'] as String?,
      isOwner: group?['is_owner'] == true,
      activities: (json['activities'] as List? ?? [])
          .map((e) => DailyActivityItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: (json['total_count'] as num?)?.toInt() ?? 0,
      week: (json['week'] as List? ?? [])
          .map((e) => DailyActivityWeekDay.fromJson(e as Map<String, dynamic>))
          .toList(),
      members: (json['members'] as List? ?? [])
          .map((e) => DailyActivityMember.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
