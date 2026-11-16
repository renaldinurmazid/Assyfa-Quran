import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/screen/quran_view/tilawah_controller.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/theme/font.dart';
import 'package:quran_app/theme/app_color.dart';

class TilawahkuScreen extends StatelessWidget {
  const TilawahkuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TilawahController());
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.loadAllBookmarks();
          await controller.fetchWeeklyStats();
        },
        color: AppColor.primaryColor,
        edgeOffset: 100,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            _buildAppBar(context, controller),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _buildWeeklyChart(context, controller),
              ),
            ),
            Obx(() {
              if (controller.isLoading.value && controller.bookmarks.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColor.primaryColor,
                    ),
                  ),
                );
              }

              if (controller.bookmarks.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppColor.primaryColor.withOpacity(0.05),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              LucideIcons.bookmarkX,
                              size: 64,
                              color: AppColor.globalTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Belum ada pembatas',
                            style: pSemiBold16.copyWith(
                              color: context.theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Simpan halaman favoritmu agar lebih mudah melanjutkan tilawah di lain waktu.',
                            textAlign: TextAlign.center,
                            style: pMedium12.copyWith(
                              color: AppColor.globalTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final bookmark = controller.bookmarks[index];
                    return _buildBookmarkCard(context, bookmark, controller);
                  }, childCount: controller.bookmarks.length),
                ),
              );
            }),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(BuildContext context, TilawahController controller) {
    return Obx(() {
      if (controller.isLoadingWeekly.value) {
        return Container(
          height: 180,
          decoration: BoxDecoration(
            border: Border.all(color: AppColor.globalBorder, width: 0.5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: CircularProgressIndicator(color: AppColor.primaryColor),
          ),
        );
      }

      final summary = controller.weeklyStats['summary'] as List? ?? [];
      final totalPages = controller.weeklyStats['total_pages'] ?? 0;

      double maxVal = 0;
      for (var item in summary) {
        if ((item['total_pages'] ?? 0).toDouble() > maxVal) {
          maxVal = (item['total_pages'] ?? 0).toDouble();
        }
      }
      if (maxVal < 5) maxVal = 5;

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: AppColor.globalBorder, width: 0.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statistik Mingguan',
                      style: pSemiBold14.copyWith(
                        color: context.theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total $totalPages Halaman Terbaca',
                      style: pMedium12.copyWith(
                        color: AppColor.globalTextSecondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.calendar,
                        size: 14,
                        color: AppColor.primaryColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '7 Hari',
                        style: pSemiBold10.copyWith(
                          color: AppColor.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 140,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: summary.map((item) {
                  final val = (item['total_pages'] ?? 0).toDouble();
                  final heightFactor = (val / maxVal).clamp(0.05, 1.0);
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${item['total_pages']}',
                        style: pMedium12.copyWith(
                          color: AppColor.globalTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        width: 12,
                        height: (40 * heightFactor).toDouble(),
                        decoration: BoxDecoration(
                          color: val > 0
                              ? AppColor.primaryColor
                              : (Get.isDarkMode
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item['day'],
                        style: pMedium12.copyWith(
                          color: val > 0
                              ? AppColor.primaryColor
                              : AppColor.globalTextSecondary,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildAppBar(BuildContext context, TilawahController controller) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: context.theme.scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'Aktivitas Tilawah',
        style: pSemiBold16.copyWith(color: context.theme.colorScheme.onSurface),
      ),
      leading: IconButton(
        icon: Icon(
          LucideIcons.arrowLeft,
          color: context.theme.colorScheme.onSurface,
        ),
        onPressed: () => Get.back(),
      ),
    );
  }

  Widget _buildBookmarkCard(
    BuildContext context,
    dynamic bookmark,
    TilawahController controller,
  ) {
    final pageNumber = bookmark['page_number'];
    final quranType = bookmark['quran_type'] ?? 'Quran';
    final quranTypeSlug = bookmark['quran_type_slug'];
    final surahName = bookmark['surah_name'] ?? '';
    final markerPath = bookmark['marker_path'] ?? '';
    final savedAt = bookmark['saved_at'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.globalBorder, width: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Get.toNamed(
              Routes.quranPage,
              arguments: {
                'slug':
                    quranTypeSlug ??
                    quranType.toLowerCase().replaceAll(' ', '-'),
                'page_number': pageNumber,
                'marker_id': bookmark['marker_id'],
              },
            );
          },
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: markerPath.isNotEmpty
                        ? Image.network(
                            markerPath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildFallbackPreview(context),
                          )
                        : _buildFallbackPreview(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        surahName,
                        style: pSemiBold14.copyWith(
                          color: context.theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            LucideIcons.fileText,
                            size: 12,
                            color: AppColor.globalTextSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Halaman $pageNumber',
                            style: pMedium12.copyWith(
                              color: AppColor.globalTextSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            LucideIcons.clock,
                            size: 12,
                            color: AppColor.globalTextSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            savedAt ??
                                controller.getTimeAgo(bookmark['created_at']),
                            style: pMedium10.copyWith(
                              color: AppColor.globalTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  LucideIcons.chevronRight,
                  color: AppColor.globalTextSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackPreview(BuildContext context) {
    return Center(
      child: Icon(
        LucideIcons.bookOpenText,
        color: AppColor.primaryColor.withOpacity(0.5),
        size: 24,
      ),
    );
  }
}
