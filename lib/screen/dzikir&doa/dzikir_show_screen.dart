import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:quran_app/controller/dzikir_show_screen_controller.dart';
import 'package:quran_app/models/dzikir_model.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';

class DzikirShowScreen extends StatelessWidget {
  const DzikirShowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DzikirShowScreenController());
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(controller),
          SliverToBoxAdapter(
            child: Obx(() {
              if (controller.isLoading.value) {
                return SizedBox(
                  height: Get.height * 0.7,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColor.primaryColor,
                    ),
                  ),
                );
              }

              if (controller.data.isEmpty) {
                return SizedBox(
                  height: Get.height * 0.7,
                  child: Center(
                    child: Text('Tidak ada data dzikir', style: pRegular14),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.all(20),
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final dzikir = controller.data[index];
                  return _DzikirCard(dzikir: dzikir, index: index + 1);
                },
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemCount: controller.data.length,
              );
            }),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(DzikirShowScreenController controller) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: AppColor.primaryColor,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Obx(
          () => Text(
            controller.title.value,
            style: pBold18.copyWith(color: Colors.white),
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColor.primaryColor,
                    AppColor.primaryColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              right: -20,
              top: -20,
              child: Icon(
                IconlyLight.star,
                size: 150,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: const Icon(IconlyLight.arrow_left_2, color: Colors.white),
        onPressed: () => Get.back(),
      ),
    );
  }
}

class _DzikirCard extends StatelessWidget {
  final DzikirModel dzikir;
  final int index;

  const _DzikirCard({required this.dzikir, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryColor.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        dzikir.title,
                        style: pBold16.copyWith(
                          color: AppColor.primaryColor,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Baca ${dzikir.read}x',
                        style: pBold10.copyWith(color: AppColor.primaryColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Teks Arab
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColor.primaryColor.withOpacity(0.05),
                    ),
                  ),
                  child: Text(
                    dzikir.arab,
                    style: GoogleFonts.amiri(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      height: 2.2,
                      color: const Color(0xFF2D2D2D),
                    ),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                  ),
                ),
                const SizedBox(height: 20),
                // Transliterasi Latin
                Text(
                  dzikir.latin,
                  style: pMedium14.copyWith(
                    color: AppColor.primaryColor.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                // Terjemahan
                Text(
                  dzikir.arti,
                  style: pRegular14.copyWith(
                    color: Colors.grey[700],
                    height: 1.6,
                  ),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 20),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildActionButton(
                      icon: Icons.copy_rounded,
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(
                            text:
                                "${dzikir.title}\n\n${dzikir.arab}\n\n${dzikir.arti}",
                          ),
                        );
                        Get.snackbar(
                          'Berhasil',
                          'Dzikir berhasil disalin',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: AppColor.primaryColor,
                          colorText: Colors.white,
                          margin: const EdgeInsets.all(20),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColor.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColor.primaryColor, size: 20),
      ),
    );
  }
}
