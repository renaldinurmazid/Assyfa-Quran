import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:quran_app/firebase_options.dart';
import 'package:quran_app/routes/app_pages.dart';
import 'package:quran_app/bindings/global_binding.dart';

import 'package:quran_app/services/fcm_service.dart';
import 'package:quran_app/services/notification_service.dart';

import 'package:quran_app/services/deep_link_service.dart';
import 'package:timezone/data/latest_all.dart' as tz; // Add this

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones(); // Add this
  DeepLinkService().init();
  await NotificationService.init();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FcmService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
      initialBinding: GlobalBinding(),
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}
