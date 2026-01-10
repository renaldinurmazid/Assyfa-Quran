import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

import 'package:quran_app/api/url.dart';
import 'package:quran_app/models/dropdown_juz_model.dart';
import 'package:quran_app/models/dropdown_surah_model.dart';
import 'package:quran_app/models/quran_page_model.dart';

enum QuranPaginationMode { browse, page }

class QuranPageScreenController extends GetxController {
  /* =======================
   * CORE STATE
   * ======================= */
  final mode = QuranPaginationMode.browse.obs;
  final dataPage = <Datum>[].obs;

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

  String get fullImageUrl => '${Url.baseUrl}/storage/';

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
        final firstAyah = currentPage.ayahs.first.ayah;
        surahId.value = firstAyah.surahId;
        selectedSurahName.value = firstAyah.surah.name;
        searchAyahController.text = firstAyah.ayahNumber.toString();
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

    final slug = Get.arguments['slug'];

    mode.value =
        (surahId != null || juzId != null || ayah != null || pageNumber != null)
        ? QuranPaginationMode.page
        : QuranPaginationMode.browse;

    String url = '${Url.baseUrl}${Url.quranPage}?qurantype=$slug';

    if (mode.value == QuranPaginationMode.browse) {
      page.value = 1;
      url += '&page=${page.value}&per_page=5';
    } else {
      if (surahId != null) url += '&surah_id=$surahId';
      if (ayah != null) url += '&ayah_number=$ayah';
      if (juzId != null) url += '&juz=$juzId';
      if (pageNumber != null) url += '&page_number=$pageNumber';
    }

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = quranPageFromJson(response.body);
        dataPage.value = data.data;
        _applyMeta(data);

        if (mode.value == QuranPaginationMode.page) {
          _jumpToTargetPage();
        }
      }
    } catch (e) {
      print("Error fetching initial data: $e");
    } finally {
      isLoading.value = false;
    }
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

    final slug = Get.arguments['slug'];
    final url =
        '${Url.baseUrl}${Url.quranPage}?qurantype=$slug&page=${page.value}&per_page=5';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = quranPageFromJson(response.body);
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
    if (mode.value != QuranPaginationMode.page || isLoading.value) return;

    isLoading.value = true;
    final slug = Get.arguments['slug'];

    final url =
        '${Url.baseUrl}${Url.quranPage}?qurantype=$slug&page_number=$pageNumber';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = quranPageFromJson(response.body);
        dataPage.value = data.data;
        _applyMeta(data);
        _jumpToTargetPage();
      }
    } catch (e) {
      print("Error fetching by page number: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /* =======================
   * PAGEVIEW CALLBACK
   * ======================= */
  void changePage(int index) {
    currentPageIndex.value = index;

    if (isPlaying.value) stopAudio();

    if (mode.value == QuranPaginationMode.page) {
      if (index == 0 &&
          prevPageNumber.value != null &&
          prevPageNumber.value is int) {
        fetchByPageNumber(prevPageNumber.value!);
      }

      if (index == dataPage.length - 1 && nextPageNumber.value != null) {
        fetchByPageNumber(nextPageNumber.value!);
      }
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
    viewportWidth.value = data.type.viewportWidth?.toDouble() ?? 0;
    viewportHeight.value = data.type.viewportHeight?.toDouble() ?? 0;
    prevPageNumber.value = data.meta.navigation.prevPageNumber;
    nextPageNumber.value = data.meta.navigation.nextPageNumber;
  }

  void _jumpToTargetPage() {
    final idx = dataPage.indexWhere((e) => e.isTargetPage == true);

    currentPageIndex.value = idx != -1 ? idx : 0;

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
    final pageData = dataPage[currentPageIndex.value];
    if (index >= pageData.ayahs.length) {
      stopAudio();
      return;
    }

    final ayah = pageData.ayahs[index];
    final audio = ayah.ayah.audio.firstWhereOrNull(
      (a) => a.reciter?.code == selectedReciter.value,
    );

    if (audio == null) {
      playAyah(index + 1);
      return;
    }

    playingAyahId.value = ayah.ayah.id;
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
      (e) => e.ayah.id == playingAyahId.value,
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
          (e) => e.ayah.id == playingAyahId.value,
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
    fetchInitial(surahId: id);
  }

  void onSelectJuz(int id) {
    Get.back();
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
    fetchInitial(
      surahId: surahId.value,
      ayah: int.tryParse(searchAyahController.text),
    );
  }

  void onJumpToPage() {
    Get.back();
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
      final response = await http.get(
        Uri.parse('${Url.baseUrl}${Url.dropdownSurah}?search=$search'),
      );

      if (response.statusCode == 200) {
        dropdownSurah.value = dropdownSurahFromJson(response.body);
      }
    } catch (e) {
      print("Error fetching dropdown surah: $e");
    } finally {
      isDialogLoading.value = false;
    }
  }

  Future<void> fetchDropdownJuz() async {
    isDialogLoading.value = true;
    try {
      final response = await http.get(
        Uri.parse('${Url.baseUrl}${Url.dropdownJuz}'),
      );

      if (response.statusCode == 200) {
        dropdownJuz.value = dropdownJuzFromJson(response.body);
      }
    } catch (e) {
      print("Error fetching dropdown juz: $e");
    } finally {
      isDialogLoading.value = false;
    }
  }
}
