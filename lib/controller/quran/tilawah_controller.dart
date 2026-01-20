import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';

class TilawahController extends GetxController {
  final bookmarks = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

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
  }

  Future<void> loadAllBookmarks() async {
    isLoading.value = true;
    try {
      final response = await Request().get(Url.listUserMarkers);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        bookmarks.value = data
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    } catch (e) {
      print("Error loading bookmarks from API: $e");
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
