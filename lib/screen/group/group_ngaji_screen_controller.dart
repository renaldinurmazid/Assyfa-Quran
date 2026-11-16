import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/models/group/group_model.dart';
import 'package:quran_app/models/public_group_model.dart';
import 'package:quran_app/widgets/app_toast.dart';

class GroupNgajiScreenController extends GetxController {
  final pageController = PageController();
  final isGroupSaya = true.obs;
  final isLoading = false.obs;
  final myGroups = <Datum>[].obs;
  final isLoadingPublic = false.obs;
  final publicGroups = <PublicGroupItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    getGroups();
    fetchPublicGroups();
  }

  void getGroups() {
    if (AuthController.to.isLogin.value) {
      fetchMyGroups();
    } else {
      return;
    }
  }

  Future<void> fetchMyGroups() async {
    try {
      isLoading.value = true;
      final response = await Request().get(Url.groups, useToken: true);

      if (response.statusCode == 200) {
        final groupsData = Groups.fromJson(response.data);
        myGroups.assignAll(groupsData.data);
      } else {
        AppToast.error(message: response.data['message']);
      }
    } catch (e) {
      AppToast.error(message: 'Terjadi kesalahan, silahkan coba lagi.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPublicGroups() async {
    try {
      isLoadingPublic.value = true;
      final response = await Request().get(Url.publicGroups);

      if (response.statusCode == 200) {
        final model = PublicGroupModel.fromJson(response.data);
        publicGroups.assignAll(model.data.data);
      } else {
        AppToast.error(message: response.data['message']);
      }
    } catch (e) {
      debugPrint(e.toString());
      AppToast.error(message: 'Terjadi kesalahan saat memuat grup populer.');
    } finally {
      isLoadingPublic.value = false;
    }
  }
}
