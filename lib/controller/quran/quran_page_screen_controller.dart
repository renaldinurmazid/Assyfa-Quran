import 'dart:async';
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

enum QuranPaginationMode { browse, page }

class QuranPageScreenController extends GetxController {
  /* =======================
   * CORE STATE
   * ======================= */
  final mode = QuranPaginationMode.browse.obs;
  final dataPage = <Datum>[].obs;
  final startReadingPage = RxnInt();
  final readingStartTime = DateTime.now();

  final isLoading = false.obs;
  final isLastPage = false.obs;
  final isFocus = true.obs;

  final currentPageIndex = 0.obs;
  final page = 1.obs;

  final prevPageNumber = Rxn<dynamic>();
  final nextPageNumber = Rxn<int>();

  final viewportWidth = 0.0.obs;
  final viewportHeight = 0.0.obs;

  final pageController = PageController();

  /* =======================
   * OFFLINE STATE
   * ======================= */
  final offlineService = QuranOfflineService();
  final isOfflineMode = false.obs;
  final isDownloading = false.obs;
  final downloadProgress = 0.obs;
  final totalPagesToDownload = 0.obs;

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

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    await fetchInitial();
    if (AuthController.to.isLogin.value) {
      await fetchMarkers();
      await loadBookmarks();
    }
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

  /* =======================
   * FETCH INITIAL (ENTRY)
   * ======================= */
  Future<void> fetchInitial({
    int? surahId,
    int? juzId,
    int? ayah,
    int? pageNumber,
  }) async {
    isLoading.value = true;
    isLastPage.value = false;
    currentPageIndex.value = 0;
    dataPage.clear();

    final Map<String, dynamic>? args = Get.arguments;
    final slug = args?['slug'] ?? 'mushaf_standard';
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

    // If all params are null, fallback to args (history)
    if (targetPage == null &&
        surahId == null &&
        juzId == null &&
        ayah == null) {
      targetPage = args?['page_number'];
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
          mode.value == QuranPaginationMode.browse) {
        _showDownloadConfirmation(slug);
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

          if (mode.value == QuranPaginationMode.page) {
            _updateDataPageWithWindow(data.data);
            _jumpToTargetPage();
          } else {
            dataPage.value = data.data;
            if (startReadingPage.value == null && dataPage.isNotEmpty) {
              startReadingPage.value = dataPage.first.pageNumber;
            }
          }
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
          dataPage.addAll(data.data);
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
          _updateDataPageWithWindow(data.data);
          _jumpToTargetPage();
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

    if (mode.value == QuranPaginationMode.browse) {
      if (index >= dataPage.length - 2) {
        fetchBrowseNext();
      }
    }
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
                'Anda belum memiliki data offline untuk Quran ini. Apakah Anda ingin mengunduhnya sekarang?',
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
    isDownloading.value = true;
    try {
      await offlineService.downloadAll(type, (progress, total) {
        downloadProgress.value = progress;
        totalPagesToDownload.value = total;
      });
      isOfflineMode.value = true;
      fetchInitial();
    } finally {
      isDownloading.value = false;
    }
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
    if (!AuthController.to.isLogin.value) return;
    try {
      final response = await Request().get(Url.listUserMarkers);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        bookmarks.value = data
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    } catch (e) {
      print("Error loading bookmarks: $e");
    }
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

      // API Call
      try {
        final response = await Request().post(
          Url.saveMarkers,
          data: {
            'marker_id': selectedMarker['id'],
            'quran_page_id': currentPage.id,
          },
        );

        if (response.statusCode == 200) {
          Get.snackbar(
            'Berhasil',
            'Halaman ${currentPage.pageNumber} ditandai.',
            backgroundColor: AppColor.primaryColor.withOpacity(0.8),
            colorText: Colors.white,
          );
          // Refresh list markers/bookmarks if needed
          await fetchMarkers();
        }
      } catch (e) {
        print("Error saving bookmark to API: $e");
        Get.snackbar(
          'Gagal',
          'Gagal menyimpan penanda ke server.',
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
      }

      isBookmarkVisible.value = false; // Close UI
    } catch (e) {
      print("Error in _executeSaveBookmark: $e");
    }
  }

  Future<void> deleteBookmark(int index) async {
    // Handle via API toggle-marker if necessary
    // bookmarks.removeAt(index);
  }

  Future<void> fetchMarkers() async {
    try {
      final response = await Request().get(Url.listMarkers);
      if (response.statusCode == 200) {
        final data = response.data;
        apiMarkers.value = List<Map<String, dynamic>>.from(data['data']);

        // Set default selection if markers available
        if (apiMarkers.isNotEmpty) {
          final usedIdx = apiMarkers.indexWhere((m) => m['isUse'] == true);
          selectedBookmarkDesign.value = usedIdx != -1 ? usedIdx : 0;
          selectedMarkerId.value =
              apiMarkers[selectedBookmarkDesign.value]['id'];
        }
      }
    } catch (e) {
      print("Error fetching markers: $e");
    }
  }

  /* =======================
   * HISTORY
   * ======================= */
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

      if (duration <= 15) return;

      int? currentSurahId;
      if (currentPage.ayahs.isNotEmpty) {
        currentSurahId = currentPage.ayahs.first.ayah?.surahId;
      }

      await Request().post(
        Url.readingHistory,
        data: {
          'surah_id': currentSurahId,
          'start_page': startPage,
          'end_page': endPage,
          'read_date': DateTime.now().toIso8601String().split('T')[0],
          'duration_seconds': duration,
        },
      );
    } catch (e) {
      print("Error saving reading history: $e");
    }
  }
}
