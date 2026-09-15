import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/services/deep_link_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // If a deep link is already pending on launch, shorten the splash delay
    // so the user gets to their shared content quickly.
    final duration = DeepLinkService().hasPendingDeepLink
        ? const Duration(milliseconds: 800)
        : const Duration(milliseconds: 1800);

    _timer = Timer(duration, () {
      if (mounted) {
        Get.offAllNamed(Routes.main);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/images/png/splash.png', fit: BoxFit.cover);
  }
}
