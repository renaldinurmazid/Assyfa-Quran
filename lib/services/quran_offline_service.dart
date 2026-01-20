import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:quran_app/api/url.dart';
import 'package:quran_app/models/quran_page_model.dart';
import 'package:quran_app/services/notification_service.dart';

class QuranOfflineService {
  final Dio dio = Dio();

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<Directory> _getQuranDir(String type) async {
    final path = await _localPath;
    final dir = Directory(p.join(path, 'quran', type));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<Directory> _getImagesDir(String type) async {
    final path = await _localPath;
    final dir = Directory(p.join(path, 'quran', type, 'images'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<bool> isIndexDownloaded(String type) async {
    final dir = await _getQuranDir(type);
    final file = File(p.join(dir.path, 'index.json'));
    return await file.exists();
  }

  Future<dynamic> getIndex(String type) async {
    final dir = await _getQuranDir(type);
    final file = File(p.join(dir.path, 'index.json'));
    if (await file.exists()) {
      final content = await file.readAsString();
      return json.decode(content);
    }
    return null;
  }

  Future<int> getDownloadedPagesCount(String type) async {
    final dir = await _getQuranDir(type);
    final files = dir.listSync();
    int count = 0;
    for (var file in files) {
      if (file is File &&
          p.basename(file.path).startsWith('page_') &&
          file.path.endsWith('.json')) {
        count++;
      }
    }
    return count;
  }

  Future<void> downloadAll(
    String type,
    Function(int progress, int total) onProgress,
  ) async {
    try {
      final quranDir = await _getQuranDir(type);
      final imagesDir = await _getImagesDir(type);

      // 1. Download Index
      final indexUrl = '${Url.baseUrl}${Url.quranOfflineIndex}?qurantype=$type';
      final indexResponse = await dio.get(indexUrl);
      if (indexResponse.statusCode == 200) {
        final indexFile = File(p.join(quranDir.path, 'index.json'));
        await indexFile.writeAsString(json.encode(indexResponse.data));
      } else {
        throw Exception('Failed to download index');
      }

      final indexData = indexResponse.data;
      final totalPages = indexData['total_pages'] ?? 604;

      // 2. Download Pages
      for (int i = 1; i <= totalPages; i++) {
        final pageUrl =
            '${Url.baseUrl}${Url.quranOfflinePage}/$i?qurantype=$type';
        final pageResponse = await dio.get(pageUrl);

        if (pageResponse.statusCode == 200) {
          final pageData = pageResponse.data;

          // Save Page JSON
          final pageFile = File(p.join(quranDir.path, 'page_$i.json'));
          await pageFile.writeAsString(json.encode(pageData));

          // Download Image
          final imageUrl = pageData['image_path'];
          final extension = p.extension(imageUrl).split('?').first;
          final imageFile = File(p.join(imagesDir.path, 'page_$i$extension'));

          await dio.download(imageUrl, imageFile.path);

          // Update progress
          onProgress(i, totalPages);
          await NotificationService.showProgressNotification(
            i,
            totalPages,
            'Downloading Quran $type',
          );
        }
      }

      await NotificationService.showCompleteNotification(
        'Download Selesai',
        'Seluruh halaman Quran $type telah diunduh.',
      );
    } catch (e) {
      print('Download error: $e');
      await NotificationService.showCompleteNotification(
        'Download Gagal',
        'Terjadi kesalahan saat mengunduh Quran.',
      );
    }
  }

  Future<Datum?> getPageData(String type, int pageNumber) async {
    final dir = await _getQuranDir(type);
    final file = File(p.join(dir.path, 'page_$pageNumber.json'));
    if (await file.exists()) {
      final content = await file.readAsString();
      final Map<String, dynamic> data = json.decode(content);

      // Update image_path to local path
      final imagesDir = await _getImagesDir(type);
      final originalPath = data['image_path'] as String;
      final extension = p.extension(originalPath).split('?').first;
      final localImagePath = p.join(
        imagesDir.path,
        'page_$pageNumber$extension',
      );

      // Mapping offline data to Datum model
      final List<dynamic> surahsJson = data['surahs'] ?? [];
      final List<dynamic> ayahsJson = data['ayahs'] ?? [];

      return Datum(
        id: pageNumber,
        pageNumber: pageNumber,
        imagePath: localImagePath,
        juzNumbers: ayahsJson
            .map((e) => e['juz_number'] as int)
            .toSet()
            .toList(),
        isTargetPage: false,
        ayahs: ayahsJson.map((a) {
          final surahData = surahsJson.firstWhere(
            (s) => s['id'] == a['surah_id'],
            orElse: () => null,
          );
          return AyahElement(
            id: a['id'] ?? 0,
            ayahId: 0,
            quranPageId: pageNumber,
            blocks: (a['blocks'] as List? ?? [])
                .map(
                  (b) => Block(
                    id: b['id'] ?? 0,
                    ayahPageMapId: 0,
                    blockNumber: b['block_number'] ?? 0,
                    top: b['top'] ?? 0,
                    left: b['left'] ?? 0,
                    width: b['width'] ?? 0,
                    height: b['height'] ?? 0,
                  ),
                )
                .toList(),
            ayah: AyahAyah(
              id: 0,
              surahId: a['surah_id'] ?? 0,
              ayahNumber: a['ayah_number'] ?? 0,
              juzNumber: a['juz_number'] ?? 0,
              audio: [],
              surah: surahData != null
                  ? Surah(
                      id: surahData['id'],
                      name: surahData['name'],
                      totalAyah: surahData['total_ayah'],
                    )
                  : null,
            ),
          );
        }).toList(),
      );
    }
    return null;
  }
}
