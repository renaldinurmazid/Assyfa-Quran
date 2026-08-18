import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:quran_app/models/arabic_learning/arabic_level_model.dart';
import 'package:quran_app/screen/arabic-quran/arabic_quran_controller.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/theme/font.dart';

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

class ArabicQuranScreen extends StatelessWidget {
  const ArabicQuranScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final controller = Get.find<ArabicQuranController>();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: colorScheme.surface,
            elevation: 0,
            leadingWidth: 52,
            leading: InkWell(
              onTap: () => Get.back(),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: colorScheme.onSurface,
                size: 20,
              ),
            ),
            title: Text(
              "Belajar Bahasa Arab",
              style: pSemiBold16.copyWith(color: colorScheme.onSurface),
            ),
            centerTitle: false,
            actions: [const SizedBox(width: 16)],
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // _buildDynamicStatsCard(context, controller),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/images/svg/xp-badge.svg',
                            width: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "1250 xp",
                            style: pBold12.copyWith(
                              color: context.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            "Lvl.",
                            style: pBold12.copyWith(
                              color: context.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "12",
                            style: pBold12.copyWith(
                              color: context.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            "3256",
                            style: pBold12.copyWith(
                              color: context.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Kata",
                            style: pBold12.copyWith(
                              color: context.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Peta Perjalanan Belajar", style: pSemiBold18),
                      const SizedBox(height: 4),
                      Text(
                        "Selesaikan setiap level untuk memahami tata bahasa dan kosakata bahasa Arab dari Al-Quran.",
                        style: pRegular12.copyWith(
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          Obx(() {
            if (controller.isLoadingLevels.value && controller.levels.isEmpty) {
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildShimmerCard(context),
                    childCount: 3,
                  ),
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final level = controller.levels[index];
                  return _buildLevelItem(context, level, controller);
                }, childCount: controller.levels.length),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDynamicStatsCard(
    BuildContext context,
    ArabicQuranController controller,
  ) {
    final colorScheme = context.theme.colorScheme;
    final isDark = context.isDarkMode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    colorScheme.surfaceContainerHighest,
                    colorScheme.surfaceContainer,
                  ]
                : [Colors.teal.shade500, Colors.teal.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.teal.withValues(alpha: isDark ? 0.2 : 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Mulai Perjalananmu!",
                    style: pSemiBold16.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Pahami makna ayat Al-Quran langsung dari sumbernya.",
                    style: pRegular12.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerCard(BuildContext context) {
    final isDark = context.isDarkMode;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }

  Widget _buildLevelItem(
    BuildContext context,
    ArabicLevel level,
    ArabicQuranController controller,
  ) {
    final colorScheme = context.theme.colorScheme;
    final isDark = context.isDarkMode;
    final levelColor = HexColor(level.color);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: level.isLocked
              ? () {
                  Get.snackbar(
                    'Level Terkunci',
                    'Selesaikan level sebelumnya terlebih dahulu.',
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(16),
                  );
                }
              : () {
                  Get.toNamed(Routes.arabicLesson, arguments: level.id);
                },
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? colorScheme.surfaceContainer : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: level.isLocked
                    ? colorScheme.outlineVariant.withValues(alpha: 0.2)
                    : levelColor.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: level.isLocked
                        ? colorScheme.surfaceContainerHighest
                        : levelColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: level.icon != null
                        ? CachedNetworkImage(
                            imageUrl: level.icon!,
                            width: 32,
                            height: 32,
                          )
                        : Icon(
                            level.isLocked
                                ? Icons.lock_rounded
                                : Icons.star_rounded,
                            color: level.isLocked
                                ? colorScheme.onSurfaceVariant
                                : levelColor,
                            size: 28,
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        level.name,
                        style: pSemiBold14.copyWith(
                          color: level.isLocked
                              ? colorScheme.onSurfaceVariant
                              : colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        level.description,
                        style: pRegular10.copyWith(
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.8,
                          ),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: level.progressPct / 100,
                                minHeight: 6,
                                backgroundColor: isDark
                                    ? colorScheme.surfaceContainerHighest
                                    : Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  level.isLocked ? Colors.grey : levelColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "${level.progressPct}%",
                            style: pSemiBold10.copyWith(
                              color: level.isLocked
                                  ? colorScheme.onSurfaceVariant
                                  : levelColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
