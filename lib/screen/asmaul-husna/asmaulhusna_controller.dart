import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/theme/font.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AsmaulhusnaController extends GetxController {
  RxList<dynamic> asmaulHusnaList = <dynamic>[].obs;
  RxBool isLoading = false.obs;
  RxInt currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    checkData();
  }

  Future<void> checkData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('asmaul_husna_data');
    if (data != null) {
      asmaulHusnaList.value = jsonDecode(data);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDownloadModal();
      });
    }
  }

  void showDownloadModal() {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Download Data',
          style: pSemiBold16.copyWith(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Data Asmaul Husna belum tersedia. Apakah Anda ingin mengunduhnya sekarang?',
          style: pRegular14.copyWith(fontSize: 12),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              Get.back(); // Kembali ke halaman sebelumnya jika batal
            },
            child: Text('Batal', style: pRegular14),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              downloadData();
            },
            style: ButtonStyle(elevation: WidgetStateProperty.all(1)),
            child: Text('Download', style: pMedium14),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> downloadData() async {
    isLoading.value = true;
    try {
      final response = await Request().get(Url.asmaulHusna, useToken: false);
      if (response.statusCode == 200) {
        final resData = response.data['data'];
        if (resData != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('asmaul_husna_data', jsonEncode(resData));
          asmaulHusnaList.value = resData;
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengunduh data Asmaul Husna');
    } finally {
      isLoading.value = false;
    }
  }

  final pageController = PageController();

  void next() {
    if (currentIndex.value < asmaulHusnaList.length - 1) {
      if (pageController.hasClients) {
        pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut);
      } else {
        currentIndex.value++;
      }
    }
  }

  void previous() {
    if (currentIndex.value > 0) {
      if (pageController.hasClients) {
        pageController.previousPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut);
      } else {
        currentIndex.value--;
      }
    }
  }
  
  void onPageChanged(int index) {
    currentIndex.value = index;
  }

  void resetToStart() {
    if (pageController.hasClients) {
      pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      currentIndex.value = 0;
    }
  }
}
