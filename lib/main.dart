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
          scaffoldBackgroundColor: const Color(0xFFFBFBFB),
          useMaterial3: true,
          colorScheme: ColorScheme.light(
            primary: AppColor.primaryColor,
            surface: const Color(0xFFFBFBFB),
            onSurface: AppColor.textColor,
            surfaceContainer: Colors.white,
          ),
          textTheme: GoogleFonts.poppinsTextTheme().apply(
            bodyColor: AppColor.textColor,
            displayColor: AppColor.textColor,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFFBFBFB),
            elevation: 0,
            iconTheme: IconThemeData(color: AppColor.textColor),
            centerTitle: true,
          ),
        ),
        darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
          primaryColor: AppColor.primaryColorDark,
          scaffoldBackgroundColor: const Color.fromARGB(255, 19, 19, 19),
          colorScheme: ColorScheme.dark(
            primary: AppColor.primaryColorDark,
            surface: const Color(0xFF121212),
            onSurface: Colors.white,
            surfaceContainer: Colors.grey[900]!,
          ),
          textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme)
              .apply(
                bodyColor: Colors.white.withOpacity(0.85),
                displayColor: Colors.white,
              ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF121212),
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.white),
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
