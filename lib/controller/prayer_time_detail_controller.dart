import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quran_app/services/notification_service.dart';

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
  }

  final calendarToday = '-'.obs;
  final calendarMasehi = '-'.obs;
  final kabKota = 'KOTA JAKARTA'.obs;
  final provinsi = 'DKI JAKARTA'.obs;
  final jadwalToday = <String, dynamic>{}.obs;
  final notificationSettings =
      <String, String>{}.obs; // stores 'silent', 'beep', 'adzan'
  final isLoading = false.obs;
  final nextPrayerName = 'Isya'.obs;
  final nextPrayerTime = '00:00'.obs;
  final countdown = '-00:00:00'.obs;
  final isPrayerArrived = false.obs;
  final showHeartbeat = true.obs;
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

      // Load location
      final kabKotaData = prefs.getString('kabKota');
      final provinsiData = prefs.getString('provinsi');
      if (kabKotaData != null) {
        kabKota.value = kabKotaData;
      }
      if (provinsiData != null) {
        provinsi.value = provinsiData;
      }

      // Load prayer schedule
      final jadwalData = prefs.getString('jadwal');
      if (jadwalData != null) {
        final jadwalMap = jsonDecode(jadwalData) as Map<String, dynamic>;
        final now = DateTime.now();
        String twoDigits(int n) => n.toString().padLeft(2, "0");
        final todayStr =
            "${now.year}-${twoDigits(now.month)}-${twoDigits(now.day)}";

        if (jadwalMap.containsKey(todayStr)) {
          jadwalToday.value = jadwalMap[todayStr] as Map<String, dynamic>;

          // Get masehi date from jadwal
          final tanggal = jadwalToday['tanggal'] as String?;
          if (tanggal != null) {
            calendarMasehi.value = tanggal;
          }

          // Calculate next prayer
          _calculateNextPrayer();
          _schedulePrayerNotifications(); // Add this
        }
      }
    } catch (e) {
      print('Error loading prayer time data: $e');
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
      // Default Imsak & Terbit to silent if not set, else beep or silent. Adzan not avail.
      if (isImsakOrTerbit(key) && notificationSettings[key] == 'adzan') {
        notificationSettings[key] = 'silent';
      }
    }
  }

  // ...

  Future<void> saveNotificationSetting(String prayerName, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notif_$prayerName', value);
    notificationSettings[prayerName] = value;
    _schedulePrayerNotifications(); // Reschedule when settings change
  }

  // ...

  Future<void> _schedulePrayerNotifications() async {
    // Basic implementation: schedule for today's remaining prayers
    final now = DateTime.now();
    // Mapping from jadwal keys to notificationSettings keys
    final keyMap = {
      'subuh': 'Subuh',
      'dzuhur': 'Dhuhur',
      'ashar': 'Asar',
      'maghrib': 'Maghrib',
      'isya': 'Isya',
    };

    if (jadwalToday.isEmpty) return;

    // Cancel all previous schedules first?
    // Ideally yes, but let's just overwrite by ID.
    // ID scheme: 1=Subuh, 2=Dzuhur, etc. or unique hash.

    int idCounter = 1;
    for (var entry in keyMap.entries) {
      final jadwalKey = entry.key;
      final notifKey = entry.value;

      final timeStr = jadwalToday[jadwalKey] as String?;
      if (timeStr == null) continue;

      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      DateTime scheduledTime = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // If time passed, schedule for tomorrow?
      // Logic: if passed, it's irrelevant for today.
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      final setting = notificationSettings[notifKey] ?? 'adzan';
      String soundName = 'silent';
      if (setting == 'beep')
        soundName = 'beep';
      else if (setting == 'adzan') {
        if (notifKey == 'Subuh')
          soundName = 'adzan_subuh';
        else
          soundName = 'adzan_general';
      }

      if (soundName != 'silent') {
        await NotificationService.schedulePrayerNotification(
          id: idCounter,
          title: 'Waktu $notifKey Telah Tiba',
          body: 'Mari tunaikan sholat $notifKey',
          scheduledTime: scheduledTime,
          soundName: soundName,
        );
      } else {
        // Cancel if silent
        await NotificationService.cancel(idCounter);
      }
      idCounter++;
    }
  }

  // ...

  void _updateCountdown() {
    if (nextPrayerTime.value == '00:00' || jadwalToday.isEmpty) {
      return;
    }

    final now = DateTime.now();

    // Check if we're in the 5-minute hold period after prayer arrival
    if (_prayerArrivalTime != null) {
      final minutesSinceArrival = now.difference(_prayerArrivalTime!).inMinutes;

      if (minutesSinceArrival < 5) {
        // Still in hold period, show "Telah tiba"
        isPrayerArrived.value = true;
        countdown.value = 'Telah tiba';
        return;
      } else {
        // 5 minutes passed, move to next prayer
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

    // Determine if prayer is today or tomorrow
    final currentMinutes = now.hour * 60 + now.minute;
    final prayerMinutes = prayerHour * 60 + prayerMinute;

    DateTime prayerTime;
    if (prayerMinutes > currentMinutes) {
      // Prayer is today
      prayerTime = DateTime(
        now.year,
        now.month,
        now.day,
        prayerHour,
        prayerMinute,
      );
    } else {
      // Prayer is tomorrow (Subuh after Isya)
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

    // Check if prayer time has arrived (within 1 minute tolerance)
    if (difference.inSeconds <= 0 && difference.inSeconds > -60) {
      // Prayer time just arrived!
      _prayerArrivalTime = now;
      isPrayerArrived.value = true;
      countdown.value = 'Telah tiba';
      _playNotification(nextPrayerName.value);
      return;
    }

    // If countdown is way past (more than 1 minute), recalculate next prayer
    if (difference.inSeconds <= -60) {
      _calculateNextPrayer();
      return;
    }

    // Normal countdown
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
      print('Error playing audio: $e');
    }
  }

  void _calculateNextPrayer() {
    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;

    final prayerNames = ['subuh', 'dzuhur', 'ashar', 'maghrib', 'isya'];
    final displayNames = {
      'subuh': 'Subuh',
      'dzuhur': 'Dhuhur',
      'ashar': 'Asar',
      'maghrib': 'Maghrib',
      'isya': 'Isya',
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

          // Calculate countdown
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
    final subuhTimeStr = jadwalToday['subuh'] as String?;
    if (subuhTimeStr != null) {
      nextPrayerName.value = 'Subuh';
      nextPrayerTime.value = subuhTimeStr;

      // Calculate countdown for tomorrow's Subuh
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
