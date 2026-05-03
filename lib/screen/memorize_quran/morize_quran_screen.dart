import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/models/memorization_level_model.dart';
import 'package:shimmer/shimmer.dart';

import 'package:quran_app/controller/memorization_controller.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/theme/app_color.dart';
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

class MorizeQuranScreen extends StatelessWidget {
  const MorizeQuranScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    // final isDark = context.isDarkMode;
    final controller = Get.put(MemorizationController());

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
              "Hafalan Quran",
              style: pSemiBold16.copyWith(color: colorScheme.onSurface),
            ),
            centerTitle: false,
            actions: [
              _buildAppBarAction(
                context,
                Icons.leaderboard_rounded,
                () => Get.toNamed(Routes.memorizeLeaderboard),
              ),
              const SizedBox(width: 16),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDynamicStatsCard(context, controller),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Perjalanan Hafalan", style: pSemiBold18),
                      const SizedBox(height: 4),
                      Text(
                        "Selesaikan setiap level untuk memperdalam pemahamanmu",
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
                  final isLocked =
                      !level.isCompleted &&
                      index > 0 &&
                      !controller.levels[index - 1].isCompleted;

                  return _buildLevelItem(context, level, isLocked, controller);
                }, childCount: controller.levels.length),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAppBarAction(
    BuildContext context,
    IconData icon,
    VoidCallback onTap,
  ) {
    final colorScheme = context.theme.colorScheme;
    final isDark = context.isDarkMode;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? colorScheme.surfaceContainer : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: context.isDarkMode ? Colors.white : AppColor.primaryColor,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicStatsCard(
    BuildContext context,
    MemorizationController controller,
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
                : [
                    AppColor.primaryColor,
                    AppColor.primaryColor.withValues(alpha: 0.8),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: AppColor.primaryColor.withValues(
                alpha: isDark ? 0.2 : 0.3,
              ),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Level terakhir",
                        style: pRegular12.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Obx(
                        () => Text(
                          controller.highestLevelTitle.value,
                          style: pBold16.copyWith(color: Colors.white),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.stars_rounded,
                        color: Colors.amber,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Obx(
                        () => Text(
                          "${controller.totalPoints.value}",
                          style: pBold12.copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildStatBadge(
                    context,
                    "Kata Dikuasai",
                    Obx(
                      () => Text(
                        "${controller.totalWordsMastered.value}",
                        style: pBold16.copyWith(color: Colors.white),
                      ),
                    ),
                    Icons.psychology_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatBadge(
                    context,
                    "Peringkat",
                    Obx(
                      () => Text(
                        "#${controller.rank.value}",
                        style: pBold16.copyWith(color: Colors.white),
                      ),
                    ),
                    Icons.emoji_events_rounded,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge(
    BuildContext context,
    String label,
    Widget value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              value,
              Text(
                label,
                style: pRegular10.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLevelItem(
    BuildContext context,
    MemorizationLevel level,
    bool isLocked,
    MemorizationController controller,
  ) {
    final colorScheme = context.theme.colorScheme;
    final isDark = context.isDarkMode;
    final levelColor = HexColor(level.backgroundColor);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (!isLocked) {
              Get.toNamed(Routes.levelDetail, arguments: level);
            }
          },
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? colorScheme.surfaceContainer : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isLocked
                    ? colorScheme.outlineVariant.withValues(alpha: 0.1)
                    : levelColor.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isLocked
                      ? Colors.transparent
                      : levelColor.withValues(alpha: isDark ? 0.1 : 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: isLocked
                            ? colorScheme.surfaceContainerHighest
                            : levelColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Opacity(
                            opacity: isLocked ? 0.3 : 1.0,
                            child: Image.network(
                              level.image,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (isLocked)
                      Positioned.fill(
                        child: Center(
                          child: Icon(
                            Icons.lock_rounded,
                            color: colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isLocked
                                  ? colorScheme.surfaceContainerHighest
                                  : levelColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "Level ${level.order}",
                              style: pBold10.copyWith(
                                color: isLocked
                                    ? colorScheme.onSurfaceVariant
                                    : levelColor,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (level.isCompleted)
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Colors.green,
                              size: 18,
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        level.title,
                        style: pSemiBold14,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: level.progressPercentage / 100,
                                minHeight: 8,
                                backgroundColor: isDark
                                    ? colorScheme.surfaceContainerHighest
                                    : Colors.grey[100],
                                color: isLocked
                                    ? colorScheme.onSurfaceVariant.withValues(
                                        alpha: 0.2,
                                      )
                                    : levelColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "${level.completedQuestionsCount}/${level.totalQuestionsCount}",
                            style: pBold12.copyWith(
                              color: colorScheme.onSurfaceVariant,
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

  Widget _buildShimmerCard(BuildContext context) {
    final isDark = context.isDarkMode;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 110,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}
