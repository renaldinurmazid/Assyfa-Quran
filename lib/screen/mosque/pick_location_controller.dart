import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/screen/home/home_screen_controller.dart';
import 'package:quran_app/screen/prayer_time/prayer_time_detail_controller.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/widgets/app_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

class PickLocationController extends GetxController {
  final isLoading = false.obs;

  Future<void> useCurrentLocation() async {
    try {
      showDialog(
        context: Get.context!,
        barrierDismissible: false,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(color: AppColor.primaryColor),
          );
        },
      );

      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.back();
        await Geolocator.openLocationSettings();
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.back();
          AppToast.error(message: 'Akses lokasi ditolak');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.back();
        AppToast.error(
          message:
              'Akses lokasi ditolak permanen, silakan aktifkan di pengaturan.',
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition();

      // Call the prayer-times API with coordinates
      final queryParams = <String, String>{
        'latitude': position.latitude.toString(),
        'longitude': position.longitude.toString(),
      };

      final response = await Request().get(
        Url.prayerTimes,
        queryParameters: queryParams,
        useToken: false,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final prayerTimes = data['prayer_times'] as Map<String, dynamic>;
        final location = data['location'] as Map<String, dynamic>;
        final dateData = data['date'] as Map<String, dynamic>;

        // Save to prefs
        final prefs = await SharedPreferences.getInstance();
        await prefs.setDouble('latitude', position.latitude);
        await prefs.setDouble('longitude', position.longitude);
        await prefs.setString('prayerTimes', jsonEncode(prayerTimes));
        await prefs.setString('kabKota', location['city'] ?? 'Jakarta');
        await prefs.setString('calendarToday', '${dateData['hijri']}');
        await prefs.setString(
          'calendarMasehi',
          '${dateData['day']}, ${dateData['gregorian']}',
        );

        // Refresh HomeScreenController
        final homeController = Get.find<HomeScreenController>();
        homeController.kabKota.value = location['city'] ?? 'Jakarta';
        homeController.calendarToday.value = '${dateData['hijri']}';
        homeController.dayName.value = '${dateData['day']}';
        homeController.jadwalToday.assignAll(prayerTimes);

        // Force recalculate prayer times on home screen
        await homeController.getPrayerTime();

        // Refresh PrayerTimeDetailController if it exists
        if (Get.isRegistered<PrayerTimeDetailController>()) {
          final prayerDetailController = Get.find<PrayerTimeDetailController>();
          prayerDetailController.kabKota.value = location['city'] ?? 'Jakarta';
          prayerDetailController.calendarToday.value = '${dateData['hijri']}';
          prayerDetailController.calendarMasehi.value =
              '${dateData['day']}, ${dateData['gregorian']}';
          prayerDetailController.jadwalToday.assignAll(prayerTimes);
          await prayerDetailController.loadDataFromPrefs();
        }

        Get.back(); // close loading dialog
        AppToast.success(
          message: 'Lokasi dan jadwal sholat berhasil diperbarui',
        );
      } else {
        Get.back();
        AppToast.error(
          message: response.data['message'] ?? 'Gagal memuat jadwal sholat',
        );
      }
    } catch (e) {
      Get.back();
      AppToast.error(message: 'Terjadi kesalahan: $e');
    }
  }
}
