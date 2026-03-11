import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/models/popup_model.dart';

class PopupController extends GetxController {
  static PopupController get to => Get.find<PopupController>();

  final popups = <PopupData>[].obs;
  final isLoading = false.obs;
  final _shownPopupIds = <int>{};

  /// Fetch active popups from API.
  /// If user is logged in, server automatically filters show_once popups.
  Future<void> fetchPopups() async {
    isLoading.value = true;
    try {
      final isLogin = AuthController.to.isLogin.value;
      final response = await Request().get(Url.popups, useToken: isLogin);

      if (response.statusCode == 200) {
        final popupResponse = PopupResponse.fromJson(response.data);
        popups.assignAll(popupResponse.data);
      }
    } catch (e) {
      // Silently fail — popup is non-critical
      print('Error fetching popups: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Record that user has viewed a popup
  Future<void> recordView(int popupId) async {
    if (!AuthController.to.isLogin.value) return;
    try {
      await Request().post(Url.popupView(popupId), data: {}, useToken: true);
    } catch (e) {
      print('Error recording popup view: $e');
    }
  }

  /// Record that user has dismissed a popup
  Future<void> recordDismiss(int popupId) async {
    if (!AuthController.to.isLogin.value) return;
    try {
      await Request().post(Url.popupDismiss(popupId), data: {}, useToken: true);
    } catch (e) {
      print('Error recording popup dismiss: $e');
    }
  }

  /// Record that user has clicked CTA button
  Future<void> recordClick(int popupId) async {
    if (!AuthController.to.isLogin.value) return;
    try {
      await Request().post(Url.popupClick(popupId), data: {}, useToken: true);
    } catch (e) {
      print('Error recording popup click: $e');
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
