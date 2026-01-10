import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
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
                    return const Text('Quran Page');
                  }
                  final currentPage =
                      controller.dataPage[controller.currentPageIndex.value];
                  final surahs = currentPage.ayahs
                      .map((e) => e.ayah.surah.name)
                      .toSet()
                      .toList();
                  return InkWell(
                    onTap: () {
                      controller.fetchDropdownSurah('');
                      controller.fetchDropdownJuz();
                      Get.dialog(_buildSearchSurah(controller));
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: Text(
                                surahs.join(', '),
                                style: pMedium16.copyWith(
                                  color: AppColor.primaryColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: AppColor.primaryColor,
                              size: 20,
                            ),
                          ],
                        ),
                        Text(
                          'Halaman ${currentPage.pageNumber}, Juz ${currentPage.juzNumbers.isNotEmpty ? currentPage.juzNumbers.first : "-"}',
                          style: pRegular12.copyWith(color: Colors.grey),
                        ),
                      ],
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
                      Icons.find_in_page_rounded,
                      color: AppColor.primaryColor,
                      size: 24,
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
                    icon: const Icon(Icons.more_vert),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    color: AppColor.primaryColor,
                    padding: const EdgeInsets.all(0),
                    menuPadding: EdgeInsets.all(0),
                    itemBuilder: (context) => [
                      controller.isLandscape.value
                          ? PopupMenuItem(
                              value: 'setPortrait',
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.crop_portrait,
                                    color: AppColor.backgroundColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Perkecil Layar',
                                    style: pRegular14.copyWith(
                                      color: AppColor.backgroundColor,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : PopupMenuItem(
                              value: 'setLandscape',
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.crop_landscape,
                                    color: AppColor.backgroundColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Perbesar Layar',
                                    style: pRegular14.copyWith(
                                      color: AppColor.backgroundColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      PopupMenuItem(
                        value: 'search',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info,
                              color: AppColor.backgroundColor,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Info Detail',
                              style: pRegular14.copyWith(
                                color: AppColor.backgroundColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'search',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.refresh,
                              color: AppColor.backgroundColor,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Muat Ulang',
                              style: pRegular14.copyWith(
                                color: AppColor.backgroundColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
                backgroundColor: AppColor.backgroundColor,
                elevation: 1,
                surfaceTintColor: AppColor.backgroundColor,
                shadowColor: AppColor.primaryColor,
                iconTheme: const IconThemeData(color: AppColor.primaryColor),
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

                      Widget buildPageContent() {
                        return Obx(() {
                          if (controller.viewportWidth.value == 0) {
                            return Image.network(
                              '${controller.fullImageUrl}${page.imagePath ?? ""}',
                              fit: isLandscape
                                  ? BoxFit.fitWidth
                                  : BoxFit.contain,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
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
                                      Image.network(
                                        '${controller.fullImageUrl}${page.imagePath ?? ""}',
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
                                              color: AppColor.primaryColor,
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
                                                          m.ayah.id ==
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
            Obx(
              () => (controller.isLoading.value && controller.dataPage.isEmpty)
                  ? const SizedBox.shrink()
                  : AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      bottom: controller.isFocus.value ? -100 : 0,
                      right: 0,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.backgroundColor,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () => controller.toggleAudio(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.primaryColor,
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(0),
                              ),
                              child: Icon(
                                controller.isPlaying.value
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: AppColor.backgroundColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 1,
                              height: 24,
                              color: AppColor.primaryColor,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                dropdownColor: AppColor.backgroundColor,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 10,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  fillColor: AppColor.backgroundColor,
                                  filled: true,
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: AppColor.primaryColor,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: AppColor.primaryColor,
                                    ),
                                  ),
                                ),
                                value: controller.selectedReciter.value,
                                items: controller.reciters.map((reciter) {
                                  return DropdownMenuItem(
                                    value: reciter['code'],
                                    child: Text(
                                      reciter['name']!,
                                      style: pMedium14,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) =>
                                    controller.changeReciter(value),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAyah(QuranPageScreenController controller) {
    return Dialog(
      child: Obx(
        () => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: AppColor.backgroundColor,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pergi Ke',
                style: pMedium16.copyWith(color: AppColor.primaryColor),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      controller.tabIsAyah.value = true;
                      controller.searchAyahPageController.jumpToPage(0);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                        ),
                        color: controller.tabIsAyah.value
                            ? AppColor.primaryColor
                            : AppColor.borderColor,
                      ),
                      child: Text(
                        'Ayat',
                        style: pMedium12.copyWith(
                          color: controller.tabIsAyah.value
                              ? AppColor.backgroundColor
                              : AppColor.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      controller.tabIsAyah.value = false;
                      controller.searchAyahPageController.jumpToPage(1);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                        color: controller.tabIsAyah.value
                            ? AppColor.borderColor
                            : AppColor.primaryColor,
                      ),
                      child: Text(
                        'Halaman',
                        style: pMedium12.copyWith(
                          color: controller.tabIsAyah.value
                              ? AppColor.primaryColor
                              : AppColor.backgroundColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 100,
                child: PageView.builder(
                  itemCount: 2,
                  controller: controller.searchAyahPageController,
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return controller.tabIsAyah.value
                        ? Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Surat', style: pRegular12),
                                    const SizedBox(height: 12),
                                    SearchAnchor(
                                      viewBackgroundColor:
                                          AppColor.backgroundColor,
                                      searchController:
                                          controller.searchAnchorController,
                                      viewHintText: 'Cari Surat',
                                      headerHintStyle: pRegular12,
                                      headerTextStyle: pRegular12,
                                      builder: (context, anchorController) {
                                        return Obx(
                                          () => InkWell(
                                            onTap: () =>
                                                anchorController.openView(),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 8,
                                                  ),
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  bottom: BorderSide(
                                                    color: AppColor.borderColor,
                                                  ),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      controller
                                                              .selectedSurahName
                                                              .value
                                                              .isEmpty
                                                          ? 'Pilih Surat'
                                                          : controller
                                                                .selectedSurahName
                                                                .value,
                                                      style: pRegular12,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  const Icon(
                                                    Icons.arrow_drop_down,
                                                    size: 20,
                                                    color:
                                                        AppColor.primaryColor,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      suggestionsBuilder:
                                          (context, anchorController) {
                                            if (anchorController.text.isEmpty &&
                                                controller
                                                    .dropdownSurah
                                                    .isEmpty) {
                                              controller.fetchDropdownSurah('');
                                            }
                                            return [
                                              Obx(() {
                                                if (controller
                                                    .isDialogLoading
                                                    .value) {
                                                  return const Center(
                                                    child: Padding(
                                                      padding: EdgeInsets.all(
                                                        16.0,
                                                      ),
                                                      child:
                                                          CircularProgressIndicator(
                                                            color: AppColor
                                                                .primaryColor,
                                                          ),
                                                    ),
                                                  );
                                                }
                                                return Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: controller
                                                      .dropdownSurah
                                                      .map((surah) {
                                                        return ListTile(
                                                          title: Text(
                                                            surah.name,
                                                            style: pRegular12,
                                                          ),
                                                          onTap: () {
                                                            controller
                                                                .selectedSurahName
                                                                .value = surah
                                                                .name;
                                                            controller
                                                                    .surahId
                                                                    .value =
                                                                surah.id;
                                                            anchorController
                                                                .closeView(
                                                                  surah.name,
                                                                );
                                                          },
                                                        );
                                                      })
                                                      .toList(),
                                                );
                                              }),
                                            ];
                                          },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              SizedBox(
                                width: 60,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Ayat', style: pRegular12),
                                    TextField(
                                      controller:
                                          controller.searchAyahController,
                                      cursorColor: AppColor.primaryColor,
                                      style: pRegular12,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        hintText: 'No',
                                        border: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: AppColor.borderColor,
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
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Halaman', style: pRegular12),
                              const SizedBox(height: 12),
                              Obx(
                                () => DropdownButtonFormField<int>(
                                  dropdownColor: AppColor.backgroundColor,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    border: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: AppColor.borderColor,
                                      ),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: AppColor.primaryColor,
                                      ),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: AppColor.borderColor,
                                      ),
                                    ),
                                  ),
                                  value: controller.selectedPage.value,
                                  items: controller.listPages.map((page) {
                                    return DropdownMenuItem<int>(
                                      value: page,
                                      child: Text('$page', style: pRegular12),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      controller.selectedPage.value = value;
                                    }
                                  },
                                ),
                              ),
                            ],
                          );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.borderColor,
                      ),
                      child: Text('Batal', style: pMedium12),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (controller.tabIsAyah.value) {
                          controller.onJumpToAyah();
                        } else {
                          controller.onJumpToPage();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primaryColor,
                      ),
                      child: Text(
                        'Pergi',
                        style: pMedium12.copyWith(
                          color: AppColor.backgroundColor,
                        ),
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        height: 500,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColor.backgroundColor,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                color: AppColor.primaryColor,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      cursorColor: AppColor.backgroundColor,
                      style: pRegular12.copyWith(
                        color: AppColor.backgroundColor,
                      ),
                      controller: controller.searchSurahController,
                      onChanged: (value) {
                        controller.onSearchChanged(value);
                      },
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColor.backgroundColor,
                          size: 20,
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        hintText: 'Cari surat',
                        hintStyle: pRegular12.copyWith(
                          color: AppColor.backgroundColor,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    padding: EdgeInsets.zero,
                    style: IconButton.styleFrom(padding: EdgeInsets.zero),
                    icon: const Icon(
                      Icons.close,
                      color: AppColor.backgroundColor,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            Obx(
              () => Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        controller.tabIsSurat.value = true;
                        controller.searchSuratPageController.jumpToPage(0);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: controller.tabIsSurat.value
                                  ? AppColor.primaryColor
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ),
                        child: Text(
                          'Surat',
                          style: pRegular12.copyWith(
                            color: controller.tabIsSurat.value
                                ? AppColor.primaryColor
                                : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        controller.tabIsSurat.value = false;
                        controller.searchSuratPageController.jumpToPage(1);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: !controller.tabIsSurat.value
                                  ? AppColor.primaryColor
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ),
                        child: Text(
                          'Juz',
                          style: pRegular12.copyWith(
                            color: !controller.tabIsSurat.value
                                ? AppColor.primaryColor
                                : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: controller.searchSuratPageController,
                itemCount: 2,
                onPageChanged: (index) {
                  controller.tabIsSurat.value = index == 0;
                },
                itemBuilder: (context, index) {
                  return Obx(
                    () => index == 0
                        ? controller.isDialogLoading.value
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColor.primaryColor,
                                  ),
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () {
                                        controller.onSelectSurah(
                                          controller.dropdownSurah[index].id,
                                        );
                                      },
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: AssetImage(
                                                  'assets/images/png/frame.png',
                                                ),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                controller
                                                    .dropdownSurah[index]
                                                    .id
                                                    .toString(),
                                                style: pSemiBold12.copyWith(
                                                  color:
                                                      AppColor.backgroundColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                controller
                                                    .dropdownSurah[index]
                                                    .name,
                                                style: pMedium14.copyWith(
                                                  color: AppColor.primaryColor,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    controller
                                                        .dropdownSurah[index]
                                                        .translationName,
                                                    style: pRegular10,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Container(
                                                    width: 1,
                                                    height: 12,
                                                    color: Colors.white,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${controller.dropdownSurah[index].cityName}(${controller.dropdownSurah[index].totalAyah})',
                                                    style: pRegular10,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  separatorBuilder: (context, index) {
                                    return const SizedBox(height: 8);
                                  },
                                  itemCount: controller.dropdownSurah.length,
                                )
                        : controller.isDialogLoading.value
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColor.primaryColor,
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  controller.onSelectJuz(
                                    controller.dropdownJuz[index].juzNomor,
                                  );
                                },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(
                                            'assets/images/png/frame.png',
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          controller.dropdownJuz[index].juzNomor
                                              .toString(),
                                          style: pSemiBold12.copyWith(
                                            color: AppColor.backgroundColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Juz ${controller.dropdownJuz[index].juzNomor}',
                                      style: pMedium14.copyWith(
                                        color: AppColor.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            separatorBuilder: (context, index) {
                              return const SizedBox(height: 8);
                            },
                            itemCount: controller.dropdownJuz.length,
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
