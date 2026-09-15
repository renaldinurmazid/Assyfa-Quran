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

  /// Prevents navigating to the exact same deep link concurrently within a short window.
  Uri? _lastProcessedUri;
  DateTime? _lastProcessedTime;

  /// Indicates if there is a deep link waiting to be processed.
  bool get hasPendingDeepLink => _pendingUri != null;

  void init() {
    _appLinks = AppLinks();
    _handleIncomingLinks();
    _handleInitialLink();
  }

  /// Call this once the main screen has finished loading,
  /// so that deferred deep links can be processed.
  void markReady() {
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 350), () {
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

    final now = DateTime.now();
    // Deduplicate: avoid processing the exact same URI twice within 2 seconds
    // (handles initial link + stream firing concurrently on launch).
    // If more than 2 seconds have passed, treat it as a fresh user intent.
    if (!isFromUserTap &&
        _lastProcessedUri != null &&
        _lastProcessedUri.toString() == uri.toString() &&
        _lastProcessedTime != null &&
        now.difference(_lastProcessedTime!) < const Duration(seconds: 2)) {
      print('DeepLink: Already processed within 2s – skipping duplicate');
      return;
    }

    _lastProcessedUri = uri;
    _lastProcessedTime = now;

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
      // If a popup dialog or bottom sheet is open, close it first so it doesn't obstruct navigation
      if (Get.isDialogOpen == true) {
        Get.back();
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
    String resource = uri.host.toLowerCase();
    List<String> segments = uri.pathSegments;

    // Support URLs with empty host like quranuna:///event/12
    if (resource.isEmpty && segments.isNotEmpty) {
      resource = segments.first.toLowerCase();
      segments = segments.skip(1).toList();
    }

    switch (resource) {
      // quranuna://group/CODE
      case 'group':
      case 'groups':
      case 'g':
        final code = segments.isNotEmpty
            ? segments.first
            : (uri.queryParameters['code'] ?? uri.queryParameters['group_code']);
        if (code != null && code.isNotEmpty) {
          _navigateToGroupByCode(code);
        }
        break;

      // quranuna://campaign/ID or quranuna://campaign/ID/REFERRAL_CODE
      case 'campaign':
      case 'campaigns':
      case 'charity':
      case 'c':
        int? campaignId =
            segments.isNotEmpty ? int.tryParse(segments.first) : null;
        campaignId ??= int.tryParse(uri.queryParameters['id'] ?? '') ??
            int.tryParse(uri.queryParameters['campaign_id'] ?? '');

        if (campaignId != null) {
          if (segments.length > 1) {
            _saveReferralCode(segments[1]);
          }
          _navigateToCampaign(campaignId);
        }
        break;

      // quranuna://mosque-charity/ID or quranuna://mosque/ID
      case 'mosque-charity':
      case 'mosque':
      case 'mosques':
      case 'm':
        int? mosqueId =
            segments.isNotEmpty ? int.tryParse(segments.first) : null;
        mosqueId ??= int.tryParse(uri.queryParameters['id'] ?? '') ??
            int.tryParse(uri.queryParameters['mosque_id'] ?? '');

        if (mosqueId != null) {
          if (segments.length > 1) {
            _saveReferralCode(segments[1]);
          }
          _navigateToMosqueCharity(mosqueId);
        }
        break;

      // quranuna://blog/SLUG
      case 'blog':
      case 'blogs':
      case 'b':
        final slug = segments.isNotEmpty
            ? segments.first
            : (uri.queryParameters['slug'] ?? uri.queryParameters['id']);
        if (slug != null && slug.isNotEmpty) {
          _navigateToBlog(slug);
        }
        break;

      // quranuna://event/SLUG_OR_ID
      case 'event':
      case 'events':
      case 'e':
        final identifier = segments.isNotEmpty
            ? segments.first
            : (uri.queryParameters['slug'] ??
                uri.queryParameters['id'] ??
                uri.queryParameters['event_id']);

        if (identifier != null && identifier.isNotEmpty) {
          final asInt = int.tryParse(identifier);
          _navigateToEvent(asInt ?? identifier);
        }
        break;

      default:
        print('DeepLink: Unrecognized custom scheme host: $resource');
        break;
    }
  }

  // ──────────────────────────────────────────────────
  // Web URL Handler
  // ──────────────────────────────────────────────────

  bool _handleWebUrl(Uri uri) {
    // Filter out common API or public prefixes
    final segments = uri.pathSegments
        .where((s) => s.isNotEmpty && s != 'api' && s != 'public')
        .toList();

    if (segments.isEmpty) return false;

    final resource = segments.first.toLowerCase();

    // ── Group: /g/{code} or /group/{code} or /groups/{code} ──
    if (resource == 'g' || resource == 'group' || resource == 'groups') {
      final code = segments.length > 1
          ? segments[1]
          : (uri.queryParameters['code'] ?? uri.queryParameters['group_code']);
      if (code != null && code.isNotEmpty) {
        _navigateToGroupByCode(code);
        return true;
      }
    }

    // ── Campaign: /c/{id} or /campaign/{id} or /campaigns/{id} ──
    if (resource == 'c' || resource == 'campaign' || resource == 'campaigns') {
      int? campaignId = segments.length > 1 ? int.tryParse(segments[1]) : null;
      campaignId ??= int.tryParse(uri.queryParameters['id'] ?? '') ??
          int.tryParse(uri.queryParameters['campaign_id'] ?? '');

      if (campaignId != null) {
        _navigateToCampaign(campaignId);
        return true;
      }
    }

    // ── Mosque Charity: /m/{id} or /mosque/{id} or /mosques/{id} or /mosque-charity/{id} ──
    if (resource == 'm' ||
        resource == 'mosque' ||
        resource == 'mosques' ||
        resource == 'mosque-charity') {
      int? mosqueId = segments.length > 1 ? int.tryParse(segments[1]) : null;
      mosqueId ??= int.tryParse(uri.queryParameters['id'] ?? '') ??
          int.tryParse(uri.queryParameters['mosque_id'] ?? '');

      if (mosqueId != null) {
        _navigateToMosqueCharity(mosqueId);
        return true;
      }
    }

    // ── Blog: /b/{slug} or /blog/{slug} or /blogs/{slug} ──
    if (resource == 'b' || resource == 'blog' || resource == 'blogs') {
      final slug = segments.length > 1
          ? segments[1]
          : (uri.queryParameters['slug'] ?? uri.queryParameters['id']);
      if (slug != null && slug.isNotEmpty) {
        _navigateToBlog(slug);
        return true;
      }
    }

    // ── Event: /e/{slug_or_id} or /event/{slug_or_id} or /events/{slug_or_id} ──
    if (resource == 'e' || resource == 'event' || resource == 'events') {
      final identifier = segments.length > 1
          ? segments[1]
          : (uri.queryParameters['slug'] ??
              uri.queryParameters['id'] ??
              uri.queryParameters['event_id']);

      if (identifier != null && identifier.isNotEmpty) {
        final asInt = int.tryParse(identifier);
        _navigateToEvent(asInt ?? identifier);
        return true;
      }
    }

    return false;
  }

  // ════════════════════════════════════════════════════
  // Navigation helpers
  // ════════════════════════════════════════════════════

  /// Navigate to campaign (charity) show screen.
  void _navigateToCampaign(int campaignId) {
    print(
      'DeepLink: Navigating to campaign $campaignId (current route: ${Get.currentRoute})',
    );
    _ensureMainAndNavigate(() {
      Get.toNamed(
        Routes.charityShow,
        arguments: {'id': campaignId},
        preventDuplicates: false,
      );
    });
  }

  /// Navigate to mosque charity show screen.
  void _navigateToMosqueCharity(int mosqueId) {
    print(
      'DeepLink: Navigating to mosque charity $mosqueId (current route: ${Get.currentRoute})',
    );
    _ensureMainAndNavigate(() {
      Get.toNamed(
        Routes.mosqueCharityShow,
        arguments: {'id': mosqueId},
        preventDuplicates: false,
      );
    });
  }

  /// Navigate to group show screen by invite code.
  void _navigateToGroupByCode(String code) {
    print(
      'DeepLink: Navigating to group by code "$code" (current route: ${Get.currentRoute})',
    );
    final asInt = int.tryParse(code);
    _ensureMainAndNavigate(() {
      Get.toNamed(
        Routes.showGroup,
        arguments: asInt ?? code,
        preventDuplicates: false,
      );
    });
  }

  /// Navigate to blog detail screen.
  void _navigateToBlog(String slug) {
    print(
      'DeepLink: Navigating to blog "$slug" (current route: ${Get.currentRoute})',
    );
    _ensureMainAndNavigate(() {
      Get.toNamed(
        Routes.showBlog,
        arguments: slug,
        preventDuplicates: false,
      );
    });
  }

  /// Navigate to event detail screen by ID or slug.
  void _navigateToEvent(dynamic eventIdentifier) {
    print(
      'DeepLink: Navigating to event $eventIdentifier (current route: ${Get.currentRoute})',
    );
    _ensureMainAndNavigate(() {
      Get.toNamed(
        Routes.showEvent,
        arguments: eventIdentifier,
        preventDuplicates: false,
      );
    });
  }

  /// Generate universal share link for event using slug or ID
  static String createEventShareLink(dynamic slugOrId) {
    return 'https://quran.titiktolak.com/api/e/$slugOrId';
  }

  /// Ensures the main screen is in the navigation stack before navigating
  /// to the target route. If the current route is splash or empty (app just
  /// started), waits until the main route is active.
  void _ensureMainAndNavigate(VoidCallback navigate) {
    final currentRoute = Get.currentRoute;

    // If on splash screen or unmounted route, wait until main screen is active
    if (currentRoute == Routes.splash ||
        currentRoute == '/' ||
        currentRoute.isEmpty) {
      print('DeepLink: Waiting for main screen (current: "$currentRoute")');
      _waitForMainAndNavigate(navigate, retries: 25);
      return;
    }

    // If on main screen or any other screen, navigate immediately
    navigate();
  }

  /// Polls until [Get.currentRoute] is [Routes.main], then calls [navigate].
  /// Gives up after [retries] attempts (each 200ms apart = up to 5s).
  void _waitForMainAndNavigate(VoidCallback navigate, {required int retries}) {
    if (retries <= 0) {
      print('DeepLink: Waiting finished – navigating now');
      navigate();
      return;
    }

    Future.delayed(const Duration(milliseconds: 200), () {
      final currentRoute = Get.currentRoute;
      if (currentRoute == Routes.main) {
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

    // 1. Direct App Route match (e.g. '/quran_page', '/notification', '/prayer_time_detail')
    final directRoutes = [
      Routes.dzikir,
      Routes.listDoa,
      Routes.prayerTimeDetail,
      Routes.quranList,
      Routes.charity,
      Routes.groupNgaji,
      Routes.eventRegistrationList,
      Routes.notification,
      Routes.theme,
      Routes.hajiAndUmrah,
      Routes.quranMp3,
      Routes.findMosque,
      Routes.chatBot,
      Routes.showEvent,
    ];

    if (directRoutes.contains(payload)) {
      Get.toNamed(payload, preventDuplicates: false);
      return;
    }

    if (payload == '/quran_page' || payload == '/quran_list') {
      Get.toNamed(payload, arguments: {'slug': 'id'}, preventDuplicates: false);
      return;
    }

    // 2. Relative paths starting with '/' that represent web or deep link paths (e.g. '/e/1', '/events/1', '/c/5')
    if (payload.startsWith('/')) {
      final syntheticUri =
          Uri.tryParse('https://quran.titiktolak.com$payload');
      if (syntheticUri != null) {
        final service = DeepLinkService();
        bool handled = service._handleWebUrl(syntheticUri);
        if (handled) return;
      }

      // Fallback for query parameters on routes
      if (payload.contains('?')) {
        final uri = Uri.tryParse(payload);
        if (uri != null) {
          Get.toNamed(
            uri.path,
            arguments: uri.queryParameters,
            preventDuplicates: false,
          );
        } else {
          Get.toNamed(payload, preventDuplicates: false);
        }
      } else {
        Get.toNamed(payload, preventDuplicates: false);
      }
      return;
    }

    // 3. Full URI (custom scheme or web URL)
    final uri = Uri.tryParse(payload);
    if (uri == null) return;

    final service = DeepLinkService();
    if (uri.scheme == 'quranuna' ||
        uri.host == 'quran.titiktolak.com' ||
        uri.pathSegments.contains('api')) {
      service._processDeepLink(uri, isFromUserTap: true);
    } else if (uri.scheme == 'http' || uri.scheme == 'https') {
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
