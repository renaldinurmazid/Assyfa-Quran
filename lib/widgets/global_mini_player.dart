import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/controller/global/global_audio_controller.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/theme/font.dart';

class GlobalMiniPlayer extends StatelessWidget {
  const GlobalMiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = GlobalAudioController.to;
    final isDark = context.isDarkMode;
    final primaryColor = Theme.of(context).primaryColor;

    return Obx(() {
      final surah = audio.currentSurah.value;
      if (surah == null) return const SizedBox.shrink();

      final isPlaying = audio.isPlaying.value;
      final isLoading = audio.isAudioLoading.value;
      final reciter = audio.currentReciter.value;

      return Container(
        decoration: BoxDecoration(
          color: context.theme.scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            SafeArea(
              top: false,
              bottom: false,
              child: InkWell(
                onTap: () {
                  // Open detail page or mp3 screen
                  Get.toNamed(Routes.quranMp3Detail, arguments: surah);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Hero(
                        tag: 'kaaba_art_detail_global',
                        child: Container(
                          height: 44,
                          width: 44,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              'assets/images/jpg/4911.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              surah.name,
                              style: pSemiBold14.copyWith(
                                color: context.theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              reciter?.name ?? 'Syeikh Mishary Rashid',
                              style: pRegular12.copyWith(
                                color: Colors.grey.shade500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      isLoading
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                              ),
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: primaryColor,
                                ),
                              ),
                            )
                          : IconButton(
                              onPressed: () {
                                audio.togglePlay();
                              },
                              icon: Icon(
                                isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: primaryColor,
                                size: 32,
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -8,
              right: 16,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    audio.closePlayer();
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade800 : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                        color: isDark
                            ? Colors.grey.shade700
                            : Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: isDark
                          ? Colors.grey.shade300
                          : Colors.grey.shade600,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
