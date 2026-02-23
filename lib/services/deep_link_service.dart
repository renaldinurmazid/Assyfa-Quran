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

  /// Tracks whether the app has finished navigating to the main screen.
  /// Deep links arriving before that are stored in [_pendingUri].
  bool _isReady = false;
  Uri? _pendingUri;

  void init() {
    _appLinks = AppLinks();
    _handleIncomingLinks();
    _handleInitialLink();
  }

  /// Call this once the main screen (or splash) has finished loading,
  /// so that deferred deep links can be processed.
  void markReady() {
    _isReady = true;
    if (_pendingUri != null) {
      _processDeepLink(_pendingUri!);
      _pendingUri = null;
    }
  }

  void dispose() {
    _linkSubscription?.cancel();
  }

  Future<void> _handleInitialLink() async {
    try {
      final Uri? initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _processDeepLink(initialUri);
      }
    } catch (e) {
      print('DeepLink: Failed to get initial link: $e');
    }
  }

  void _handleIncomingLinks() {
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        _processDeepLink(uri);
      },
      onError: (err) {
        print('DeepLink: Stream error: $err');
      },
    );
  }

  void _processDeepLink(Uri uri) {
    print('DeepLink: Processing → $uri');

    // If the app hasn't finished initializing, queue the link
    if (!_isReady) {
      print('DeepLink: App not ready – queuing');
      _pendingUri = uri;
      // Still save referral code immediately so it's not lost
      _extractAndSaveReferralCode(uri);
      return;
    }

    // ════════════════════════════════════════════════
    // 1. Custom Scheme: quranuna://
    // ════════════════════════════════════════════════
    if (uri.scheme == 'quranuna') {
      _handleCustomScheme(uri);
      return;
    }

    // ════════════════════════════════════════════════
    // 2. Web URL: https://quran.titiktolak.com/...
    //    Routes:
    //    - /g/{code}        → Group
    //    - /c/{id}?ref=XXX  → Campaign
    //    - /m/{id}?ref=XXX  → Mosque Charity
    //    (Also with /api/ prefix)
    // ════════════════════════════════════════════════
    _handleWebUrl(uri);
  }

  // ──────────────────────────────────────────────────
  // Custom Scheme Handler: quranuna://
  // ──────────────────────────────────────────────────

  void _handleCustomScheme(Uri uri) {
    final host = uri.host;
    final segments = uri.pathSegments;

    switch (host) {
      // quranuna://group/CODE
      case 'group':
        if (segments.isNotEmpty) {
          _navigateToGroupByCode(segments.first);
        }
        break;

      // quranuna://campaign/ID  or  quranuna://campaign/ID/REFERRAL_CODE
      case 'campaign':
        if (segments.isNotEmpty) {
          final campaignId = int.tryParse(segments.first);
          if (campaignId != null) {
            if (segments.length > 1) {
              _saveReferralCode(segments[1]);
            }
            _navigateToCampaign(campaignId);
          }
        }
        break;

      // quranuna://mosque-charity/ID  or  quranuna://mosque-charity/ID/REFERRAL_CODE
      case 'mosque-charity':
        if (segments.isNotEmpty) {
          final mosqueId = int.tryParse(segments.first);
          if (mosqueId != null) {
            if (segments.length > 1) {
              _saveReferralCode(segments[1]);
            }
            _navigateToMosqueCharity(mosqueId);
          }
        }
        break;

      default:
        print('DeepLink: Unknown custom scheme host: $host');
        _extractAndSaveReferralCode(uri);
    }
  }

  // ──────────────────────────────────────────────────
  // Web URL Handler
  // ──────────────────────────────────────────────────

  void _handleWebUrl(Uri uri) {
    final segments = uri.pathSegments;

    // Find the key segment. Routes can be:
    //   /g/{code}   or   /api/g/{code}
    //   /c/{id}     or   /api/c/{id}
    //   /m/{id}     or   /api/m/{id}

    // ── Group: /g/CODE ──
    int gIndex = segments.indexOf('g');
    if (gIndex != -1 && gIndex + 1 < segments.length) {
      _navigateToGroupByCode(segments[gIndex + 1]);
      return;
    }

    // ── Campaign: /c/ID ──
    int cIndex = segments.indexOf('c');
    if (cIndex != -1 && cIndex + 1 < segments.length) {
      final campaignId = int.tryParse(segments[cIndex + 1]);
      if (campaignId != null) {
        _extractAndSaveReferralCode(uri);
        _navigateToCampaign(campaignId);
        return;
      }
    }

    // ── Mosque Charity: /m/ID ──
    int mIndex = segments.indexOf('m');
    if (mIndex != -1 && mIndex + 1 < segments.length) {
      final mosqueId = int.tryParse(segments[mIndex + 1]);
      if (mosqueId != null) {
        _extractAndSaveReferralCode(uri);
        _navigateToMosqueCharity(mosqueId);
        return;
      }
    }

    // ── Fallback: just save referral code if any ──
    _extractAndSaveReferralCode(uri);
  }

  // ════════════════════════════════════════════════════
  // Navigation helpers
  // ════════════════════════════════════════════════════

  /// Navigate to campaign (charity) show screen.
  /// CharityShowController expects: Get.arguments = {'id': int}
  void _navigateToCampaign(int campaignId) {
    print('DeepLink: → Campaign #$campaignId');
    Get.toNamed(Routes.charityShow, arguments: {'id': campaignId});
  }

  /// Navigate to mosque charity show screen.
  /// MosqueCharityShowController expects: Get.arguments = {'id': int}
  void _navigateToMosqueCharity(int mosqueId) {
    print('DeepLink: → Mosque Charity #$mosqueId');
    Get.toNamed(Routes.mosqueCharityShow, arguments: {'id': mosqueId});
  }

  /// Navigate to group show screen by invite code.
  /// ShowGroupController expects: Get.arguments = int (group ID) or String (code).
  /// When receiving a code from deep link, we pass it as a String;
  /// the controller needs to handle resolving code → group detail.
  void _navigateToGroupByCode(String code) {
    print('DeepLink: → Group invite code: $code');
    // Try parsing as int first (in case it's an ID)
    final asInt = int.tryParse(code);
    Get.toNamed(Routes.showGroup, arguments: asInt ?? code);
  }

  // ════════════════════════════════════════════════════
  // Referral code helpers
  // ════════════════════════════════════════════════════

  /// Extracts referral code from query parameters (?ref= or ?referral=).
  void _extractAndSaveReferralCode(Uri uri) {
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
      _saveReferralCode(code);
    }
  }

  void _saveReferralCode(String code) {
    print('DeepLink: Referral code → $code');
    if (Get.isRegistered<AuthController>()) {
      AuthController.to.referralCode.value = code;
    } else {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('referral_code_temp', code);
      });
    }
    Get.snackbar(
      'Referral Berhasil',
      'Kode referral $code berhasil diterapkan.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
