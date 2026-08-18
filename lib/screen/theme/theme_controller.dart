import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/widgets/app_toast.dart';

class ThemeController extends GetxController {
  static ThemeController get to => Get.find();

  final _isDarkMode = true.obs;
  bool get isDarkMode => _isDarkMode.value;

  final backgrounds = <Map<String, dynamic>>[].obs;
  final isLoadingBackgrounds = false.obs;

  ThemeMode get themeMode =>
      _isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
    fetchBackgrounds();
  }

  Future<void> fetchBackgrounds() async {
    try {
      isLoadingBackgrounds.value = true;
      final response = await Request().get('/api/master-background');
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        backgrounds.assignAll(List<Map<String, dynamic>>.from(response.data['data']));
      }
    } catch (e) {
      debugPrint('Error fetching backgrounds: $e');
    } finally {
      isLoadingBackgrounds.value = false;
    }
  }

  Future<void> selectBackground(int id) async {
    try {
      final response = await Request().post(
        '/api/master-background/select',
        data: {'background_id': id},
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        // Update local selection state
        for (var bg in backgrounds) {
          bg['is_selected'] = bg['id'] == id;
        }
        backgrounds.refresh();

        // Update AuthController userData to reflect the change globally
        if (Get.isRegistered<AuthController>()) {
          final authController = AuthController.to;
          final updatedData = Map<String, dynamic>.from(authController.userData);
          updatedData['selected_background_path_url'] =
              response.data['data']['selected_background_path_url'];
          authController.userData.value = updatedData;
          
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_data', jsonEncode(updatedData));
        }

        AppToast.success(message: 'Background berhasil diperbarui');
      }
    } catch (e) {
      debugPrint('Error selecting background: $e');
      AppToast.error(message: 'Gagal memperbarui background');
    }
  }

  void toggleTheme() {
    _isDarkMode.value = !_isDarkMode.value;
    Get.changeThemeMode(themeMode);
    _saveTheme(_isDarkMode.value);
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode.value = prefs.getBool('isDarkMode') ?? false;
    // We don't call Get.changeThemeMode here because the initial theme
    // is set in GetMaterialApp via ThemeController.to.themeMode
  }

  Future<void> _saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }
}
