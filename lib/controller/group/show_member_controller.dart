import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:quran_app/api/url.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/models/group/member_group_tilawah.dart';

class ShowMemberController extends GetxController {
  final isLoading = false.obs;
  final group = Rxn<Data>();
  int? groupId;

  @override
  void onInit() {
    super.onInit();
    groupId = Get.arguments;
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
}
