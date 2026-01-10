import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:quran_app/models/quran_list_detail_model.dart';
import 'package:flutter/services.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class QuranListDetailScreenController extends GetxController {
  final isLoading = false.obs;
  final data = Rxn<Data>();
  final audioPlayer = AudioPlayer();
  final isPlaying = false.obs;
  final selectedReciter = '01'.obs;
  final currentAyahIndex = 0.obs;

  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  final reciters = [
    {"code": "01", "name": "Abdullah Al-Juhany"},
    {"code": "02", "name": "Abdul Muhsin Al-Qasim"},
    {"code": "03", "name": "Abdurrahman As-Sudais"},
    {"code": "04", "name": "Ibrahim Al-Dossari"},
    {"code": "05", "name": "Misyari Rasyid Al-Afasi"},
    {"code": "06", "name": "Yasser Al-Dosari"},
  ];

  @override
  void onInit() async {
    super.onInit();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    final nomorSurat = Get.arguments;
    await getQuranListDetail(nomorSurat);

    // Listen to playback state
    audioPlayer.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
    });

    // Listen to current index for auto-scroll
    audioPlayer.currentIndexStream.listen((index) {
      if (index != null) {
        currentAyahIndex.value = index;
        if (itemScrollController.isAttached) {
          itemScrollController.scrollTo(
            index: index,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOutCubic,
          );
        }
      }
    });
  }

  @override
  void onClose() {
    audioPlayer.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.onClose();
  }

  Future<void> getQuranListDetail(int nomorSurat) async {
    isLoading.value = true;
    final response = await http.get(
      Uri.parse('https://equran.id/api/v2/surat/$nomorSurat'),
    );
    if (response.statusCode == 200) {
      data.value = quranListDetailModelFromJson(response.body).data;
    } else {
      Get.snackbar('Error', 'Failed to fetch data');
    }
    isLoading.value = false;
  }

  void onReciterChanged(String? value) async {
    if (value != null) {
      final wasPlaying = audioPlayer.playing;
      final currentIndex = audioPlayer.currentIndex;
      final currentPosition = audioPlayer.position;

      selectedReciter.value = value;

      // Only update source if it's already been initialized
      if (audioPlayer.processingState != ProcessingState.idle) {
        try {
          await _setAudioSource(
            initialIndex: currentIndex,
            initialPosition: currentPosition,
          );
          if (wasPlaying) {
            audioPlayer.play();
          }
        } catch (e) {
          Get.snackbar('Error', 'Gagal mengubah qori: $e');
        }
      }
    }
  }

  Future<void> _setAudioSource({
    int? initialIndex,
    Duration? initialPosition,
  }) async {
    if (data.value == null) return;

    final playlist = ConcatenatingAudioSource(
      children: data.value!.ayat.map((ayat) {
        return AudioSource.uri(Uri.parse(ayat.audio[selectedReciter.value]!));
      }).toList(),
    );

    await audioPlayer.setAudioSource(
      playlist,
      initialIndex: initialIndex,
      initialPosition: initialPosition,
    );
  }

  Future<void> playPauseAudio() async {
    try {
      if (isPlaying.value) {
        await audioPlayer.pause();
      } else {
        if (audioPlayer.processingState == ProcessingState.idle ||
            audioPlayer.processingState == ProcessingState.completed) {
          await _setAudioSource();
        }
        await audioPlayer.play();
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memutar audio: $e');
    }
  }

  Future<void> stopAudio() async {
    await audioPlayer.stop();
    isPlaying.value = false;
  }
}
