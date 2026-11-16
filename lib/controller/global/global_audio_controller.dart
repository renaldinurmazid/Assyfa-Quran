import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/models/dropdown_surah_model.dart';
import 'package:quran_app/models/reciter_model.dart';
import 'package:quran_app/widgets/app_toast.dart';

class GlobalAudioController extends GetxController {
  static GlobalAudioController get to => Get.find();

  final AudioPlayer audioPlayer = AudioPlayer();

  // State variables for global mini player and MP3 screen
  final playingSurahId = RxnInt();
  final isPlaying = false.obs;
  final isAudioLoading = false.obs;

  // Track details
  final currentSurah = Rxn<DropdownSurah>();
  final currentReciter = Rxn<ReciterModel>();

  final position = Duration.zero.obs;
  final duration = Duration.zero.obs;
  final isShuffle = false.obs;
  final isRepeat = false.obs;
  final playbackSpeed = 1.0.obs;
  final currentAyahIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
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
        // We do not manually set isPlaying.value = false here anymore.
        // If there's no next track, the controller should call pause() or stop().
        // If there is a next track, it will load and play, keeping playingStream as true.
      }
    });
  }

  Future<void> loadAndPlayAudio(
    DropdownSurah surah,
    ReciterModel reciter,
  ) async {
    try {
      if (playingSurahId.value == surah.id &&
          currentReciter.value?.id == reciter.id) {
        // Already playing/paused the exact same track
        if (!audioPlayer.playing) {
          audioPlayer.play();
        }
        return;
      }

      isAudioLoading.value = true;
      playingSurahId.value = surah.id;
      currentSurah.value = surah;
      currentReciter.value = reciter;

      final response = await Request().get(
        Url.surahAudio,
        queryParameters: {'surah_id': surah.id, 'reciter_id': reciter.id},
      );

      if (response.statusCode == 200) {
        final String? audioUrl = response.data['data']['audio_url'];

        if (audioUrl != null) {
          final audioSource = AudioSource.uri(
            Uri.parse(audioUrl),
            tag: MediaItem(
              id: '${surah.id}_${reciter.id}',
              album: "Quranuna Murottal",
              title: surah.name,
              artist: reciter.name,
              artUri: Uri.parse(
                'https://img.magnific.com/free-vector/holy-kaaba-mecca-saudi-arabia-hand-drawn-sketch-vector-illustration_460848-9985.jpg?t=st=1784350527~exp=1784354127~hmac=425d8e0cc9bb6016fd168fe3420bf1741df509cfa3c329c374f515123648b1f0&w=2000',
              ),
            ),
          );

          await audioPlayer.setAudioSource(audioSource);
          audioPlayer.play();
        } else {
          _resetState();
        }
      } else {
        AppToast.error(message: 'Gagal memuat audio surah');
        _resetState();
      }
    } catch (e) {
      print("Error loading audio: $e");
      AppToast.error(message: 'Terjadi kesalahan saat memuat audio');
      _resetState();
    } finally {
      isAudioLoading.value = false;
    }
  }

  void togglePlay() {
    if (audioPlayer.playing) {
      audioPlayer.pause();
    } else {
      audioPlayer.play();
    }
  }

  void _resetState() {
    playingSurahId.value = null;
    currentSurah.value = null;
    audioPlayer.stop();
  }

  void closePlayer() {
    _resetState();
  }

  @override
  void onClose() {
    audioPlayer.dispose();
    super.onClose();
  }
}
