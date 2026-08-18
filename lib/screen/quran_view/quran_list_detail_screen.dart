import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/screen/quran_view/quran_list_detail_screen_controller.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:quran_app/models/quran_list_detail_model.dart';
import 'package:quran_app/theme/font.dart';

class QuranListDetailScreen extends StatelessWidget {
  const QuranListDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(QuranListDetailScreenController());
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.data.value?.namaLatin ?? 'Memuat...',
            style: pSemiBold16.copyWith(color: Theme.of(context).primaryColor),
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        // actions: [
        //   IconButton(
        //     onPressed: () {
        //       // Share or bookmark logic could go here
        //     },
        //     icon: const Icon(Icons.share_outlined),
        //   ),
        // ],
      ),
      body: Obx(
        () => controller.isLoading.value
            ? Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                ),
              )
            : Stack(
                children: [
                  ScrollablePositionedList.builder(
                    itemScrollController: controller.itemScrollController,
                    itemPositionsListener: controller.itemPositionsListener,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                    itemCount: (controller.data.value?.ayat.length ?? 0) + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _buildHeader(controller.data.value!);
                      }

                      final ayahIndex = index - 1;
                      final ayat = controller.data.value?.ayat[ayahIndex];
                      return Obx(() {
                        final isCurrent =
                            controller.currentAyahIndex.value == ayahIndex &&
                            controller.isPlaying.value;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.08)
                                : Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: isCurrent
                                    ? Theme.of(
                                        context,
                                      ).primaryColor.withOpacity(0.1)
                                    : Colors.black.withOpacity(
                                        Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? 0.2
                                            : 0.02,
                                      ),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: isCurrent
                                  ? Theme.of(
                                      context,
                                    ).primaryColor.withOpacity(0.2)
                                  : Theme.of(
                                      context,
                                    ).primaryColor.withOpacity(0.05),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 36,
                                    width: 36,
                                    decoration: BoxDecoration(
                                      color: isCurrent
                                          ? Theme.of(context).primaryColor
                                          : Theme.of(
                                              context,
                                            ).primaryColor.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      ayat?.nomorAyat.toString() ?? '',
                                      style: pBold12.copyWith(
                                        color: isCurrent
                                            ? Colors.white
                                            : Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    onPressed: () {
                                      // Individual ayah audio or bookmark
                                    },
                                    icon: Icon(
                                      Icons.more_vert,
                                      color: Theme.of(
                                        context,
                                      ).hintColor.withOpacity(0.4),
                                      size: 20,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                ayat?.teksArab ?? '',
                                style: pBold24.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  height: 1.8,
                                ),
                                textAlign: TextAlign.end,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                ayat?.teksLatin ?? '',
                                style: pMedium14.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                ayat?.teksIndonesia ?? '',
                                style: pRegular14.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        );
                      });
                    },
                  ),
                  _buildAudioPlayer(controller),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader(Data data) {
    return Builder(
      builder: (context) {
        return Container(
          margin: const EdgeInsets.only(top: 16, bottom: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                data.namaLatin,
                style: pSemiBold20.copyWith(color: Colors.white),
              ),
              Text(
                data.arti,
                style: pMedium14.copyWith(color: Colors.white.withOpacity(0.8)),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(color: Colors.white24, thickness: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data.tempatTurun.toUpperCase(),
                    style: pMedium12.copyWith(
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 4,
                    width: 4,
                    decoration: const BoxDecoration(
                      color: Colors.white54,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${data.jumlahAyat} AYAT',
                    style: pMedium12.copyWith(
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                style: pBold24.copyWith(color: Colors.white, fontSize: 28),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAudioPlayer(QuranListDetailScreenController controller) {
    return Builder(
      builder: (context) {
        return Positioned(
          bottom: 24,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.1,
                  ),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                Obx(
                  () => Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () => controller.playPauseAudio(),
                      icon: Icon(
                        controller.isPlaying.value
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pilih Qori',
                        style: pMedium10.copyWith(
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      Obx(
                        () => DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isDense: true,
                            isExpanded: true,
                            dropdownColor: Theme.of(
                              context,
                            ).colorScheme.surface,
                            value: controller.selectedReciter.value,
                            items: controller.reciters.map((reciter) {
                              return DropdownMenuItem(
                                value: reciter['code'],
                                child: Text(
                                  reciter['name']!,
                                  style: pSemiBold14.copyWith(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: controller.onReciterChanged,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
