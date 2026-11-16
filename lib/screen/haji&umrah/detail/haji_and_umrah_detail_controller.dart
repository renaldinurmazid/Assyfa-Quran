import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/models/haji_umrah_package_model.dart';
import 'package:quran_app/widgets/app_toast.dart';

class HajiAndUmrahDetailController extends GetxController {
  final RxBool isLoading = false.obs;
  final Rxn<HajiUmrahPackageModel> package = Rxn<HajiUmrahPackageModel>();
  
  late final String packageId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null) {
      packageId = args.toString();
      fetchUmrahDetail();
    } else {
      AppToast.error(message: 'Paket tidak ditemukan');
      Get.back();
    }
  }

  Future<void> fetchUmrahDetail() async {
    try {
      isLoading.value = true;
      final response = await Request().get('${Url.umrah}/$packageId');

      if (response.statusCode == 200) {
        final payload = response.data;
        if (payload['status'] == 'success') {
          final dataObj = payload['data'];
          if (dataObj != null && dataObj is Map<String, dynamic>) {
            package.value = HajiUmrahPackageModel.fromJson(dataObj);
          } else {
            AppToast.error(message: 'Format data tidak valid');
          }
        } else {
          AppToast.error(message: payload['message'] ?? 'Gagal memuat detail paket');
        }
      } else {
        AppToast.error(message: 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching umrah detail: $e');
      AppToast.error(message: 'Gagal menghubungkan ke server.');
    } finally {
      isLoading.value = false;
    }
  }
}
