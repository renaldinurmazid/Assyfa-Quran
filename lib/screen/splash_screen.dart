import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/services/deep_link_service.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Timer(const Duration(seconds: 3), () {
      Get.offAllNamed(Routes.main);
      // Process any deep links that arrived during splash
      DeepLinkService().markReady();
    });
    return Image.asset('assets/images/png/splash.png', fit: BoxFit.cover);
  }
}
