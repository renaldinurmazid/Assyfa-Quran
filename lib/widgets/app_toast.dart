import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';
import 'package:quran_app/theme/font.dart';

class AppToast {
  // Cache to track recently shown messages to prevent duplicates
  static final Map<String, DateTime> _recentMessages = {};
  static const Duration _throttleDuration = Duration(seconds: 5);
  static const Duration _connectionErrorThrottleDuration = Duration(seconds: 10);
  static DateTime? _lastConnectionErrorTime;

  static Future<void> show({
    BuildContext? context,
    required String message,
    String? title,
    ToastificationType type = ToastificationType.success,
    Duration duration = const Duration(seconds: 3),
  }) async {
    final effectiveContext = context ?? Get.context;
    if (effectiveContext == null) return;

    final now = DateTime.now();
    final lowerMessage = message.toLowerCase();
    final isConnectionError = lowerMessage.contains('koneksi') || 
                             lowerMessage.contains('internet') || 
                             lowerMessage.contains('terhubung') ||
                             lowerMessage.contains('timeout');

    // If it's an error, check for connectivity-based suppression
    if (type == ToastificationType.error || type == ToastificationType.warning) {
      final connectivityResult = await (Connectivity().checkConnectivity());
      final isOffline = connectivityResult.contains(ConnectivityResult.none);

      if (isOffline) {
        // If we are offline and this is a connection-related error
        if (isConnectionError) {
          if (_lastConnectionErrorTime != null && 
              now.difference(_lastConnectionErrorTime!) < _connectionErrorThrottleDuration) {
            return;
          }
          _lastConnectionErrorTime = now;
        } else {
          // If we are offline but this is a "generic" error (e.g. from a catch block)
          // Suppress it if a connection error was recently shown or if we are clearly offline
          if (_lastConnectionErrorTime != null && 
              now.difference(_lastConnectionErrorTime!) < _connectionErrorThrottleDuration) {
            return;
          }
        }
      } else if (isConnectionError) {
        // Even if not strictly "offline" (maybe just a timeout), still throttle connection errors
        if (_lastConnectionErrorTime != null && 
            now.difference(_lastConnectionErrorTime!) < _connectionErrorThrottleDuration) {
          return;
        }
        _lastConnectionErrorTime = now;
      }
    }

    // Throttling logic for identical messages
    final cacheKey = '${type.toString()}_$message';
    if (_recentMessages.containsKey(cacheKey)) {
      final lastShown = _recentMessages[cacheKey]!;
      if (now.difference(lastShown) < _throttleDuration) {
        return;
      }
    }
    _recentMessages[cacheKey] = now;

    // Clean up old messages from cache periodically
    if (_recentMessages.length > 50) {
      _recentMessages.removeWhere((key, time) => now.difference(time) > _throttleDuration * 2);
    }

    toastification.show(
      context: effectiveContext,
      type: type,
      style: ToastificationStyle.flat,
      autoCloseDuration: duration,
      title: title != null
          ? Text(title, style: pBold14)
          : Text(
              type == ToastificationType.success
                  ? 'Berhasil'
                  : type == ToastificationType.error
                  ? 'Error'
                  : (type == ToastificationType.warning
                        ? 'Peringatan'
                        : 'Informasi'),
              style: pBold14,
            ),
      description: Text(message, style: pRegular12),
      alignment: Alignment.topCenter,
      direction: TextDirection.ltr,
      animationDuration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: BorderRadius.circular(12),
      showProgressBar: true,
      closeButtonShowType: CloseButtonShowType.none,
      closeOnClick: true,
      pauseOnHover: true,
      dragToClose: true,
    );
  }

  static Future<void> success({
    BuildContext? context,
    required String message,
    String? title,
  }) async {
    await show(
      context: context,
      message: message,
      title: title,
      type: ToastificationType.success,
    );
  }

  static Future<void> error({
    BuildContext? context,
    required String message,
    String? title,
  }) async {
    await show(
      context: context,
      message: message,
      title: title,
      type: ToastificationType.error,
    );
  }

  static Future<void> warning({
    BuildContext? context,
    required String message,
    String? title,
  }) async {
    await show(
      context: context,
      message: message,
      title: title,
      type: ToastificationType.warning,
    );
  }

  static Future<void> info({
    BuildContext? context,
    required String message,
    String? title,
  }) async {
    await show(
      context: context,
      message: message,
      title: title,
      type: ToastificationType.info,
    );
  }
}
