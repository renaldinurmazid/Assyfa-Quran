import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:share_plus/share_plus.dart';

class ProfileScreenController extends GetxController {
  final isLoadingShare = false.obs;

  Future<void> shareApp() async {
    if (isLoadingShare.value) return;

    isLoadingShare.value = true;
    try {
      final response = await Request().get(Url.myReferral);

      if (response.statusCode == 200) {
        final String? referralLink = response.data['data']['referral_link'];
        if (referralLink != null) {
          await Share.share(
            'Yuk download aplikasi Quranuna dan mulai tilawah bersama! Gunakan link berikut untuk mendaftar: $referralLink',
            subject: 'Berbagi Kebaikan dengan Quranuna',
          );
        } else {
          Get.snackbar(
            'Gagal',
            'Link referral tidak ditemukan',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          'Gagal',
          'Gagal mengambil link referral',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Error sharing: $e");
      Get.snackbar(
        'Gagal',
        'Terjadi kesalahan saat mencoba berbagi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingShare.value = false;
    }
  }
}
