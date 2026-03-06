import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/models/prayer_model.dart';
import 'package:quran_app/theme/app_color.dart';

class ListPrayerController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;

  final allPrayers = <PrayerItem>[].obs;
  final myPrayers = <PrayerItem>[].obs;

  final isLoadingAll = false.obs;
  final isLoadingMy = false.obs;
  final isLoadingMoreAll = false.obs;
  final isLoadingMoreMy = false.obs;

  final allCurrentPage = 1.obs;
  final myCurrentPage = 1.obs;
  final allLastPage = 1.obs;
  final myLastPage = 1.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    fetchAllPrayers();
    fetchMyPrayers();

    // Refresh when login status changes
    ever(AuthController.to.isLogin, (_) {
      fetchAllPrayers();
      fetchMyPrayers();
    });
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  Future<void> fetchAllPrayers({bool isRefresh = true}) async {
    if (isRefresh) {
      isLoadingAll.value = true;
      allCurrentPage.value = 1;
    } else {
      if (allCurrentPage.value >= allLastPage.value) return;
      isLoadingMoreAll.value = true;
      allCurrentPage.value++;
    }

    try {
      final response = await Request().get(
        '${Url.prayers}?page=${allCurrentPage.value}',
      );
      if (response.statusCode == 200) {
        final prayerResponse = PrayerResponse.fromJson(response.data);
        if (isRefresh) {
          allPrayers.assignAll(prayerResponse.data?.data ?? []);
        } else {
          allPrayers.addAll(prayerResponse.data?.data ?? []);
        }
        allLastPage.value = prayerResponse.data?.lastPage ?? 1;
      }
    } catch (e) {
      print("Error fetching all prayers: $e");
    } finally {
      isLoadingAll.value = false;
      isLoadingMoreAll.value = false;
    }
  }

  Future<void> fetchMyPrayers({bool isRefresh = true}) async {
    if (!AuthController.to.isLogin.value) {
      myPrayers.clear();
      return;
    }

    if (isRefresh) {
      isLoadingMy.value = true;
      myCurrentPage.value = 1;
    } else {
      if (myCurrentPage.value >= myLastPage.value) return;
      isLoadingMoreMy.value = true;
      myCurrentPage.value++;
    }

    try {
      final response = await Request().get(
        '${Url.myPrayers}?page=${myCurrentPage.value}',
      );
      if (response.statusCode == 200) {
        final prayerResponse = PrayerResponse.fromJson(response.data);
        if (isRefresh) {
          myPrayers.assignAll(prayerResponse.data?.data ?? []);
        } else {
          myPrayers.addAll(prayerResponse.data?.data ?? []);
        }
        myLastPage.value = prayerResponse.data?.lastPage ?? 1;
      }
    } catch (e) {
      print("Error fetching my prayers: $e");
    } finally {
      isLoadingMy.value = false;
      isLoadingMoreMy.value = false;
    }
  }

  Future<void> toggleAmen(int prayerId) async {
    try {
      final response = await Request().post(
        Url.amenPrayer(prayerId),
        data: {},
        useToken: true,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        _updatePrayerInLists(prayerId, data['amens_count'], true);

        Get.snackbar(
          'Aamiin',
          response.data['message'] ?? 'Doa telah diaminkan',
          backgroundColor: AppColor.primaryColor,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(20),
        );
      } else if (response.data['status'] == 'error') {
        Get.snackbar(
          'Informasi',
          response.data['message'] ?? 'Anda sudah mengaminkan doa ini',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(20),
        );
      }
    } catch (e) {
      print("Error toggling amen: $e");
    }
  }

  void _updatePrayerInLists(int prayerId, int amensCount, bool isAmened) {
    void updateList(RxList<PrayerItem> list) {
      final index = list.indexWhere((p) => p.id == prayerId);
      if (index != -1) {
        final current = list[index];
        list[index] = PrayerItem(
          id: current.id,
          content: current.content,
          isAnonymous: current.isAnonymous,
          userName: current.userName,
          userProfile: current.userProfile,
          publishedAt: current.publishedAt,
          amensCount: amensCount,
          latestAmens: current.latestAmens,
          isAmened: isAmened,
          isMyPrayer: current.isMyPrayer,
        );
      }
    }

    updateList(allPrayers);
    updateList(myPrayers);
  }
}
