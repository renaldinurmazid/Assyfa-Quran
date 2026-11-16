import 'package:flutter_test/flutter_test.dart';
import 'package:quran_app/models/daily_activity/activity_group_model.dart';
import 'package:quran_app/models/daily_activity/daily_activity_model.dart';

void main() {
  test('parses a personal day and derives the counts from the items', () {
    final day = DailyActivityDay.fromJson({
      'date': '2026-11-16',
      'group': null,
      'activities': [
        {'id': 1, 'title': 'Tilawah', 'icon': 'tilawah', 'checked': true},
        {'id': 2, 'title': 'Dzikir pagi', 'icon': null, 'checked': false},
      ],
      'total_count': 2,
      'week': [
        {'date': '2026-11-15', 'checked': 2, 'total': 2},
        {'date': '2026-11-16', 'checked': 1, 'total': 2},
      ],
    });

    expect(day.groupId, isNull);
    expect(day.canManage, isTrue);
    expect(day.checkedCount, 1);
    day.activities[1].checked = true;
    expect(day.checkedCount, 2);
    expect(day.week[0].isComplete, isTrue);
    expect(day.week[1].isComplete, isFalse);
    expect(day.members, isEmpty);
  });

  test('only the group owner can manage a group list', () {
    Map<String, dynamic> json(bool owner) => {
      'date': '2026-11-16',
      'group': {'id': 7, 'name': 'Ngaji', 'is_owner': owner},
      'activities': [],
      'total_count': 0,
      'week': [],
      'members': [
        {'user_id': 1, 'name': 'Ani', 'profile_picture': null, 'checked': 3},
      ],
    };

    expect(DailyActivityDay.fromJson(json(true)).canManage, isTrue);
    final member = DailyActivityDay.fromJson(json(false));
    expect(member.canManage, isFalse);
    expect(member.groupId, 7);
    expect(member.members.single.checked, 3);
  });

  test('an empty day is never "complete"', () {
    expect(
      const DailyActivityWeekDay(
        date: '2026-11-16',
        checked: 0,
        total: 0,
      ).isComplete,
      isFalse,
    );
  });

  test('parses an activity group with its members', () {
    final detail = ActivityGroupDetail.fromJson({
      'id': 3,
      'name': 'Keluarga',
      'code': 'AB12CD',
      'member_count': 2,
      'is_owner': false,
      'members': [
        {
          'user_id': 1,
          'name': 'Ani',
          'profile_picture': null,
          'is_owner': true,
        },
        {
          'user_id': 2,
          'name': 'Budi',
          'profile_picture': 'x.png',
          'is_owner': false,
        },
      ],
    });

    expect(detail.group.code, 'AB12CD');
    expect(detail.group.isOwner, isFalse);
    expect(detail.members.map((m) => m.name), ['Ani', 'Budi']);
    expect(detail.members.first.isOwner, isTrue);
  });
}
