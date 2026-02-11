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
      backgroundColor: const Color(0xFFFBFBFE),
      body: RefreshIndicator(
        onRefresh: () async {
          searchController.clear();
          controller.searchQuery.value = '';
          await controller.fetchMosqueCharityList();
        },
        color: AppColor.primaryColor,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Temukan Masjid',
                      style: pBold24.copyWith(color: const Color(0xFF1A1A1A)),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Salurkan bantuan untuk kemakmuran rumah Allah',
                      style: pRegular14.copyWith(color: Colors.black45),
                    ),
                    const SizedBox(height: 24),
                    _buildSearchBar(controller, searchController),
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
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      pinned: true,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton(
          icon: const Icon(
            IconlyLight.arrow_left_2,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            IconlyBroken.location,
            color: AppColor.primaryColor,
            size: 20,
          ),
          onPressed: () => Get.toNamed(Routes.mosqueMap),
        ),
      ],

      centerTitle: true,
      title: Text(
        'Infaq Masjid',
        style: pBold16.copyWith(color: Colors.black87),
      ),
    );
  }

  Widget _buildSearchBar(
    MosqueCharityController controller,
    TextEditingController searchController,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryColor.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        onChanged: (value) => controller.searchMosque(value),
        decoration: InputDecoration(
          hintText: 'Cari nama masjid atau lokasi...',
          hintStyle: pRegular14.copyWith(color: Colors.black26),
          prefixIcon: const Icon(
            IconlyLight.search,
            color: AppColor.primaryColor,
            size: 20,
          ),
          suffixIcon: Obx(
            () => controller.searchQuery.value.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.close,
                      size: 18,
                      color: Colors.black26,
                    ),
                    onPressed: () {
                      searchController.clear();
                      controller.searchMosque('');
                    },
                  )
                : const SizedBox(),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
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
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    IconlyLight.search,
                    size: 48,
                    color: AppColor.primaryColor.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Masjid tidak ditemukan',
                  style: pBold16.copyWith(color: Colors.black87),
                ),
                const SizedBox(height: 6),
                Text(
                  'Coba cari dengan kata kunci lain',
                  style: pRegular14.copyWith(color: Colors.black45),
                ),
              ],
            ),
          ),
        );
      }

      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            mainAxisExtent: 256,
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                          child: Hero(
                            tag: 'mosque_${mosque.id}',
                            child: Image.network(
                              mosque.coverImage,
                              height: 100,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 100,
                                  color: const Color(0xFFF5F5F7),
                                  child: const Icon(
                                    IconlyLight.image,
                                    color: Colors.black12,
                                    size: 30,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  IconlyBold.location,
                                  color: Colors.redAccent,
                                  size: 10,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  mosque.city,
                                  style: pBold10.copyWith(
                                    color: Colors.black87,
                                    fontSize: 8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 36,
                              child: Text(
                                mosque.name,
                                style: pBold14.copyWith(
                                  color: const Color(0xFF1A1A1A),
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(
                                  IconlyLight.location,
                                  size: 12,
                                  color: Colors.black26,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    mosque.address,
                                    style: pMedium10.copyWith(
                                      color: Colors.black38,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9FE),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Terkumpul',
                                    style: pMedium10.copyWith(
                                      color: Colors.black38,
                                      fontSize: 8,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Rp ${mosque.currentAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                    style: pBold12.copyWith(
                                      color: AppColor.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          mainAxisExtent: 280,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => Shimmer.fromColors(
            baseColor: Colors.grey[200]!,
            highlightColor: Colors.grey[50]!,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          childCount: 4,
        ),
      ),
    );
  }
}
