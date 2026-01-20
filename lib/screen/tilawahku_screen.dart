import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:quran_app/controller/quran/tilawah_controller.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';

class TilawahkuScreen extends StatelessWidget {
  const TilawahkuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final controller = Get.put(TilawahController());

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      body: RefreshIndicator(
        onRefresh: () => controller.loadAllBookmarks(),
        color: AppColor.primaryColor,
        edgeOffset: 100,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            _buildAppBar(controller),
            Obx(() {
              if (controller.isLoading.value && controller.bookmarks.isEmpty) {
                return const SliverFillRemaining(
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
                              IconlyLight.bookmark,
                              size: 64,
                              color: AppColor.primaryColor.withOpacity(0.3),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Belum ada pembatas',
                            style: pBold18.copyWith(
                              color: AppColor.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Simpan halaman favoritmu agar lebih mudah melanjutkan tilawah di lain waktu.',
                            textAlign: TextAlign.center,
                            style: pRegular14.copyWith(
                              color: Colors.grey.shade500,
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
                    return _buildBookmarkCard(bookmark, controller);
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

  Widget _buildAppBar(TilawahController controller) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 120,
      backgroundColor: AppColor.backgroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.only(bottom: 16),
        title: Text(
          'Aktivitas Tilawah',
          style: pBold18.copyWith(color: AppColor.primaryColor),
        ),
        background: Container(
          decoration: BoxDecoration(
            color: AppColor.primaryColor.withOpacity(0.03),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
        ),
      ),
      actions: [
        Obx(
          () => controller.bookmarks.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${controller.bookmarks.length}',
                        style: pBold12.copyWith(color: AppColor.primaryColor),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildBookmarkCard(dynamic bookmark, TilawahController controller) {
    final pageNumber = bookmark['page_number'];
    final quranType = bookmark['quran_type'] ?? 'Quran';
    final quranTypeSlug = bookmark['quran_type_slug'];
    final surahName = bookmark['surah_name'] ?? '';
    final markerPath = bookmark['marker_path'] ?? '';
    final savedAt = bookmark['saved_at'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
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
              },
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  height: 85,
                  width: 65,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.primaryColor.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: markerPath.isNotEmpty
                        ? Image.network(
                            markerPath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildFallbackPreview(),
                          )
                        : _buildFallbackPreview(),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.primaryColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          quranType.toUpperCase(),
                          style: pBold10.copyWith(
                            color: AppColor.primaryColor,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        surahName,
                        style: pBold16.copyWith(color: Colors.black87),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            IconlyLight.document,
                            size: 14,
                            color: AppColor.primaryColor.withOpacity(0.6),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Halaman $pageNumber',
                            style: pMedium12.copyWith(
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            IconlyLight.time_circle,
                            size: 12,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            savedAt ??
                                controller.getTimeAgo(bookmark['created_at']),
                            style: pRegular10.copyWith(
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  IconlyLight.arrow_right_2,
                  color: AppColor.primaryColor.withOpacity(0.3),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackPreview() {
    return Container(
      color: AppColor.primaryColor.withOpacity(0.05),
      child: Center(
        child: Icon(
          Icons.menu_book_rounded,
          color: AppColor.primaryColor.withOpacity(0.2),
          size: 24,
        ),
      ),
    );
  }
}
