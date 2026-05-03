import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:shimmer/shimmer.dart';
import 'package:quran_app/controller/mosque_charity_controller.dart';
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
        title: Text('Infaq Masjid', style: pSemiBold16),
        centerTitle: true,
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
        color: AppColor.primaryColorDark,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchBar(controller, searchController),
                    const SizedBox(height: 24),
                    Text("Daftar Masjid Pilihan", style: pSemiBold14),
                  ],
                ),
              ),
            ),
            _buildMosqueList(controller),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
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
        color: Get.context!.isDarkMode
            ? Colors.grey.shade900
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(100),
      ),
      child: TextField(
        controller: searchController,
        onChanged: (value) => controller.searchMosque(value),
        style: pRegular14,
        decoration: InputDecoration(
          hintText: 'Cari nama masjid atau lokasi...',
          hintStyle: pRegular14.copyWith(color: Colors.grey),
          prefixIcon: const Icon(
            IconlyLight.search,
            color: Colors.grey,
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
                Icon(IconlyLight.search, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(
                  'Masjid tidak ditemukan',
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
            mainAxisExtent: 262,
          ),
          delegate: SliverChildBuilderDelegate((context, index) {
            final mosque = controller.filteredMosqueList[index];
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
                        : Colors.grey.shade100,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
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
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 120,
                          color: context.theme.colorScheme.surfaceVariant,
                          child: const Icon(IconlyLight.image),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
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
                          SizedBox(
                            height: 30,
                            child: Text(
                              mosque.address,
                              style: pRegular10.copyWith(
                                color: context.theme.colorScheme.onSurface,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: mosque.percentage / 100,
                              minHeight: 6,
                              backgroundColor: context.isDarkMode
                                  ? Colors.grey.shade900
                                  : Colors.grey.shade100,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColor.primaryColorDark,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Terkumpul', style: pRegular10),
                              Text(mosque.collectedAmount, style: pSemiBold12),
                            ],
                          ),
                        ],
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
          mainAxisExtent: 280,
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
