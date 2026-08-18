import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/models/dropdown_surah_model.dart';
import 'package:quran_app/models/reciter_model.dart';
import 'package:quran_app/widgets/app_toast.dart';
import 'package:quran_app/controller/global/global_audio_controller.dart';

class QuranMp3Controller extends GetxController {
  final scrollController = ScrollController();
  final searchController = TextEditingController();

  final surahList = <DropdownSurah>[].obs;
  final isLoading = false.obs;
  final isLoadMoreLoading = false.obs;
  final searchQuery = ''.obs;

  final reciters = <ReciterModel>[].obs;
  final selectedReciter = Rxn<ReciterModel>();
  final isRecitersLoading = false.obs;

  GlobalAudioController get audio => GlobalAudioController.to;

  // Active player state for premium UI player card and tile highlights
  RxnInt get playingSurahId => audio.playingSurahId;
  RxBool get isPlaying => audio.isPlaying;
  RxBool get isAudioLoading => audio.isAudioLoading;

  // Audio state getters
  Rx<Duration> get position => audio.position;
  Rx<Duration> get duration => audio.duration;
  RxBool get isShuffle => audio.isShuffle;
  RxBool get isRepeat => audio.isRepeat;
  RxDouble get playbackSpeed => audio.playbackSpeed;
  RxInt get currentAyahIndex => audio.currentAyahIndex;

  int _currentPage = 1;
  int _lastPage = 1;
  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    fetchSurahList(isRefresh: true);
    fetchReciters();

    audio.audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        playNextSurah();
      }
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    searchController.dispose();
    _debounce?.cancel();
    super.onClose();
  }

  Future<void> loadAndPlayAudio(int surahId, int reciterId) async {
    final surah = surahList.firstWhereOrNull((s) => s.id == surahId);
    final reciter = reciters.firstWhereOrNull((r) => r.id == reciterId);
    
    if (surah != null && reciter != null) {
      await audio.loadAndPlayAudio(surah, reciter);
    }
  }

  void togglePlay(int id) {
    if (playingSurahId.value == id) {
      audio.togglePlay();
    } else {
      if (selectedReciter.value != null) {
        loadAndPlayAudio(id, selectedReciter.value!.id);
      } else {
        AppToast.error(message: 'Pilih qori terlebih dahulu');
      }
    }
  }

  void seek(Duration pos) {
    audio.audioPlayer.seek(pos);
  }

  void next() {
    playNextSurah();
  }

  void previous() {
    if (playingSurahId.value == null) return;

    final currentIndex = surahList.indexWhere(
      (s) => s.id == playingSurahId.value,
    );
    if (currentIndex > 0) {
      final prevSurah = surahList[currentIndex - 1];

      if (selectedReciter.value != null) {
        loadAndPlayAudio(prevSurah.id, selectedReciter.value!.id);
      }
    } else if (currentIndex == 0) {
      audio.audioPlayer.seek(Duration.zero);
    }
  }

  void playNextSurah() {
    if (playingSurahId.value == null) return;

    final currentIndex = surahList.indexWhere(
      (s) => s.id == playingSurahId.value,
    );
    if (currentIndex != -1 && currentIndex < surahList.length - 1) {
      final nextSurah = surahList[currentIndex + 1];

      if (selectedReciter.value != null) {
        loadAndPlayAudio(nextSurah.id, selectedReciter.value!.id);
      }
    } else {
      audio.audioPlayer.pause();
    }
  }

  void toggleSpeed() {
    double nextSpeed = 1.0;
    if (audio.playbackSpeed.value == 1.0) {
      nextSpeed = 1.25;
    } else if (audio.playbackSpeed.value == 1.25) {
      nextSpeed = 1.5;
    } else if (audio.playbackSpeed.value == 1.5) {
      nextSpeed = 2.0;
    } else {
      nextSpeed = 1.0;
    }
    audio.audioPlayer.setSpeed(nextSpeed);
  }

  void toggleShuffle() {
    audio.audioPlayer.setShuffleModeEnabled(!audio.isShuffle.value);
  }

  void toggleRepeat() {
    audio.audioPlayer.setLoopMode(audio.isRepeat.value ? LoopMode.off : LoopMode.all);
  }

  DropdownSurah? get currentPlayingSurah {
    return audio.currentSurah.value;
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      fetchSurahList(isRefresh: false);
    }
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      fetchSurahList(isRefresh: true);
    });
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    fetchSurahList(isRefresh: true);
  }

  Future<void> fetchReciters() async {
    if (reciters.isNotEmpty) return;
    try {
      isRecitersLoading.value = true;
      final response = await Request().get(Url.recitersFullAudio);
      if (response.statusCode == 200) {
        final List<dynamic> dataJson = response.data['data'];
        reciters.assignAll(
          dataJson.map((e) => ReciterModel.fromJson(e)).toList(),
        );

        if (reciters.isNotEmpty && selectedReciter.value == null) {
          selectedReciter.value =
              reciters.firstWhereOrNull(
                (r) => r.name.toLowerCase().contains('musyari'),
              ) ??
              reciters.first;
        }
      }
    } catch (e) {
      AppToast.warning(message: 'Gagal memuat qori');
    } finally {
      isRecitersLoading.value = false;
    }
  }

  Future<void> fetchSurahList({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
      _lastPage = 1;
      isLoading.value = true;
    } else {
      if (_currentPage > _lastPage ||
          isLoadMoreLoading.value ||
          isLoading.value) {
        return;
      }
      isLoadMoreLoading.value = true;
    }

    try {
      final queryParams = <String, dynamic>{
        'page': _currentPage,
        'per_page': 20,
      };
      if (searchQuery.value.isNotEmpty) {
        queryParams['search'] = searchQuery.value;
      }

      final response = await Request().get(
        Url.dropdownSurah,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> dataJson = response.data['data'];
        final List<DropdownSurah> newSurahs = dataJson
            .map((e) => DropdownSurah.fromJson(e))
            .toList();

        final meta = response.data['meta'];
        if (meta != null) {
          _currentPage = (meta['current_page'] as int) + 1;
          _lastPage = meta['last_page'] as int;
        } else {
          _currentPage++;
        }

        if (isRefresh) {
          surahList.assignAll(newSurahs);
        } else {
          surahList.addAll(newSurahs);
        }
      } else {
        AppToast.error(
          message: response.data['message'] ?? 'Gagal memuat daftar surah',
        );
      }
    } catch (e) {
      AppToast.error(message: 'Terjadi kesalahan koneksi');
    } finally {
      isLoading.value = false;
      isLoadMoreLoading.value = false;
    }
  }
}
