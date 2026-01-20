import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:quran_app/api/url.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/models/group/member_group_tilawah.dart';

class ShowMemberController extends GetxController {
  final isLoading = false.obs;
  final group = Rxn<Data>();
  int? groupId;
  int? creatorId;

  bool get isOwner =>
      AuthController.to.userData['id'] == (creatorId ?? group.value?.id);

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is int) {
      groupId = Get.arguments;
    } else if (Get.arguments is Map) {
      groupId = Get.arguments['groupId'];
      creatorId = Get.arguments['creatorId'];
    }

    if (groupId != null) {
      fetchMemberTilawah();
    }
  }

  Future<void> fetchMemberTilawah() async {
    try {
      isLoading.value = true;
      final response = await http.get(
        Uri.parse("${Url.baseUrl}${Url.groups}/$groupId/member-group-tilawah"),
        headers: {
          'Authorization': 'Bearer ${AuthController.to.token.value}',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final result = memberGroupTilawahFromJson(response.body);
        group.value = result.data;
      } else {
        Get.snackbar('Error', 'Gagal mengambil data anggota');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan saat mengambil data');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> dropUser(int userId) async {
    try {
      isLoading.value = true;
      final response = await http.post(
        Uri.parse("${Url.baseUrl}${Url.groups}/drop-user"),
        headers: {
          'Authorization': 'Bearer ${AuthController.to.token.value}',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'group_id': groupId, 'user_id': userId}),
      );

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Anggota berhasil dikeluarkan');
        fetchMemberTilawah(); // Refresh list
      } else {
        final error = jsonDecode(response.body);
        Get.snackbar('Error', error['message'] ?? 'Gagal mengeluarkan anggota');
      }

      isLoading.value = false;
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan saat mengeluarkan anggota');
    } finally {
      isLoading.value = false;
    }
  }
}
