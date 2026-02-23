import 'package:flutter/foundation.dart';
import 'package:play_install_referrer/play_install_referrer.dart';
import 'package:quran_app/controller/global/auth_controller.dart';

class ReferrerService {
  static Future<void> checkReferrer([AuthController? authController]) async {
    final controller = authController ?? AuthController.to;

    // Only check if not logged in and referral code is empty
    if (controller.isLogin.value || controller.referralCode.value.isNotEmpty) {
      return;
    }

    if (defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    try {
      ReferrerDetails details = await PlayInstallReferrer.installReferrer;
      String? referrer = details.installReferrer;

      if (referrer != null && referrer.isNotEmpty) {
        debugPrint('Install Referrer: $referrer');
        // Expected format: https://play.google.com/store/apps/details?id=com.quranuna.app&referrer=NHNNK5KK
        // The installReferrer usually contains just the query parameters if it's from the Play Store link

        Uri uri = Uri.parse('?$referrer');
        String? code = uri.queryParameters['referrer'];

        if (code != null && code.isNotEmpty) {
          controller.referralCode.value = code;
          debugPrint('Extracted Referral Code: $code');
        }
      }
    } catch (e) {
      debugPrint('Error getting install referrer: $e');
    }
  }
}
