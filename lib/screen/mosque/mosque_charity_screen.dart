import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:shimmer/shimmer.dart';
import 'package:quran_app/screen/mosque/mosque_charity_controller.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';

class MosqueCharityScreen extends StatelessWidget {
  const MosqueCharityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MosqueCharityController());
    final searchController = TextEditingController();

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Infaq Masjid', style: pBold16),
        centerTitle: true,
        backgroundColor: context.theme.scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(
              IconlyBroken.location,
              color: AppColor.primaryColorDark,
              size: 20,
            ),
            onPressed: () => Get.toNamed(Routes.mosqueMap),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          searchController.clear();
          controller.searchQuery.value = '';
          await controller.fetchMosqueCharityList();
        },
        color: AppColor.primaryColor,
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero Banner
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.primaryColorDark.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: AppColor.primaryColorDark.withOpacity(
                                  0.2,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.home_work_rounded,
                                  size: 12,
                                  color: AppColor.primaryColorDark,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Amal Jariah Masjid',
                                  style: pSemiBold10.copyWith(
                                    color: AppColor.primaryColorDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Kemakmuran & Infaq Masjid',
                        style: pBold20.copyWith(
                          color: context.theme.colorScheme.onSurface,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Alirkan pahala jariyah Anda untuk membantu pembangunan dan program kemakmuran masjid.',
                        style: pRegular12.copyWith(
                          color: context.theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSearchBar(controller, searchController),
                      const SizedBox(height: 24),
                      Text("Daftar Masjid Pilihan", style: pBold14),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              _buildMosqueList(controller),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(
    MosqueCharityController controller,
    TextEditingController searchController,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Get.context!.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: Get.context!.isDarkMode
              ? Colors.grey.shade800
              : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        onChanged: (value) => controller.searchMosque(value),
        style: pRegular14,
        decoration: InputDecoration(
          hintText: 'Cari nama masjid atau lokasi...',
          hintStyle: pRegular14.copyWith(
            color: Get.context!.isDarkMode
                ? Colors.grey.shade600
                : Colors.grey.shade400,
          ),
          prefixIcon: Icon(
            IconlyLight.search,
            color: Get.context!.isDarkMode
                ? Colors.grey.shade600
                : Colors.grey.shade400,
            size: 18,
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 32),
          suffixIcon: Obx(
            () => controller.searchQuery.value.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.close,
                      size: 18,
                      color: Get.context!.theme.colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () {
                      searchController.clear();
                      controller.searchMosque('');
                    },
                  )
                : const SizedBox(),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildMosqueList(MosqueCharityController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildListShimmer();
      }

      if (controller.filteredMosqueList.isEmpty) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/png/no-data-illustration.png',
                  height: 280,
                ),
                Text(
                  'Masjid tidak ditemukan.',
                  style: pMedium14.copyWith(color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
        );
      }

      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            mainAxisExtent: 240,
          ),
          delegate: SliverChildBuilderDelegate((context, index) {
            final mosque = controller.filteredMosqueList[index];
            final double progressValue = (mosque.percentage / 100).clamp(
              0.0,
              1.0,
            );
            return GestureDetector(
              onTap: () => Get.toNamed(
                Routes.mosqueCharityShow,
                arguments: {'id': mosque.id},
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: context.isDarkMode
                        ? Colors.grey.shade800
                        : Colors.grey.shade200,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: Image.network(
                        mosque.coverImage,
                        height: 110,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 110,
                          color:
                              context.theme.colorScheme.surfaceContainerHighest,
                          child: const Icon(IconlyLight.image),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mosque.name,
                                  style: pSemiBold12.copyWith(
                                    color: context.theme.colorScheme.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      IconlyLight.location,
                                      size: 10,
                                      color: context
                                          .theme
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        mosque.address,
                                        style: pRegular10.copyWith(
                                          color: context
                                              .theme
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: progressValue,
                                    minHeight: 5,
                                    backgroundColor: context.isDarkMode
                                        ? Colors.grey.shade900
                                        : Colors.grey.shade100,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          AppColor.primaryColorDark,
                                        ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Terkumpul', style: pRegular10),
                                    Text(
                                      mosque.collectedAmount,
                                      style: pSemiBold10.copyWith(
                                        color:
                                            context.theme.colorScheme.onSurface,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }, childCount: controller.filteredMosqueList.length),
        ),
      );
    });
  }

  Widget _buildListShimmer() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          mainAxisExtent: 275,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => Shimmer.fromColors(
            baseColor: context.isDarkMode
                ? Colors.grey.shade900
                : Colors.grey.shade200,
            highlightColor: context.isDarkMode
                ? Colors.grey.shade800
                : Colors.grey.shade100,
            child: Container(
              decoration: BoxDecoration(
                color: context.theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          childCount: 4,
        ),
      ),
    );
  }
}
