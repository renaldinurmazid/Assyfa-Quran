import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/controller/home_screen_controller.dart';
import 'package:quran_app/controller/quran/tilawah_controller.dart';
import 'package:quran_app/widgets/app_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global service that monitors connectivity changes and automatically
/// syncs pending local reading history to the API when connection is restored.
class ConnectivityService extends GetxService {
  static ConnectivityService get to => Get.find<ConnectivityService>();

  final isOnline = true.obs;
  final isSyncing = false.obs;
  final pendingCount = 0.obs;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  bool _wasOffline = false;

  @override
  void onInit() {
    super.onInit();
    _checkInitialConnection();
    _listenToConnectivity();
    _updatePendingCount();
  }

  @override
  void onClose() {
    _connectivitySub?.cancel();
    super.onClose();
  }

  /// Check current connectivity on init
  Future<void> _checkInitialConnection() async {
    final result = await Connectivity().checkConnectivity();
    final online = !result.contains(ConnectivityResult.none);
    isOnline.value = online;
    _wasOffline = !online;

    // If online on init, try syncing any pending data
    if (online) {
      await syncPendingHistory();
    }
  }

  /// Listen for connectivity changes
  void _listenToConnectivity() {
    _connectivitySub = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> results) async {
        final online = !results.contains(ConnectivityResult.none);
        isOnline.value = online;

        if (online && _wasOffline) {
          debugPrint(
            '[ConnectivityService] Connection restored! Syncing pending history...',
          );
          AppToast.success(
            message: 'Koneksi internet kembali terhubung',
            title: 'Koneksi Pulih',
          );
          // Small delay to let the connection stabilize
          await Future.delayed(const Duration(seconds: 2));
          await syncPendingHistory();
        } else if (!online && !_wasOffline) {
          AppToast.warning(
            message: 'Koneksi internet terputus. Beberapa fitur mungkin tidak tersedia.',
            title: 'Offline',
          );
        }

        _wasOffline = !online;
      },
    );
  }

  /// Update the count of pending (unsynced) history entries
  Future<void> _updatePendingCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? historyJson = prefs.getString('local_history');
      if (historyJson == null) {
        pendingCount.value = 0;
        return;
      }

      final List<dynamic> localHistory = jsonDecode(historyJson);
      int count = 0;
      for (var entry in localHistory) {
        if (entry['is_synced'] == false || entry['is_synced'] == null) {
          count++;
        }
      }
      pendingCount.value = count;
    } catch (e) {
      debugPrint('[ConnectivityService] Error updating pending count: $e');
    }
  }

  /// Sync all pending (unsynced) local history entries to the API.
  /// Called automatically when connectivity is restored, or can be called manually.
  Future<void> syncPendingHistory() async {
    // Guard: must be logged in
    if (!Get.isRegistered<AuthController>() ||
        !AuthController.to.isLogin.value) {
      debugPrint('[ConnectivityService] Sync skipped: User not logged in.');
      return;
    }

    // Guard: must be online
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      debugPrint('[ConnectivityService] Sync skipped: No internet connection.');
      return;
    }

    // Guard: prevent concurrent syncs
    if (isSyncing.value) {
      debugPrint('[ConnectivityService] Sync skipped: Already syncing.');
      return;
    }

    isSyncing.value = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? historyJson = prefs.getString('local_history');
      if (historyJson == null) {
        debugPrint('[ConnectivityService] No local history to sync.');
        return;
      }

      List<dynamic> localHistory = jsonDecode(historyJson);
      bool anyChange = false;
      int syncedCount = 0;
      int failedCount = 0;

      for (var i = 0; i < localHistory.length; i++) {
        var entry = localHistory[i];

        // Only sync entries that are not yet synced
        if (entry['is_synced'] == false || entry['is_synced'] == null) {
          try {
            debugPrint('[ConnectivityService] Syncing entry ${entry['id']} (page ${entry['start_page']}-${entry['end_page']})...');

            final response = await Request().post(
              Url.readingHistory,
              data: {
                'surah_id': entry['surah_id'],
                'start_page': entry['start_page'],
                'end_page': entry['end_page'],
                'duration_seconds': entry['duration_seconds'],
                'quran_type_slug': entry['quran_type_slug'],
              },
            );

            if (response.statusCode == 200 || response.statusCode == 201) {
              entry['is_synced'] = true;
              entry['synced_at'] = DateTime.now().toIso8601String();
              anyChange = true;
              syncedCount++;
            } else {
              failedCount++;
            }
          } catch (e) {
            debugPrint('[ConnectivityService] Failed to sync entry ${entry['id']}: $e');
            failedCount++;
            // If we get a network error, stop trying (connection might be lost again)
            if (e.toString().contains('SocketException') ||
                e.toString().contains('Connection refused')) {
              debugPrint('[ConnectivityService] Network error detected, stopping sync.');
              break;
            }
          }
        }
      }

      if (anyChange) {
        // Remove synced entries from local storage — only keep unsynced ones
        localHistory.removeWhere((entry) => entry['is_synced'] == true);

        if (localHistory.isEmpty) {
          await prefs.remove('local_history');
        } else {
          await prefs.setString('local_history', jsonEncode(localHistory));
        }

        debugPrint('[ConnectivityService] Sync complete: $syncedCount synced, $failedCount failed. ${localHistory.length} entries remaining locally.');

        // Refresh dependent controllers
        _refreshControllers();
      }

      await _updatePendingCount();
    } catch (e) {
      debugPrint('[ConnectivityService] Error in syncPendingHistory: $e');
    } finally {
      isSyncing.value = false;
    }
  }

  /// Refresh all dependent controllers after sync
  void _refreshControllers() {
    // Refresh HomeScreenController stats
    if (Get.isRegistered<HomeScreenController>()) {
      try {
        final homeController = Get.find<HomeScreenController>();
        homeController.fetchWeeklyStats();
        homeController.fetchReadingHistoryTotal();
      } catch (e) {
        debugPrint('[ConnectivityService] Error refreshing HomeScreenController: $e');
      }
    }

    // Refresh TilawahController stats
    if (Get.isRegistered<TilawahController>()) {
      try {
        final tilawahController = Get.find<TilawahController>();
        tilawahController.fetchWeeklyStats();
      } catch (e) {
        debugPrint('[ConnectivityService] Error refreshing TilawahController: $e');
      }
    }
  }
}
