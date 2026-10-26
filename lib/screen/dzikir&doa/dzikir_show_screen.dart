import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/screen/dzikir&doa/dzikir_show_screen_controller.dart';
import 'package:quran_app/models/dzikir_model.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';

class DzikirShowScreen extends StatelessWidget {
  const DzikirShowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DzikirShowScreenController());
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Obx(
          () => Text(controller.title.value, style: pSemiBold16.copyWith()),
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColor.primaryColor),
            );
          }

          if (controller.data.isEmpty) {
            return Center(
              child: Text(
                'Tidak ada data dzikir',
                style: pRegular14.copyWith(color: AppColor.globalTextSecondary),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 16),
            physics: const BouncingScrollPhysics(),
            itemCount: controller.data.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final dzikir = controller.data[index];
              return _CollapsibleDzikirCard(dzikir: dzikir);
            },
          );
        }),
      ),
    );
  }
}

class _CollapsibleDzikirCard extends StatefulWidget {
  final DzikirModel dzikir;

  const _CollapsibleDzikirCard({required this.dzikir});

  @override
  State<_CollapsibleDzikirCard> createState() => _CollapsibleDzikirCardState();
}

class _CollapsibleDzikirCardState extends State<_CollapsibleDzikirCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isExpanded = !isExpanded;
        });
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 14),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          border: Border.all(color: AppColor.globalBorder, width: 0.5),
          borderRadius: BorderRadius.circular(14),
          color: Theme.of(
            context,
          ).scaffoldBackgroundColor, // Ensure tap detection
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.dzikir.title,
                    style: pSemiBold14.copyWith(
                      color: AppColor.globalTextSecondary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "dibaca ${widget.dzikir.read}x",
                      style: pMedium12.copyWith(
                        color: AppColor.globalTextSecondary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: const Icon(LucideIcons.chevronDown, size: 20),
                    ),
                  ],
                ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: isExpanded
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            widget.dzikir.arab,
                            style: pRegular16.copyWith(
                              fontSize: 24,
                              height: 2,
                              fontWeight: FontWeight.w700,
                              fontFamily: GoogleFonts.amiri().fontFamily,
                              color: AppColor.globalTextSecondary,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          widget.dzikir.latin,
                          style: pSemiBold16.copyWith(
                            color: AppColor.primaryColor,
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          widget.dzikir.arti,
                          style: pRegular14.copyWith(
                            color: AppColor.globalTextSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(width: double.infinity, height: 0),
            ),
          ],
        ),
      ),
    );
  }
}
