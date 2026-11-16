import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Short sound effects of the Arabic course (bundled in `assets/audio/`).
class ArabicSfx {
  ArabicSfx._();

  /// Paths relative to `assets/`, as [AssetSource] expects.
  static const correct = 'audio/answer-correct.mp3';
  static const wrong = 'audio/answer-wrong.mp3';
  static const levelCompleted = 'audio/completed-level.mp3';

  static AudioPlayer? _player;

  /// A cue must not pause the Quran/adzan audio that may be playing in the
  /// background, so it takes no audio focus and uses the `ambient` iOS category,
  /// which mixes with other audio by itself (and follows the silent switch).
  /// Note `mixWithOthers` must not be passed with `ambient`: audioplayers asserts.
  static AudioContext get context => AudioContext(
    android: const AudioContextAndroid(audioFocus: AndroidAudioFocus.none),
    iOS: AudioContextIOS(category: AVAudioSessionCategory.ambient),
  );

  static AudioPlayer get _sfx => _player ??= AudioPlayer();

  static Future<void> answer({required bool isCorrect}) =>
      _play(isCorrect ? correct : wrong);

  static Future<void> celebrateLevel() => _play(levelCompleted);

  static Future<void> _play(String asset) async {
    try {
      final player = _sfx;
      await player.setAudioContext(context);
      await player.stop(); // a new cue replaces one still playing
      await player.play(AssetSource(asset));
    } catch (e) {
      // A sound effect is never worth failing the quiz over.
      debugPrint('ArabicSfx: could not play $asset: $e');
    }
  }
}
