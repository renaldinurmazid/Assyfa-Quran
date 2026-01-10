import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:quran_app/controller/home_screen_controller.dart';
import 'package:quran_app/controller/prayer_time_detail_controller.dart';
import 'package:quran_app/models/indonesia_city_model.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class PickLocationController extends GetxController {
  final searchController = TextEditingController();
  final listCity = <Datum>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    fetchCity();
    super.onInit();
  }

  void onSearch(String query) {
    if (query.isEmpty) {
      fetchCity();
    } else {
      listCity.value = listCity
          .where(
            (city) => city.lokasi.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
  }

  void saveIdCity(String id) async {
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

      await _saveIdProcess(id);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      Get.back();
    }
  }

  Future<void> _saveIdProcess(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('idCity', id);

    await Get.find<HomeScreenController>().getPrayerTime();
    await Get.find<HomeScreenController>().getCalendarToday();
    await Get.find<PrayerTimeDetailController>().loadDataFromPrefs();
  }

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
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        String? city = placemarks[0].subAdministrativeArea;
        if (city == null || city.isEmpty) {
          city = placemarks[0].locality;
        }

        if (city != null) {
          final response = await http.get(
            Uri.parse('https://api.myquran.com/v3/sholat/kabkota/cari/$city'),
          );

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            if (data['status'] == true &&
                data['data'] != null &&
                data['data'] is List &&
                (data['data'] as List).isNotEmpty) {
              String id = data['data'][0]['id'];
              await _saveIdProcess(id);
              Get.back(); // close the current location loading dialog
              Get.back(); // close pick location screen
            } else {
              Get.back();
              Get.snackbar('Error', 'City not found in API: $city');
            }
          } else {
            Get.back();
            Get.snackbar('Error', 'Failed to search city');
          }
        } else {
          Get.back();
          Get.snackbar('Error', 'Could not determine city name');
        }
      } else {
        Get.back();
        Get.snackbar('Error', 'No location data found');
      }
    } catch (e) {
      Get.back();
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> fetchCity() async {
    try {
      isLoading.value = true;
      final response = await http.get(
        Uri.parse('https://api.myquran.com/v3/sholat/kabkota/semua'),
      );
      if (response.statusCode == 200) {
        final data = IndonesianCityModel.fromJson(jsonDecode(response.body));
        listCity.value = data.data;
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
