import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:quran_app/controller/home_screen_controller.dart';
import 'package:quran_app/widgets/app_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/models/dropdown_juz_model.dart';
import 'package:quran_app/models/dropdown_surah_model.dart';
import 'package:quran_app/models/quran_page_model.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/services/quran_offline_service.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';

enum QuranPaginationMode { browse, page }

class QuranPageScreenController extends GetxController {
  /* =======================
   * CORE STATE
   * ======================= */
  final mode = QuranPaginationMode.browse.obs;
  final dataPage = <Datum>[].obs;
  final startReadingPage = RxnInt();
  var readingStartTime = DateTime.now();

  final isLoading = false.obs;
  final isLastPage = false.obs;
  final isFocus = true.obs;

  final currentPageIndex = 0.obs;
  final page = 1.obs;

  final prevPageNumber = Rxn<dynamic>();
  final nextPageNumber = Rxn<int>();

  final currentSlug = ''.obs;

  final viewportWidth = 0.0.obs;
  final viewportHeight = 0.0.obs;

  final pageController = PageController();

  /* =======================
   * OFFLINE STATE
   * ======================= */
  final offlineService = QuranOfflineService();
  final isOfflineMode = false.obs;
  final isDownloading = false.obs;
  final isPaused = false.obs;
  final downloadProgress = 0.obs;
  final totalPagesToDownload = 0.obs;
  final hasShownDownloadPrompt = false.obs;

  /* =======================
   * SEARCH / FILTER STATE
   * ======================= */
  final surahId = 0.obs;
  final juzId = 0.obs;
  final selectedPage = 1.obs;
  final selectedSurahName = ''.obs;

  final searchAyahController = TextEditingController();
  final searchSurahController = TextEditingController();
  final searchAnchorController = SearchController();

  final dropdownSurah = <DropdownSurah>[].obs;
  final dropdownJuz = <DropdownJuz>[].obs;

  final isDialogLoading = false.obs;
  final tabIsAyah = true.obs;
  final tabIsSurat = true.obs;
  final searchAyahPageController = PageController();
  final searchSuratPageController = PageController();
  final listPages = <int>[].obs;
  Timer? _searchTimer;

  /* =======================
   * AUDIO
   * ======================= */
  final audioPlayer = AudioPlayer();
  final isPlaying = false.obs;
  final playingAyahId = 0.obs;

  final reciters = const [
    {"code": "01", "name": "Abdullah Al-Juhany"},
    {"code": "02", "name": "Abdul Muhsin Al-Qasim"},
    {"code": "03", "name": "Abdurrahman As-Sudais"},
    {"code": "04", "name": "Ibrahim Al-Dossari"},
    {"code": "05", "name": "Misyari Rasyid Al-Afasi"},
    {"code": "06", "name": "Yasser Al-Dosari"},
  ];

  final selectedReciter = '01'.obs;
  final isLandscape = false.obs;

  /* =======================
   * BOOKMARKS
   * ======================= */
  final isBookmarkVisible = false.obs;
  final bookmarks = <Map<String, dynamic>>[].obs;
  final apiMarkers = <Map<String, dynamic>>[].obs;
  final selectedBookmarkDesign =
      0.obs; // This will store the index of apiMarkers
  final selectedMarkerId = Rxn<int>();

  /* =======================
   * LIFECYCLE
   * ======================= */
  @override
  void onInit() async {
    super.onInit();

    // Prevent screen from sleeping while reading Al-Quran
    WakelockPlus.enable();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    await fetchInitial();
    await fetchMarkers();
    await loadBookmarks();
    audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _playNextAyah();
      }
    });

    searchAnchorController.addListener(() {
      _debouncedSurahSearch(searchAnchorController.text);
    });
  }

  @override
  void onClose() {
    WakelockPlus.disable();
    audioPlayer.dispose();
    _searchTimer?.cancel();
    searchAyahController.dispose();
    searchSurahController.dispose();
    searchAnchorController.dispose();
    searchAyahPageController.dispose();
    searchSuratPageController.dispose();
    pageController.dispose();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    super.onClose();
  }

  /* =======================
   * HELPERS
   * ======================= */
  void toggleFocus() {
    isFocus.value = !isFocus.value;
  }

  Future<bool> _checkConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return !connectivityResult.contains(ConnectivityResult.none);
  }

  void fetchListPages() {
    if (listPages.isEmpty) {
      for (int i = 1; i <= 604; i++) {
        listPages.add(i);
      }
    }
  }

  void onSearchChanged(String value) {
    _debouncedSurahSearch(value);
  }

  void initGoToDefaults() {
    if (dataPage.isNotEmpty && currentPageIndex.value < dataPage.length) {
      final currentPage = dataPage[currentPageIndex.value];
      selectedPage.value = currentPage.pageNumber;
      if (currentPage.ayahs.isNotEmpty) {
        final ayah = currentPage.ayahs.first.ayah;
        if (ayah != null) {
          surahId.value = ayah.surahId;
          selectedSurahName.value = ayah.surah?.name ?? '';
          searchAyahController.text = ayah.ayahNumber.toString();
        }
      }
    }
  }

  Future<void> _resolveLocalImages(List<Datum> items) async {
    final slug = currentSlug.value;
    for (var item in items) {
      if (item.id < 0) continue; // Skip dummy pages
      final localPath = await offlineService.getLocalImagePath(
        slug,
        item.pageNumber,
      );
      if (localPath != null && await File(localPath).exists()) {
        item.imagePath = localPath;
      }
    }
  }

  /* =======================
   * FETCH INITIAL (ENTRY)
   * ======================= */
  Future<void> fetchInitial({
    int? surahId,
    int? juzId,
    int? ayah,
    int? pageNumber,
  }) async {
    // Save current reading session before starting a new one
    await saveReadingHistory();
    _resetReadingSession();

    isLoading.value = true;
    isLastPage.value = false;
    currentPageIndex.value = 0;
    dataPage.clear();

    final Map<String, dynamic>? args = Get.arguments;
    final slug = args?['slug'] ?? 'mushaf_standard';
    currentSlug.value = slug;
    int? targetPage = pageNumber;

    // Sync class-level state if param is provided
    if (surahId != null) this.surahId.value = surahId;
    if (juzId != null) this.juzId.value = juzId;

    // Resolve targetPage from index.json if available
    final isOfflineAvailable = await offlineService.isIndexDownloaded(slug);
    if (isOfflineAvailable) {
      try {
        final dynamic index = await offlineService.getIndex(slug);
        if (index != null && index is Map) {
          // 1. Resolve Surah + Ayah
          if (surahId != null && ayah != null) {
            final sapMap = index['surah_ayah_to_page'];
            if (sapMap != null && sapMap is Map) {
              final key = '$surahId:$ayah';
              if (sapMap.containsKey(key)) {
                targetPage = int.tryParse(sapMap[key].toString());
                print("Resolved Surah:Ayah $key to Page $targetPage");
              }
            }
          }

          // 2. Resolve Surah (if not resolved by ayah)
          if (targetPage == null && surahId != null) {
            final s2pMap = index['surah_to_page'];
            if (s2pMap != null && s2pMap is Map) {
              final key = surahId.toString();
              if (s2pMap.containsKey(key)) {
                targetPage = int.tryParse(s2pMap[key].toString());
                print("Resolved Surah $surahId to Page $targetPage");
              }
            }
          }

          // 3. Resolve Juz (fallback to list search if no direct map)
          if (targetPage == null && juzId != null) {
            final j2pMap = index['juz_to_page'];
            if (j2pMap != null && j2pMap is Map) {
              final key = juzId.toString();
              if (j2pMap.containsKey(key)) {
                targetPage = int.tryParse(j2pMap[key].toString());
                print("Resolved Juz $juzId to Page $targetPage");
              }
            } else {
              // Fallback to searching Juz list
              final juzs =
                  index['juzs'] ?? index['data']?['juzs'] ?? index['list_juz'];
              if (juzs is List) {
                final juzData = juzs.firstWhere((j) {
                  final jId =
                      j['id'] ?? j['juz_number'] ?? j['nomor'] ?? j['number'];
                  return jId?.toString() == juzId.toString();
                }, orElse: () => null);
                if (juzData != null) {
                  final resolvedPage =
                      juzData['start_page'] ??
                      juzData['page_number'] ??
                      juzData['page'];
                  targetPage = int.tryParse(resolvedPage.toString());
                  print("Resolved Juz $juzId via list to Page $targetPage");
                }
              }
            }
          }
        }
      } catch (e) {
        print("Error resolving from index.json: $e");
      }
    }

    // Hard fallback for Juz if still null
    if (targetPage == null && juzId != null) {
      targetPage = (juzId - 1) * 20 + 2;
      if (juzId == 1) targetPage = 1;
      if (juzId == 30) targetPage = 582;
    }

    // If all params are null, fallback to args (history) or last reading page
    if (targetPage == null &&
        surahId == null &&
        juzId == null &&
        ayah == null) {
      targetPage = args?['page_number'];

      // If still no target page, check local storage for last reading page
      if (targetPage == null) {
        targetPage = await _getLastReadingPage(slug);
      }
    }

    final isOnline = await _checkConnection();

    // If any filter is provided, we should switch to page mode to jump to the target
    if (surahId != null ||
        juzId != null ||
        ayah != null ||
        targetPage != null) {
      mode.value = QuranPaginationMode.page;
    }

    if (isOnline) {
      if (!isOfflineAvailable &&
          !isDownloading.value &&
          !hasShownDownloadPrompt.value) {
        _showDownloadConfirmation(slug);
        hasShownDownloadPrompt.value = true;
      }

      try {
        final response = await Request().get(
          Url.quranPage,
          queryParameters: {
            'qurantype': slug,
            if (mode.value == QuranPaginationMode.browse) ...{
              'page': page.value,
              'per_page': 5,
            } else ...{
              if (targetPage != null) 'page_number': targetPage,
              if (surahId != null && targetPage == null) 'surah_id': surahId,
              if (ayah != null && targetPage == null) 'ayah_number': ayah,
              if (juzId != null && targetPage == null) 'juz': juzId,
              if (pageNumber != null && targetPage == null)
                'page_number': pageNumber,
            },
          },
        );

        if (response.statusCode == 200) {
          final data = QuranPage.fromJson(response.data);
          _applyMeta(data);
          isOfflineMode.value = false;

          // Resolve local images even in online mode if they exist
          await _resolveLocalImages(data.data);

          if (mode.value == QuranPaginationMode.page) {
            _updateDataPageWithWindow(data.data);
            _jumpToTargetPage();
          } else {
            dataPage.value = data.data;
            if (startReadingPage.value == null && dataPage.isNotEmpty) {
              startReadingPage.value = dataPage.first.pageNumber;
            }
          }
          _precacheNearbyPages(currentPageIndex.value);
          _cacheOnlinePages(data.data); // Automatic background download for persistence
          isLoading.value = false;
          return;
        }
      } catch (e) {
        print("API fetch failed, trying offline fallback: $e");
      }
    }

    // Fallback or No Internet
    if (isOfflineAvailable) {
      isOfflineMode.value = true;
      await _fetchOfflineInitial(targetPage: targetPage);
    } else {
      isOfflineMode.value = false;
      if (!isOnline) {
        Get.snackbar(
          'Tidak ada internet',
          'Silahkan aktifkan internet atau download data offline.',
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
      }
    }
    isLoading.value = false;
  }

  /* =======================
   * BROWSE NEXT
   * ======================= */
  Future<void> fetchBrowseNext() async {
    if (mode.value != QuranPaginationMode.browse ||
        isLoading.value ||
        isLastPage.value)
      return;

    isLoading.value = true;
    page.value++;

    final Map<String, dynamic>? args = Get.arguments;
    final slug = args?['slug'] ?? 'mushaf_standard';

    try {
      final response = await Request().get(
        Url.quranPage,
        queryParameters: {'qurantype': slug, 'page': page.value, 'per_page': 5},
      );
      if (response.statusCode == 200) {
        final data = QuranPage.fromJson(response.data);
        if (data.data.isEmpty) {
          isLastPage.value = true;
        } else {
          // Resolve local images even in online mode if they exist
          await _resolveLocalImages(data.data);
          dataPage.addAll(data.data);
          _cacheOnlinePages(data.data); // Automatic background download for persistence
        }
        _applyMeta(data);
      }
    } catch (e) {
      print("Error fetching browse next: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /* =======================
   * PAGE NAVIGATION (PREV / NEXT)
   * ======================= */
  Future<void> fetchByPageNumber(int pageNumber) async {
    if (isLoading.value) return;

    isLoading.value = true;
    final slug = Get.arguments['slug'];
    final isOnline = await _checkConnection();

    if (isOnline) {
      try {
        final response = await Request().get(
          Url.quranPage,
          queryParameters: {'qurantype': slug, 'page_number': pageNumber},
        );
        if (response.statusCode == 200) {
          final data = QuranPage.fromJson(response.data);
          _applyMeta(data);

          // Resolve local images even in online mode if they exist
          await _resolveLocalImages(data.data);

          _updateDataPageWithWindow(data.data);
          _jumpToTargetPage();
          _cacheOnlinePages(data.data); // Automatic background download for persistence
          isOfflineMode.value = false;
          isLoading.value = false;
          return;
        }
      } catch (e) {
        print("API fetch by page failed, trying offline: $e");
      }
    }

    // Try offline
    final datum = await offlineService.getPageData(slug, pageNumber);
    if (datum != null) {
      isOfflineMode.value = true;
      _applyMetaOffline(pageNumber);
      _updateDataPageWithWindow([datum]);
      _jumpToTargetPage();
    } else if (!isOnline) {
      Get.snackbar(
        'Offline',
        'Halaman ini belum diunduh dan tidak ada internet.',
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    }

    isLoading.value = false;
  }

  void _updateDataPageWithWindow(List<Datum> currentData) {
    dataPage.clear();

    // Add dummy prev if exists
    if (prevPageNumber.value != null && prevPageNumber.value is int) {
      dataPage.add(_createDummyPage(prevPageNumber.value!, -1));
    }

    dataPage.addAll(currentData);

    // Add dummy next if exists
    if (nextPageNumber.value != null && nextPageNumber.value is int) {
      dataPage.add(_createDummyPage(nextPageNumber.value!, -2));
    }
  }

  Datum _createDummyPage(int pageNumber, int id) {
    return Datum(
      id: id,
      pageNumber: pageNumber,
      imagePath: '',
      juzNumbers: [],
      isTargetPage: false,
      ayahs: [],
    );
  }

  /* =======================
   * PAGEVIEW CALLBACK
   * ======================= */
  void changePage(int index) {
    if (index < 0 || index >= dataPage.length) return;

    currentPageIndex.value = index;
    final selectedDatum = dataPage[index];

    if (isPlaying.value) stopAudio();

    // Check if we hit a dummy page
    if (selectedDatum.id < 0) {
      fetchByPageNumber(selectedDatum.pageNumber);
      return;
    }

    // Attempt to cache current and nearby pages in background
    _cacheNearbyOnlinePages(index);

    // Save last reading page to local storage
    _saveLastReadingPage(selectedDatum.pageNumber);

    if (mode.value == QuranPaginationMode.browse) {
      if (index >= dataPage.length - 2) {
        fetchBrowseNext();
      }
    }

    _precacheNearbyPages(index);
  }

  void _precacheNearbyPages(int index) {
    if (dataPage.isEmpty || index < 0 || index >= dataPage.length) return;

    // Precache current, next 3, and previous 2 pages for smoother browsing
    final indicesToCache = [index, index + 1, index + 2, index + 3, index - 1, index - 2];

    for (var idx in indicesToCache) {
      if (idx >= 0 && idx < dataPage.length) {
        final item = dataPage[idx];
        if (item.id < 0) continue;

        final ImageProvider provider = item.imagePath.startsWith('http')
            ? CachedNetworkImageProvider(item.imagePath)
            : FileImage(File(item.imagePath));

        precacheImage(provider, Get.context!);
      }
    }
  }

  /// Automatically download and cache online pages into the local file system
  /// so that next time they are available offline instantly.
  Future<void> _cacheOnlinePages(List<Datum> items) async {
    final slug = currentSlug.value;
    for (var item in items) {
      if (item.id < 0) continue; // Skip dummy pages
      
      // If it's already local, no need to download
      if (item.imagePath.isNotEmpty && !item.imagePath.startsWith('http')) continue;

      // Check if it's already downloaded in local storage
      final exists = await offlineService.isPageDownloaded(slug, item.pageNumber);
      if (!exists) {
        // Silently download in background
        offlineService.downloadPage(slug, item.pageNumber).then((_) async {
          // Once downloaded, update the in-memory path to the local one
          final localPath = await offlineService.getLocalImagePath(slug, item.pageNumber);
          if (localPath != null && await File(localPath).exists()) {
            item.imagePath = localPath;
          }
        }).catchError((e) {
          print("Background auto-cache failed for page ${item.pageNumber}: $e");
        });
      }
    }
  }

  /// Cache nearby pages that haven't been downloaded yet
  void _cacheNearbyOnlinePages(int index) {
    if (dataPage.isEmpty || index < 0 || index >= dataPage.length) return;
    
    final nearby = <Datum>[];
    // Cache current, next 2, and previous 1
    final indices = [index, index + 1, index + 2, index - 1];
    for(var idx in indices) {
      if (idx >= 0 && idx < dataPage.length) {
        nearby.add(dataPage[idx]);
      }
    }
    _cacheOnlinePages(nearby);
  }

  /* =======================
   * META HANDLER
   * ======================= */
  void _applyMeta(QuranPage data) {
    viewportWidth.value = data.type?.viewportWidth.toDouble() ?? 0.0;
    viewportHeight.value = data.type?.viewportHeight.toDouble() ?? 0.0;

    final prev = data.meta?.navigation?.prevPageNumber;
    final next = data.meta?.navigation?.nextPageNumber;

    prevPageNumber.value = prev is String ? int.tryParse(prev) : prev;
    nextPageNumber.value = next is String ? int.tryParse(next) : next;
  }

  /* =======================
   * OFFLINE HELPERS
   * ======================= */
  void _showDownloadConfirmation(String type) {
    Get.dialog(
      Dialog(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppColor.backgroundColor,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Download Quran Offline?',
                style: pMedium18.copyWith(color: AppColor.primaryColor),
              ),
              const SizedBox(height: 12),
              Text(
                'Anda belum memiliki data offline untuk Quran ini. Apakah Anda ingin mengunduh semua halaman sekarang agar bisa dibaca tanpa internet?',
                style: pRegular14,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: Text('Nanti Saja', style: pMedium14),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        _startDownload(type);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primaryColor,
                      ),
                      child: Text(
                        'Download',
                        style: pMedium14.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startDownload(String type) async {
    if (isDownloading.value) return;

    isDownloading.value = true;
    isPaused.value = false;
    try {
      final total = await offlineService.downloadIndex(type);
      totalPagesToDownload.value = total;

      for (int i = 1; i <= total; i++) {
        // Stop the loop if paused OR if isDownloading becomes false (e.g. user force closed it)
        if (isPaused.value || !isDownloading.value) {
          debugPrint("Download stopped or paused at page $i");
          return;
        }

        if (await offlineService.isPageDownloaded(type, i)) {
          downloadProgress.value = i;
          continue;
        }

        await offlineService.downloadPage(type, i);
        downloadProgress.value = i;
      }

      isOfflineMode.value = true;
      fetchInitial();
    } catch (e) {
      print("Download error: $e");
    } finally {
      isDownloading.value = false;
    }
  }

  void pauseDownload() {
    isPaused.value = true;
    isDownloading.value = false;
  }

  void resumeDownload() {
    final slug = Get.arguments['slug'] ?? 'mushaf_standard';
    _startDownload(slug);
  }

  void downloadAllContent() {
    final slug = Get.arguments['slug'] ?? 'mushaf_standard';
    _startDownload(slug);
  }

  Future<void> _fetchOfflineInitial({int? targetPage}) async {
    final Map<String, dynamic>? args = Get.arguments;
    final slug = args?['slug'] ?? 'mushaf_standard';
    final pageNum = targetPage ?? 1;

    final datum = await offlineService.getPageData(slug, pageNum);
    if (datum != null) {
      _applyMetaOffline(pageNum);
      _updateDataPageWithWindow([datum]);
      _jumpToTargetPage();
    }
  }

  void _applyMetaOffline(int currentPage) {
    // Standard Mushaf dimensions if not specified
    viewportWidth.value = 1080;
    viewportHeight.value = 1748;

    // Set navigation for offline mode
    prevPageNumber.value = currentPage > 1 ? currentPage - 1 : null;
    nextPageNumber.value = currentPage < 604 ? currentPage + 1 : null;
  }

  void _jumpToTargetPage() {
    int idx = dataPage.indexWhere((e) => e.isTargetPage == true);

    // If no target page marked, and we have multiple items (dummies),
    // it's likely the middle one (the only non-dummy).
    if (idx == -1) {
      idx = dataPage.indexWhere((e) => e.id >= 0);
    }

    currentPageIndex.value = idx != -1 ? idx : 0;

    // Track start page for history
    if (startReadingPage.value == null && idx != -1) {
      startReadingPage.value = dataPage[idx].pageNumber;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (pageController.hasClients) {
        pageController.jumpToPage(currentPageIndex.value);
      }
    });
  }

  /* =======================
   * AUDIO
   * ======================= */
  void toggleAudio() {
    if (isPlaying.value) {
      stopAudio();
    } else {
      playAyah(0);
    }
  }

  void playAyah(int index) async {
    if (currentPageIndex.value >= dataPage.length) return;
    final pageData = dataPage[currentPageIndex.value];
    if (index >= pageData.ayahs.length) {
      stopAudio();
      return;
    }

    final ayahElement = pageData.ayahs[index];
    final ayah = ayahElement.ayah;
    if (ayah == null) {
      playAyah(index + 1);
      return;
    }

    final audio = ayah.audio.firstWhereOrNull(
      (a) => a.reciter?.code == selectedReciter.value,
    );

    if (audio == null) {
      playAyah(index + 1);
      return;
    }

    playingAyahId.value = ayah.id;
    isPlaying.value = true;

    try {
      await audioPlayer.setUrl(audio.audioPath);
      audioPlayer.play();
    } catch (e) {
      print("Error playing audio: $e");
      _playNextAyah();
    }
  }

  void _playNextAyah() {
    if (!isPlaying.value) return;

    final pageData = dataPage[currentPageIndex.value];
    final idx = pageData.ayahs.indexWhere(
      (e) => e.ayah?.id == playingAyahId.value,
    );

    if (idx != -1 && idx < pageData.ayahs.length - 1) {
      playAyah(idx + 1);
    } else {
      stopAudio();
    }
  }

  void stopAudio() {
    audioPlayer.stop();
    isPlaying.value = false;
    playingAyahId.value = 0;
  }

  void changeReciter(String? code) {
    if (code != null) {
      selectedReciter.value = code;
      if (isPlaying.value) {
        final pageData = dataPage[currentPageIndex.value];
        final idx = pageData.ayahs.indexWhere(
          (e) => e.ayah?.id == playingAyahId.value,
        );
        if (idx != -1) {
          playAyah(idx);
        }
      }
    }
  }

  /* =======================
   * SEARCH HANDLERS
   * ======================= */
  void onSelectSurah(int id) {
    Get.back();
    isFocus.value = true;
    fetchInitial(surahId: id);
  }

  void onSelectJuz(int id) {
    Get.back();
    isFocus.value = false;
    fetchInitial(juzId: id);
  }

  void onJumpToAyah() {
    if (surahId.value == 0) {
      Get.snackbar('Peringatan', 'Silahkan pilih surat terlebih dahulu');
      return;
    }
    if (searchAyahController.text.isEmpty) {
      Get.snackbar('Peringatan', 'Silahkan masukkan nomor ayat');
      return;
    }
    Get.back();
    isFocus.value = true;
    fetchInitial(
      surahId: surahId.value,
      ayah: int.tryParse(searchAyahController.text),
    );
  }

  void onJumpToPage() {
    Get.back();
    isFocus.value = true;
    fetchInitial(pageNumber: selectedPage.value);
  }

  /* =======================
   * DROPDOWN
   * ======================= */
  void _debouncedSurahSearch(String value) {
    _searchTimer?.cancel();
    _searchTimer = Timer(
      const Duration(milliseconds: 400),
      () => fetchDropdownSurah(value),
    );
  }

  Future<void> fetchDropdownSurah(String search) async {
    isDialogLoading.value = true;
    try {
      final String response = await rootBundle.loadString(
        'assets/data/ddl-surah.json',
      );
      final List<DropdownSurah> allSurahs = dropdownSurahFromJson(response);

      if (search.isEmpty) {
        dropdownSurah.value = allSurahs;
      } else {
        dropdownSurah.value = allSurahs
            .where((s) => s.name.toLowerCase().contains(search.toLowerCase()))
            .toList();
      }
    } catch (e) {
      print("Error loading surah assets: $e");
    } finally {
      isDialogLoading.value = false;
    }
  }

  Future<void> fetchDropdownJuz() async {
    isDialogLoading.value = true;
    try {
      // Create Juz items with a loop (1-30)
      final List<DropdownJuz> allJuz = [];
      for (int i = 1; i <= 30; i++) {
        allJuz.add(DropdownJuz(juzNomor: i, surah: []));
      }
      dropdownJuz.value = allJuz;
    } catch (e) {
      print("Error generating juz items: $e");
    } finally {
      isDialogLoading.value = false;
    }
  }

  /* =======================
   * BOOKMARK METHODS
   * ======================= */
  Future<void> loadBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? bookmarksJson = prefs.getString('local_bookmarks');
      if (bookmarksJson != null) {
        final List<dynamic> data = jsonDecode(bookmarksJson);
        bookmarks.value = data.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        bookmarks.clear();
      }
      _updateMarkersUsageStatus();
    } catch (e) {
      print("Error loading bookmarks: $e");
    }
  }

  void _updateMarkersUsageStatus() {
    if (apiMarkers.isEmpty) return;

    // Get all marker IDs that are currently in use by bookmarks
    final usedMarkerIds = bookmarks.map((b) => b['marker_id']).toSet();

    // Update isUse for each marker in apiMarkers
    final updatedMarkers = apiMarkers.map((marker) {
      final updatedMarker = Map<String, dynamic>.from(marker);
      updatedMarker['isUse'] = usedMarkerIds.contains(marker['id']);
      return updatedMarker;
    }).toList();

    apiMarkers.value = updatedMarkers;
  }

  Future<void> saveBookmark() async {
    if (dataPage.isEmpty || currentPageIndex.value >= dataPage.length) return;

    final selectedMarker = apiMarkers[selectedBookmarkDesign.value];

    if (selectedMarker['isUse'] == true) {
      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColor.backgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.info_outline,
                    color: AppColor.primaryColor,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Pindahkan Pembatas?',
                  style: pBold18.copyWith(color: AppColor.primaryColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Ingin memindahkan pembatas ke halaman ini?',
                  style: pRegular14.copyWith(color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Get.back(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Batal',
                          style: pSemiBold14.copyWith(color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          _executeSaveBookmark();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Pindahkan',
                          style: pSemiBold14.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      _executeSaveBookmark();
    }
  }

  Future<void> _executeSaveBookmark() async {
    try {
      final currentPage = dataPage[currentPageIndex.value];
      final selectedMarker = apiMarkers[selectedBookmarkDesign.value];

      final prefs = await SharedPreferences.getInstance();
      final String? bookmarksJson = prefs.getString('local_bookmarks');
      List<Map<String, dynamic>> localBookmarks = [];
      
      if (bookmarksJson != null) {
        localBookmarks = List<Map<String, dynamic>>.from(jsonDecode(bookmarksJson));
      }

      // Find if there's already a bookmark for this page or with the same marker design
      // Note: According to the logic in saveBookmark, if the marker design is in use, we're replacing it.
      // Or maybe we want to allow multiple bookmarks but one per "marker design"?
      
      // Remove existing bookmark with the same marker design if we are "moving" it
      localBookmarks.removeWhere((b) => b['marker_id'] == selectedMarker['id']);
      
      // Optionally also remove if there's already a bookmark on THIS page (common UX for Quran apps)
      localBookmarks.removeWhere((b) => 
        b['page_number'] == currentPage.pageNumber && 
        b['quran_type_slug'] == currentSlug.value
      );

      // Get surah name for context
      String surahName = 'Unknown';
      if (currentPage.ayahs.isNotEmpty) {
        surahName = currentPage.ayahs.first.ayah?.surah?.name ?? 'Unknown';
      }

      // Add new bookmark
      localBookmarks.add({
        'id': DateTime.now().millisecondsSinceEpoch, // Local ID
        'marker_id': selectedMarker['id'],
        'marker_path': selectedMarker['marker_path'],
        'page_number': currentPage.pageNumber,
        'quran_type_slug': currentSlug.value,
        'surah_name': surahName,
        'created_at': DateTime.now().toIso8601String(),
      });

      await prefs.setString('local_bookmarks', jsonEncode(localBookmarks));
      
      AppToast.success(
        message: 'Halaman ${currentPage.pageNumber} ditandai.',
        title: 'Berhasil',
      );
      
      await loadBookmarks(); // Refresh local list
      isBookmarkVisible.value = false; // Close UI
    } catch (e) {
      print("Error in _executeSaveBookmark: $e");
      AppToast.error(
        message: 'Gagal menyimpan penanda secara lokal.',
        title: 'Gagal',
      );
    }
  }

  Future<void> deleteBookmark(int index) async {}

  void initMarkerSelection() {
    if (apiMarkers.isEmpty) return;

    final Map<String, dynamic>? args = Get.arguments;
    final passedMarkerId = args?['marker_id'];

    int targetIdx = -1;

    // 1. If currently on a page that HAS a bookmark, select that bookmark's marker
    if (dataPage.isNotEmpty && currentPageIndex.value < dataPage.length) {
      final currentPageNum = dataPage[currentPageIndex.value].pageNumber;
      final existing = bookmarks.firstWhereOrNull(
        (b) =>
            b['page_number'] == currentPageNum &&
            b['quran_type_slug'] == currentSlug.value,
      );
      if (existing != null) {
        targetIdx = apiMarkers.indexWhere(
          (m) => m['id'] == existing['marker_id'],
        );
      }
    }

    // 2. If not found, and passed from context (tilawahku/history)
    if (targetIdx == -1 && passedMarkerId != null) {
      targetIdx = apiMarkers.indexWhere((m) => m['id'] == passedMarkerId);
    }

    // 3. If not found or not passed, find first UNUSED marker
    if (targetIdx == -1) {
      targetIdx = apiMarkers.indexWhere((m) => m['isUse'] == false);
    }

    // 4. Fallback to first USED marker
    if (targetIdx == -1) {
      targetIdx = apiMarkers.indexWhere((m) => m['isUse'] == true);
    }

    // Apply
    selectedBookmarkDesign.value = targetIdx != -1 ? targetIdx : 0;
    selectedMarkerId.value = apiMarkers[selectedBookmarkDesign.value]['id'];
  }

  Future<void> fetchMarkers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load from cache first
      final String? markersCache = prefs.getString('local_markers_cache');
      if (markersCache != null) {
        final List<dynamic> cachedData = jsonDecode(markersCache);
        apiMarkers.value = cachedData.map((e) => Map<String, dynamic>.from(e)).toList();
        _updateMarkersUsageStatus();
        initMarkerSelection();
      }

      // Try fetching from API to update cache if online
      final response = await Request().get(Url.listMarkers);
      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> markerList = data['data'];
        
        // Save to cache
        await prefs.setString('local_markers_cache', jsonEncode(markerList));
        
        apiMarkers.value = markerList.map((e) => Map<String, dynamic>.from(e)).toList();
        _updateMarkersUsageStatus();
        initMarkerSelection();
      }
    } catch (e) {
      print("Error fetching/caching markers: $e");
    }
  }

  /* =======================
   * HISTORY
   * ======================= */
  void _resetReadingSession() {
    startReadingPage.value = null;
    readingStartTime = DateTime.now();
  }

  Future<void> saveReadingHistory() async {
    if (!AuthController.to.isLogin.value) return;
    if (dataPage.isEmpty || currentPageIndex.value >= dataPage.length) return;

    try {
      final currentPage = dataPage[currentPageIndex.value];
      final currentNum = currentPage.pageNumber;
      final initialNum = startReadingPage.value ?? currentNum;

      // Ensure start_page <= end_page for API validation
      final startPage = initialNum < currentNum ? initialNum : currentNum;
      final endPage = initialNum < currentNum ? currentNum : initialNum;

      final duration = DateTime.now().difference(readingStartTime).inSeconds;

      // Proceed to show dialog and save if duration is reasonable (e.g. > 1s for testing)
      if (duration <= 15) return;

      int? currentSurahId;
      if (currentPage.ayahs.isNotEmpty) {
        currentSurahId = currentPage.ayahs.first.ayah?.surahId;
      }

      // Show Loading indicator
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: AppColor.primaryColor),
        ),
        barrierDismissible: false,
      );

      final prefs = await SharedPreferences.getInstance();
      final String? historyJson = prefs.getString('local_history');
      List<Map<String, dynamic>> localHistory = [];
      
      if (historyJson != null) {
        localHistory = List<Map<String, dynamic>>.from(jsonDecode(historyJson));
      }

      final newHistory = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'surah_id': currentSurahId,
        'surah_name': currentPage.ayahs.isNotEmpty ? currentPage.ayahs.first.ayah?.surah?.name : 'Unknown',
        'start_page': startPage,
        'end_page': endPage,
        'page_number': currentNum, // Helpful for display
        'quran_type_slug': currentSlug.value,
        'read_date': DateTime.now().toIso8601String().split('T')[0],
        'duration_seconds': duration,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      localHistory.insert(0, newHistory); // Newest first
      if (localHistory.length > 50) localHistory.removeLast(); // Limit history

      await prefs.setString('local_history', jsonEncode(localHistory));

      if (Get.isOverlaysOpen) {
        Get.back(); // Close Loading Dialog
      }

      // Save last reading page to local storage (already done by _saveLastReadingPage but keeping here for consistency)
      _saveLastReadingPage(currentNum);
      
      // Refresh Home stats if needed
      if (Get.isRegistered<HomeScreenController>()) {
        Get.find<HomeScreenController>().fetchWeeklyStats();
      }
    } catch (e) {
      if (Get.isOverlaysOpen) {
        Get.back(); // Close Loading Dialog if still open
      }
      AppToast.error(
        message: 'Gagal menyimpan sejarah pembacaan.',
        title: 'Gagal',
      );
    }
  }

  /* =======================
   * LAST READING LOCAL STORAGE
   * ======================= */
  Future<void> _saveLastReadingPage(int pageNumber) async {
    try {
      final Map<String, dynamic>? args = Get.arguments;
      final slug = args?['slug'] ?? 'mushaf_standard';
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('last_reading_page_$slug', pageNumber);
    } catch (e) {
      print("Error saving last reading page: $e");
    }
  }

  Future<int?> _getLastReadingPage(String slug) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('last_reading_page_$slug');
    } catch (e) {
      print("Error getting last reading page: $e");
      return null;
    }
  }
}
