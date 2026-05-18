import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/widgets/app_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/controller/popup_controller.dart';
import 'package:quran_app/widgets/popup_widget.dart';
import 'package:quran_app/services/connectivity_service.dart';
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
  final readingHistoryTotal = 0.obs;
  String get formattedReadingHistoryTotal =>
      NumberFormat.decimalPattern('id').format(readingHistoryTotal.value);

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

  final isEmailLogin = false.obs;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isPasswordVisible = false.obs;

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
    fetchReadingHistoryTotal();

    // Listen to ConnectivityService for sync-aware refresh
    if (Get.isRegistered<ConnectivityService>()) {
      ever(ConnectivityService.to.isOnline, (bool online) {
        isOfflineMode.value = !online;
        if (online && AuthController.to.isLogin.value) {
          // Trigger sync & refresh when back online
          ConnectivityService.to.syncPendingHistory();
        }
      });

      ever(ConnectivityService.to.isSyncing, (bool syncing) {
        if (!syncing && AuthController.to.isLogin.value) {
          // Sync just completed, refresh stats
          fetchWeeklyStats();
          fetchReadingHistoryTotal();
        }
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (AuthController.to.isLogin.value) {
        fetchWeeklyStats();
      }

      ever(AuthController.to.isLogin, (bool? loggedIn) {
        if (loggedIn == true) {
          fetchWeeklyStats();
          fetchPrayers();
          // Re-fetch popups after login (server filters show_once)
          _fetchAndShowPopups();
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

      // Fetch and show popups after a short delay for smooth UX
      _fetchAndShowPopups();
    });
  }

  Future<void> _fetchAndShowPopups() async {
    // Delay to let home screen settle
    await Future.delayed(const Duration(milliseconds: 1500));
    final popupController = Get.put(PopupController());
    await popupController.fetchPopups();
    if (popupController.popups.isNotEmpty) {
      PopupWidget.showPopups();
    }
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
      } else {
        AppToast.error(
          message: response.data['message'] ?? 'Gagal mengambil waktu sholat',
        );
      }
    } catch (e) {
      debugPrint('Error fetching prayer times: $e');
      AppToast.error(message: 'Gagal mengambil waktu sholat');
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
      Map<String, dynamic> stats = {};
      final response = await Request().get(Url.readingHistoryWeekly);
      if (response.statusCode == 200) {
        stats = Map<String, dynamic>.from(response.data['data']);
      } else {
        // If failed, start with empty base
        stats = {'total_pages': 0, 'summary': _generateEmptyWeeklySummary()};
      }

      // Always merge with local unsynced data
      await _mergeLocalStats(stats);
      weeklyStats.value = stats;
    } catch (e) {
      debugPrint("Error fetching weekly stats: $e");
      // Fallback to local only
      final stats = {
        'total_pages': 0,
        'summary': _generateEmptyWeeklySummary(),
      };
      await _mergeLocalStats(stats);
      weeklyStats.value = stats;
    } finally {
      isLoadingWeekly.value = false;
    }
  }

  List<Map<String, dynamic>> _generateEmptyWeeklySummary() {
    final now = DateTime.now();
    final List<String> days = ['A', 'S', 'S', 'R', 'K', 'J', 'S'];
    final List<Map<String, dynamic>> summary = [];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      // In Indonesia, Monday is usually index 1, Sunday index 7
      // DateTime.weekday: 1=Mon, 7=Sun
      summary.add({
        'day': days[date.weekday % 7],
        'date': date.toIso8601String().split('T')[0],
        'total_pages': 0,
      });
    }

    // Sort summary to always be Sunday to Saturday order
    summary.sort((a, b) {
      final dateA = DateTime.parse(a['date']);
      final dateB = DateTime.parse(b['date']);
      return (dateA.weekday % 7).compareTo(dateB.weekday % 7);
    });

    return summary;
  }

  Future<void> _mergeLocalStats(Map<String, dynamic> stats) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? historyJson = prefs.getString('local_history');
      if (historyJson == null) return;

      final List<dynamic> localHistory = jsonDecode(historyJson);
      final summary = stats['summary'] as List;

      int localTotalAdded = 0;

      for (var entry in localHistory) {
        // Only count unsynced entries within the range of stats summary
        if (entry['is_synced'] == false || entry['is_synced'] == null) {
          final readDate = entry['read_date'];
          final pages = (entry['end_page'] - entry['start_page']).abs() + 1;

          for (var dayItem in summary) {
            if (dayItem['date'] == readDate) {
              dayItem['total_pages'] = (dayItem['total_pages'] ?? 0) + pages;
              localTotalAdded += pages as int;
              break;
            }
          }
        }
      }

      stats['total_pages'] = (stats['total_pages'] ?? 0) + localTotalAdded;
    } catch (e) {
      debugPrint("Error merging local stats: $e");
    }
  }

  Future<void> fetchBanners() async {
    isLoadingBanner.value = true;
    try {
      final response = await Request().get(Url.banners);
      if (response.statusCode == 200) {
        final bannerResponse = BannerResponse.fromJson(response.data);
        dataBanner.assignAll(bannerResponse.data);
      } else {
        AppToast.error(
          message: response.data['message'] ?? 'Gagal memuat banner',
        );
      }
    } catch (e) {
      AppToast.error(message: 'Gagal memuat banner');
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
        prayers.assignAll(prayerResponse.data?.data ?? []);
      } else {
        AppToast.error(message: response.data['message'] ?? 'Gagal memuat doa');
      }
    } catch (e) {
      AppToast.error(message: 'Gagal memuat doa');
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
        AppToast.success(
          message: response.data['message'] ?? 'Doa telah diaminkan',
        );
      } else if (response.data['status'] == 'error') {
        AppToast.info(
          message: response.data['message'] ?? 'Anda sudah mengaminkan doa ini',
        );
      }
    } catch (e) {
      AppToast.error(message: 'Terjadi kesalahan saat mengaminkan doa');
    }
  }

  Future<void> fetchReadingHistoryTotal() async {
    try {
      int total = 0;
      final response = await Request().get(Url.readingHistoryTotal);
      if (response.statusCode == 200) {
        final rawTotal =
            response.data['data']['total_pages']?.toString() ?? '0';
        // Hapus titik (separator ribuan) sebelum parsing
        final sanitizedTotal = rawTotal.replaceAll('.', '');
        total = int.tryParse(sanitizedTotal) ?? 0;
      }

      // Add local unsynced total
      final prefs = await SharedPreferences.getInstance();
      final String? historyJson = prefs.getString('local_history');
      if (historyJson != null) {
        final List<dynamic> localHistory = jsonDecode(historyJson);
        for (var entry in localHistory) {
          if (entry['is_synced'] == false || entry['is_synced'] == null) {
            final pages = (entry['end_page'] - entry['start_page']).abs() + 1;
            total += pages as int;
          }
        }
      }

      readingHistoryTotal.value = total;
    } catch (e) {
      if (readingHistoryTotal.value == 0) {
        final prefs = await SharedPreferences.getInstance();
        final historyJson = prefs.getString('local_history');
        if (historyJson != null) {
          final List<dynamic> localHistory = jsonDecode(historyJson);
          int localOnly = 0;
          for (var entry in localHistory) {
            final pages = (entry['end_page'] - entry['start_page']).abs() + 1;
            localOnly += pages as int;
          }
          readingHistoryTotal.value = localOnly;
        }
      }
    }
  }
}
