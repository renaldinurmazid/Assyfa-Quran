import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:geolocator/geolocator.dart';

import 'package:quran_app/models/banner_model.dart';
import 'package:quran_app/models/prayer_model.dart';

class HomeScreenController extends GetxController {
  final calendarToday = '-'.obs;
  final dayName = '-'.obs;
  final isLoading = false.obs;
  final isLoadingPrayerTime = false.obs;
  final kabKota = 'Jakarta'.obs;
  final jadwalToday = <String, dynamic>{}.obs;
  final isOfflineMode = false.obs;

  final prayers = <PrayerItem>[].obs;
  final isLoadingPrayers = false.obs;

  final displayPrayers = <Map<String, String>>[].obs;
  Timer? timer;
  Timer? heartbeatTimer;
  final countdownText = "00:00:00".obs;
  final isPrayerArrived = false.obs;
  final showHeartbeat = true.obs;
  DateTime? prayerArrivalTime;

  final weeklyStats = <String, dynamic>{}.obs;
  final isLoadingWeekly = false.obs;

  Timer? bannerTimer;
  Timer? loginBannerTimer;

  final sliderController = PageController();
  final dataBanner = <BannerData>[].obs;
  final isLoadingBanner = false.obs;

  final bannerLoginController = PageController();
  final bannerLoginPage = 0.obs;
  final banner = [
    'assets/images/png/login1.png',
    'assets/images/png/login2.png',
    'assets/images/png/login3.png',
  ];

  @override
  void onInit() {
    super.onInit();
    getPrayerTime();
    _startTimer();
    fetchBanners();
    autoSlideBanner();
    fetchPrayers();
    _checkConnection();
    _listenToConnectivity();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (AuthController.to.isLogin.value) {
        fetchWeeklyStats();
      }

      ever(AuthController.to.isLogin, (bool? loggedIn) {
        if (loggedIn == true) {
          fetchWeeklyStats();
          fetchPrayers();
        } else {
          weeklyStats.clear();
          fetchPrayers();
        }
      });

      // Listen to jadwalToday changes
      ever(jadwalToday, (_) {
        if (jadwalToday.isNotEmpty) {
          _calculatePrayers(this);
        }
      });
      if (jadwalToday.isNotEmpty) {
        _calculatePrayers(this);
      }
    });
  }

  @override
  void onClose() {
    timer?.cancel();
    heartbeatTimer?.cancel();
    bannerTimer?.cancel();
    loginBannerTimer?.cancel();
    super.onClose();
  }

  void autoSlideBanner() {
    bannerTimer?.cancel();
    bannerTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (sliderController.hasClients) {
        int nextPage = (sliderController.page?.round() ?? 0) + 1;
        if (nextPage >= dataBanner.length) {
          sliderController.animateToPage(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeIn,
          );
        } else {
          sliderController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeIn,
          );
        }
      }
    });

    autoSlideLoginBanner();
  }

  void autoSlideLoginBanner() {
    loginBannerTimer?.cancel();
    loginBannerTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (bannerLoginController.hasClients) {
        int nextPage = (bannerLoginController.page?.round() ?? 0) + 1;
        if (nextPage >= banner.length) {
          bannerLoginController.animateToPage(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeIn,
          );
        } else {
          bannerLoginController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeIn,
          );
        }
      }
    });
  }

  void _startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateCountdown();
    });

    heartbeatTimer?.cancel();
    // Heartbeat animation timer
    heartbeatTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (isPrayerArrived.value) {
        showHeartbeat.value = !showHeartbeat.value;
      }
    });
  }

  void _calculatePrayers(HomeScreenController controller) {
    final now = DateTime.now();
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final todayStr =
        "${now.year}-${twoDigits(now.month)}-${twoDigits(now.day)}";
    final tomorrow = now.add(const Duration(days: 1));
    final tomorrowStr =
        "${tomorrow.year}-${twoDigits(tomorrow.month)}-${twoDigits(tomorrow.day)}";

    final todaySchedule = Map<String, dynamic>.from(controller.jadwalToday);
    if (todaySchedule.isEmpty) return;

    final tomorrowSchedule = todaySchedule;

    // Use new API keys
    final orderedNames = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];
    final displayNames = {
      'fajr': 'Subuh',
      'dhuhr': 'Dhuhur',
      'asr': 'Asar',
      'maghrib': 'Maghrib',
      'isha': 'Isya',
    };

    List<Map<String, String>> upcomingPrayers = [];
    int currentMinutes = now.hour * 60 + now.minute;

    for (var name in orderedNames) {
      if (todaySchedule.containsKey(name)) {
        final timeStr = todaySchedule[name] as String;
        final parts = timeStr.split(':');
        final pMinutes = int.parse(parts[0]) * 60 + int.parse(parts[1]);
        if (pMinutes >= currentMinutes) {
          upcomingPrayers.add({
            'name': displayNames[name]!,
            'time': timeStr,
            'date': todayStr,
          });
        }
      }
    }

    if (upcomingPrayers.length < 3) {
      for (var name in orderedNames) {
        if (tomorrowSchedule.containsKey(name)) {
          upcomingPrayers.add({
            'name': displayNames[name]!,
            'time': tomorrowSchedule[name] as String,
            'date': tomorrowStr,
          });
          if (upcomingPrayers.length >= 3) break;
        }
      }
    }

    displayPrayers.assignAll(upcomingPrayers.take(3).toList());
    _updateCountdown();
  }

  void _updateCountdown() {
    if (displayPrayers.isEmpty) {
      return;
    }

    final now = DateTime.now();

    // Check if we're in the 5-minute hold period after prayer arrival
    if (prayerArrivalTime != null) {
      final minutesSinceArrival = now.difference(prayerArrivalTime!).inMinutes;

      if (minutesSinceArrival < 5) {
        // Still in hold period
        if (!isClosed) {
          isPrayerArrived.value = true;
          countdownText.value = 'Telah tiba';
        }
        return;
      } else {
        // 5 minutes passed, move to next prayer
        prayerArrivalTime = null;
        isPrayerArrived.value = false;
        showHeartbeat.value = true;
        _calculatePrayers(this);
        return;
      }
    }

    final nextPrayer = displayPrayers.first;
    final timeStr = nextPrayer['time']!;
    final dateStr = nextPrayer['date']!; // We need to store date to be accurate

    final timeParts = timeStr.split(':');
    final dateParts = dateStr.split('-');

    final nextPrayerTime = DateTime(
      int.parse(dateParts[0]),
      int.parse(dateParts[1]),
      int.parse(dateParts[2]),
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );

    final difference = nextPrayerTime.difference(now);

    // Check if prayer time has arrived (within 1 minute tolerance)
    if (difference.inSeconds <= 0 && difference.inSeconds > -60) {
      // Prayer time just arrived!
      prayerArrivalTime = now;
      if (!isClosed) {
        isPrayerArrived.value = true;
        countdownText.value = 'Telah tiba';
      }
      return;
    }

    // If countdown is way past (more than 1 minute), recalculate
    if (difference.inSeconds <= -60) {
      // Prayer time passed, recalculate
      _calculatePrayers(this);
    } else {
      // Normal countdown
      final hours = difference.inHours.toString().padLeft(2, '0');
      final minutes = (difference.inMinutes % 60).toString().padLeft(2, '0');
      final seconds = (difference.inSeconds % 60).toString().padLeft(2, '0');

      if (!isClosed) {
        isPrayerArrived.value = false;
        countdownText.value = "-$hours:$minutes:$seconds";
      }
    }
  }

  Future<void> getPrayerTime() async {
    isLoadingPrayerTime.value = true;

    // Load cached data immediately so we don't show shimmer if we have data
    await _loadPrayerTimeFromPrefs();

    try {
      // Try to get GPS coordinates
      double? latitude;
      double? longitude;

      final prefs = await SharedPreferences.getInstance();

      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (serviceEnabled) {
          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }
          if (permission == LocationPermission.whileInUse ||
              permission == LocationPermission.always) {
            final position = await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.low,
                timeLimit: Duration(seconds: 5),
              ),
            );
            latitude = position.latitude;
            longitude = position.longitude;

            // Save GPS coordinates to local storage
            await prefs.setDouble('latitude', latitude);
            await prefs.setDouble('longitude', longitude);
          }
        }
      } catch (e) {
        print('Error getting GPS location: $e');
      }

      // If GPS failed, try loading saved coordinates
      if (latitude == null || longitude == null) {
        final savedLat = prefs.getDouble('latitude');
        final savedLng = prefs.getDouble('longitude');
        if (savedLat != null && savedLng != null) {
          latitude = savedLat;
          longitude = savedLng;
        }
      }

      // Build query params
      final queryParams = <String, String>{};
      if (latitude != null && longitude != null) {
        queryParams['latitude'] = latitude.toString();
        queryParams['longitude'] = longitude.toString();
      }

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
        await prefs.setString('prayerTimes', jsonEncode(prayerTimes));
        await prefs.setString('kabKota', location['city'] ?? 'Jakarta');
        await prefs.setString('calendarToday', '${dateData['hijri']}');
        await prefs.setString('dayName', '${dateData['day']}');
        await prefs.setString(
          'calendarMasehi',
          '${dateData['day']}, ${dateData['gregorian']}',
        );

        // Load to observables
        kabKota.value = location['city'] ?? 'Jakarta';
        calendarToday.value = '${dateData['hijri']}';
        dayName.value = '${dateData['day']}';
        jadwalToday.assignAll(prayerTimes);
      }
    } catch (e) {
      print('Error getting prayer time: $e');
    } finally {
      isLoadingPrayerTime.value = false;
    }
  }

  Future<void> _loadPrayerTimeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final kabKotaData = prefs.getString('kabKota');
    final prayerTimesData = prefs.getString('prayerTimes');
    final calendarData = prefs.getString('calendarToday');
    final dayNameData = prefs.getString('dayName');

    if (kabKotaData != null) kabKota.value = kabKotaData;
    if (calendarData != null) calendarToday.value = calendarData;
    if (dayNameData != null) dayName.value = dayNameData;
    if (prayerTimesData != null) {
      final prayerMap = jsonDecode(prayerTimesData) as Map<String, dynamic>;
      jadwalToday.assignAll(prayerMap);
      _calculatePrayers(this);
    }
  }

  Future<void> _checkConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    isOfflineMode.value = connectivityResult.contains(ConnectivityResult.none);
  }

  void _listenToConnectivity() {
    Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      isOfflineMode.value = results.contains(ConnectivityResult.none);
    });
  }

  Future<void> fetchWeeklyStats() async {
    if (!AuthController.to.isLogin.value) return;
    isLoadingWeekly.value = true;
    try {
      final response = await Request().get(Url.readingHistoryWeekly);
      if (response.statusCode == 200) {
        weeklyStats.value = response.data['data'];
      }
    } catch (e) {
      print("Error fetching weekly stats: $e");
    } finally {
      isLoadingWeekly.value = false;
    }
  }

  Future<void> fetchBanners() async {
    isLoadingBanner.value = true;
    try {
      final response = await Request().get(Url.banners);
      if (response.statusCode == 200) {
        final bannerResponse = BannerResponse.fromJson(response.data);
        dataBanner.assignAll(bannerResponse.data);
      }
    } catch (e) {
      print("Error fetching banners: $e");
    } finally {
      isLoadingBanner.value = false;
    }
  }

  Future<void> fetchPrayers() async {
    isLoadingPrayers.value = true;
    try {
      final response = await Request().get(Url.prayers);
      if (response.statusCode == 200) {
        final prayerResponse = PrayerResponse.fromJson(response.data);
        prayers.assignAll(prayerResponse.data ?? []);
      }
    } catch (e) {
      print("Error fetching prayers: $e");
    } finally {
      isLoadingPrayers.value = false;
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
        final index = prayers.indexWhere((p) => p.id == prayerId);
        if (index != -1) {
          final current = prayers[index];
          // Local update to improve responsiveness
          prayers[index] = PrayerItem(
            id: current.id,
            content: current.content,
            isAnonymous: current.isAnonymous,
            userName: current.userName,
            userProfile: current.userProfile,
            publishedAt: current.publishedAt,
            amensCount: data['amens_count'],
            latestAmens: current.latestAmens,
            isAmened: true, // Assuming success means it's now amened
            isMyPrayer: current.isMyPrayer,
          );
        }
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
}
