import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:app_links/app_links.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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

  /// Prevents navigating to the same deep link twice (e.g. from initial + stream).
  Uri? _lastProcessedUri;

  void init() {
    _appLinks = AppLinks();
    _handleIncomingLinks();
    _handleInitialLink();
  }

  /// Call this once the main screen (or splash) has finished loading,
  /// so that deferred deep links can be processed.
  void markReady() {
    if (_isReady) return; // Prevent double-calling
    _isReady = true;
    _flushPendingUri();
  }

  /// Attempts to navigate to the pending deep-link URI.
  /// Uses [WidgetsBinding.addPostFrameCallback] + a short delay to guarantee
  /// the navigation stack has settled after the splash → main transition.
  void _flushPendingUri() {
    if (_pendingUri == null) return;

    final uri = _pendingUri!;
    _pendingUri = null;

    // Wait for the current frame to finish, then add a small delay
    // to ensure the route transition (splash → main) has fully completed.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 600), () {
        _safeNavigate(uri);
      });
    });
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

  void _processDeepLink(Uri uri, {bool isFromUserTap = false}) {
    print('DeepLink: Processing → $uri');

    // Deduplicate: avoid processing the exact same URI twice
    // (initial link + stream can fire the same URI)
    if (!isFromUserTap &&
        _lastProcessedUri != null &&
        _lastProcessedUri.toString() == uri.toString()) {
      print('DeepLink: Already processed – skipping');
      return;
    }

    // Always save referral code immediately so it's not lost
    _extractAndSaveReferralCode(uri);

    // If the app hasn't finished initializing, queue the link
    if (!_isReady) {
      print('DeepLink: App not ready – queuing');
      _pendingUri = uri;
      return;
    }

    _safeNavigate(uri);
  }

  /// Actually resolve the URI to a route and navigate.
  /// Wrapped in a try-catch so navigation errors don't crash the app silently.
  void _safeNavigate(Uri uri) async {
    try {
      // Mark as last processed to prevent duplicates
      _lastProcessedUri = uri;

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
      bool handled = _handleWebUrl(uri);
      
      if (!handled && (uri.scheme == 'http' || uri.scheme == 'https')) {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      print('DeepLink: Navigation error: $e');
    }
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

      // quranuna://blog/SLUG
      case 'blog':
        if (segments.isNotEmpty) {
          _navigateToBlog(segments.first);
        }
        break;

      default:
        break;
    }
  }

  // ──────────────────────────────────────────────────
  // Web URL Handler
  // ──────────────────────────────────────────────────

  bool _handleWebUrl(Uri uri) {
    final segments = uri.pathSegments;

    // Find the key segment. Routes can be:
    //   /g/{code}   or   /api/g/{code}
    //   /c/{id}     or   /api/c/{id}
    //   /m/{id}     or   /api/m/{id}

    // ── Group: /g/CODE ──
    int gIndex = segments.indexOf('g');
    if (gIndex != -1 && gIndex + 1 < segments.length) {
      _navigateToGroupByCode(segments[gIndex + 1]);
      return true;
    }

    // ── Campaign: /c/ID ──
    int cIndex = segments.indexOf('c');
    if (cIndex != -1 && cIndex + 1 < segments.length) {
      final campaignId = int.tryParse(segments[cIndex + 1]);
      if (campaignId != null) {
        _navigateToCampaign(campaignId);
        return true;
      }
    }

    // ── Mosque Charity: /m/ID ──
    int mIndex = segments.indexOf('m');
    if (mIndex != -1 && mIndex + 1 < segments.length) {
      final mosqueId = int.tryParse(segments[mIndex + 1]);
      if (mosqueId != null) {
        _navigateToMosqueCharity(mosqueId);
        return true;
      }
    }

    // ── Blog: /b/SLUG ──
    int bIndex = segments.indexOf('b');
    if (bIndex != -1 && bIndex + 1 < segments.length) {
      _navigateToBlog(segments[bIndex + 1]);
      return true;
    }
    
    return false;
  }

  // ════════════════════════════════════════════════════
  // Navigation helpers
  // ════════════════════════════════════════════════════

  /// Navigate to campaign (charity) show screen.
  /// CharityShowController expects: Get.arguments = {'id': int}
  void _navigateToCampaign(int campaignId) {
    print(
      'DeepLink: Navigating to campaign $campaignId (current route: ${Get.currentRoute})',
    );
    _ensureMainAndNavigate(() {
      Get.toNamed(Routes.charityShow, arguments: {'id': campaignId});
    });
  }

  /// Navigate to mosque charity show screen.
  /// MosqueCharityShowController expects: Get.arguments = {'id': int}
  void _navigateToMosqueCharity(int mosqueId) {
    print(
      'DeepLink: Navigating to mosque charity $mosqueId (current route: ${Get.currentRoute})',
    );
    _ensureMainAndNavigate(() {
      Get.toNamed(Routes.mosqueCharityShow, arguments: {'id': mosqueId});
    });
  }

  /// Navigate to group show screen by invite code.
  /// ShowGroupController expects: Get.arguments = int (group ID) or String (code).
  void _navigateToGroupByCode(String code) {
    print(
      'DeepLink: Navigating to group by code "$code" (current route: ${Get.currentRoute})',
    );
    final asInt = int.tryParse(code);
    _ensureMainAndNavigate(() {
      Get.toNamed(Routes.showGroup, arguments: asInt ?? code);
    });
  }

  /// Navigate to blog detail screen.
  /// ShowBlogScreen expects: Get.arguments = String (slug)
  void _navigateToBlog(String slug) {
    print(
      'DeepLink: Navigating to blog "$slug" (current route: ${Get.currentRoute})',
    );
    _ensureMainAndNavigate(() {
      Get.toNamed(Routes.showBlog, arguments: slug);
    });
  }

  /// Ensures the main screen is in the navigation stack before navigating
  /// to the target route. If the current route is splash or empty (app just
  /// started), waits until the main route is active.
  void _ensureMainAndNavigate(VoidCallback navigate) {
    final currentRoute = Get.currentRoute;

    // If we're on the main screen, navigate directly
    if (currentRoute == Routes.main) {
      navigate();
      return;
    }

    // If we're on splash or the route is empty/unknown, the splash → main
    // transition might still be in progress. Wait and retry.
    if (currentRoute == Routes.splash ||
        currentRoute == '/' ||
        currentRoute.isEmpty) {
      print('DeepLink: Waiting for main screen (current: "$currentRoute")');
      _waitForMainAndNavigate(navigate, retries: 10);
      return;
    }

    // We're on some other screen (maybe already navigated somewhere).
    // Just push the target route.
    navigate();
  }

  /// Polls until [Get.currentRoute] is [Routes.main], then calls [navigate].
  /// Gives up after [retries] attempts (each 300ms apart).
  void _waitForMainAndNavigate(VoidCallback navigate, {required int retries}) {
    if (retries <= 0) {
      print('DeepLink: Gave up waiting for main screen – navigating anyway');
      navigate();
      return;
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      final currentRoute = Get.currentRoute;
      if (currentRoute == Routes.main) {
        // Extra safety: wait one more frame so the widget tree is fully built
        WidgetsBinding.instance.addPostFrameCallback((_) {
          navigate();
        });
      } else {
        _waitForMainAndNavigate(navigate, retries: retries - 1);
      }
    });
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
    if (Get.isRegistered<AuthController>()) {
      AuthController.to.referralCode.value = code;
    } else {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('referral_code_temp', code);
      });
    }
  }

  static Future<void> handlePayload(String payload) async {
    if (payload.isEmpty) return;

    // Handle internal relative paths
    if (payload.startsWith('/')) {
      if (payload == '/quran_page' || payload == '/quran_list') {
        Get.toNamed(payload, arguments: {'slug': 'id'});
      } else if (payload.contains('?')) {
        final uri = Uri.tryParse(payload);
        if (uri != null) {
          Get.toNamed(uri.path, arguments: uri.queryParameters);
        } else {
          Get.toNamed(payload);
        }
      } else {
        Get.toNamed(payload);
      }
      return;
    }

    final uri = Uri.tryParse(payload);
    if (uri == null) return;

    // Handle deep links (custom scheme or web url)
    final service = DeepLinkService();
    if (uri.scheme == 'quranuna' ||
        uri.host == 'quran.titiktolak.com' ||
        uri.pathSegments.contains('api')) {
      service._processDeepLink(uri, isFromUserTap: true);
    } else if (uri.scheme == 'http' || uri.scheme == 'https') {
      // Handle normal web URLs
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  static String? extractPayload(Map<String, dynamic> data) {
    return data['url'] ??
        data['link'] ??
        (data['click_action'] != 'FLUTTER_NOTIFICATION_CLICK'
            ? data['click_action']
            : null);
  }
}
