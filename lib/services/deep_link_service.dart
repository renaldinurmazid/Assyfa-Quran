import 'dart:async';
import 'package:get/get.dart';
import 'package:app_links/app_links.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      (Uri uri) {
        _parseAndSaveReferralCode(uri);
      },
      onError: (err) {
        print('Deep link stream error: $err');
      },
    );
  }

  void _parseAndSaveReferralCode(Uri uri) {
    print('Processing deep link: $uri');

    // Handle Group Invite
    // Custom scheme: quranuna://group/CODE
    if (uri.scheme == 'quranuna' && uri.host == 'group') {
      if (uri.pathSegments.isNotEmpty) {
        _handleGroupInvite(uri.pathSegments.first);
        return;
      }
    }

    // Web URL patterns
    final path = uri.path;

    // 1. Group Invite: /api/g/CODE or /g/CODE or /group/CODE
    if (path.contains('/api/g/') || path.contains('/g/')) {
      final segments = uri.pathSegments;
      int gIndex = segments.indexOf('g');
      if (gIndex != -1 && gIndex + 1 < segments.length) {
        _handleGroupInvite(segments[gIndex + 1]);
        return;
      }
    }

    // 2. Campaign / Charity: /campaign/ID or /charity/ID or /c/ID
    if (path.contains('/campaign/') ||
        path.contains('/charity/') ||
        path.contains('/c/')) {
      final segments = uri.pathSegments;
      for (var segment in ['campaign', 'charity', 'c']) {
        int index = segments.indexOf(segment);
        if (index != -1 && index + 1 < segments.length) {
          _handleNavigation(Routes.charityShow, segments[index + 1]);
          return;
        }
      }
    }

    // 3. Mosque Charity: /mosque-charity/ID or /mc/ID
    if (path.contains('/mosque-charity/') || path.contains('/m/')) {
      final segments = uri.pathSegments;
      for (var segment in ['mosque-charity', 'm']) {
        int index = segments.indexOf(segment);
        if (index != -1 && index + 1 < segments.length) {
          _handleNavigation(Routes.mosqueCharityShow, segments[index + 1]);
          return;
        }
      }
    }

    // 4. Referral Code
    String code = '';
    if (uri.queryParameters.containsKey('ref')) {
      code = uri.queryParameters['ref']!;
    } else if (uri.queryParameters.containsKey('referral')) {
      code = uri.queryParameters['referral']!;
    } else if (uri.pathSegments.contains('referral')) {
      int index = uri.pathSegments.indexOf('referral');
      if (index + 1 < uri.pathSegments.length) {
        code = uri.pathSegments[index + 1];
      }
    }

    if (code.isNotEmpty) {
      print('Referral code extracted: $code');
      if (Get.isRegistered<AuthController>()) {
        AuthController.to.referralCode.value = code;
      } else {
        // AuthController not ready yet, save to SharedPreferences for later pickup
        SharedPreferences.getInstance().then((prefs) {
          prefs.setString('referral_code_temp', code);
        });
      }
      // Optional: Show notification to user that referral is applied
      Get.snackbar(
        'Referral Berhasil',
        'Kode referral $code berhasil diterapkan.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _handleNavigation(String route, dynamic arguments) {
    print('Navigating to $route with args: $arguments');
    Get.toNamed(route, arguments: arguments);
  }

  void _handleGroupInvite(String code) {
    print('Processing group invite link: $code');
    Get.toNamed(Routes.showGroup, arguments: code);
  }
}
