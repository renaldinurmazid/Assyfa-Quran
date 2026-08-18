import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:quran_app/screen/quran_mp3/quran_mp3_controller.dart';
import 'package:quran_app/theme/font.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/models/dropdown_surah_model.dart';

class QuranMp3Screen extends StatefulWidget {
  const QuranMp3Screen({super.key});

  @override
  State<QuranMp3Screen> createState() => _QuranMp3ScreenState();
}

class _QuranMp3ScreenState extends State<QuranMp3Screen> {
  DropdownSurah? _lastActiveSurah;
  late final QuranMp3Controller controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<QuranMp3Controller>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showReciterBottomSheet();
    });
  }

  void _showReciterBottomSheet() {
    final TextEditingController reciterSearchController =
        TextEditingController();
    final RxString searchReciterQuery = ''.obs;
    bool hasScrolledToInitial = false;

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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
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
                        icon: Icon(
                          Icons.close,
                          color: context.theme.colorScheme.onSurface,
                        ),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                ),

                // Search Input
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey.shade900
                          : const Color(0xFFF5F5F5),
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
                        suffixIcon: Obx(
                          () => searchReciterQuery.value.isNotEmpty
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
                              : const SizedBox.shrink(),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Reciter List
                Expanded(
                  child: Obx(() {
                    if (controller.isRecitersLoading.value &&
                        controller.reciters.isEmpty) {
                      return Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      );
                    }

                    final filteredReciters = controller.reciters.where((
                      reciter,
                    ) {
                      return reciter.name.toLowerCase().contains(
                        searchReciterQuery.value.toLowerCase(),
                      );
                    }).toList();

                    if (filteredReciters.isEmpty) {
                      return Center(
                        child: Text(
                          'Qori tidak ditemukan',
                          style: pMedium14.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      );
                    }

                    if (!hasScrolledToInitial &&
                        controller.selectedReciter.value != null &&
                        filteredReciters.isNotEmpty) {
                      final selectedIndex = filteredReciters.indexWhere(
                        (r) => r.id == controller.selectedReciter.value?.id,
                      );
                      if (selectedIndex > 0) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (scrollController.hasClients) {
                            final maxScroll =
                                scrollController.position.maxScrollExtent;
                            final offset = (selectedIndex * 57.0).clamp(
                              0.0,
                              maxScroll,
                            );
                            scrollController.jumpTo(offset);
                          }
                        });
                      }
                      hasScrolledToInitial = true;
                    }

                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      itemCount: filteredReciters.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                      ),
                      itemBuilder: (context, index) {
                        final reciter = filteredReciters[index];
                        final isSelected =
                            controller.selectedReciter.value?.id == reciter.id;

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            reciter.name,
                            style: pMedium16.copyWith(
                              color: isSelected
                                  ? primaryColor
                                  : context.theme.colorScheme.onSurface,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(Icons.check_circle, color: primaryColor)
                              : null,
                          onTap: () {
                            controller.selectedReciter.value = reciter;
                            if (controller.playingSurahId.value != null) {
                              controller.loadAndPlayAudio(
                                controller.playingSurahId.value!,
                                reciter.id,
                              );
                            }
                            Get.back();
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

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Murottal',
          style: pBold20.copyWith(
            color: context.theme.colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
        backgroundColor: context.theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: context.theme.colorScheme.onSurface),
        actions: [
          IconButton(
            icon: Icon(
              Icons.record_voice_over_outlined,
              color: context.theme.colorScheme.onSurface,
            ),
            onPressed: _showReciterBottomSheet,
            tooltip: 'Pilih Qori',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          CustomScrollView(
            controller: controller.scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 2. Minimalist Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey.shade900
                          : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Obx(
                      () => TextField(
                        controller: controller.searchController,
                        onChanged: controller.onSearchChanged,
                        cursorColor: primaryColor,
                        style: pMedium14.copyWith(
                          color: context.theme.colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Cari surah...',
                          hintStyle: pRegular14.copyWith(
                            color: Colors.grey.shade500,
                          ),
                          prefixIcon: Icon(
                            IconlyLight.search,
                            color: Colors.grey.shade500,
                            size: 20,
                          ),
                          suffixIcon: controller.searchQuery.value.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.grey.shade500,
                                    size: 20,
                                  ),
                                  onPressed: controller.clearSearch,
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 3. Surah List Observer
              Obx(() {
                if (controller.isLoading.value &&
                    controller.surahList.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    ),
                  );
                }

                if (controller.surahList.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/png/no-data-illustration.png',
                            height: 260,
                          ),
                          Text(
                            'Surah tidak ditemukan',
                            style: pMedium14.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final surah = controller.surahList[index];

                    return Obx(() {
                      final isCurrentPlaying =
                          controller.playingSurahId.value == surah.id;
                      final isPlaying =
                          isCurrentPlaying && controller.isPlaying.value;

                      return Column(
                        children: [
                          InkWell(
                            onTap: () => controller.togglePlay(surah.id),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              child: Row(
                                children: [
                                  // Number
                                  SizedBox(
                                    width: 32,
                                    child: Text(
                                      surah.id.toString().padLeft(2, '0'),
                                      style: pMedium14.copyWith(
                                        color: isCurrentPlaying
                                            ? primaryColor
                                            : Colors.grey.shade500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          surah.name,
                                          style: pSemiBold16.copyWith(
                                            color: isCurrentPlaying
                                                ? primaryColor
                                                : context
                                                      .theme
                                                      .colorScheme
                                                      .onSurface,
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${surah.cityName} • ${surah.totalAyah} Ayat',
                                          style: pRegular12.copyWith(
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Playing Indicator / Action
                                  if (isCurrentPlaying && isPlaying)
                                    _buildPulsingBars(primaryColor)
                                  else if (isCurrentPlaying &&
                                      controller.isAudioLoading.value)
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: primaryColor,
                                      ),
                                    )
                                  else if (isCurrentPlaying && !isPlaying)
                                    Icon(
                                      Icons.play_arrow_rounded,
                                      color: primaryColor,
                                      size: 20,
                                    )
                                  else
                                    Icon(
                                      Icons.play_arrow_rounded,
                                      color: Colors.grey.shade300,
                                      size: 20,
                                    ),
                                ],
                              ),
                            ),
                          ),
                          // Minimalist Divider
                          if (index < controller.surahList.length - 1)
                            Divider(
                              height: 1,
                              thickness: 1,
                              indent: 64, // Aligns with text
                              endIndent: 20,
                              color: isDark
                                  ? Colors.grey.shade900
                                  : Colors.grey.shade100,
                            ),
                        ],
                      );
                    });
                  }, childCount: controller.surahList.length),
                );
              }),

              // 4. Load More Spinner
              Obx(() {
                if (controller.isLoadMoreLoading.value) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(
                        child: SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ),
                  );
                }
                return const SliverToBoxAdapter(child: SizedBox(height: 24));
              }),

              // Space for bottom player
              SliverToBoxAdapter(
                child: Obx(
                  () => SizedBox(
                    height: controller.playingSurahId.value != null ? 100 : 24,
                  ),
                ),
              ),
            ],
          ),

          // 5. Minimalist Docked Player
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Obx(() {
              final activeSurah = controller.currentPlayingSurah;
              if (activeSurah != null) {
                _lastActiveSurah = activeSurah;
              }
              final displaySurah = activeSurah ?? _lastActiveSurah;
              final showPlayer = activeSurah != null;

              return AnimatedSlide(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                offset: showPlayer ? Offset.zero : const Offset(0, 1.0),
                child: displaySurah != null
                    ? _buildMinimalistBottomPlayer(
                        context,
                        controller,
                        displaySurah,
                        primaryColor,
                        isDark,
                      )
                    : const SizedBox.shrink(),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalistBottomPlayer(
    BuildContext context,
    QuranMp3Controller controller,
    DropdownSurah surah,
    Color primaryColor,
    bool isDark,
  ) {
    final isPlaying = controller.isPlaying.value;
    final isLoading = controller.isAudioLoading.value;

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
      child: SafeArea(
        top: false,
        child: InkWell(
          onTap: () {
            Get.toNamed(Routes.quranMp3Detail, arguments: surah);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                // Clean Artwork
                Hero(
                  tag: 'kaaba_art_detail',
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

                // Track Info
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
                      Obx(
                        () => Text(
                          controller.selectedReciter.value?.name ??
                              'Syeikh Mishary Rashid',
                          style: pRegular12.copyWith(
                            color: Colors.grey.shade500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                // Minimal Controls
                // IconButton(
                //   icon: Icon(
                //     IconlyLight.heart,
                //     color: Colors.grey.shade500,
                //     size: 24,
                //   ),
                //   onPressed: () {
                //     AppToast.success(message: 'Ditambahkan ke Favorit');
                //   },
                // ),
                isLoading
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
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
                          controller.togglePlay(surah.id);
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
    );
  }

  Widget _buildPulsingBars(Color color) {
    return SizedBox(
      height: 14,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildBar(8, color),
          const SizedBox(width: 2),
          _buildBar(14, color),
          const SizedBox(width: 2),
          _buildBar(10, color),
          const SizedBox(width: 2),
          _buildBar(12, color),
        ],
      ),
    );
  }

  Widget _buildBar(double height, Color color) {
    return Container(
      width: 2.5,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
