import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreenController extends GetxController {
  final calendarToday = '-'.obs;
  final defaultIdCity = '58a2fc6ed39fd083f55d4182bf88826d';
  final isLoading = false.obs;
  final kabKota = 'KOTA JAKARTA'.obs;
  final provinsi = 'DKI JAKARTA'.obs;
  final jadwalToday = <String, dynamic>{}.obs;
  final isOfflineMode = false.obs;

  final displayPrayers = <Map<String, String>>[].obs;
  Timer? timer;
  Timer? heartbeatTimer;
  final countdownText = "00:00:00".obs;
  final isPrayerArrived = false.obs;
  final showHeartbeat = true.obs;
  DateTime? prayerArrivalTime;

  Timer? bannerTimer;
  Timer? loginBannerTimer;

  final sliderController = PageController();
  final dataBanner = [
    'assets/images/png/banner-1.png',
    'assets/images/png/banner-2.png',
  ];

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
    getCalendarToday();
    getPrayerTime();
    _startTimer();
    autoSlideBanner();
    _checkConnection();
    _listenToConnectivity();
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    // Simple formatter helper
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final todayStr =
        "${now.year}-${twoDigits(now.month)}-${twoDigits(now.day)}";
    final tomorrow = now.add(const Duration(days: 1));
    final tomorrowStr =
        "${tomorrow.year}-${twoDigits(tomorrow.month)}-${twoDigits(tomorrow.day)}";

    // Access RxMap properly
    final todaySchedule = Map<String, dynamic>.from(controller.jadwalToday);
    if (todaySchedule.isEmpty) return;

    // For tomorrow, we'll just use today's data as fallback
    final tomorrowSchedule = todaySchedule;

    final orderedNames = ['subuh', 'dzuhur', 'ashar', 'maghrib', 'isya'];

    List<Map<String, String>> upcomingPrayers = [];
    int currentMinutes = now.hour * 60 + now.minute;

    // Check today's remaining prayers
    for (var name in orderedNames) {
      if (todaySchedule.containsKey(name)) {
        final timeStr = todaySchedule[name] as String;
        final parts = timeStr.split(':');
        final pMinutes = int.parse(parts[0]) * 60 + int.parse(parts[1]);
        if (pMinutes >= currentMinutes) {
          upcomingPrayers.add({
            'name': name,
            'time': timeStr,
            'date': todayStr,
          });
        }
      }
    }

    // Add tomorrow's prayers if needed
    if (upcomingPrayers.length < 3) {
      for (var name in orderedNames) {
        if (tomorrowSchedule.containsKey(name)) {
          upcomingPrayers.add({
            'name': name,
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
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final idCity = prefs.getString('idCity') ?? defaultIdCity;

      final now = DateTime.now();
      final response = await http.get(
        Uri.parse(
          'https://api.myquran.com/v3/sholat/jadwal/$idCity/${now.year}-${now.month}',
        ),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('idCity', data['data']['id']);
        await prefs.setString('kabKota', data['data']['kabko']);
        await prefs.setString('provinsi', data['data']['prov']);
        await prefs.setString('jadwal', jsonEncode(data['data']['jadwal']));

        // Load to observables
        await getPrayerTimeFromPrefs();
      }
    } catch (e) {
      print('Error getting prayer time: $e');
      // Load from prefs if API fails
      await getPrayerTimeFromPrefs();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getPrayerTimeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final kabKotaData = prefs.getString('kabKota');
    final provinsiData = prefs.getString('provinsi');
    final jadwalData = prefs.getString('jadwal');

    if (kabKotaData != null) {
      kabKota.value = kabKotaData;
    }
    if (provinsiData != null) {
      provinsi.value = provinsiData;
    }
    if (jadwalData != null) {
      final jadwalMap = jsonDecode(jadwalData) as Map<String, dynamic>;
      final now = DateTime.now();
      String twoDigits(int n) => n.toString().padLeft(2, "0");
      final todayStr =
          "${now.year}-${twoDigits(now.month)}-${twoDigits(now.day)}";

      if (jadwalMap.containsKey(todayStr)) {
        jadwalToday.assignAll(jadwalMap[todayStr] as Map<String, dynamic>);
        _calculatePrayers(this);
      }
    }
  }

  Future<void> getCalendarToday() async {
    isLoading.value = true;
    try {
      final today = DateTime.now();
      final response = await http.get(
        Uri.parse(
          'https://api.myquran.com/v3/cal/hijr/${today.year}-${today.month}-${today.day}?method=islamic-umalqura',
        ),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('calendarToday', data['data']['hijr']['today']);
      }
    } catch (e) {
      print('Error getting calendar: $e');
    } finally {
      await getCalendarTodayFromPrefs();
      isLoading.value = false;
    }
  }

  Future<void> getCalendarTodayFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final calendarToday = prefs.getString('calendarToday');
    if (calendarToday != null) {
      this.calendarToday.value = calendarToday;
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
}
