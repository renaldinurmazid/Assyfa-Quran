import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:firebase_core/firebase_core.dart';
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
      print('=== FCM FOREGROUND MESSAGE ===');
      print('Message ID: ${message.messageId}');
      print('From: ${message.from}');
      print('Category: ${message.category}');
      print('Collapse Key: ${message.collapseKey}');
      print('Content Available: ${message.contentAvailable}');
      print('Mutable Content: ${message.mutableContent}');
      print('Sent Time: ${message.sentTime}');
      print('TTL: ${message.ttl}');
      print('--- Notification Payload ---');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Android Image: ${message.notification?.android?.imageUrl}');
      print('Apple Image: ${message.notification?.apple?.imageUrl}');
      print('--- Data Payload ---');
      message.data.forEach((key, value) {
        print('  $key: $value');
      });
      print('Raw data: ${message.data}');
      print('=== END FCM FOREGROUND MESSAGE ===');

      RemoteNotification? notification = message.notification;

      // Extract details, prioritizing data payload to match user's PHP logic
      String? title = message.data['title'] ?? notification?.title;
      String? body = message.data['body'] ?? notification?.body;
      String? imageUrl =
          message.data['image'] ??
          notification?.android?.imageUrl ??
          notification?.apple?.imageUrl;

      // Extract URL from custom data or click_action
      String? urlPayload = DeepLinkService.extractPayload(message.data);

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
      print('=== FCM MESSAGE OPENED APP ===');
      print('Message ID: ${message.messageId}');
      print('Notification Title: ${message.notification?.title}');
      print('Notification Body: ${message.notification?.body}');
      print('Data Payload:');
      message.data.forEach((key, value) {
        print('  $key: $value');
      });
      print('Raw data: ${message.data}');
      print('=== END FCM MESSAGE OPENED APP ===');
      String? urlPayload = DeepLinkService.extractPayload(message.data);
      if (urlPayload != null) {
        await DeepLinkService.handlePayload(urlPayload);
      }
    });

    // Handle the case where the app was launched from a notification (terminated state)
    RemoteMessage? initialMessage = await FirebaseMessaging.instance
        .getInitialMessage();
    if (initialMessage != null) {
      print('=== FCM INITIAL MESSAGE (from terminated) ===');
      print('Message ID: ${initialMessage.messageId}');
      print('Notification Title: ${initialMessage.notification?.title}');
      print('Notification Body: ${initialMessage.notification?.body}');
      print('Data Payload:');
      initialMessage.data.forEach((key, value) {
        print('  $key: $value');
      });
      print('Raw data: ${initialMessage.data}');
      print('=== END FCM INITIAL MESSAGE ===');
      String? urlPayload = DeepLinkService.extractPayload(initialMessage.data);
      if (urlPayload != null) {
        Future.delayed(const Duration(seconds: 1), () {
          DeepLinkService.handlePayload(urlPayload);
        });
      }
    }

    // Call saveToken on startup if already logged in (wait a bit to ensure AuthController is ready)
    Future.delayed(const Duration(seconds: 5), () {
      if (Get.isRegistered<AuthController>() &&
          AuthController.to.isLogin.value) {
        saveToken();
      }
    });

    // Listen for token refreshes
    _firebaseMessaging.onTokenRefresh.listen((token) {
      if (Get.isRegistered<AuthController>() &&
          AuthController.to.isLogin.value) {
        saveToken();
      }
    });
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
      String? token;

      // On iOS, we must ensure APNS token is available before calling getToken()
      if (Platform.isIOS) {
        int retryCount = 0;
        while (retryCount < 3) {
          final apnsToken = await _firebaseMessaging.getAPNSToken();
          if (apnsToken != null) break;

          print("Waiting for APNS token... (attempt ${retryCount + 1})");
          await Future.delayed(Duration(seconds: 2 * (retryCount + 1)));
          retryCount++;
        }
      }

      try {
        token = await _firebaseMessaging.getToken();
      } on FirebaseException catch (e) {
        if (e.code == 'apns-token-not-set') {
          print(
            "FCM Save Token: APNS token still not set, will try again later.",
          );
          _isSaving = false;
          return;
        }
        rethrow;
      }

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
        final String deviceType =
            Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : 'unknown');
        final response = await Request().post(
          Url.saveFcmToken,
          data: {
            'fcm_token': token,
            'device_type': deviceType,
          },
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
  print('=== FCM BACKGROUND MESSAGE ===');
  print('Message ID: ${message.messageId}');
  print('From: ${message.from}');
  print('Notification Title: ${message.notification?.title}');
  print('Notification Body: ${message.notification?.body}');
  print('Data Payload:');
  message.data.forEach((key, value) {
    print('  $key: $value');
  });
  print('Raw data: ${message.data}');
  print('=== END FCM BACKGROUND MESSAGE ===');
}
