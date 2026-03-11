import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:quran_app/services/deep_link_service.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Prevents multiple initializations
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (e) {
      print('NotificationService: Could not set local location: $e');
      // Fallback to Asia/Jakarta since the app is for Indonesian users
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
      } catch (_) {}
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

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        final String? payload = response.payload;
        if (payload != null) {
          await DeepLinkService.handlePayload(payload);
        }
      },
    );

    // Handle the case where the app was launched from a notification (terminated state)
    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        await _notificationsPlugin.getNotificationAppLaunchDetails();
    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      final String? payload =
          notificationAppLaunchDetails?.notificationResponse?.payload;
      if (payload != null) {
        Future.delayed(const Duration(seconds: 1), () {
          DeepLinkService.handlePayload(payload);
        });
      }
    }

    // Request notification permission for Android 13+ (API 33+)
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin != null) {
      // Request POST_NOTIFICATIONS permission (Android 13+)
      await androidPlugin.requestNotificationsPermission();
      // Request exact alarm permission for Android 12+ (API 31+)
      await androidPlugin.requestExactAlarmsPermission();
    }

    _initialized = true;
    print('NotificationService: Initialized successfully');
  }

  /// Cancel all scheduled prayer notifications before rescheduling
  static Future<void> cancelAllPrayerNotifications() async {
    // Prayer notification IDs are 1-5 (fajr, dhuhr, asr, maghrib, isha)
    for (int i = 1; i <= 5; i++) {
      await _notificationsPlugin.cancel(i);
    }
    print('NotificationService: Cancelled all prayer notifications');
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
          // Ensure notification appears even in Do Not Disturb on some devices
          category: AndroidNotificationCategory.alarm,
          fullScreenIntent: true,
        );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidUniqueDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    // Convert to TZDateTime
    var tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

    // Ensure scheduled time is in the future
    final now = tz.TZDateTime.now(tz.local);
    if (tzScheduledTime.isBefore(now)) {
      tzScheduledTime = tzScheduledTime.add(const Duration(days: 1));
    }

    print(
      'NotificationService: Scheduling "$title" at $tzScheduledTime (id=$id, sound=$soundName)',
    );

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

  static Future<void> showGeneralNotification({
    required int id,
    required String title,
    required String body,
    String? url,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'general_notification_channel',
          'General Notifications',
          channelDescription: 'Generic notifications for the app',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: url,
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

  static Future<void> showBigPictureNotification({
    required int id,
    required String title,
    required String body,
    required String assetPath,
    String? url,
  }) async {
    final ByteData byteData = await rootBundle.load(assetPath);
    final Uint8List uint8list = byteData.buffer.asUint8List();

    final BigPictureStyleInformation bigPictureStyleInformation =
        BigPictureStyleInformation(
          ByteArrayAndroidBitmap(uint8list),
          largeIcon: ByteArrayAndroidBitmap(uint8list),
          contentTitle: title,
          summaryText: body,
        );

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'big_picture_notification_channel',
          'Big Picture Notifications',
          channelDescription: 'Notifications with images',
          importance: Importance.max,
          priority: Priority.high,
          styleInformation: bigPictureStyleInformation,
        );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: const DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: url,
    );
  }

  static Future<void> cancel(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}
