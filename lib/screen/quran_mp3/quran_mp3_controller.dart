import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/models/dropdown_surah_model.dart';
import 'package:quran_app/models/reciter_model.dart';
import 'package:quran_app/widgets/app_toast.dart';

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

  // Active player state for premium UI player card and tile highlights
  final playingSurahId = RxnInt();
  final isPlaying = false.obs;
  final lastPlayingSurah = Rxn<DropdownSurah>();

  final AudioPlayer audioPlayer = AudioPlayer();
  final isAudioLoading = false.obs;

  // Audio state
  final position = Duration.zero.obs;
  final duration = Duration.zero.obs;
  final isShuffle = false.obs;
  final isRepeat = false.obs;
  final playbackSpeed = 1.0.obs;
  final currentAyahIndex = 0.obs;

  int _currentPage = 1;
  int _lastPage = 1;
  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    fetchSurahList(isRefresh: true);
    fetchReciters();
    _initAudioPlayer();
  }

  void _initAudioPlayer() {
    audioPlayer.playingStream.listen((playing) {
      isPlaying.value = playing;
    });
    audioPlayer.positionStream.listen((pos) {
      position.value = pos;
    });
    audioPlayer.durationStream.listen((dur) {
      if (dur != null) duration.value = dur;
    });
    audioPlayer.currentIndexStream.listen((index) {
      if (index != null) currentAyahIndex.value = index;
    });
    audioPlayer.loopModeStream.listen((loopMode) {
      isRepeat.value = loopMode == LoopMode.all;
    });
    audioPlayer.shuffleModeEnabledStream.listen((shuffle) {
      isShuffle.value = shuffle;
    });
    audioPlayer.speedStream.listen((speed) {
      playbackSpeed.value = speed;
    });
    audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        // Audio finished playing
        playNextSurah();
      }
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    searchController.dispose();
    _debounce?.cancel();
    audioPlayer.dispose();
    super.onClose();
  }

  Future<void> loadAndPlayAudio(int surahId, int reciterId) async {
    try {
      isAudioLoading.value = true;
      final response = await Request().get(
        Url.surahAudio,
        queryParameters: {'surah_id': surahId, 'reciter_id': reciterId},
      );

      if (response.statusCode == 200) {
        final String? audioUrl = response.data['data']['audio_url'];

        if (audioUrl != null) {
          final audioSource = AudioSource.uri(
            Uri.parse(audioUrl),
            tag: surahId,
          );

          await audioPlayer.setAudioSource(audioSource);
          audioPlayer.play();
        } else {
          AppToast.error(message: 'Audio surah tidak tersedia');
        }
      } else {
        AppToast.error(message: 'Gagal memuat audio surah');
      }
    } catch (e) {
      print("Error loading audio: $e");
      AppToast.error(message: 'Terjadi kesalahan saat memuat audio');
    } finally {
      isAudioLoading.value = false;
    }
  }

  void togglePlay(int id) {
    if (playingSurahId.value == id) {
      // Toggle play/pause for current track
      if (audioPlayer.playing) {
        audioPlayer.pause();
      } else {
        audioPlayer.play();
      }
    } else {
      // Play new track
      playingSurahId.value = id;

      final surah = surahList.firstWhereOrNull((s) => s.id == id);
      if (surah != null) {
        lastPlayingSurah.value = surah;
      }

      if (selectedReciter.value != null) {
        loadAndPlayAudio(id, selectedReciter.value!.id);
      } else {
        AppToast.error(message: 'Pilih qori terlebih dahulu');
      }
    }
  }

  void seek(Duration pos) {
    audioPlayer.seek(pos);
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

      playingSurahId.value = prevSurah.id;
      lastPlayingSurah.value = prevSurah;

      if (selectedReciter.value != null) {
        loadAndPlayAudio(prevSurah.id, selectedReciter.value!.id);
      }
    } else if (currentIndex == 0) {
      // If it's the first surah, just seek to start
      audioPlayer.seek(Duration.zero);
    }
  }

  void playNextSurah() {
    if (playingSurahId.value == null) return;

    final currentIndex = surahList.indexWhere(
      (s) => s.id == playingSurahId.value,
    );
    if (currentIndex != -1 && currentIndex < surahList.length - 1) {
      final nextSurah = surahList[currentIndex + 1];

      playingSurahId.value = nextSurah.id;
      lastPlayingSurah.value = nextSurah;

      if (selectedReciter.value != null) {
        loadAndPlayAudio(nextSurah.id, selectedReciter.value!.id);
      }
    }
  }

  void toggleSpeed() {
    double nextSpeed = 1.0;
    if (playbackSpeed.value == 1.0) {
      nextSpeed = 1.25;
    } else if (playbackSpeed.value == 1.25) {
      nextSpeed = 1.5;
    } else if (playbackSpeed.value == 1.5) {
      nextSpeed = 2.0;
    } else {
      nextSpeed = 1.0;
    }
    audioPlayer.setSpeed(nextSpeed);
  }

  void toggleShuffle() {
    audioPlayer.setShuffleModeEnabled(!isShuffle.value);
  }

  void toggleRepeat() {
    audioPlayer.setLoopMode(isRepeat.value ? LoopMode.off : LoopMode.all);
  }

  DropdownSurah? get currentPlayingSurah {
    if (playingSurahId.value == null) return null;
    return surahList.firstWhereOrNull((s) => s.id == playingSurahId.value);
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
      print("Error fetching reciters: $e");
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
      print("Error fetching surah list: $e");
      AppToast.error(message: 'Terjadi kesalahan koneksi');
    } finally {
      isLoading.value = false;
      isLoadMoreLoading.value = false;
    }
  }
}
