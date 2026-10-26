import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/screen/dzikir&doa/list_doa_screen_controller.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';

class ListDoaScreen extends StatelessWidget {
  const ListDoaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ListDoaScreenController());
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Kumpulan Doa', style: pSemiBold16.copyWith()),
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
                'Tidak ada data doa',
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
              final doa = controller.data[index];
              return _CollapsibleDoaCard(doa: doa);
            },
          );
        }),
      ),
    );
  }
}

class _CollapsibleDoaCard extends StatefulWidget {
  final dynamic doa;

  const _CollapsibleDoaCard({required this.doa});

  @override
  State<_CollapsibleDoaCard> createState() => _CollapsibleDoaCardState();
}

class _CollapsibleDoaCardState extends State<_CollapsibleDoaCard> {
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
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.doa.nama,
                    style: pSemiBold14.copyWith(
                      color: AppColor.globalTextSecondary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(LucideIcons.chevronDown, size: 20),
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
                            widget.doa.ar,
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
                          widget.doa.idn,
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
