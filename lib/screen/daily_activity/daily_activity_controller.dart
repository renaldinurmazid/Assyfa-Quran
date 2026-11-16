import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/models/daily_activity/activity_group_model.dart';
import 'package:quran_app/models/daily_activity/daily_activity_model.dart';
import 'package:quran_app/widgets/app_toast.dart';

/// Daily checklist. It starts on the personal list; the user can switch to any of their activity
/// groups (Grup Aktivitas, separate from Grup Ngaji) or create/join one.
class DailyActivityController extends GetxController {
  static final _dateFormat = DateFormat('yyyy-MM-dd');

  final isLoading = true.obs;
  final day = Rxn<DailyActivityDay>();
  final selectedDate = _dateFormat.format(DateTime.now()).obs;
  final groupId = RxnInt();
  final myGroups = <ActivityGroup>[].obs;
  final presets = <DailyActivityPreset>[].obs;
  final isSaving = false.obs;

  /// Items with a request in flight; further taps on them are ignored so retries cannot race.
  final busyIds = <int>{}.obs;

  int _loadSeq = 0;

  String get today => _dateFormat.format(DateTime.now());
  bool get isToday => selectedDate.value == today;

  @override
  void onInit() {
    super.onInit();
    if (AuthController.to.isLogin.value) {
      loadGroups();
      loadPresets();
      load();
    } else {
      isLoading.value = false;
    }
  }

  Future<void> load({bool silent = false}) async {
    final seq = ++_loadSeq;
    if (!silent) {
      isLoading.value = true;
    }
    try {
      final response = await Request().get(
        Url.dailyActivities,
        queryParameters: {
          'date': selectedDate.value,
          if (groupId.value != null) 'group_id': groupId.value,
        },
      );
      if (seq != _loadSeq) return; // the user switched day/group meanwhile
      day.value = DailyActivityDay.fromJson(response.data['data']);
    } catch (e) {
      if (seq != _loadSeq) return;
      _toastError(e, 'Gagal memuat aktivitas harian.');
    } finally {
      if (seq == _loadSeq) {
        isLoading.value = false;
      }
    }
  }

  Future<void> loadGroups() async {
    try {
      final response = await Request().get(Url.activityGroups);
      myGroups.assignAll(
        (response.data['data'] as List? ?? []).map(
          (g) => ActivityGroup.fromJson(g as Map<String, dynamic>),
        ),
      );
    } catch (e) {
      debugPrint('daily activity groups: $e');
    }
  }

  Future<void> loadPresets() async {
    try {
      final response = await Request().get(Url.dailyActivityPresets);
      presets.assignAll(
        (response.data['data'] as List).map(
          (e) => DailyActivityPreset.fromJson(e as Map<String, dynamic>),
        ),
      );
    } catch (e) {
      debugPrint('daily activity presets: $e');
    }
  }

  /// Creates a group and switches to it. Returns false (after a toast) on failure.
  Future<bool> createGroup(String name) async {
    isSaving.value = true;
    try {
      final response = await Request().post(
        Url.activityGroups,
        data: {'name': name.trim()},
      );
      final group = ActivityGroup.fromJson(response.data['data']);
      await loadGroups();
      selectGroup(group.id);
      AppToast.success(message: 'Grup "${group.name}" berhasil dibuat.');
      return true;
    } catch (e) {
      _toastError(e, 'Gagal membuat grup.');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> joinGroup(String code) async {
    isSaving.value = true;
    try {
      final response = await Request().post(
        Url.activityGroupJoin,
        data: {'code': code.trim()},
      );
      final group = ActivityGroup.fromJson(response.data['data']);
      await loadGroups();
      selectGroup(group.id);
      AppToast.success(message: 'Berhasil bergabung ke "${group.name}".');
      return true;
    } catch (e) {
      _toastError(e, 'Gagal bergabung ke grup.');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// After the group screen: the group may have been renamed, left or deleted.
  Future<void> refreshGroupsAfterManage() async {
    await loadGroups();
    final current = groupId.value;
    if (current != null && !myGroups.any((g) => g.id == current)) {
      selectGroup(null);
    } else {
      await load(silent: true);
    }
  }

  void selectGroup(int? id) {
    if (groupId.value == id) return;
    groupId.value = id;
    selectedDate.value = today;
    day.value = null;
    load();
  }

  void selectDate(String date) {
    if (selectedDate.value == date) return;
    selectedDate.value = date;
    load(silent: true);
  }

  /// Optimistic: the box flips at once and is put back if the server says no.
  Future<void> toggle(DailyActivityItem item) async {
    final current = day.value;
    if (current == null || busyIds.contains(item.id)) return;

    final target = !item.checked;
    item.checked = target;
    _bumpWeek(current, target ? 1 : -1);
    busyIds.add(item.id);
    day.refresh();

    try {
      await Request().post(
        Url.dailyActivityCheck(item.id),
        data: {'checked': target, 'date': selectedDate.value},
      );
      if (current.groupId != null) {
        load(silent: true); // keep the member list current
      }
    } catch (e) {
      item.checked = !target;
      _bumpWeek(current, target ? -1 : 1);
      _toastError(e, 'Gagal menyimpan. Coba lagi.');
    } finally {
      busyIds.remove(item.id);
      day.refresh();
    }
  }

  void _bumpWeek(DailyActivityDay current, int delta) {
    final i = current.week.indexWhere((d) => d.date == selectedDate.value);
    if (i < 0) return;
    final d = current.week[i];
    current.week[i] = DailyActivityWeekDay(
      date: d.date,
      checked: (d.checked + delta).clamp(0, d.total),
      total: d.total,
    );
  }

  Future<bool> addActivity(String title, {String? icon}) async {
    isSaving.value = true;
    try {
      await Request().post(
        Url.dailyActivities,
        data: {
          'title': title.trim(),
          'icon': icon ?? 'custom',
          if (groupId.value != null) 'group_id': groupId.value,
        },
      );
      await load(silent: true);
      return true;
    } catch (e) {
      _toastError(e, 'Gagal menambah aktivitas.');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> renameActivity(DailyActivityItem item, String title) async {
    isSaving.value = true;
    try {
      await Request().put(
        Url.dailyActivity(item.id),
        data: {'title': title.trim(), 'icon': item.icon},
      );
      await load(silent: true);
      return true;
    } catch (e) {
      _toastError(e, 'Gagal mengubah aktivitas.');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteActivity(DailyActivityItem item) async {
    try {
      await Request().delete(Url.dailyActivity(item.id));
      await load(silent: true);
    } catch (e) {
      _toastError(e, 'Gagal menghapus aktivitas.');
    }
  }

  void _toastError(Object e, String fallback) {
    var message = fallback;
    if (e is dio.DioException) {
      final data = e.response?.data;
      if (data is Map && data['message'] is String) {
        message = data['message'] as String;
      }
    }
    AppToast.error(message: message);
  }
}
