import 'dart:io';
import 'package:flutter/foundation.dart';

class PlatformService {
  /// Mendapatkan nama platform sebagai string kecil: 'android', 'ios', 'web', 'macos', 'windows', 'linux', atau 'unknown'
  static String get currentPlatform {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isWindows) return 'windows';
    if (Platform.isLinux) return 'linux';
    return 'unknown';
  }

  /// Mengecek apakah platform saat ini adalah mobile (Android atau iOS)
  static bool get isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// Mengecek apakah platform saat ini adalah desktop (MacOS, Windows, atau Linux)
  static bool get isDesktop => !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

  /// Mengecek apakah platform saat ini adalah Web
  static bool get isWeb => kIsWeb;
}
