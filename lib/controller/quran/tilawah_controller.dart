import 'dart:convert';
import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
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
        }
      });
    }
  }

  Future<void> fetchWeeklyStats() async {
    if (!Get.isRegistered<AuthController>() ||
        !AuthController.to.isLogin.value) {
      return;
    }
    isLoadingWeekly.value = true;
    try {
      final response = await Request().get(Url.readingHistoryWeekly);
      if (response.statusCode == 200) {
        weeklyStats.value = response.data['data'];
      }
    } catch (e) {
      print("Error loading weekly stats: $e");
    } finally {
      isLoadingWeekly.value = false;
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
      print("Error loading bookmarks from local storage: $e");
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
