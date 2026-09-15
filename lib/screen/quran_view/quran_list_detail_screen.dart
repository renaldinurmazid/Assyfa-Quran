import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_app/screen/quran_view/quran_list_detail_screen_controller.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:quran_app/models/quran_list_detail_model.dart';
import 'package:quran_app/theme/font.dart';

class QuranListDetailScreen extends StatelessWidget {
  const QuranListDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(QuranListDetailScreenController());
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        centerTitle: false,
        title: Obx(
          () => Text(
            controller.data.value?.namaLatin ?? '',
            style: pSemiBold18.copyWith(color: Colors.white),
          ),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Obx(() {
                final data = controller.data.value;
                if (data == null) return const SizedBox();
                return Text(
                  '${data.jumlahAyat} Aya, ${data.tempatTurun}',
                  style: pMedium14.copyWith(color: Colors.white),
                );
              }),
            ),
          ),
        ],
      ),
      body: Obx(
        () => controller.isLoading.value
            ? Center(child: CircularProgressIndicator(color: primaryColor))
            : Stack(
                children: [
                  ScrollablePositionedList.builder(
                    itemScrollController: controller.itemScrollController,
                    itemPositionsListener: controller.itemPositionsListener,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                    itemCount: (controller.data.value?.ayat.length ?? 0) + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _buildBismillahHeader(controller.data.value!);
                      }

                      final ayahIndex = index - 1;
                      final ayat = controller.data.value?.ayat[ayahIndex];
                      return Obx(() {
                        final isCurrent =
                            controller.currentAyahIndex.value == ayahIndex &&
                            controller.isPlaying.value;

                        return Container(
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? primaryColor.withOpacity(0.08)
                                : Colors.transparent,
                            border: Border(
                              bottom: BorderSide(
                                color: Theme.of(
                                  context,
                                ).dividerColor.withOpacity(0.12),
                                width: 1,
                              ),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Arabic Text + Ayah Number in Frame
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // Frame with ayah number
                                  SizedBox(
                                    height: 32,
                                    width: 32,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/images/png/frame.png',
                                          height: 32,
                                          width: 32,
                                          fit: BoxFit.contain,
                                        ),
                                        Text(
                                          ayat?.nomorAyat.toString() ?? '',
                                          style: pBold10.copyWith(
                                            color: primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // Arabic text
                                  Expanded(
                                    child: Text(
                                      ayat?.teksArab ?? '',
                                      style: GoogleFonts.amiri(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        height: 2.0,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                      textAlign: TextAlign.right,
                                      textDirection: TextDirection.rtl,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Latin / Transliteration
                              Text(
                                ayat?.teksLatin ?? '',
                                style: pMedium14.copyWith(
                                  color: primaryColor,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 6),
                              // Indonesian Translation with Number prefix
                              Text(
                                '${ayat?.nomorAyat}. ${ayat?.teksIndonesia ?? ''}',
                                style: pRegular14.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.85),
                                  height: 1.5,
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

  Widget _buildBismillahHeader(Data data) {
    // Surah At-Taubah (nomor 9) tidak diawali bismillah
    if (data.nomor == 9) return const SizedBox(height: 8);

    return Builder(
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor.withOpacity(0.12),
                width: 1,
              ),
            ),
          ),
          child: Center(
            child: Text(
              'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
              style: GoogleFonts.amiri(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
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
