import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_links/app_links.dart';
import 'package:quran_app/controller/global/auth_controller.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  void init() {
    _appLinks = AppLinks();
    _handleIncomingLinks();
    _handleInitialLink();
  }

  void dispose() {
    _linkSubscription?.cancel();
  }

  Future<void> _handleInitialLink() async {
    try {
      final Uri? initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _parseAndSaveReferralCode(initialUri);
      }
    } catch (e) {
      print('Failed to get initial link: $e');
    }
  }

  void _handleIncomingLinks() {
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null) {
          _parseAndSaveReferralCode(uri);
        }
      },
      onError: (err) {
        print('Deep link stream error: $err');
      },
    );
  }

  void _parseAndSaveReferralCode(Uri uri) {
    print('Processing deep link: $uri');

    // example: quranuna://group/CODE
    if (uri.scheme == 'quranuna' && uri.host == 'group') {
      if (uri.pathSegments.isNotEmpty) {
        final groupCode = uri.pathSegments.first;
        _handleGroupInvite(groupCode);
        return;
      }
    }

    // example: https://domain.com/api/g/CODE
    if (uri.pathSegments.contains('g')) {
      int index = uri.pathSegments.indexOf('g');
      if (index + 1 < uri.pathSegments.length) {
        final groupCode = uri.pathSegments[index + 1];
        _handleGroupInvite(groupCode);
        return;
      }
    }

    // Example: https://quran.titiktolak.com/referral/ABCDE
    // Example: https://quran.titiktolak.com/?ref=ABCDE

    String code = '';

    // Check query parameter 'ref'
    if (uri.queryParameters.containsKey('ref')) {
      code = uri.queryParameters['ref']!;
    }
    // Check query parameter 'referral'
    else if (uri.queryParameters.containsKey('referral')) {
      code = uri.queryParameters['referral']!;
    }
    // Check path segments (assuming /referral/CODE)
    else if (uri.pathSegments.contains('referral')) {
      int index = uri.pathSegments.indexOf('referral');
      if (index + 1 < uri.pathSegments.length) {
        code = uri.pathSegments[index + 1];
      }
    }

    if (code.isNotEmpty) {
      print('Referral code extracted: $code');
      // Save it in AuthController
      AuthController.to.referralCode.value = code;
    }
  }

  void _handleGroupInvite(String code) {
    print('Processing group invite link: $code');
    // For now, show info and potentially navigate to join screen
    // This part can be expanded to navigate to a specific JoinGroupScreen
    Get.snackbar(
      'Undangan Grup',
      'Kode Grup: $code. Segera hadir fitur join otomatis!',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.white.withOpacity(0.9),
      colorText: Colors.black,
      duration: const Duration(seconds: 5),
    );
  }
}
