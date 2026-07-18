import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/models/nearby_mosque_model.dart';
import 'package:quran_app/widgets/app_toast.dart';

class FindMosqueController extends GetxController {
  final isLoading = false.obs;
  final isLocating = false.obs;
  final isPermissionError = false.obs;
  final errorMessage = ''.obs;

  final mosques = <NearbyMosque>[].obs;
  final currentAddress = 'Mencari lokasi Anda...'.obs;
  final latitude = 0.0.obs;
  final longitude = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    getLocationAndFetch();
  }

  Future<void> getLocationAndFetch() async {
    isLocating.value = true;
    isLoading.value = true;
    isPermissionError.value = false;
    errorMessage.value = '';

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        isLocating.value = false;
        isLoading.value = false;
        isPermissionError.value = true;
        errorMessage.value = 'Layanan lokasi (GPS) tidak aktif. Silakan aktifkan GPS Anda di Pengaturan.';
        AppToast.error(message: 'Layanan lokasi tidak aktif');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          isLocating.value = false;
          isLoading.value = false;
          isPermissionError.value = true;
          errorMessage.value = 'Akses lokasi ditolak. Aplikasi memerlukan izin lokasi untuk mencari masjid terdekat.';
          AppToast.error(message: 'Akses lokasi ditolak');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        isLocating.value = false;
        isLoading.value = false;
        isPermissionError.value = true;
        errorMessage.value = 'Akses lokasi ditolak secara permanen. Silakan aktifkan izin lokasi di Pengaturan aplikasi.';
        AppToast.error(message: 'Akses lokasi ditolak permanen');
        return;
      }

      // Get current location
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      latitude.value = position.latitude;
      longitude.value = position.longitude;

      // Geocoding: Get physical address
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          final street = placemark.street ?? '';
          final subLocality = placemark.subLocality ?? '';
          final locality = placemark.locality ?? '';
          final subAdministrativeArea = placemark.subAdministrativeArea ?? '';
          final administrativeArea = placemark.administrativeArea ?? '';
          final postalCode = placemark.postalCode ?? '';

          List<String> addressParts = [];
          if (street.isNotEmpty && !street.contains('+')) addressParts.add(street);
          if (subLocality.isNotEmpty) addressParts.add(subLocality);
          if (locality.isNotEmpty) addressParts.add(locality);
          if (subAdministrativeArea.isNotEmpty) addressParts.add(subAdministrativeArea);
          if (administrativeArea.isNotEmpty) addressParts.add(administrativeArea);
          if (postalCode.isNotEmpty) addressParts.add(postalCode);

          currentAddress.value = addressParts.isNotEmpty 
              ? addressParts.join(', ') 
              : '${position.latitude}, ${position.longitude}';
        } else {
          currentAddress.value = '${position.latitude}, ${position.longitude}';
        }
      } catch (e) {
        debugPrint('Geocoding error: $e');
        currentAddress.value = 'Subang, Jawa Barat (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})';
      }

      isLocating.value = false;
      await fetchNearbyMosques(position.latitude, position.longitude);

    } catch (e) {
      isLocating.value = false;
      isLoading.value = false;
      isPermissionError.value = false;
      errorMessage.value = 'Gagal memuat lokasi: $e';
      AppToast.error(message: 'Gagal mengambil lokasi');
    }
  }

  Future<void> fetchNearbyMosques(double lat, double lng) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await Request().get(
        Url.nearbyMosques,
        queryParameters: {
          'latitude': lat.toString(),
          'longitude': lng.toString(),
        },
        useToken: true,
      );

      if (response.statusCode == 200) {
        final mosqueResponse = NearbyMosqueResponse.fromJson(response.data);
        mosques.assignAll(mosqueResponse.data);
      } else {
        errorMessage.value = response.data['message'] ?? 'Gagal memuat data masjid terdekat';
        AppToast.error(message: errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan: $e';
      AppToast.error(message: 'Terjadi kesalahan saat memuat data');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}
