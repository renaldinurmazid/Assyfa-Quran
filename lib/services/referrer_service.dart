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
        debugPrint('ReferrerService: Raw install referrer → $referrer');

        // The Play Store Install Referrer API returns the value of the
        // `referrer` query parameter from the Play Store URL.
        //
        // Case 1: Simple referral code
        //   Play Store URL: ...&referrer=NHNNK5KK
        //   installReferrer returns: "NHNNK5KK"
        //
        // Case 2: Encoded query string (from campaign share)
        //   Play Store URL: ...&referrer=campaign_id%3D2%26referral_code%3DNHNNK5KK
        //   installReferrer returns: "campaign_id=2&referral_code=NHNNK5KK"

        String code = '';

        // Try parsing as query parameters first (Case 2)
        if (referrer.contains('=')) {
          Uri uri = Uri.parse('?$referrer');

          // Check for referral_code parameter
          code =
              uri.queryParameters['referral_code'] ??
              uri.queryParameters['referrer'] ??
              uri.queryParameters['ref'] ??
              '';

          debugPrint('ReferrerService: Parsed as query params → code: $code');
        }

        // If no code found from query parsing, use the raw string (Case 1)
        // The raw referrer IS the code itself
        if (code.isEmpty) {
          // Make sure it looks like a valid code (not a URL or garbage)
          final trimmed = referrer.trim();
          if (trimmed.isNotEmpty &&
              !trimmed.contains('http') &&
              !trimmed.contains(' ') &&
              trimmed.length <= 30) {
            code = trimmed;
            debugPrint('ReferrerService: Using raw referrer as code → $code');
          }
        }

        if (code.isNotEmpty) {
          controller.referralCode.value = code;
          debugPrint('ReferrerService: ✅ Referral code set → $code');
        } else {
          debugPrint('ReferrerService: ⚠️ No valid referral code found');
        }
      } else {
        debugPrint('ReferrerService: No install referrer available');
      }
    } catch (e) {
      debugPrint('ReferrerService: Error getting install referrer → $e');
    }
  }
}
