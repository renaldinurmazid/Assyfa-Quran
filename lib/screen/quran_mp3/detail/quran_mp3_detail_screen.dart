import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:quran_app/screen/quran_mp3/quran_mp3_controller.dart';
import 'package:quran_app/models/dropdown_surah_model.dart';
import 'package:quran_app/theme/font.dart';
import 'package:quran_app/widgets/app_toast.dart';

class QuranMp3DetailScreen extends StatefulWidget {
  const QuranMp3DetailScreen({super.key});

  @override
  State<QuranMp3DetailScreen> createState() => _QuranMp3DetailScreenState();
}

class _QuranMp3DetailScreenState extends State<QuranMp3DetailScreen> {
  late DropdownSurah activeSurah;

  @override
  void initState() {
    super.initState();
    activeSurah =
        Get.arguments as DropdownSurah? ??
        DropdownSurah(
          id: 1,
          name: "Al-Fatihah",
          translationName: "Pembukaan",
          cityName: "Makkiyah",
          totalAyah: 7,
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<QuranMp3Controller>();
      if (controller.playingSurahId.value != activeSurah.id) {
        controller.togglePlay(activeSurah.id);
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    // Find the shared QuranMp3Controller
    final controller = Get.find<QuranMp3Controller>();

    final isDark = context.isDarkMode;
    final primaryColor = Theme.of(context).primaryColor;
    final onSurface = context.theme.colorScheme.onSurface;
    final onSurfaceVariant = Colors.grey.shade500;

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back, color: onSurface, size: 32),
        //   onPressed: () => Get.back(),
        // ),
        // actions: [
        //   IconButton(
        //     icon: Icon(
        //       Icons.more_horiz_rounded,
        //       color: onSurface,
        //     ),
        //     onPressed: () {},
        //   ),
        // ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 24),

                    // 1. Clean Artwork Display
                    Hero(
                      tag: 'kaaba_art_detail',
                      child: Container(
                        height: MediaQuery.of(context).size.width - 48,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.grey.shade200,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                isDark ? 0.3 : 0.05,
                              ),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            'assets/images/jpg/4911.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),

                    // 2. Surah and Reciter details
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activeSurah.name,
                                style: pBold24.copyWith(
                                  color: onSurface,
                                  letterSpacing: -0.5,
                                  fontSize: 28,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _showReciterPicker(
                                    context,
                                    controller,
                                    isDark,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                      horizontal: 2,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Obx(
                                          () => Text(
                                            controller
                                                    .selectedReciter
                                                    .value
                                                    ?.name ??
                                                'Memilih Qori...',
                                            style: pRegular16.copyWith(
                                              color: primaryColor,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: primaryColor,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // IconButton(
                        //   onPressed: () {
                        //     AppToast.success(message: 'Ditambahkan ke Favorit');
                        //   },
                        //   icon: Icon(
                        //     Icons.favorite_border_rounded,
                        //     color: onSurfaceVariant,
                        //     size: 28,
                        //   ),
                        // ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 3. Audio Progress Slider
                    Obx(() {
                      final position = controller.position.value;
                      final duration = controller.duration.value;
                      double sliderValue = position.inMilliseconds.toDouble();
                      double sliderMax = duration.inMilliseconds.toDouble();
                      if (sliderMax <= 0) sliderMax = 1.0;
                      if (sliderValue < 0.0) sliderValue = 0.0;
                      if (sliderValue > sliderMax) sliderValue = sliderMax;

                      return Column(
                        children: [
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: onSurface,
                              inactiveTrackColor: isDark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade200,
                              thumbColor: onSurface,
                              trackHeight: 4.0,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6.0,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 16.0,
                              ),
                            ),
                            child: Slider(
                              value: sliderValue,
                              min: 0.0,
                              max: sliderMax,
                              onChanged: (value) {
                                controller.seek(
                                  Duration(milliseconds: value.toInt()),
                                );
                              },
                            ),
                          ),
                          // Time Indicators
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(position),
                                style: pMedium12.copyWith(
                                  color: onSurfaceVariant,
                                ),
                              ),
                              Text(
                                _formatDuration(duration),
                                style: pMedium12.copyWith(
                                  color: onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }),

                    const SizedBox(height: 32),

                    // 4. Media Controller buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Shuffle
                        Obx(
                          () => IconButton(
                            icon: Icon(
                              Icons.shuffle_rounded,
                              color: controller.isShuffle.value
                                  ? primaryColor
                                  : onSurfaceVariant,
                              size: 24,
                            ),
                            onPressed: () {
                              controller.toggleShuffle();
                            },
                          ),
                        ),
                        // Skip Previous
                        IconButton(
                          icon: Icon(
                            Icons.skip_previous_rounded,
                            color: onSurface,
                            size: 40,
                          ),
                          onPressed: () {
                            controller.previous();
                          },
                        ),
                        // Play/Pause button
                        Obx(() {
                          final isPlaying = controller.isPlaying.value;
                          final isLoading = controller.isAudioLoading.value;
                          return GestureDetector(
                            onTap: () {
                              if (!isLoading) {
                                controller.togglePlay(activeSurah.id);
                              }
                            },
                            child: Container(
                              height: 72,
                              width: 72,
                              decoration: BoxDecoration(
                                color: onSurface,
                                shape: BoxShape.circle,
                              ),
                              child: isLoading
                                  ? Padding(
                                      padding: const EdgeInsets.all(24.0),
                                      child: CircularProgressIndicator(
                                        color: context
                                            .theme
                                            .scaffoldBackgroundColor,
                                        strokeWidth: 3,
                                      ),
                                    )
                                  : Icon(
                                      isPlaying
                                          ? Icons.pause_rounded
                                          : Icons.play_arrow_rounded,
                                      color:
                                          context.theme.scaffoldBackgroundColor,
                                      size: 40,
                                    ),
                            ),
                          );
                        }),
                        // Skip Next
                        IconButton(
                          icon: Icon(
                            Icons.skip_next_rounded,
                            color: onSurface,
                            size: 40,
                          ),
                          onPressed: () {
                            controller.next();
                          },
                        ),
                        // Repeat
                        Obx(
                          () => IconButton(
                            icon: Icon(
                              Icons.repeat_rounded,
                              color: controller.isRepeat.value
                                  ? primaryColor
                                  : onSurfaceVariant,
                              size: 24,
                            ),
                            onPressed: () {
                              controller.toggleRepeat();
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 48),

                    // 5. Utility row (Speed, Timer, Share, Playlist)
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     // Speed
                    //     InkWell(
                    //       onTap: () {
                    //         setState(() {
                    //           if (_recitationSpeed == 1.0) {
                    //             _recitationSpeed = 1.25;
                    //           } else if (_recitationSpeed == 1.25) {
                    //             _recitationSpeed = 1.5;
                    //           } else if (_recitationSpeed == 1.5) {
                    //             _recitationSpeed = 2.0;
                    //           } else {
                    //             _recitationSpeed = 1.0;
                    //           }
                    //         });
                    //       },
                    //       borderRadius: BorderRadius.circular(100),
                    //       child: Container(
                    //         padding: const EdgeInsets.symmetric(
                    //           horizontal: 16,
                    //           vertical: 8,
                    //         ),
                    //         decoration: BoxDecoration(
                    //           borderRadius: BorderRadius.circular(100),
                    //           color: isDark
                    //               ? Colors.grey.shade900
                    //               : Colors.grey.shade100,
                    //         ),
                    //         child: Row(
                    //           children: [
                    //             Icon(
                    //               Icons.speed_rounded,
                    //               size: 16,
                    //               color: onSurfaceVariant,
                    //             ),
                    //             const SizedBox(width: 6),
                    //             Text(
                    //               '${_recitationSpeed}x',
                    //               style: pSemiBold12.copyWith(
                    //                 color: onSurfaceVariant,
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //     ),
                    //     const SizedBox(width: 16),
                    //     // Sleep Timer
                    //     IconButton(
                    //       icon: Icon(
                    //         Icons.access_time_rounded,
                    //         color: onSurfaceVariant,
                    //         size: 24,
                    //       ),
                    //       onPressed: () {
                    //         AppToast.success(
                    //           message: 'Pengatur waktu tidur diaktifkan',
                    //         );
                    //       },
                    //     ),
                    //     const SizedBox(width: 16),
                    //     // Share
                    //     IconButton(
                    //       icon: Icon(
                    //         Icons.share_outlined,
                    //         color: onSurfaceVariant,
                    //         size: 24,
                    //       ),
                    //       onPressed: () {
                    //         AppToast.success(
                    //           message: 'Membagikan audio Murottal',
                    //         );
                    //       },
                    //     ),
                    //     const SizedBox(width: 16),
                    //     // Playlist
                    //     IconButton(
                    //       icon: Icon(
                    //         Icons.playlist_play_rounded,
                    //         color: onSurfaceVariant,
                    //         size: 28,
                    //       ),
                    //       onPressed: () {
                    //         AppToast.success(message: 'Menampilkan antrean');
                    //       },
                    //     ),
                    //   ],
                    // ),
                    // const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReciterPicker(
    BuildContext context,
    QuranMp3Controller controller,
    bool isDark,
  ) {
    final TextEditingController reciterSearchController = TextEditingController();
    final RxString searchReciterQuery = ''.obs;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final isDark = context.isDarkMode;
        final primaryColor = Theme.of(context).primaryColor;

        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pilih Qori',
                        style: pBold20.copyWith(
                          color: context.theme.colorScheme.onSurface,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: context.theme.colorScheme.onSurface),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                ),

                // Search Input
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade900 : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: reciterSearchController,
                      onChanged: (value) => searchReciterQuery.value = value,
                      cursorColor: primaryColor,
                      style: pMedium14.copyWith(
                        color: context.theme.colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Cari qori...',
                        hintStyle: pRegular14.copyWith(
                          color: Colors.grey.shade500,
                        ),
                        prefixIcon: Icon(
                          IconlyLight.search,
                          color: Colors.grey.shade500,
                          size: 20,
                        ),
                        suffixIcon: Obx(() => searchReciterQuery.value.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.close,
                                  color: Colors.grey.shade500,
                                  size: 20,
                                ),
                                onPressed: () {
                                  reciterSearchController.clear();
                                  searchReciterQuery.value = '';
                                },
                              )
                            : const SizedBox.shrink()),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Reciter List
                Expanded(
                  child: Obx(() {
                    if (controller.isRecitersLoading.value && controller.reciters.isEmpty) {
                      return Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      );
                    }

                    final filteredReciters = controller.reciters.where((reciter) {
                      return reciter.name.toLowerCase().contains(searchReciterQuery.value.toLowerCase());
                    }).toList();

                    if (filteredReciters.isEmpty) {
                      return Center(
                        child: Text(
                          'Qori tidak ditemukan',
                          style: pMedium14.copyWith(color: Colors.grey.shade600),
                        ),
                      );
                    }

                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      itemCount: filteredReciters.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      ),
                      itemBuilder: (context, index) {
                        final reciter = filteredReciters[index];
                        final isSelected = controller.selectedReciter.value?.id == reciter.id;

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            reciter.name,
                            style: pMedium16.copyWith(
                              color: isSelected ? primaryColor : context.theme.colorScheme.onSurface,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(Icons.check_circle, color: primaryColor)
                              : null,
                          onTap: () {
                            controller.selectedReciter.value = reciter;
                            Get.back();
                            AppToast.success(
                              message: 'Qori diubah ke ${reciter.name}',
                            );
                            // Reload audio with new reciter
                            controller.loadAndPlayAudio(activeSurah.id, reciter.id);
                          },
                        );
                      },
                    );
                  }),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
