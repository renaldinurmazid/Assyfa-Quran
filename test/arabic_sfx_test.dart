import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_app/screen/arabic-quran/arabic_sfx.dart';

void main() {
  test('every sound effect points at a bundled audio asset', () {
    for (final path in [
      ArabicSfx.correct,
      ArabicSfx.wrong,
      ArabicSfx.levelCompleted,
    ]) {
      expect(File('assets/$path').existsSync(), isTrue, reason: path);
    }
  });

  test('audio context is valid (audioplayers asserts on bad iOS options)', () {
    expect(() => ArabicSfx.context, returnsNormally);
  });

  test('assets/audio is declared in pubspec', () {
    expect(
      File('pubspec.yaml').readAsStringSync(),
      contains('- assets/audio/'),
    );
  });
}
