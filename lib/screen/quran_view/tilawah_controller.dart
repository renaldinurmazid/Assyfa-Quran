import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/services/connectivity_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TilawahController extends GetxController {
  final bookmarks = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

  final weeklyStats = <String, dynamic>{}.obs;
  final isLoadingWeekly = false.obs;

  final List<String> slugs = [
    'per-ayat',
    'id',
    'id-tajwid',
    'kata-tajwid',
    'latin-tajwid',
    'md',
    'md-tajwid',
  ];

  final Map<String, String> slugNames = {
    'per-ayat': 'Per Ayat',
    'id': 'Indonesia',
    'id-tajwid': 'Indonesia Tajwid',
    'kata-tajwid': 'Per Kata Tajwid',
    'latin-tajwid': 'Latin Tajwid',
    'md': 'Madinah',
    'md-tajwid': 'Madinah Tajwid',
  };

  @override
  void onInit() {
    super.onInit();
    loadAllBookmarks();
    fetchWeeklyStats();

    if (Get.isRegistered<AuthController>()) {
      ever(AuthController.to.isLogin, (bool loggedIn) {
        if (loggedIn) {
          loadAllBookmarks();
          fetchWeeklyStats();
          // Trigger sync when user logs in
          _triggerSync();
        }
      });
    }

    // Listen to connectivity changes — when back online, sync and refresh
    if (Get.isRegistered<ConnectivityService>()) {
      ever(ConnectivityService.to.isOnline, (bool online) {
        if (online) {
          debugPrint('[TilawahController] Connection restored, refreshing stats...');
          _triggerSync();
          fetchWeeklyStats();
        }
      });

      // Also listen for sync completion to refresh stats
      ever(ConnectivityService.to.isSyncing, (bool syncing) {
        if (!syncing) {
          // Sync just completed, refresh stats to reflect synced data
          fetchWeeklyStats();
        }
      });
    }
  }

  /// Trigger the global connectivity service to sync pending history
  Future<void> _triggerSync() async {
    if (Get.isRegistered<ConnectivityService>()) {
      await ConnectivityService.to.syncPendingHistory();
    }
  }

  Future<void> fetchWeeklyStats() async {
    if (!Get.isRegistered<AuthController>() ||
        !AuthController.to.isLogin.value) {
      // Even if not logged in, show local-only stats
      await _loadLocalOnlyStats();
      return;
    }

    isLoadingWeekly.value = true;
    try {
      // Check connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      final bool isOnline = !connectivityResult.contains(ConnectivityResult.none);

      Map<String, dynamic> stats = {};

      if (isOnline) {
        try {
          final response = await Request().get(Url.readingHistoryWeekly);
          if (response.statusCode == 200) {
            stats = Map<String, dynamic>.from(response.data['data']);
          } else {
            stats = {
              'total_pages': 0,
              'summary': _generateEmptyWeeklySummary(),
            };
          }
        } catch (e) {
          debugPrint("[TilawahController] API fetch failed, using local data: $e");
          stats = {
            'total_pages': 0,
            'summary': _generateEmptyWeeklySummary(),
          };
        }
      } else {
        // Offline: start with empty base, merge local data
        stats = {
          'total_pages': 0,
          'summary': _generateEmptyWeeklySummary(),
        };
      }

      // Always merge with local unsynced data for accurate display
      await _mergeLocalStats(stats);
      weeklyStats.value = stats;
    } catch (e) {
      debugPrint("Error loading weekly stats: $e");
      final stats = {
        'total_pages': 0,
        'summary': _generateEmptyWeeklySummary(),
      };
      await _mergeLocalStats(stats);
      weeklyStats.value = stats;
    } finally {
      isLoadingWeekly.value = false;
    }
  }

  /// Load stats purely from local storage (for non-logged-in users or as fallback)
  Future<void> _loadLocalOnlyStats() async {
    isLoadingWeekly.value = true;
    try {
      final stats = {
        'total_pages': 0,
        'summary': _generateEmptyWeeklySummary(),
      };
      await _mergeLocalStats(stats);
      weeklyStats.value = stats;
    } catch (e) {
      debugPrint("Error loading local stats: $e");
    } finally {
      isLoadingWeekly.value = false;
    }
  }

  List<Map<String, dynamic>> _generateEmptyWeeklySummary() {
    final now = DateTime.now();
    final List<String> days = ['A', 'S', 'S', 'R', 'K', 'J', 'S'];
    final List<Map<String, dynamic>> summary = [];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      summary.add({
        'day': days[date.weekday % 7],
        'date': date.toIso8601String().split('T')[0],
        'total_pages': 0,
      });
    }
    
    // Sort summary to always be Sunday to Saturday order
    summary.sort((a, b) {
      final dateA = DateTime.parse(a['date']);
      final dateB = DateTime.parse(b['date']);
      return (dateA.weekday % 7).compareTo(dateB.weekday % 7);
    });
    
    return summary;
  }

  Future<void> _mergeLocalStats(Map<String, dynamic> stats) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? historyJson = prefs.getString('local_history');
      if (historyJson == null) return;

      final List<dynamic> localHistory = jsonDecode(historyJson);
      final summary = stats['summary'] as List;

      int localTotalAdded = 0;

      for (var entry in localHistory) {
        if (entry['is_synced'] == false || entry['is_synced'] == null) {
          final readDate = entry['read_date'];
          final pages = (entry['end_page'] - entry['start_page']).abs() + 1;

          for (var dayItem in summary) {
            if (dayItem['date'] == readDate) {
              dayItem['total_pages'] = (dayItem['total_pages'] ?? 0) + pages;
              localTotalAdded += pages as int;
              break;
            }
          }
        }
      }

      stats['total_pages'] = (stats['total_pages'] ?? 0) + localTotalAdded;
    } catch (e) {
      debugPrint("Error merging local stats: $e");
    }
  }

  Future<void> loadAllBookmarks() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? bookmarksJson = prefs.getString('local_bookmarks');
      if (bookmarksJson != null) {
        final List<dynamic> data = jsonDecode(bookmarksJson);
        bookmarks.value = data.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        bookmarks.clear();
      }
    } catch (e) {
      debugPrint("Error loading bookmarks from local storage: $e");
    } finally {
      isLoading.value = false;
    }
  }

  String getTimeAgo(dynamic timestamp) {
    if (timestamp == null) return 'Baru Saja';

    DateTime? date;
    if (timestamp is int) {
      date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    } else if (timestamp is String) {
      date = DateTime.tryParse(timestamp);
    }

    if (date == null) return 'Baru Saja';

    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Baru Saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit yang lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam yang lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari yang lalu';
    return '${date.day}/${date.month}/${date.year}';
  }
}
