// Quran Page Screen
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/controller/quran/quran_page_screen_controller.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';

class QuranPageScreen extends StatelessWidget {
  const QuranPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(QuranPageScreenController());
    return Scaffold(
      backgroundColor: Colors.white,
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
                      Get.dialog(_buildSearchSurah(controller));
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
                                    color: AppColor.primaryColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                IconlyLight.arrow_down_2,
                                color: AppColor.primaryColor,
                                size: 14,
                              ),
                            ],
                          ),
                          Text(
                            'Halaman ${currentPage.pageNumber} • Juz ${currentPage.juzNumbers.isNotEmpty ? currentPage.juzNumbers.first : "-"}',
                            style: pMedium12.copyWith(
                              color: Colors.grey.shade500,
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
                      Get.dialog(_buildSearchAyah(controller));
                    },
                    icon: Icon(
                      IconlyLight.search,
                      color: AppColor.primaryColor,
                      size: 22,
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
                    },
                    icon: Icon(
                      IconlyLight.more_square,
                      color: AppColor.primaryColor,
                      size: 22,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    color: Colors.white,
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
                              color: AppColor.primaryColor,
                              size: 18,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              controller.isLandscape.value
                                  ? 'Mode Potret'
                                  : 'Mode Lanskap',
                              style: pMedium14.copyWith(
                                color: AppColor.primaryColor,
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
                              color: AppColor.primaryColor,
                              size: 18,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Info Detail',
                              style: pMedium14.copyWith(
                                color: AppColor.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                ],
                backgroundColor: AppColor.backgroundColor,
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
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColor.primaryColor,
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
                      final isLandscape = orientation == Orientation.landscape;

                      if (page.id < 0) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColor.primaryColor,
                          ),
                        );
                      }

                      Widget buildPageContent() {
                        return Obx(() {
                          if (controller.viewportWidth.value == 0) {
                            return controller.isOfflineMode.value
                                ? Image.file(
                                    File(page.imagePath),
                                    fit: isLandscape
                                        ? BoxFit.fitWidth
                                        : BoxFit.contain,
                                  )
                                : Image.network(
                                    page.imagePath,
                                    fit: isLandscape
                                        ? BoxFit.fitWidth
                                        : BoxFit.contain,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value:
                                                  loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                  : null,
                                              color: AppColor.primaryColor,
                                            ),
                                          );
                                        },
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                        child: Icon(
                                          Icons.error,
                                          color: Colors.red,
                                          size: 40,
                                        ),
                                      );
                                    },
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
                                      controller.isOfflineMode.value
                                          ? Image.file(
                                              File(page.imagePath),
                                              width: displayWidth,
                                              height: displayHeight,
                                              fit: BoxFit.fill,
                                            )
                                          : Image.network(
                                              page.imagePath,
                                              width: displayWidth,
                                              height: displayHeight,
                                              fit: BoxFit.fill,
                                              loadingBuilder: (context, child, loadingProgress) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                }
                                                return Center(
                                                  child: CircularProgressIndicator(
                                                    value:
                                                        loadingProgress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? loadingProgress
                                                                  .cumulativeBytesLoaded /
                                                              loadingProgress
                                                                  .expectedTotalBytes!
                                                        : null,
                                                    color:
                                                        AppColor.primaryColor,
                                                  ),
                                                );
                                              },
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    return const Center(
                                                      child: Icon(
                                                        Icons.error,
                                                        color: Colors.red,
                                                        size: 40,
                                                      ),
                                                    );
                                                  },
                                            ),
                                      Obx(
                                        () => controller.isPlaying.value
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
                                                            block.left * scale,
                                                        top: block.top * scale,
                                                        width:
                                                            block.width * scale,
                                                        height:
                                                            block.height *
                                                            scale,
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            color: AppColor
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
                                      // Render Saved Bookmark
                                      Obx(() {
                                        final bookmark = controller.bookmarks
                                            .firstWhereOrNull(
                                              (b) =>
                                                  b['page_number'] ==
                                                  page.pageNumber,
                                            );
                                        if (bookmark == null) {
                                          return const SizedBox.shrink();
                                        }
                                        return Positioned(
                                          top: 0,
                                          right: 20 * scale,
                                          child: Image.network(
                                            bookmark['marker_path'],
                                            width: 40 * scale,
                                            height: 120 * scale,
                                            fit: BoxFit.contain,
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
                        return SingleChildScrollView(child: buildPageContent());
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
              if (controller.isDownloading.value) {
                return Container(
                  color: Colors.black.withOpacity(0.6),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(30),
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
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
                              color: AppColor.primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                value: controller.totalPagesToDownload.value > 0
                                    ? controller.downloadProgress.value /
                                          controller.totalPagesToDownload.value
                                    : null,
                                color: AppColor.primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Mengunduh Data Al-Quran',
                            style: pBold18.copyWith(
                              color: AppColor.primaryColor,
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
                              color: AppColor.primaryColor,
                              backgroundColor: AppColor.primaryColor
                                  .withOpacity(0.1),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Mohon tunggu sebentar dan jangan tutup aplikasi.',
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
              () => (controller.isLoading.value && controller.dataPage.isEmpty)
                  ? const SizedBox.shrink()
                  : AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      bottom: controller.isFocus.value ? -160 : 20,
                      right: 20,
                      left: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
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
                              if (AuthController.to.isLogin.value &&
                                  !controller.isOfflineMode.value) ...[
                                InkWell(
                                  onTap: () {
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
                                          color: AppColor.primaryColor,
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
                                  color: Colors.grey.shade100,
                                ),
                              ],
                              // Audio Player Row
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => controller.toggleAudio(),
                                      child: Container(
                                        height: 48,
                                        width: 48,
                                        decoration: BoxDecoration(
                                          color: AppColor.primaryColor,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColor.primaryColor
                                                  .withOpacity(0.3),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          controller.isPlaying.value
                                              ? IconlyBold.voice
                                              : IconlyBold.play,
                                          color: Colors.white,
                                          size: 24,
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
                                          color: AppColor.primaryColor
                                              .withOpacity(0.05),
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: controller
                                                .selectedReciter
                                                .value,
                                            isExpanded: true,
                                            icon: Icon(
                                              IconlyLight.arrow_down_2,
                                              size: 16,
                                              color: AppColor.primaryColor,
                                            ),
                                            items: controller.reciters.map((
                                              reciter,
                                            ) {
                                              return DropdownMenuItem(
                                                value: reciter['code'],
                                                child: Text(
                                                  reciter['name']!,
                                                  style: pMedium14.copyWith(
                                                    color:
                                                        AppColor.primaryColor,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                            onChanged: (value) =>
                                                controller.changeReciter(value),
                                          ),
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
                                onTap: () {}, // Prevent tap through to backdrop
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.42,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
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
                                          color: AppColor.primaryColor,
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
                                        itemCount: controller.apiMarkers.length,
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
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: isSelected
                                                        ? AppColor.primaryColor
                                                        : Colors.grey.shade200,
                                                    width: isSelected ? 3 : 1,
                                                  ),
                                                  boxShadow: isSelected
                                                      ? [
                                                          BoxShadow(
                                                            color: AppColor
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
                                                      BorderRadius.circular(10),
                                                  child: Stack(
                                                    children: [
                                                      Positioned.fill(
                                                        child: Image.network(
                                                          marker['marker_path'],
                                                          fit: BoxFit.cover,
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
                                                              color: AppColor
                                                                  .primaryColor,
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
                                          backgroundColor:
                                              AppColor.primaryColor,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
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
                                            color: AppColor.backgroundColor,
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
                                  final currentPageNumber =
                                      controller.dataPage.isNotEmpty &&
                                          controller.currentPageIndex.value <
                                              controller.dataPage.length
                                      ? controller
                                            .dataPage[controller
                                                .currentPageIndex
                                                .value]
                                            .pageNumber
                                      : "";
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
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
                                          color: Colors.black.withOpacity(0.4),
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
                                            child: controller.apiMarkers.isEmpty
                                                ? const Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  )
                                                : Image.network(
                                                    controller
                                                        .apiMarkers[controller
                                                        .selectedBookmarkDesign
                                                        .value]['marker_path'],
                                                    fit: BoxFit.cover,
                                                  ),
                                          ),
                                          // Shadow/gradient for depth
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.only(
                                                    bottomLeft: Radius.circular(
                                                      20,
                                                    ),
                                                    bottomRight:
                                                        Radius.circular(20),
                                                  ),
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Colors.black.withOpacity(0.1),
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
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAyah(QuranPageScreenController controller) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Obx(
        () => Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pergi Ke',
                style: pBold18.copyWith(color: AppColor.primaryColor),
              ),
              const SizedBox(height: 24),
              // Tab Selector
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(15),
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
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: controller.tabIsAyah.value
                                ? AppColor.primaryColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            'Ayat',
                            textAlign: TextAlign.center,
                            style: pSemiBold14.copyWith(
                              color: controller.tabIsAyah.value
                                  ? Colors.white
                                  : Colors.grey,
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
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !controller.tabIsAyah.value
                                ? AppColor.primaryColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            'Halaman',
                            textAlign: TextAlign.center,
                            style: pSemiBold14.copyWith(
                              color: !controller.tabIsAyah.value
                                  ? Colors.white
                                  : Colors.grey,
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
                                style: pMedium12.copyWith(color: Colors.grey),
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
                                            color: Colors.grey.shade200,
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
                                              style: pSemiBold14,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Icon(
                                            IconlyLight.arrow_down_2,
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
                                style: pMedium12.copyWith(color: Colors.grey),
                              ),
                              TextField(
                                controller: controller.searchAyahController,
                                keyboardType: TextInputType.number,
                                style: pBold14,
                                decoration: InputDecoration(
                                  hintText: 'No',
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppColor.primaryColor,
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
                          style: pMedium12.copyWith(color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        DropdownButtonHideUnderline(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.grey.shade200),
                              ),
                            ),
                            child: DropdownButton<int>(
                              value: controller.selectedPage.value,
                              isExpanded: true,
                              items: controller.listPages
                                  .map(
                                    (page) => DropdownMenuItem(
                                      value: page,
                                      child: Text(
                                        'Halaman $page',
                                        style: pSemiBold14,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  controller.selectedPage.value = v!,
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
                          borderRadius: BorderRadius.circular(15),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                        minimumSize: const Size(0, 50),
                      ),
                      child: Text(
                        'Batal',
                        style: pSemiBold14.copyWith(color: Colors.grey),
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
                          borderRadius: BorderRadius.circular(15),
                        ),
                        minimumSize: const Size(0, 50),
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

  Widget _buildSearchSurah(QuranPageScreenController controller) {
    controller.searchSurahController.clear();
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        height: MediaQuery.of(Get.context!).size.height * 0.7,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white,
        ),
        child: Column(
          children: [
            // Header Search Bar
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColor.primaryColor.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: controller.searchSurahController,
                            onChanged: (value) =>
                                controller.onSearchChanged(value),
                            style: pMedium14,
                            decoration: InputDecoration(
                              hintText: 'Cari Surat atau Juz...',
                              hintStyle: pRegular14.copyWith(
                                color: Colors.grey,
                              ),
                              border: InputBorder.none,
                              icon: Icon(
                                IconlyLight.search,
                                size: 20,
                                color: AppColor.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            IconlyLight.close_square,
                            size: 22,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Tab Selector
            Obx(
              () => Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(15),
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
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: controller.tabIsSurat.value
                                ? AppColor.primaryColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Surat',
                            textAlign: TextAlign.center,
                            style: pSemiBold14.copyWith(
                              color: controller.tabIsSurat.value
                                  ? Colors.white
                                  : Colors.grey,
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
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !controller.tabIsSurat.value
                                ? AppColor.primaryColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Juz',
                            textAlign: TextAlign.center,
                            style: pSemiBold14.copyWith(
                              color: !controller.tabIsSurat.value
                                  ? Colors.white
                                  : Colors.grey,
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
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: controller.dropdownSurah.length,
                            itemBuilder: (context, index) {
                              final surah = controller.dropdownSurah[index];
                              return InkWell(
                                onTap: () => controller.onSelectSurah(surah.id),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey.shade100,
                                      ),
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
                                            style: pBold12,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              surah.name,
                                              style: pSemiBold16,
                                            ),
                                            Text(
                                              '${surah.translationName} • ${surah.totalAyah} Ayat',
                                              style: pRegular12.copyWith(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        surah.cityName,
                                        style: pMedium12.copyWith(
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
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: controller.dropdownJuz.length,
                            itemBuilder: (context, index) {
                              final juz = controller.dropdownJuz[index];
                              return InkWell(
                                onTap: () =>
                                    controller.onSelectJuz(juz.juzNomor),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey.shade100,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                          color: AppColor.primaryColor
                                              .withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            juz.juzNomor.toString(),
                                            style: pBold14.copyWith(
                                              color: AppColor.primaryColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Text(
                                        'Juz ${juz.juzNomor}',
                                        style: pSemiBold16,
                                      ),
                                      const Spacer(),
                                      Icon(
                                        IconlyLight.arrow_right_2,
                                        size: 16,
                                        color: Colors.grey.shade300,
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
}
