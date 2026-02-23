import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/controller/home_screen_controller.dart';
import 'package:quran_app/controller/prayer_time_detail_controller.dart';
import 'package:quran_app/theme/app_color.dart';
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
          Get.snackbar('Error', 'Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.back();
        Get.snackbar(
          'Error',
          'Location permissions are permanently denied, we cannot request permissions.',
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
        homeController.jadwalToday.assignAll(prayerTimes);

        // Refresh PrayerTimeDetailController if it exists
        if (Get.isRegistered<PrayerTimeDetailController>()) {
          await Get.find<PrayerTimeDetailController>().loadDataFromPrefs();
        }

        Get.back(); // close loading dialog
      } else {
        Get.back();
        Get.snackbar('Error', 'Gagal memuat jadwal sholat');
      }
    } catch (e) {
      Get.back();
      Get.snackbar('Error', e.toString());
    }
  }
}
