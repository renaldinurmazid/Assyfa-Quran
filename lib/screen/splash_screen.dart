import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/routes/app_routes.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Timer(const Duration(seconds: 3), () {
      Get.offAllNamed(Routes.main);
      // Deep link processing is handled by HomeScreen's addPostFrameCallback
      // via DeepLinkService().markReady() – do NOT call it here because the
      // main route transition hasn't finished yet.
    });
    return Image.asset('assets/images/png/splash.png', fit: BoxFit.cover);
  }
}
