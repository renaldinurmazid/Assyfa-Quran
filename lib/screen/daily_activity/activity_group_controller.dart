import 'package:dio/dio.dart' as dio;
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/models/daily_activity/activity_group_model.dart';
import 'package:quran_app/widgets/app_toast.dart';
import 'package:share_plus/share_plus.dart';

/// Members and invite code of one activity group (Grup Aktivitas, not Grup Ngaji).
class ActivityGroupController extends GetxController {
  final isLoading = true.obs;
  final isSaving = false.obs;
  final detail = Rxn<ActivityGroupDetail>();

  late final int groupId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    groupId = args is int ? args : 0;
    load();
  }

  Future<void> load() async {
    try {
      final response = await Request().get(Url.activityGroup(groupId));
      detail.value = ActivityGroupDetail.fromJson(response.data['data']);
    } catch (e) {
      _toastError(e, 'Gagal memuat grup.');
    } finally {
      isLoading.value = false;
    }
  }

  void copyCode() {
    final code = detail.value?.group.code;
    if (code == null) return;
    Clipboard.setData(ClipboardData(text: code));
    AppToast.success(message: 'Kode grup disalin');
  }

  void shareCode() {
    final group = detail.value?.group;
    if (group == null) return;
    SharePlus.instance.share(
      ShareParams(
        text:
            'Ayo gabung grup "${group.name}" di Aktivitas Harian Quranuna.\n'
            'Buka Aktivitas Harian → Buat / gabung grup → masukkan kode: ${group.code}',
      ),
    );
  }

  Future<bool> rename(String name) async {
    isSaving.value = true;
    try {
      await Request().put(Url.activityGroup(groupId), data: {'name': name});
      await load();
      return true;
    } catch (e) {
      _toastError(e, 'Gagal mengubah nama grup.');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// Deletes the group (owner). Closes the screen on success.
  Future<void> deleteGroup() async {
    try {
      await Request().delete(Url.activityGroup(groupId));
      Get.back();
      AppToast.success(message: 'Grup berhasil dihapus.');
    } catch (e) {
      _toastError(e, 'Gagal menghapus grup.');
    }
  }

  /// A member leaves (not the owner). Closes the screen on success.
  Future<void> leaveGroup() async {
    try {
      await Request().post(Url.activityGroupLeave(groupId));
      Get.back();
      AppToast.success(message: 'Anda telah keluar dari grup.');
    } catch (e) {
      _toastError(e, 'Gagal keluar dari grup.');
    }
  }

  Future<void> removeMember(ActivityGroupMember member) async {
    try {
      await Request().delete(Url.activityGroupMember(groupId, member.userId));
      await load();
    } catch (e) {
      _toastError(e, 'Gagal mengeluarkan anggota.');
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
