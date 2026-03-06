import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/services/deep_link_service.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FcmService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.max,
  );

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Request permission for iOS/Android 13+
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Initialize local notifications for foreground
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        final String? payload = response.payload;
        if (payload != null) {
          await DeepLinkService.handlePayload(payload);
        }
      },
    );

    // Create the channel on Android
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else {
      print('User declined or has not accepted permission');
    }

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      RemoteNotification? notification = message.notification;

      // Extract details, prioritizing data payload to match user's PHP logic
      String? title = message.data['title'] ?? notification?.title;
      String? body = message.data['body'] ?? notification?.body;
      String? imageUrl =
          message.data['image'] ??
          notification?.android?.imageUrl ??
          notification?.apple?.imageUrl;

      // Extract URL from custom data or click_action
      String? urlPayload =
          message.data['url'] ??
          message.data['link'] ??
          (message.data['click_action'] != 'FLUTTER_NOTIFICATION_CLICK'
              ? message.data['click_action']
              : null);

      if (title != null || body != null) {
        print('Displaying foreground notification: $title');
        try {
          int notificationId =
              notification?.hashCode ?? DateTime.now().millisecond;

          String? largeIconPath;
          String? bigPicturePath;

          if (imageUrl != null && imageUrl.isNotEmpty) {
            bigPicturePath = await _downloadAndSaveFile(
              imageUrl,
              'notification_big_picture_$notificationId',
            );
            largeIconPath = bigPicturePath;
          }

          await flutterLocalNotificationsPlugin.show(
            notificationId,
            title ?? 'Notifikasi Baru',
            body ?? '',
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                icon: '@mipmap/ic_launcher',
                importance: Importance.max,
                priority: Priority.high,
                ticker: 'ticker',
                playSound: true,
                enableVibration: true,
                color: AppColor.primaryColor,
                styleInformation: bigPicturePath != null
                    ? BigPictureStyleInformation(
                        FilePathAndroidBitmap(bigPicturePath),
                        largeIcon: FilePathAndroidBitmap(largeIconPath!),
                        contentTitle: title,
                        summaryText: body,
                      )
                    : null,
              ),
              iOS: DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
                attachments: bigPicturePath != null
                    ? [DarwinNotificationAttachment(bigPicturePath)]
                    : null,
              ),
            ),
            payload: urlPayload,
          );
        } catch (e) {
          print('Error showing local notification: $e');
        }
      }
    });

    // Handle app opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      print('A new onMessageOpenedApp event was published!');
      String? urlPayload =
          message.data['url'] ??
          message.data['link'] ??
          (message.data['click_action'] != 'FLUTTER_NOTIFICATION_CLICK'
              ? message.data['click_action']
              : null);
      if (urlPayload != null) {
        await DeepLinkService.handlePayload(urlPayload);
      }
    });

    // Handle the case where the app was launched from a notification (terminated state)
    RemoteMessage? initialMessage = await FirebaseMessaging.instance
        .getInitialMessage();
    if (initialMessage != null) {
      String? urlPayload =
          initialMessage.data['url'] ??
          initialMessage.data['link'] ??
          (initialMessage.data['click_action'] != 'FLUTTER_NOTIFICATION_CLICK'
              ? initialMessage.data['click_action']
              : null);
      if (urlPayload != null) {
        Future.delayed(const Duration(seconds: 1), () {
          DeepLinkService.handlePayload(urlPayload);
        });
      }
    }
  }

  static String? _lastToken;
  static bool _isSaving = false;
  static bool _hasUnauthorizedError = false;

  static Future<void> saveToken() async {
    if (_isSaving) return;
    if (_hasUnauthorizedError) return;
    if (!AuthController.to.isLogin.value) return;

    _isSaving = true;
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        if (!AuthController.to.isLogin.value) {
          _isSaving = false;
          return;
        }

        if (token == _lastToken) {
          _isSaving = false;
          return;
        }

        final prefs = await SharedPreferences.getInstance();
        final savedToken = prefs.getString('saved_fcm_token');
        if (token == savedToken) {
          _lastToken = token;
          _isSaving = false;
          return;
        }

        print("Saving FCM Token: $token");
        final response = await Request().post(
          Url.saveFcmToken,
          data: {'fcm_token': token},
        );

        if (response.statusCode == 200) {
          _lastToken = token;
          await prefs.setString('saved_fcm_token', token);
          print("FCM Token saved successfully");
        }
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        _hasUnauthorizedError = true;
        print(
          "FCM Token save failed (401): Stopping further attempts this session.",
        );
      } else {
        print("Error saving FCM Token (Dio): $e");
      }
    } catch (e) {
      print("Error saving FCM Token: $e");
    } finally {
      _isSaving = false;
    }
  }

  static void resetUnauthorizedError() {
    _hasUnauthorizedError = false;
    _lastToken = null;
  }

  static Future<String?> _downloadAndSaveFile(
    String url,
    String fileName,
  ) async {
    try {
      final Directory directory = await getTemporaryDirectory();
      final String filePath = '${directory.path}/$fileName';
      final Response response = await Dio().get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      final File file = File(filePath);
      await file.writeAsBytes(response.data);
      return filePath;
    } catch (e) {
      print('Error downloading file: $e');
      return null;
    }
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}
