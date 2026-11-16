import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/models/popup_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PopupController extends GetxController {
  static PopupController get to => Get.find<PopupController>();

  static const _deviceIdKey = 'popup_device_id';

  final popups = <PopupData>[].obs;
  final isLoading = false.obs;
  final _shownPopupIds = <int>{};
  String? _cachedDeviceId;

  /// Stable id that tells the server which popups this device has already seen.
  ///
  /// Guests have nothing else to be recognised by. Android's `androidInfo.id` is the *firmware build*
  /// id, identical on every phone with the same build, so it must not be used here: one person
  /// dismissing a popup would hide it for everybody. A random id kept in preferences is unique.
  Future<String> _getDeviceId() async {
    if (_cachedDeviceId != null) return _cachedDeviceId!;

    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_deviceIdKey);

    if (id == null) {
      try {
        // iOS: keep the vendor id the server may already know.
        if (Platform.isIOS) {
          id = (await DeviceInfoPlugin().iosInfo).identifierForVendor;
        }
      } catch (e) {
        debugPrint('Error getting device info: $e');
      }
      id ??= _randomId();
      await prefs.setString(_deviceIdKey, id);
    }

    return _cachedDeviceId = id;
  }

  static String _randomId() {
    final random = Random.secure();
    return List.generate(
      32,
      (_) => random.nextInt(16).toRadixString(16),
    ).join();
  }

  /// Fetch the popups this visitor may see now.
  /// The server applies schedule and frequency, for guests (by device id) and users (by token).
  Future<void> fetchPopups() async {
    isLoading.value = true;
    try {
      final isLogin = AuthController.to.isLogin.value;
      final response = await Request().get(
        Url.popups,
        queryParameters: {'device_id': await _getDeviceId()},
        useToken: isLogin,
      );

      if (response.statusCode == 200) {
        final popupResponse = PopupResponse.fromJson(response.data);
        popups.assignAll(popupResponse.data);
      }
    } catch (e) {
      // Silently fail — popup is non-critical
      debugPrint('Error fetching popups: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Record that the popup was shown.
  Future<void> recordView(int popupId) => _track(Url.popupView(popupId));

  /// Record that the visitor closed the popup.
  Future<void> recordDismiss(int popupId) => _track(Url.popupDismiss(popupId));

  /// Record that the visitor tapped the call-to-action.
  Future<void> recordClick(int popupId) => _track(Url.popupClick(popupId));

  /// Tracking is open to guests too: they are identified by the device id.
  Future<void> _track(String url) async {
    try {
      await Request().post(
        url,
        data: {'device_id': await _getDeviceId()},
        useToken: AuthController.to.isLogin.value,
      );
    } catch (e) {
      debugPrint('Error recording popup event: $e');
    }
  }

  /// Get the next popup to show (highest priority first, not yet shown in this session)
  PopupData? getNextPopup() {
    for (var popup in popups) {
      if (!_shownPopupIds.contains(popup.id)) {
        return popup;
      }
    }
    return null;
  }

  /// Mark a popup as shown in this session
  void markAsShown(int popupId) {
    _shownPopupIds.add(popupId);
  }

  /// Remove a popup from the list (after dismiss)
  void removePopup(int popupId) {
    popups.removeWhere((p) => p.id == popupId);
    _shownPopupIds.add(popupId);
  }
}
