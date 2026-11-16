// Quran Page Screen
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/screen/quran_view/quran_page_screen_controller.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';
import 'package:cached_network_image/cached_network_image.dart';

class QuranPageScreen extends StatelessWidget {
  const QuranPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(QuranPageScreenController());
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;

        final bool? shouldPop = await Get.dialog<bool>(
          Builder(
            builder: (context) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColor.globalBorder),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          LucideIcons.info,
                          color: AppColor.globalTextSecondary,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Akhiri Bacaan?',
                        style: pBold18.copyWith(color: AppColor.primaryColor),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Apakah Anda yakin ingin mengakhiri bacaan Al-Quran?',
                        style: pRegular14.copyWith(
                          color: AppColor.globalTextSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Get.back(result: false),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Lanjutkan',
                                style: pSemiBold14.copyWith(
                                  color: Theme.of(context).hintColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Get.back(result: true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: context.isDarkMode
                                    ? AppColor.primaryColorDark
                                    : AppColor.primaryColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Ya, Keluar',
                                style: pSemiBold14.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );

        if (shouldPop == true) {
          // Always close the screen after attempting to save history
          await controller.saveReadingHistory();
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColor.backgroundColor,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Obx(() {
            if (controller.isLoading.value && controller.dataPage.isEmpty) {
              return const SizedBox.shrink();
            }
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: controller.isFocus.value
                  ? 0
                  : kToolbarHeight + MediaQuery.of(context).padding.top,
              child: SingleChildScrollView(
                child: AppBar(
                  centerTitle: false,
                  titleSpacing: 0,
                  leading: IconButton(
                    onPressed: () async {
                      Navigator.maybePop(context);
                    },
                    icon: const Icon(LucideIcons.arrowLeft),
                  ),
                  title: Obx(() {
                    if (controller.dataPage.isEmpty) {
                      return Text('Al-Quran', style: pBold18);
                    }
                    final currentPage =
                        controller.dataPage[controller.currentPageIndex.value];
                    final surahs = currentPage.ayahs
                        .map((e) => e.ayah?.surah?.name ?? '')
                        .where((name) => name.isNotEmpty)
                        .toSet()
                        .toList();
                    return InkWell(
                      onTap: () {
                        controller.fetchDropdownSurah('');
                        controller.fetchDropdownJuz();
                        controller.tabIsSurat.value = true;
                        Get.dialog(_buildSearchSurah(context, controller));
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    surahs.join(', '),
                                    style: pBold16.copyWith(
                                      color: AppColor.globalTextSecondary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  IconlyLight.arrow_down_2,
                                  color: AppColor.globalTextSecondary,
                                  size: 14,
                                ),
                              ],
                            ),
                            Text(
                              'Halaman ${currentPage.pageNumber} • Juz ${currentPage.juzNumbers.isNotEmpty ? currentPage.juzNumbers.first : "-"}',
                              style: pMedium12.copyWith(
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  actions: [
                    IconButton(
                      onPressed: () {
                        controller.fetchListPages();
                        controller.initGoToDefaults();
                        controller.tabIsAyah.value = true;
                        Get.dialog(_buildSearchAyah(context, controller));
                      },
                      icon: Icon(
                        LucideIcons.search,
                        color: AppColor.globalTextSecondary,
                        size: 22,
                      ),
                    ),
                    Obx(
                      () => IconButton(
                        onPressed: () => controller.toggleTranslation(),
                        style: IconButton.styleFrom(
                          backgroundColor: controller.isTranslationVisible.value
                              ? AppColor.globalTextSecondary.withOpacity(0.12)
                              : Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        tooltip: 'Terjemahan',
                        icon: Icon(
                          LucideIcons.bookOpen,
                          color: AppColor.globalTextSecondary,
                          size: 22,
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'setLandscape') {
                          controller.isLandscape.value = true;
                          SystemChrome.setPreferredOrientations([
                            DeviceOrientation.landscapeLeft,
                            DeviceOrientation.landscapeRight,
                          ]);
                        }
                        if (value == 'setPortrait') {
                          controller.isLandscape.value = false;
                          SystemChrome.setPreferredOrientations([
                            DeviceOrientation.portraitUp,
                            DeviceOrientation.portraitDown,
                          ]);
                        }
                        if (value == 'info') {
                          Get.toNamed(
                            Routes.quranPageInfo,
                            arguments: {'slug': controller.currentSlug.value},
                          );
                        }
                        if (value == 'download_all') {
                          controller.downloadAllContent();
                        }
                      },
                      icon: Icon(
                        LucideIcons.moreVertical,
                        color: AppColor.globalTextSecondary,
                        size: 22,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      color: Theme.of(context).colorScheme.surface,
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: controller.isLandscape.value
                              ? 'setPortrait'
                              : 'setLandscape',
                          child: Row(
                            children: [
                              Icon(
                                controller.isLandscape.value
                                    ? IconlyLight.document
                                    : IconlyLight.show,
                                color: AppColor.globalTextSecondary,
                                size: 18,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                controller.isLandscape.value
                                    ? 'Mode Potret'
                                    : 'Mode Lanskap',
                                style: pMedium14.copyWith(
                                  color: AppColor.globalTextSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'download_all',
                          child: Row(
                            children: [
                              Icon(
                                IconlyLight.document,
                                color: AppColor.globalTextSecondary,
                                size: 18,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Download Semua',
                                style: pMedium14.copyWith(
                                  color: AppColor.globalTextSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'info',
                          child: Row(
                            children: [
                              Icon(
                                IconlyLight.info_square,
                                color: AppColor.globalTextSecondary,
                                size: 18,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Info Detail',
                                style: pMedium14.copyWith(
                                  color: AppColor.globalTextSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                  ],
                  backgroundColor: Theme.of(
                    context,
                  ).appBarTheme.backgroundColor,
                  elevation: 0,
                  surfaceTintColor: Colors.transparent,
                ),
              ),
            );
          }),
        ),
        body: GestureDetector(
          onTap: () => controller.toggleFocus(),
          child: Stack(
            children: [
              Obx(() {
                if (controller.isLoading.value && controller.dataPage.isEmpty) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                    ),
                  );
                }

                if (controller.dataPage.isEmpty) {
                  return const Center(child: Text('Tidak ada data'));
                }

                return PageView.builder(
                  controller: controller.pageController,
                  itemCount: controller.dataPage.length,
                  reverse: true,
                  onPageChanged: (index) => controller.changePage(index),
                  itemBuilder: (context, index) {
                    final page = controller.dataPage[index];
                    return OrientationBuilder(
                      builder: (context, orientation) {
                        final isLandscape =
                            orientation == Orientation.landscape;

                        if (page.id < 0) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: Theme.of(context).primaryColor,
                            ),
                          );
                        }

                        Widget buildPageContent() {
                          return Obx(() {
                            if (controller.viewportWidth.value == 0) {
                              final localPath =
                                  controller.localImagePaths[page.pageNumber];
                              return localPath != null
                                  ? Image.file(
                                      File(localPath),
                                      fit: isLandscape
                                          ? BoxFit.fitWidth
                                          : BoxFit.contain,
                                      gaplessPlayback: true,
                                      filterQuality: FilterQuality.medium,
                                      errorBuilder: (context, error, stackTrace) {
                                        // Delete the corrupted local file
                                        try {
                                          File(localPath).delete();
                                          controller.localImagePaths.remove(
                                            page.pageNumber,
                                          );
                                        } catch (_) {}

                                        return CachedNetworkImage(
                                          imageUrl: page.imagePath,
                                          fit: isLandscape
                                              ? BoxFit.fitWidth
                                              : BoxFit.contain,
                                          filterQuality: FilterQuality.medium,
                                          placeholder: (context, url) => Center(
                                            child: CircularProgressIndicator(
                                              color: Theme.of(
                                                context,
                                              ).primaryColor,
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              const Center(
                                                child: Icon(
                                                  Icons.error,
                                                  color: Colors.red,
                                                  size: 40,
                                                ),
                                              ),
                                        );
                                      },
                                    )
                                  : CachedNetworkImage(
                                      imageUrl: page.imagePath,
                                      fit: isLandscape
                                          ? BoxFit.fitWidth
                                          : BoxFit.contain,
                                      filterQuality: FilterQuality.medium,
                                      placeholder: (context, url) => Center(
                                        child: CircularProgressIndicator(
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          const Center(
                                            child: Icon(
                                              Icons.error,
                                              color: Colors.red,
                                              size: 40,
                                            ),
                                          ),
                                    );
                            }
                            return LayoutBuilder(
                              builder: (context, constraints) {
                                final viewportWidth =
                                    controller.viewportWidth.value;
                                final viewportHeight =
                                    controller.viewportHeight.value;
                                final screenWidth = constraints.maxWidth;
                                final screenHeight = constraints.maxHeight;

                                final scaleX = screenWidth / viewportWidth;
                                final scaleY = screenHeight / viewportHeight;
                                final scale = isLandscape
                                    ? scaleX
                                    : (scaleX < scaleY ? scaleX : scaleY);

                                final displayWidth = viewportWidth * scale;
                                final displayHeight = viewportHeight * scale;

                                return Center(
                                  child: SizedBox(
                                    width: displayWidth,
                                    height: displayHeight,
                                    child: Stack(
                                      children: [
                                        () {
                                          final localPath = controller
                                              .localImagePaths[page.pageNumber];
                                          return localPath != null
                                              ? Image.file(
                                                  File(localPath),
                                                  width: displayWidth,
                                                  height: displayHeight,
                                                  fit: BoxFit.fill,
                                                  gaplessPlayback: true,
                                                  filterQuality:
                                                      FilterQuality.medium,
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) {
                                                        // Delete the corrupted local file
                                                        try {
                                                          File(
                                                            localPath,
                                                          ).delete();
                                                          controller
                                                              .localImagePaths
                                                              .remove(
                                                                page.pageNumber,
                                                              );
                                                        } catch (_) {}

                                                        return CachedNetworkImage(
                                                          imageUrl:
                                                              page.imagePath,
                                                          width: displayWidth,
                                                          height: displayHeight,
                                                          fit: BoxFit.fill,
                                                          filterQuality:
                                                              FilterQuality
                                                                  .medium,
                                                          placeholder:
                                                              (
                                                                context,
                                                                url,
                                                              ) => Center(
                                                                child: CircularProgressIndicator(
                                                                  color: Theme.of(
                                                                    context,
                                                                  ).primaryColor,
                                                                ),
                                                              ),
                                                          errorWidget:
                                                              (
                                                                context,
                                                                url,
                                                                error,
                                                              ) => const Center(
                                                                child: Icon(
                                                                  Icons.error,
                                                                  color: Colors
                                                                      .red,
                                                                  size: 40,
                                                                ),
                                                              ),
                                                        );
                                                      },
                                                )
                                              : CachedNetworkImage(
                                                  imageUrl: page.imagePath,
                                                  width: displayWidth,
                                                  height: displayHeight,
                                                  fit: BoxFit.fill,
                                                  filterQuality:
                                                      FilterQuality.medium,
                                                  placeholder: (context, url) =>
                                                      Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                              color: Theme.of(
                                                                context,
                                                              ).primaryColor,
                                                            ),
                                                      ),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          const Center(
                                                            child: Icon(
                                                              Icons.error,
                                                              color: Colors.red,
                                                              size: 40,
                                                            ),
                                                          ),
                                                );
                                        }(),
                                        Obx(
                                          () =>
                                              controller.playingAyahId.value !=
                                                  0
                                              ? Stack(
                                                  children: page.ayahs
                                                      .where(
                                                        (m) =>
                                                            m.ayah?.id ==
                                                            controller
                                                                .playingAyahId
                                                                .value,
                                                      )
                                                      .expand((m) => m.blocks)
                                                      .map((block) {
                                                        return Positioned(
                                                          left:
                                                              block.left *
                                                              scale,
                                                          top:
                                                              block.top * scale,
                                                          width:
                                                              block.width *
                                                              scale,
                                                          height:
                                                              block.height *
                                                              scale,
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  Theme.of(
                                                                        context,
                                                                      )
                                                                      .primaryColor
                                                                      .withOpacity(
                                                                        0.1,
                                                                      ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    4,
                                                                  ),
                                                            ),
                                                          ),
                                                        );
                                                      })
                                                      .toList(),
                                                )
                                              : const SizedBox.shrink(),
                                        ),
                                        // Render Saved Bookmark / Preview
                                        Obx(() {
                                          // Filtered bookmarks for this specific mushaf type
                                          final savedBookmark = controller
                                              .bookmarks
                                              .firstWhereOrNull(
                                                (b) =>
                                                    b['page_number'] ==
                                                        page.pageNumber &&
                                                    b['quran_type_slug'] ==
                                                        controller
                                                            .currentSlug
                                                            .value,
                                              );

                                          // If we are currently marking this specific page, show a preview of the selected design
                                          final isMarking = controller
                                              .isBookmarkVisible
                                              .value;
                                          final isCurrentPage =
                                              controller
                                                  .currentPageIndex
                                                  .value ==
                                              index;

                                          String? markerPath;
                                          if (isMarking && isCurrentPage) {
                                            if (controller
                                                .apiMarkers
                                                .isNotEmpty) {
                                              markerPath =
                                                  controller
                                                      .apiMarkers[controller
                                                      .selectedBookmarkDesign
                                                      .value]['marker_path'];
                                            }
                                          } else {
                                            markerPath =
                                                savedBookmark?['marker_path'];
                                          }

                                          if (markerPath == null) {
                                            return const SizedBox.shrink();
                                          }

                                          return Positioned(
                                            top: 0,
                                            right: 20 * scale,
                                            child: CachedNetworkImage(
                                              imageUrl: markerPath,
                                              width: 40 * scale,
                                              height: 120 * scale,
                                              fit: BoxFit.contain,
                                              filterQuality:
                                                  FilterQuality.medium,
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          });
                        }

                        if (isLandscape) {
                          return SingleChildScrollView(
                            key: ValueKey(
                              'scroll_${page.pageNumber}_$orientation',
                            ),
                            child: buildPageContent(),
                          );
                        } else {
                          return InteractiveViewer(
                            minScale: 1.0,
                            maxScale: 4.0,
                            child: Center(child: buildPageContent()),
                          );
                        }
                      },
                    );
                  },
                );
              }),
              Obx(() {
                if (controller.isDownloading.value ||
                    controller.isPaused.value) {
                  return Container(
                    color: Colors.black.withOpacity(0.6),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(30),
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                Theme.of(context).brightness == Brightness.dark
                                    ? 0.3
                                    : 0.1,
                              ),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  value:
                                      controller.totalPagesToDownload.value > 0
                                      ? controller.downloadProgress.value /
                                            controller
                                                .totalPagesToDownload
                                                .value
                                      : null,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Mengunduh Data Al-Quran',
                              style: pBold18.copyWith(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${controller.downloadProgress.value} dari ${controller.totalPagesToDownload.value} Halaman',
                              style: pSemiBold14,
                            ),
                            const SizedBox(height: 20),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                minHeight: 8,
                                value: controller.totalPagesToDownload.value > 0
                                    ? controller.downloadProgress.value /
                                          controller.totalPagesToDownload.value
                                    : null,
                                color: Theme.of(context).primaryColor,
                                backgroundColor: Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.1),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Obx(
                              () => Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (controller.isDownloading.value)
                                    ElevatedButton.icon(
                                      onPressed: () =>
                                          controller.pauseDownload(),
                                      icon: const Icon(
                                        Icons.pause,
                                        color: Colors.white,
                                      ),
                                      label: const Text(
                                        'Pause',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange,
                                      ),
                                    ),
                                  if (controller.isPaused.value)
                                    ElevatedButton.icon(
                                      onPressed: () =>
                                          controller.resumeDownload(),
                                      icon: const Icon(
                                        Icons.play_arrow,
                                        color: Colors.white,
                                      ),
                                      label: const Text(
                                        'Lanjutkan',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(
                                          context,
                                        ).primaryColor,
                                      ),
                                    ),
                                  const SizedBox(width: 12),
                                  TextButton(
                                    onPressed: () {
                                      controller.pauseDownload();
                                      controller.isPaused.value = false;
                                    },
                                    child: Text(
                                      'Tutup',
                                      style: pMedium14.copyWith(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              controller.isPaused.value
                                  ? 'Download dihentikan sementara.'
                                  : 'Mohon tunggu sebentar dan jangan tutup aplikasi.',
                              style: pRegular12.copyWith(color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
              Obx(
                () =>
                    (controller.isLoading.value && controller.dataPage.isEmpty)
                    ? const SizedBox.shrink()
                    : AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        bottom:
                            (controller.isFocus.value ||
                                controller.isTranslationVisible.value)
                            ? -160
                            : 20,
                        right: 20,
                        left: 20,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(
                                  Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? 0.3
                                      : 0.08,
                                ),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () {
                                    controller.initMarkerSelection();
                                    controller.isFocus.value = true;
                                    controller.isBookmarkVisible.value = true;
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 14,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          IconlyBold.bookmark,
                                          size: 22,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Tandai Halaman Ini',
                                          style: pSemiBold14,
                                        ),
                                        const Spacer(),
                                        Icon(
                                          IconlyLight.arrow_right_2,
                                          size: 16,
                                          color: Colors.grey.shade400,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 1,
                                  color: context.isDarkMode
                                      ? Colors.grey.shade800
                                      : Colors.grey.shade100,
                                ),
                                // Audio Player Row
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () => controller.toggleAudio(),
                                        child: Obx(
                                          () => Container(
                                            height: 48,
                                            width: 48,
                                            decoration: BoxDecoration(
                                              color: Theme.of(
                                                context,
                                              ).primaryColor,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              controller.isPlaying.value
                                                  ? Icons
                                                        .pause_circle_outline_rounded
                                                  : Icons.play_arrow_rounded,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: AppColor.globalBorder,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: Obx(
                                              () => DropdownButton<String>(
                                                value: controller
                                                    .selectedReciter
                                                    .value,
                                                isExpanded: true,
                                                icon: Icon(
                                                  LucideIcons.chevronDown,
                                                  size: 16,
                                                  color: AppColor
                                                      .globalTextSecondary,
                                                ),
                                                items: controller.reciters.map((
                                                  reciter,
                                                ) {
                                                  return DropdownMenuItem(
                                                    value: reciter['code'],
                                                    child: Text(
                                                      reciter['name']!,
                                                      style: pMedium14.copyWith(
                                                        color: AppColor
                                                            .globalTextSecondary,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                                onChanged: (value) => controller
                                                    .changeReciter(value),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () {
                                          if (controller
                                              .dropdownSurah
                                              .isEmpty) {
                                            controller.fetchDropdownSurah('');
                                          }
                                          controller.initAudioRange();
                                          _showAudioSettings(
                                            context,
                                            controller,
                                          );
                                        },
                                        child: Container(
                                          height: 48,
                                          width: 48,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: AppColor.globalBorder,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.settings,
                                            color: AppColor.globalTextSecondary,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
              ),

              Obx(() {
                if (!controller.isBookmarkVisible.value) {
                  return const SizedBox.shrink();
                }
                return Positioned.fill(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: controller.isBookmarkVisible.value ? 1.0 : 0.0,
                    child: Material(
                      color: Colors.black.withOpacity(0.1),
                      child: InkWell(
                        onTap: () => controller.isBookmarkVisible.value = false,
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        child: Stack(
                          children: [
                            // Left Selection Panel
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 24),
                                child: GestureDetector(
                                  onTap:
                                      () {}, // Prevent tap through to backdrop
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.42,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surface,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(
                                            Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? 0.4
                                                : 0.2,
                                          ),
                                          blurRadius: 20,
                                          offset: const Offset(5, 5),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Pilih Desain',
                                          style: pBold16.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).primaryColor,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        GridView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 2,
                                                crossAxisSpacing: 10,
                                                mainAxisSpacing: 10,
                                                childAspectRatio: 1,
                                              ),
                                          itemCount:
                                              controller.apiMarkers.length,
                                          itemBuilder: (context, index) {
                                            return Obx(() {
                                              final isSelected =
                                                  controller
                                                      .selectedBookmarkDesign
                                                      .value ==
                                                  index;
                                              final marker =
                                                  controller.apiMarkers[index];
                                              final isUse =
                                                  marker['isUse'] ?? false;

                                              return GestureDetector(
                                                onTap: () =>
                                                    controller
                                                            .selectedBookmarkDesign
                                                            .value =
                                                        index,
                                                child: AnimatedContainer(
                                                  duration: const Duration(
                                                    milliseconds: 200,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                    border: Border.all(
                                                      color: isSelected
                                                          ? Theme.of(
                                                              context,
                                                            ).primaryColor
                                                          : Theme.of(
                                                              context,
                                                            ).dividerColor,
                                                      width: isSelected ? 3 : 1,
                                                    ),
                                                    boxShadow: isSelected
                                                        ? [
                                                            BoxShadow(
                                                              color:
                                                                  Theme.of(
                                                                        context,
                                                                      )
                                                                      .primaryColor
                                                                      .withOpacity(
                                                                        0.3,
                                                                      ),
                                                              blurRadius: 8,
                                                              spreadRadius: 1,
                                                            ),
                                                          ]
                                                        : [],
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                    child: Stack(
                                                      children: [
                                                        Positioned.fill(
                                                          child: CachedNetworkImage(
                                                            imageUrl:
                                                                marker['marker_path'],
                                                            fit: BoxFit.cover,
                                                            filterQuality:
                                                                FilterQuality
                                                                    .medium,
                                                          ),
                                                        ),
                                                        if (isUse)
                                                          Positioned.fill(
                                                            child: Container(
                                                              color: Colors.grey
                                                                  .withOpacity(
                                                                    0.5,
                                                                  ),
                                                            ),
                                                          ),
                                                        if (isSelected)
                                                          Align(
                                                            alignment: Alignment
                                                                .topRight,
                                                            child: Container(
                                                              margin:
                                                                  const EdgeInsets.all(
                                                                    4,
                                                                  ),
                                                              decoration:
                                                                  const BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                              child: Icon(
                                                                Icons
                                                                    .check_circle,
                                                                color: Theme.of(
                                                                  context,
                                                                ).primaryColor,
                                                                size: 20,
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            });
                                          },
                                        ),
                                        const SizedBox(height: 24),
                                        ElevatedButton(
                                          onPressed: () =>
                                              controller.saveBookmark(),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Theme.of(
                                              context,
                                            ).primaryColor,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            minimumSize: const Size(
                                              double.infinity,
                                              50,
                                            ),
                                            elevation: 8,
                                          ),
                                          child: Text(
                                            'Simpan',
                                            style: pBold14.copyWith(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Right Hanging Preview
                            Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 24),
                                child: GestureDetector(
                                  onTap: () {}, // Prevent tap through
                                  child: Obx(() {
                                    // final currentPageNumber =
                                    //     controller.dataPage.isNotEmpty &&
                                    //         controller.currentPageIndex.value <
                                    //             controller.dataPage.length
                                    //     ? controller
                                    //           .dataPage[controller
                                    //               .currentPageIndex
                                    //               .value]
                                    //           .pageNumber
                                    //     : "";
                                    return AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      height: 480,
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.42,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(20),
                                          bottomRight: Radius.circular(20),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.4,
                                            ),
                                            blurRadius: 25,
                                            offset: const Offset(0, 15),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(20),
                                          bottomRight: Radius.circular(20),
                                        ),
                                        child: Stack(
                                          children: [
                                            Positioned.fill(
                                              child:
                                                  controller.apiMarkers.isEmpty
                                                  ? const Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    )
                                                  : CachedNetworkImage(
                                                      imageUrl:
                                                          controller
                                                              .apiMarkers[controller
                                                              .selectedBookmarkDesign
                                                              .value]['marker_path'],
                                                      fit: BoxFit.cover,
                                                      filterQuality:
                                                          FilterQuality.medium,
                                                    ),
                                            ),
                                            // Shadow/gradient for depth
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    const BorderRadius.only(
                                                      bottomLeft:
                                                          Radius.circular(20),
                                                      bottomRight:
                                                          Radius.circular(20),
                                                    ),
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    Colors.black.withOpacity(
                                                      0.1,
                                                    ),
                                                    Colors.transparent,
                                                    Colors.black.withOpacity(
                                                      0.05,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            // Hanging string representation
                                            Align(
                                              alignment: Alignment.topCenter,
                                              child: Container(
                                                height: 60,
                                                width: 3,
                                                color: Colors.black45,
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.topCenter,
                                              child: Container(
                                                margin: const EdgeInsets.only(
                                                  top: 55,
                                                ),
                                                height: 12,
                                                width: 12,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Colors.black45,
                                                    width: 2,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),

              // Translation Panel
              Obx(() {
                if (!controller.isTranslationVisible.value) {
                  return const SizedBox.shrink();
                }
                return _buildTranslationPanel(context, controller);
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showAudioSettings(
    BuildContext context,
    QuranPageScreenController controller,
  ) {
    final colorScheme = context.theme.colorScheme;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Pengaturan Audio",
              style: pSemiBold18.copyWith(
                color: AppColor.globalTextSecondary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Sesuaikan pengalaman mendengarkan murottal Anda",
              style: pRegular12.copyWith(color: AppColor.globalTextSecondary),
            ),
            const SizedBox(height: 24),
            Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dari', style: pSemiBold12),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // From Surah
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest
                                .withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: controller.fromSurahId.value,
                              isExpanded: true,
                              dropdownColor: colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              items: controller.dropdownSurah.isEmpty
                                  ? [
                                      DropdownMenuItem<int>(
                                        value: controller.fromSurahId.value,
                                        child: const Text('Loading...'),
                                      ),
                                    ]
                                  : controller.dropdownSurah.map((surah) {
                                      return DropdownMenuItem<int>(
                                        value: surah.id,
                                        child: Text(
                                          surah.name,
                                          style: pMedium14,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  controller.fromSurahId.value = val;
                                  controller.fromAyahNumber.value = 1;
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // From Ayah
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest
                                .withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: controller.fromAyahNumber.value,
                              isExpanded: true,
                              dropdownColor: colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              items: () {
                                final surah = controller.dropdownSurah
                                    .firstWhereOrNull(
                                      (s) =>
                                          s.id == controller.fromSurahId.value,
                                    );
                                int total = surah?.totalAyah ?? 0;
                                if (total == 0) {
                                  return [
                                    DropdownMenuItem<int>(
                                      value: controller.fromAyahNumber.value,
                                      child: Text(
                                        controller.fromAyahNumber.value
                                            .toString(),
                                      ),
                                    ),
                                  ];
                                }
                                return List.generate(total, (i) => i + 1).map((
                                  ayah,
                                ) {
                                  return DropdownMenuItem<int>(
                                    value: ayah,
                                    child: Text(
                                      ayah.toString(),
                                      style: pMedium14,
                                    ),
                                  );
                                }).toList();
                              }(),
                              onChanged: (val) {
                                if (val != null) {
                                  controller.fromAyahNumber.value = val;
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sampai', style: pSemiBold12),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // To Surah
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest
                                .withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: controller.toSurahId.value,
                              isExpanded: true,
                              dropdownColor: colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              items: controller.dropdownSurah.isEmpty
                                  ? [
                                      DropdownMenuItem<int>(
                                        value: controller.toSurahId.value,
                                        child: const Text('Loading...'),
                                      ),
                                    ]
                                  : controller.dropdownSurah.map((surah) {
                                      return DropdownMenuItem<int>(
                                        value: surah.id,
                                        child: Text(
                                          surah.name,
                                          style: pMedium14,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  controller.toSurahId.value = val;
                                  controller.toAyahNumber.value = 1;
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // To Ayah
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest
                                .withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: controller.toAyahNumber.value,
                              isExpanded: true,
                              dropdownColor: colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              items: () {
                                final surah = controller.dropdownSurah
                                    .firstWhereOrNull(
                                      (s) => s.id == controller.toSurahId.value,
                                    );
                                int total = surah?.totalAyah ?? 0;
                                if (total == 0) {
                                  return [
                                    DropdownMenuItem<int>(
                                      value: controller.toAyahNumber.value,
                                      child: Text(
                                        controller.toAyahNumber.value
                                            .toString(),
                                      ),
                                    ),
                                  ];
                                }
                                return List.generate(total, (i) => i + 1).map((
                                  ayah,
                                ) {
                                  return DropdownMenuItem<int>(
                                    value: ayah,
                                    child: Text(
                                      ayah.toString(),
                                      style: pMedium14,
                                    ),
                                  );
                                }).toList();
                              }(),
                              onChanged: (val) {
                                if (val != null) {
                                  controller.toAyahNumber.value = val;
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Repeat Dropdown
            _buildSettingRow(
              context,
              label: "Pengulangan per Ayat",
              child: Obx(
                () => DropdownButton<int>(
                  value: controller.repeatCount.value,
                  underline: const SizedBox(),
                  dropdownColor: colorScheme.surface,
                  items: [1, 2, 3, 5, 10].map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text("x$value", style: pMedium14),
                    );
                  }).toList(),
                  onChanged: (val) => controller.repeatCount.value = val ?? 1,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Delay Dropdown
            _buildSettingRow(
              context,
              label: "Jeda antar Ayat",
              child: Obx(
                () => DropdownButton<int>(
                  value: controller.delayBetweenAyahs.value,
                  underline: const SizedBox(),
                  dropdownColor: colorScheme.surface,
                  items: List.generate(11, (index) => index).map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text("$value dtk", style: pMedium14),
                    );
                  }).toList(),
                  onChanged: (val) =>
                      controller.delayBetweenAyahs.value = val ?? 0,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Playback Repeat Dropdown
            _buildSettingRow(
              context,
              label: "Putar ulang pemutaran",
              child: Obx(
                () => DropdownButton<int>(
                  value: controller.playbackRepeatOption.value,
                  underline: const SizedBox(),
                  dropdownColor: colorScheme.surface,
                  items: [
                    DropdownMenuItem<int>(
                      value: 1,
                      child: Text("Tidak", style: pMedium14),
                    ),
                    DropdownMenuItem<int>(
                      value: 2,
                      child: Text("2x", style: pMedium14),
                    ),
                    DropdownMenuItem<int>(
                      value: 3,
                      child: Text("3x", style: pMedium14),
                    ),
                    DropdownMenuItem<int>(
                      value: 5,
                      child: Text("5x", style: pMedium14),
                    ),
                    DropdownMenuItem<int>(
                      value: 10,
                      child: Text("10x", style: pMedium14),
                    ),
                    DropdownMenuItem<int>(
                      value: -1,
                      child: Text("Selamanya", style: pMedium14),
                    ),
                  ],
                  onChanged: (val) =>
                      controller.playbackRepeatOption.value = val ?? 1,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Play/Stop Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: Obx(
                () => ElevatedButton.icon(
                  onPressed: () {
                    Get.back();
                    controller.playAudioRange();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  icon: Icon(
                    controller.isPlaying.value
                        ? Icons.stop_rounded
                        : Icons.play_arrow_rounded,
                  ),
                  label: Text(
                    controller.isPlaying.value
                        ? "Hentikan Murottal"
                        : "Putar Murottal",
                    style: pSemiBold16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildSettingRow(
    BuildContext context, {
    required String label,
    required Widget child,
  }) {
    final colorScheme = context.theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: pSemiBold14)),
          child,
        ],
      ),
    );
  }

  Widget _buildSearchAyah(
    BuildContext context,
    QuranPageScreenController controller,
  ) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Obx(
        () => Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(color: AppColor.globalBorder, width: 0.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pergi Ke',
                style: pSemiBold16.copyWith(
                  color: AppColor.globalTextSecondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 24),
              // Tab Selector
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColor.globalBorder, width: 0.5),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          controller.tabIsAyah.value = true;
                          controller.searchAyahPageController.jumpToPage(0);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: controller.tabIsAyah.value
                                ? AppColor.primaryColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Ayat',
                            textAlign: TextAlign.center,
                            style: pSemiBold14.copyWith(
                              color: controller.tabIsAyah.value
                                  ? Colors.white
                                  : AppColor.globalTextSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          controller.tabIsAyah.value = false;
                          controller.searchAyahPageController.jumpToPage(1);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: !controller.tabIsAyah.value
                                ? AppColor.primaryColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Halaman',
                            textAlign: TextAlign.center,
                            style: pSemiBold14.copyWith(
                              color: !controller.tabIsAyah.value
                                  ? Colors.white
                                  : AppColor.globalTextSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 80,
                child: PageView(
                  controller: controller.searchAyahPageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    // Ayat Search
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Surah',
                                style: pMedium12.copyWith(
                                  color: AppColor.globalTextSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              SearchAnchor(
                                builder: (context, anchorController) {
                                  return InkWell(
                                    onTap: () => anchorController.openView(),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: AppColor.globalBorder,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              controller
                                                      .selectedSurahName
                                                      .value
                                                      .isEmpty
                                                  ? 'Pilih Surah'
                                                  : controller
                                                        .selectedSurahName
                                                        .value,
                                              style: pMedium14,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Icon(
                                            LucideIcons.chevronDown,
                                            size: 16,
                                            color: AppColor.primaryColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                suggestionsBuilder:
                                    (context, anchorController) {
                                      if (anchorController.text.isEmpty &&
                                          controller.dropdownSurah.isEmpty) {
                                        controller.fetchDropdownSurah('');
                                      }
                                      return [
                                        Obx(
                                          () => Column(
                                            children: controller.dropdownSurah
                                                .map(
                                                  (surah) => ListTile(
                                                    title: Text(
                                                      surah.name,
                                                      style: pMedium14,
                                                    ),
                                                    onTap: () {
                                                      controller
                                                              .selectedSurahName
                                                              .value =
                                                          surah.name;
                                                      controller.surahId.value =
                                                          surah.id;
                                                      anchorController
                                                          .closeView(
                                                            surah.name,
                                                          );
                                                    },
                                                  ),
                                                )
                                                .toList(),
                                          ),
                                        ),
                                      ];
                                    },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ayat',
                                style: pMedium12.copyWith(
                                  color: AppColor.globalTextSecondary,
                                ),
                              ),
                              TextField(
                                controller: controller.searchAyahController,
                                keyboardType: TextInputType.number,
                                style: pMedium14,
                                decoration: InputDecoration(
                                  hintText: 'No',
                                  hintStyle: pRegular14.copyWith(
                                    color: AppColor.globalTextSecondary,
                                  ),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.only(
                                    top: 12,
                                    bottom: 8,
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppColor.globalBorder,
                                    ),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppColor.globalBorder,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Page Search
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halaman',
                          style: pMedium12.copyWith(
                            color: AppColor.globalTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        DropdownButtonHideUnderline(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: AppColor.globalBorder,
                                ),
                              ),
                            ),
                            child: Obx(
                              () => DropdownButton<int>(
                                value: controller.selectedPage.value,
                                isExpanded: true,
                                icon: Icon(
                                  LucideIcons.chevronDown,
                                  size: 16,
                                  color: AppColor.primaryColor,
                                ),
                                items: controller.listPages
                                    .map(
                                      (page) => DropdownMenuItem(
                                        value: page,
                                        child: Text(
                                          'Halaman $page',
                                          style: pRegular14,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) =>
                                    controller.selectedPage.value = v!,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: AppColor.globalBorder),
                        minimumSize: const Size(0, 48),
                      ),
                      child: Text(
                        'Batal',
                        style: pSemiBold14.copyWith(
                          color: AppColor.globalTextSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => controller.tabIsAyah.value
                          ? controller.onJumpToAyah()
                          : controller.onJumpToPage(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size(0, 48),
                        elevation: 0,
                      ),
                      child: Text(
                        'Pergi',
                        style: pSemiBold14.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSurah(
    BuildContext context,
    QuranPageScreenController controller,
  ) {
    controller.searchSurahController.clear();
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        height: MediaQuery.of(Get.context!).size.height * 0.7,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(color: AppColor.globalBorder, width: 0.5),
        ),
        child: Column(
          children: [
            // Header Search Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                border: Border(
                  bottom: BorderSide(color: AppColor.globalBorder, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColor.globalBorder,
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.search,
                            size: 18,
                            color: AppColor.globalTextSecondary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: controller.searchSurahController,
                              onChanged: (value) =>
                                  controller.onSearchChanged(value),
                              style: pMedium14.copyWith(
                                color: AppColor.globalTextSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Cari Surat...',
                                hintStyle: pRegular14.copyWith(
                                  color: AppColor.globalTextSecondary,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColor.primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        LucideIcons.x,
                        size: 20,
                        color: AppColor.globalTextSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Tab Selector
            Obx(
              () => Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColor.globalBorder, width: 0.5),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          controller.tabIsSurat.value = true;
                          controller.searchSuratPageController.jumpToPage(0);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: controller.tabIsSurat.value
                                ? AppColor.primaryColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Surat',
                            textAlign: TextAlign.center,
                            style: pSemiBold14.copyWith(
                              color: controller.tabIsSurat.value
                                  ? Colors.white
                                  : AppColor.globalTextSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          controller.tabIsSurat.value = false;
                          controller.searchSuratPageController.jumpToPage(1);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: !controller.tabIsSurat.value
                                ? AppColor.primaryColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Juz',
                            textAlign: TextAlign.center,
                            style: pSemiBold14.copyWith(
                              color: !controller.tabIsSurat.value
                                  ? Colors.white
                                  : AppColor.globalTextSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // List Content
            Expanded(
              child: PageView(
                controller: controller.searchSuratPageController,
                onPageChanged: (index) =>
                    controller.tabIsSurat.value = index == 0,
                children: [
                  // Surah List
                  Obx(
                    () => controller.isDialogLoading.value
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemCount: controller.dropdownSurah.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final surah = controller.dropdownSurah[index];
                              return InkWell(
                                onTap: () => controller.onSelectSurah(surah.id),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColor.globalBorder,
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/images/png/frame.png',
                                            height: 36,
                                            width: 36,
                                          ),
                                          Text(
                                            surah.id.toString(),
                                            style: pBold12.copyWith(
                                              color:
                                                  AppColor.globalTextSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              surah.name,
                                              style: pSemiBold14.copyWith(
                                                color: AppColor
                                                    .globalTextSecondary,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            Text(
                                              '${surah.translationName} • ${surah.totalAyah} Ayat',
                                              style: pRegular12.copyWith(
                                                color: AppColor
                                                    .globalTextSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        surah.cityName,
                                        style: pSemiBold12.copyWith(
                                          color: AppColor.primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  // Juz List
                  Obx(
                    () => controller.isDialogLoading.value
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemCount: controller.dropdownJuz.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final juz = controller.dropdownJuz[index];
                              return Theme(
                                data: Theme.of(
                                  context,
                                ).copyWith(dividerColor: Colors.transparent),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColor.globalBorder,
                                      width: 0.5,
                                    ),
                                  ),
                                  child: ExpansionTile(
                                    tilePadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    title: Row(
                                      children: [
                                        Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Image.asset(
                                              'assets/images/png/frame.png',
                                              height: 36,
                                              width: 36,
                                            ),
                                            Text(
                                              juz.juzNomor.toString(),
                                              style: pBold12.copyWith(
                                                color: AppColor.primaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Juz ${juz.juzNomor}',
                                          style: pSemiBold14.copyWith(
                                            color: AppColor.globalTextSecondary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    children: [
                                      Container(
                                        color: AppColor.globalBorder
                                            .withOpacity(0.2),
                                        child: Column(
                                          children: juz.surah.map((surah) {
                                            return InkWell(
                                              onTap: () =>
                                                  controller.onSelectSurah(
                                                    surah.id,
                                                    ayah: surah.startAyah,
                                                  ),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                      horizontal: 16,
                                                    ),
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    top: BorderSide(
                                                      color:
                                                          AppColor.globalBorder,
                                                      width: 0.5,
                                                    ),
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            surah.name,
                                                            style: pSemiBold14
                                                                .copyWith(
                                                                  color: AppColor
                                                                      .globalTextSecondary,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                          ),
                                                          Text(
                                                            '${surah.translationName} • ${surah.totalAyah} Ayat',
                                                            style: pRegular12
                                                                .copyWith(
                                                                  color: AppColor
                                                                      .globalTextSecondary,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Text(
                                                      surah.cityName,
                                                      style: pSemiBold12
                                                          .copyWith(
                                                            color: AppColor
                                                                .primaryColor,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTranslationPanel(
    BuildContext context,
    QuranPageScreenController controller,
  ) {
    final isDark = context.isDarkMode;
    final surfaceColor = isDark
        ? Theme.of(context).colorScheme.surface
        : const Color(0xFFFBF9F5);

    return DraggableScrollableSheet(
      initialChildSize: 0.42,
      minChildSize: 0.18,
      maxChildSize: 0.85,
      snap: true,
      snapSizes: const [0.18, 0.42, 0.85],
      builder: (context, scrollController) {
        return GestureDetector(
          onTap: () {}, // Prevent tap propagation to background PageView
          child: Container(
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: Column(
              children: [
                // Drag Handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 8),
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey.shade700
                          : const Color(0xFFD8D0C4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Controls Row
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () => _showFontSizeSettings(context, controller),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                'T',
                                style: pBold16.copyWith(
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF2C2C2C),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'ᴛ',
                                style: pBold14.copyWith(
                                  color: isDark
                                      ? Colors.redAccent.shade100
                                      : const Color(0xFFD32F2F),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // ✕ Close Button
                      InkWell(
                        onTap: () =>
                            controller.isTranslationVisible.value = false,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.close,
                            size: 20,
                            color: isDark
                                ? Colors.grey.shade400
                                : const Color(0xFF555555),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: isDark
                      ? Colors.grey.shade800
                      : const Color(0xFFEBE5DB),
                ),

                // Ayahs Translation List
                Expanded(
                  child: Obx(() {
                    if (controller.dataPage.isEmpty ||
                        controller.currentPageIndex.value >=
                            controller.dataPage.length) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).primaryColor,
                          strokeWidth: 2.5,
                        ),
                      );
                    }

                    final currentPage =
                        controller.dataPage[controller.currentPageIndex.value];
                    final ayahs = currentPage.ayahs;

                    if (ayahs.isEmpty) {
                      return Center(
                        child: Text(
                          'Tidak ada data terjemahan untuk halaman ini.',
                          style: pRegular14.copyWith(
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      key: ValueKey('trans_page_${currentPage.pageNumber}'),
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      itemCount: ayahs.length,
                      itemBuilder: (context, index) {
                        final ayahElement = ayahs[index];
                        final ayah = ayahElement.ayah;
                        final ayahNum = ayah?.ayahNumber ?? (index + 1);
                        final translation = ayah?.translation ?? '';
                        final isPlaying =
                            controller.playingAyahId.value != 0 &&
                            ayah?.id == controller.playingAyahId.value;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Ayah Number Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isPlaying
                                      ? Theme.of(
                                          context,
                                        ).primaryColor.withOpacity(0.15)
                                      : (isDark
                                            ? const Color(0xFF2C2C30)
                                            : const Color(0xFFF3EFE6)),
                                  borderRadius: BorderRadius.circular(6),
                                  border: isPlaying
                                      ? Border.all(
                                          color: Theme.of(context).primaryColor,
                                          width: 1,
                                        )
                                      : null,
                                ),
                                child: Text(
                                  '$ayahNum',
                                  style: pBold12.copyWith(
                                    color: isPlaying
                                        ? Theme.of(context).primaryColor
                                        : (isDark
                                              ? Colors.white70
                                              : const Color(0xFF4A4035)),
                                  ),
                                ),
                              ),

                              // Optional Arabic / Transliteration Text when toggled
                              if (controller.showTransliteration.value &&
                                  ayah?.textArabic != null &&
                                  ayah!.textArabic!.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    ayah.textArabic!,
                                    textAlign: TextAlign.right,
                                    style: pBold18.copyWith(
                                      height: 1.8,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF1E1E1E),
                                    ),
                                  ),
                                ),
                              ],

                              const SizedBox(height: 8),

                              // Translation Text
                              Obx(
                                () => SelectableText(
                                  translation.trim().isNotEmpty
                                      ? translation
                                      : 'Terjemahan tidak tersedia untuk ayat ini.',
                                  style: pRegular14.copyWith(
                                    fontSize:
                                        controller.translationFontSize.value,
                                    height: 1.65,
                                    color: isDark
                                        ? Colors.white.withOpacity(0.88)
                                        : const Color(0xFF2D2D2D),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFontSizeSettings(
    BuildContext context,
    QuranPageScreenController controller,
  ) {
    final isDark = context.isDarkMode;
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Ukuran Font Terjemahan', style: pSemiBold16),
                Obx(
                  () => Text(
                    '${controller.translationFontSize.value.toInt()} pt',
                    style: pBold14.copyWith(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Live Preview Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.15),
                ),
              ),
              child: Obx(
                () => Text(
                  'Dengan nama Allah Yang Maha Pengasih, Maha Penyayang.',
                  style: pRegular14.copyWith(
                    fontSize: controller.translationFontSize.value,
                    height: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Slider Row with - and + buttons
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (controller.translationFontSize.value > 12) {
                      controller.setTranslationFontSize(
                        controller.translationFontSize.value - 1,
                      );
                    }
                  },
                  icon: const Icon(Icons.remove_circle_outline),
                  color: Theme.of(context).primaryColor,
                ),
                Expanded(
                  child: Obx(
                    () => Slider(
                      value: controller.translationFontSize.value,
                      min: 12.0,
                      max: 22.0,
                      divisions: 10,
                      label: '${controller.translationFontSize.value.toInt()}',
                      activeColor: Theme.of(context).primaryColor,
                      onChanged: (val) {
                        controller.setTranslationFontSize(val);
                      },
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (controller.translationFontSize.value < 22) {
                      controller.setTranslationFontSize(
                        controller.translationFontSize.value + 1,
                      );
                    }
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
