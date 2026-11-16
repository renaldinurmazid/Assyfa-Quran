/// Groups of the daily activity checklist. Not related to Grup Ngaji.
class ActivityGroup {
  final int id;
  final String name;
  final String code;
  final int memberCount;
  final bool isOwner;

  const ActivityGroup({
    required this.id,
    required this.name,
    required this.code,
    required this.memberCount,
    required this.isOwner,
  });

  factory ActivityGroup.fromJson(Map<String, dynamic> json) => ActivityGroup(
    id: json['id'] as int,
    name: json['name'] as String? ?? '',
    code: json['code'] as String? ?? '',
    memberCount: (json['member_count'] as num?)?.toInt() ?? 0,
    isOwner: json['is_owner'] == true,
  );
}

class ActivityGroupMember {
  final int userId;
  final String name;
  final String? profilePicture;
  final bool isOwner;

  const ActivityGroupMember({
    required this.userId,
    required this.name,
    this.profilePicture,
    required this.isOwner,
  });

  factory ActivityGroupMember.fromJson(Map<String, dynamic> json) =>
      ActivityGroupMember(
        userId: json['user_id'] as int,
        name: json['name'] as String? ?? '-',
        profilePicture: json['profile_picture'] as String?,
        isOwner: json['is_owner'] == true,
      );
}

class ActivityGroupDetail {
  final ActivityGroup group;
  final List<ActivityGroupMember> members;

  const ActivityGroupDetail({required this.group, required this.members});

  factory ActivityGroupDetail.fromJson(Map<String, dynamic> json) =>
      ActivityGroupDetail(
        group: ActivityGroup.fromJson(json),
        members: (json['members'] as List? ?? [])
            .map((e) => ActivityGroupMember.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
