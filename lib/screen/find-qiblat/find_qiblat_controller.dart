import 'dart:async';
import 'dart:math' show pi, sin, cos, atan2;
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class FindQiblatController extends GetxController {
  RxDouble heading = 0.0.obs;
  RxDouble qiblaDirection = 0.0.obs;
  RxBool hasPermission = false.obs;
  RxBool isLoading = true.obs;
  RxBool needsCalibration = false.obs;

  StreamSubscription<CompassEvent>? _compassSubscription;

  @override
  void onInit() {
    super.onInit();
    _initQibla();
  }

  @override
  void onClose() {
    _compassSubscription?.cancel();
    super.onClose();
  }

  Future<void> _initQibla() async {
    isLoading.value = true;
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar('Error', 'Location services are disabled.');
      isLoading.value = false;
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar('Error', 'Location permissions are denied');
        isLoading.value = false;
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar('Error',
          'Location permissions are permanently denied, we cannot request permissions.');
      isLoading.value = false;
      return;
    }

    hasPermission.value = true;
    
    // Get current position
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Calculate Qibla Direction
    qiblaDirection.value = _calculateQibla(position.latitude, position.longitude);

    // Start compass
    _compassSubscription = FlutterCompass.events?.listen((event) {
      heading.value = event.heading ?? 0;
      
      // Check calibration
      // if accuracy is not high, suggest calibration
      // Note: event.accuracy is only on Android (0: Unreliable, 1: Low, 2: Medium, 3: High)
      // Some devices might return null.
      if (event.accuracy != null && event.accuracy == 0) {
        needsCalibration.value = true;
      } else {
        needsCalibration.value = false;
      }
    });

    isLoading.value = false;
  }

  double _calculateQibla(double lat, double lon) {
    // Mecca Coordinates
    const double meccaLat = 21.422487;
    const double meccaLon = 39.826206;

    // Convert to radians
    double lat1 = lat * pi / 180.0;
    double lon1 = lon * pi / 180.0;
    double lat2 = meccaLat * pi / 180.0;
    double lon2 = meccaLon * pi / 180.0;

    double y = sin(lon2 - lon1) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(lon2 - lon1);
    
    double qibla = atan2(y, x);
    
    // Convert back to degrees
    qibla = (qibla * 180.0 / pi);
    
    // Normalize to 0-360
    return (qibla + 360.0) % 360.0;
  }
}