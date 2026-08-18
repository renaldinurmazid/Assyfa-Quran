import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:quran_app/screen/dzikir&doa/dzikir_show_screen_controller.dart';
import 'package:quran_app/models/dzikir_model.dart';
import 'package:quran_app/theme/font.dart';
import 'package:quran_app/widgets/app_toast.dart';

class DzikirShowScreen extends StatelessWidget {
  const DzikirShowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DzikirShowScreenController());
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: CustomScrollView(
          slivers: [
            _buildSliverAppBar(context, controller),
            SliverToBoxAdapter(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return SizedBox(
                    height: Get.height * 0.7,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  );
                }

                if (controller.data.isEmpty) {
                  return SizedBox(
                    height: Get.height * 0.7,
                    child: Center(
                      child: Text(
                        'Tidak ada data dzikir',
                        style: pRegular14.copyWith(
                          color: Theme.of(context).hintColor,
                        ),
                      ),
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
      ),
    );
  }

  Widget _buildSliverAppBar(
    BuildContext context,
    DzikirShowScreenController controller,
  ) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).primaryColor,
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
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
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
      actions: [
        Obx(() {
          final isAlMatsurat =
              controller.title.value.toLowerCase().contains('al-matsurat');
          if (!isAlMatsurat) return const SizedBox.shrink();

          return PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            color: Theme.of(context).colorScheme.surface,
            onSelected: (value) {
              if (value == 'toggleLandscape') {
                controller.toggleOrientation();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'toggleLandscape',
                child: Row(
                  children: [
                    Icon(
                      controller.isLandscape.value
                          ? Icons.stay_current_portrait_rounded
                          : Icons.stay_current_landscape_rounded,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      controller.isLandscape.value
                          ? 'Mode Potret'
                          : 'Mode Landscape',
                      style: pMedium14.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.1 : 0.04),
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
                          color: Theme.of(context).primaryColor,
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
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Baca ${dzikir.read}x',
                        style: pBold10.copyWith(
                          color: Theme.of(context).primaryColor,
                        ),
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
                    color: Theme.of(context).primaryColor.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.05),
                    ),
                  ),
                  child: Text(
                    dzikir.arab,
                    style: GoogleFonts.amiri(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      height: 2.2,
                      color: Theme.of(context).colorScheme.onSurface,
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
                    color: Theme.of(context).primaryColor.withOpacity(0.8),
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                // Terjemahan
                Text(
                  dzikir.arti,
                  style: pRegular14.copyWith(
                    color: Theme.of(context).hintColor,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 20),
                Divider(height: 1, color: Theme.of(context).dividerColor),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildActionButton(
                      context,
                      icon: Icons.copy_rounded,
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(
                            text:
                                "${dzikir.title}\n\n${dzikir.arab}\n\n${dzikir.arti}",
                          ),
                        );
                        AppToast.success(
                          context: context,
                          message: 'Dzikir berhasil disalin',
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

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
      ),
    );
  }
}
