import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quran_app/services/notification_service.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/widgets/app_toast.dart';
import 'package:geolocator/geolocator.dart';

class PrayerTimeDetailController extends GetxController {
  final player = AudioPlayer();

  @override
  void onClose() {
    _timer?.cancel();
    _heartbeatTimer?.cancel();
    player.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    NotificationService.init();
    loadDataFromPrefs();
    loadNotificationSettings();
    _startTimer();
    _checkExactAlarmPermission();
  }

  Future<void> _checkExactAlarmPermission() async {
    isExactAlarmGranted.value =
        await NotificationService.canScheduleExactAlarms();
    print('PrayerNotif: exactAlarmGranted=${isExactAlarmGranted.value}');
  }

  /// Panggil dari UI (tombol/banner) untuk meminta user mengizinkan exact alarm
  Future<void> checkAndRequestExactAlarm() async {
    final granted = await NotificationService.canScheduleExactAlarms();
    if (!granted) {
      // Buka halaman pengaturan alarm di Settings
      await NotificationService.requestExactAlarmPermission();
      // Cek ulang setelah user kembali
      await Future.delayed(const Duration(seconds: 1));
      isExactAlarmGranted.value =
          await NotificationService.canScheduleExactAlarms();
      if (isExactAlarmGranted.value) {
        await _schedulePrayerNotifications();
      }
    } else {
      isExactAlarmGranted.value = true;
    }
  }

  final calendarToday = '-'.obs;
  final calendarMasehi = '-'.obs;
  final kabKota = 'Jakarta'.obs;
  final jadwalToday = <String, dynamic>{}.obs;
  final notificationSettings =
      <String, String>{}.obs; // stores 'silent', 'beep', 'adzan'
  final isLoading = false.obs;
  final nextPrayerName = 'Isya'.obs;
  final nextPrayerTime = '00:00'.obs;
  final countdown = '-00:00:00'.obs;
  final isPrayerArrived = false.obs;
  final showHeartbeat = true.obs;
  final isExactAlarmGranted =
      true.obs; // track apakah exact alarm permission sudah di-grant
  Timer? _timer;
  Timer? _heartbeatTimer;
  DateTime? _prayerArrivalTime;

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateCountdown();
    });

    // Heartbeat animation timer (blink every 500ms)
    _heartbeatTimer = Timer.periodic(const Duration(milliseconds: 500), (
      timer,
    ) {
      if (isPrayerArrived.value) {
        showHeartbeat.value = !showHeartbeat.value;
      }
    });
  }

  Future<void> loadDataFromPrefs() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load calendar
      final calendarData = prefs.getString('calendarToday');
      if (calendarData != null) {
        calendarToday.value = calendarData;
      }

      // Load masehi calendar
      final masehiData = prefs.getString('calendarMasehi');
      if (masehiData != null) {
        calendarMasehi.value = masehiData;
      }

      // Load location
      final kabKotaData = prefs.getString('kabKota');
      if (kabKotaData != null) {
        kabKota.value = kabKotaData;
      }

      // Load prayer schedule (new format: flat map)
      final prayerTimesData = prefs.getString('prayerTimes');
      if (prayerTimesData != null) {
        final prayerMap = jsonDecode(prayerTimesData) as Map<String, dynamic>;
        jadwalToday.assignAll(prayerMap);
        _calculateNextPrayer();
        _schedulePrayerNotifications();
      }
    } catch (e) {
      AppToast.error(message: 'Gagal memuat data jadwal sholat');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshPrayerTimes() async {
    isLoading.value = true;
    try {
      // Try to get GPS coordinates
      double? latitude;
      double? longitude;

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
          }
        }
      } catch (e) {
        AppToast.error(message: 'Gagal mendapatkan koordinat GPS');
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
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('prayerTimes', jsonEncode(prayerTimes));
        await prefs.setString('kabKota', location['city'] ?? 'Jakarta');
        await prefs.setString('calendarToday', '${dateData['hijri']}');
        await prefs.setString(
          'calendarMasehi',
          '${dateData['day']}, ${dateData['gregorian']}',
        );

        // Update observables
        kabKota.value = location['city'] ?? 'Jakarta';
        calendarToday.value = '${dateData['hijri']}';
        calendarMasehi.value = '${dateData['day']}, ${dateData['gregorian']}';
        jadwalToday.assignAll(prayerTimes);
        _calculateNextPrayer();
        _schedulePrayerNotifications();
      } else {
        AppToast.error(
          message:
              response.data['message'] ?? 'Gagal memperbarui jadwal sholat',
        );
      }
    } catch (e) {
      AppToast.error(
        message: 'Terjadi kesalahan koneksi saat memperbarui jadwal',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = [
      'Imsak',
      'Subuh',
      'Terbit',
      'Dhuhur',
      'Asar',
      'Maghrib',
      'Isya',
    ];
    for (var key in keys) {
      notificationSettings[key] = prefs.getString('notif_$key') ?? 'adzan';
      // Default Imsak & Terbit to silent if not set
      if (isImsakOrTerbit(key) && notificationSettings[key] == 'adzan') {
        notificationSettings[key] = 'silent';
      }
    }
  }

  Future<void> saveNotificationSetting(String prayerName, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notif_$prayerName', value);
    notificationSettings[prayerName] = value;
    _schedulePrayerNotifications();
  }

  Future<void> _schedulePrayerNotifications() async {
    final now = DateTime.now();
    // Mapping from new API keys to notification setting keys
    final keyMap = {
      'fajr': 'Subuh',
      'dhuhr': 'Dhuhur',
      'asr': 'Asar',
      'maghrib': 'Maghrib',
      'isha': 'Isya',
    };

    if (jadwalToday.isEmpty) {
      print('PrayerNotif: jadwalToday is empty, skipping scheduling');
      return;
    }

    // Update status exact alarm permission
    isExactAlarmGranted.value =
        await NotificationService.canScheduleExactAlarms();

    // Cancel all existing prayer notifications before rescheduling
    await NotificationService.cancelAllPrayerNotifications();

    int idCounter = 1;
    for (var entry in keyMap.entries) {
      final jadwalKey = entry.key;
      final notifKey = entry.value;

      final timeStr = jadwalToday[jadwalKey] as String?;
      if (timeStr == null) {
        print('PrayerNotif: No time found for $jadwalKey, skipping');
        idCounter++;
        continue;
      }

      final parts = timeStr.split(':');
      if (parts.length < 2) {
        print('PrayerNotif: Invalid time format "$timeStr" for $jadwalKey');
        idCounter++;
        continue;
      }

      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      if (hour == null || minute == null) {
        print('PrayerNotif: Could not parse time "$timeStr" for $jadwalKey');
        idCounter++;
        continue;
      }

      DateTime scheduledTime = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      final setting = notificationSettings[notifKey] ?? 'adzan';
      String soundName = 'silent';
      if (setting == 'beep') {
        soundName = 'beep';
      } else if (setting == 'adzan') {
        if (notifKey == 'Subuh') {
          soundName = 'adzan_subuh';
        } else {
          soundName = 'adzan_general';
        }
      }

      if (soundName != 'silent') {
        try {
          await NotificationService.schedulePrayerNotification(
            id: idCounter,
            title: 'Waktu $notifKey Telah Tiba',
            body: 'Mari tunaikan sholat $notifKey',
            scheduledTime: scheduledTime,
            soundName: soundName,
          );
          print(
            'PrayerNotif: Scheduled $notifKey at $scheduledTime (id=$idCounter, sound=$soundName)',
          );
        } catch (e) {
          // Log error tapi LANJUTKAN ke waktu sholat berikutnya
          // Jangan tampilkan toast di sini (terlalu banyak toast jika semua gagal)
          print('PrayerNotif: Failed to schedule $notifKey: $e');
        }
      } else {
        print('PrayerNotif: $notifKey set to silent, skipping');
        await NotificationService.cancel(idCounter);
      }
      idCounter++;
    }
    print(
      'PrayerNotif: Scheduling complete (exactAlarm=${isExactAlarmGranted.value})',
    );
  }

  void _updateCountdown() {
    if (nextPrayerTime.value == '00:00' || jadwalToday.isEmpty) {
      return;
    }

    final now = DateTime.now();

    // Check if we're in the 5-minute hold period after prayer arrival
    if (_prayerArrivalTime != null) {
      final minutesSinceArrival = now.difference(_prayerArrivalTime!).inMinutes;

      if (minutesSinceArrival < 5) {
        isPrayerArrived.value = true;
        countdown.value = 'Telah tiba';
        return;
      } else {
        _prayerArrivalTime = null;
        isPrayerArrived.value = false;
        showHeartbeat.value = true;
        _calculateNextPrayer();
        return;
      }
    }

    final parts = nextPrayerTime.value.split(':');
    final prayerHour = int.parse(parts[0]);
    final prayerMinute = int.parse(parts[1]);

    final currentMinutes = now.hour * 60 + now.minute;
    final prayerMinutes = prayerHour * 60 + prayerMinute;

    DateTime prayerTime;
    if (prayerMinutes > currentMinutes) {
      prayerTime = DateTime(
        now.year,
        now.month,
        now.day,
        prayerHour,
        prayerMinute,
      );
    } else {
      final tomorrow = now.add(const Duration(days: 1));
      prayerTime = DateTime(
        tomorrow.year,
        tomorrow.month,
        tomorrow.day,
        prayerHour,
        prayerMinute,
      );
    }

    final difference = prayerTime.difference(now);

    if (difference.inSeconds <= 0 && difference.inSeconds > -60) {
      _prayerArrivalTime = now;
      isPrayerArrived.value = true;
      countdown.value = 'Telah tiba';
      _playNotification(nextPrayerName.value);
      return;
    }

    if (difference.inSeconds <= -60) {
      _calculateNextPrayer();
      return;
    }

    isPrayerArrived.value = false;
    final hours = difference.inHours.toString().padLeft(2, '0');
    final minutes = (difference.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (difference.inSeconds % 60).toString().padLeft(2, '0');
    countdown.value = '-$hours:$minutes:$seconds';
  }

  Future<void> _playNotification(String prayerName) async {
    final setting =
        notificationSettings[prayerName] ??
        (isImsakOrTerbit(prayerName) ? 'silent' : 'adzan');

    if (setting == 'silent') return;

    try {
      if (setting == 'beep') {
        await player.play(AssetSource('audio/beep.wav'));
      } else if (setting == 'adzan') {
        if (prayerName.toLowerCase() == 'subuh') {
          await player.play(AssetSource('audio/adzan_subuh.mp3'));
        } else {
          await player.play(AssetSource('audio/adzan_general.mp3'));
        }
      }
    } catch (e) {
      AppToast.error(message: 'Gagal memutar audio');
    }
  }

  void _calculateNextPrayer() {
    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;

    // Use new API keys
    final prayerNames = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];
    final displayNames = {
      'fajr': 'Subuh',
      'dhuhr': 'Dhuhur',
      'asr': 'Asar',
      'maghrib': 'Maghrib',
      'isha': 'Isya',
    };

    // Check today's remaining prayers
    for (var prayerName in prayerNames) {
      final timeStr = jadwalToday[prayerName] as String?;
      if (timeStr != null) {
        final parts = timeStr.split(':');
        final prayerMinutes = int.parse(parts[0]) * 60 + int.parse(parts[1]);

        if (prayerMinutes > currentMinutes) {
          nextPrayerName.value = displayNames[prayerName]!;
          nextPrayerTime.value = timeStr;

          final prayerTime = DateTime(
            now.year,
            now.month,
            now.day,
            int.parse(parts[0]),
            int.parse(parts[1]),
          );
          final difference = prayerTime.difference(now);
          final hours = difference.inHours.toString().padLeft(2, '0');
          final minutes = (difference.inMinutes % 60).toString().padLeft(
            2,
            '0',
          );
          final seconds = (difference.inSeconds % 60).toString().padLeft(
            2,
            '0',
          );
          countdown.value = '-$hours:$minutes:$seconds';
          return;
        }
      }
    }

    // If all prayers today have passed, show tomorrow's Subuh
    final subuhTimeStr = jadwalToday['fajr'] as String?;
    if (subuhTimeStr != null) {
      nextPrayerName.value = 'Subuh';
      nextPrayerTime.value = subuhTimeStr;

      final parts = subuhTimeStr.split(':');
      final tomorrow = now.add(const Duration(days: 1));
      final subuhTime = DateTime(
        tomorrow.year,
        tomorrow.month,
        tomorrow.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
      final difference = subuhTime.difference(now);
      final hours = difference.inHours.toString().padLeft(2, '0');
      final minutes = (difference.inMinutes % 60).toString().padLeft(2, '0');
      final seconds = (difference.inSeconds % 60).toString().padLeft(2, '0');
      countdown.value = '-$hours:$minutes:$seconds';
    }
  }

  bool isImsakOrTerbit(String prayerName) {
    return prayerName.toLowerCase() == 'imsak' ||
        prayerName.toLowerCase() == 'terbit';
  }
}
