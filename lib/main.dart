import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_app/firebase_options.dart';
import 'package:quran_app/routes/app_pages.dart';
import 'package:quran_app/bindings/global_binding.dart';

import 'package:quran_app/services/fcm_service.dart';
import 'package:quran_app/services/notification_service.dart';

import 'package:quran_app/services/deep_link_service.dart';
import 'package:quran_app/controller/theme_controller.dart';
import 'package:quran_app/theme/app_color.dart';

import 'package:toastification/toastification.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_session/audio_session.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DeepLinkService().init();
  await NotificationService.init();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FcmService.init();
  
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );

  final session = await AudioSession.instance;
  await session.configure(const AudioSessionConfiguration.music());

  Get.put(ThemeController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: AppColor.primaryColor,
          scaffoldBackgroundColor: AppColor.backgroundColor,
          useMaterial3: true,
          colorScheme: const ColorScheme.light(
            primary: AppColor.primaryColor,
            surface: AppColor.backgroundColor,
            onSurface: AppColor.textColor,
            surfaceContainer: AppColor.surfaceColor,
          ),
          textTheme: GoogleFonts.poppinsTextTheme().apply(
            bodyColor: AppColor.textColor,
            displayColor: AppColor.textColor,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColor.backgroundColor,
            elevation: 0,
            iconTheme: IconThemeData(color: AppColor.textColor),
            centerTitle: true,
          ),
        ),
        darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
          primaryColor: AppColor.primaryColorDark,
          scaffoldBackgroundColor: AppColor.backgroundColorDark,
          colorScheme: const ColorScheme.dark(
            primary: AppColor.primaryColorDark,
            surface: AppColor.backgroundColorDark,
            onSurface: AppColor.textColorDark,
            surfaceContainer: AppColor.surfaceColorDark,
          ),
          textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme)
              .apply(
                bodyColor: AppColor.textColorDark,
                displayColor: AppColor.textColorDark,
              ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColor.backgroundColorDark,
            elevation: 0,
            iconTheme: IconThemeData(color: AppColor.textColorDark),
            centerTitle: true,
          ),
        ),
        themeMode: ThemeController.to.themeMode,
        initialBinding: GlobalBinding(),
        initialRoute: AppPages.initial,
        getPages: AppPages.routes,
      ),
    );
  }
}
