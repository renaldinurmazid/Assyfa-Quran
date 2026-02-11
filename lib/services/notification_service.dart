import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (e) {
      print('Could not set local location: $e');
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> schedulePrayerNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String soundName,
  }) async {
    String? androidSoundRawResourceName;
    if (soundName == 'beep') {
      androidSoundRawResourceName = 'beep';
    } else if (soundName == 'adzan_subuh') {
      androidSoundRawResourceName = 'adzan_subuh';
    } else if (soundName == 'adzan_general') {
      androidSoundRawResourceName = 'adzan_general';
    }

    String channelId = 'prayer_channel_$soundName';
    String channelName = 'Prayer Times ($soundName)';

    AndroidNotificationDetails androidUniqueDetails =
        AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: 'Notifications for prayer times',
          importance: Importance.max,
          priority: Priority.high,
          playSound: androidSoundRawResourceName != null,
          sound: androidSoundRawResourceName != null
              ? RawResourceAndroidNotificationSound(androidSoundRawResourceName)
              : null,
        );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidUniqueDetails,
    );

    // Ensure scheduled time is in the future
    var tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);
    if (tzScheduledTime.isBefore(tz.TZDateTime.now(tz.local))) {
      // If time passed, schedule for tomorrow?
      // For now, let's just add a day if it's strictly in the past,
      // but prayer times are usually loaded for 'today'.
      // If it's passed, maybe we don't schedule or it's for tomorrow's list.
      // Let's assume the controller passes a valid future time.
      if (tzScheduledTime.isBefore(tz.TZDateTime.now(tz.local))) {
        tzScheduledTime = tzScheduledTime.add(const Duration(days: 1));
      }
    }

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzScheduledTime,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> showProgressNotification(
    int progress,
    int total,
    String title,
  ) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'quran_download_channel',
          'Quran Download',
          channelDescription: 'Notification for Quran download progress',
          importance: Importance.low,
          priority: Priority.low,
          showProgress: true,
          maxProgress: total,
          progress: progress,
          onlyAlertOnce: true,
          ongoing: true,
          silent: true,
        );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      100,
      title,
      '$progress / $total Halaman',
      platformChannelSpecifics,
    );
  }

  static Future<void> showCompleteNotification(
    String title,
    String body,
  ) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'quran_download_channel',
          'Quran Download',
          channelDescription: 'Notification for Quran download status',
          importance: Importance.high,
          priority: Priority.high,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(100, title, body, platformChannelSpecifics);
  }

  static Future<void> cancel(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}
