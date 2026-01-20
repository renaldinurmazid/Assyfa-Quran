import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
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
