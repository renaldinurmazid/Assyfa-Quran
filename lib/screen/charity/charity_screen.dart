import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:shimmer/shimmer.dart';
import 'package:quran_app/controller/charity/charity_screen_controller.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';

class CharityScreen extends StatelessWidget {
  const CharityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CharityScreenController());
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchCharityList(),
        color: AppColor.primaryColor,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Column(
                  children: [
                    _buildSearchBar(),
                    const SizedBox(height: 32),
                    _buildSectionHeader('Infaq Pilihan', () {}),
                    const SizedBox(height: 16),
                    _buildFeaturedSection(controller),
                    const SizedBox(height: 32),
                    _buildSectionHeader('Infaq Lainnya', () {}),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            _buildOtherCharitySection(controller),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      stretch: true,
      backgroundColor: AppColor.primaryColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(IconlyLight.arrow_left_2, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          'Infaq & Sedekah',
          style: pBold18.copyWith(color: Colors.white),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Using a placeholder or existing image for background
            Image.asset(
              'assets/images/png/bg-palestine.png', // Reusing this for theme consistency
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    AppColor.primaryColor.withOpacity(0.8),
                    AppColor.primaryColor,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Cari program kebaikan...',
          hintStyle: pRegular14.copyWith(color: Colors.grey),
          prefixIcon: const Icon(
            IconlyLight.search,
            color: AppColor.primaryColor,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: pBold18.copyWith(color: Colors.black87)),
        TextButton(
          onPressed: onTap,
          child: Text(
            'Lihat Semua',
            style: pSemiBold14.copyWith(color: AppColor.primaryColor),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedSection(CharityScreenController controller) {
    return SizedBox(
      height: 280,
      child: Obx(() {
        if (controller.isLoading.value) {
          return _buildFeaturedShimmer();
        }
        return ListView.separated(
          itemCount: controller.charityList.length,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final charity = controller.charityList[index];
            return Container(
              width: 260,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                            image: DecorationImage(
                              image: NetworkImage(charity.coverImage),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  IconlyBold.star,
                                  color: Colors.orange,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Pilihan',
                                  style: pBold10.copyWith(
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            charity.title,
                            style: pBold14.copyWith(color: Colors.black87),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          _buildProgressBar(charity.percentage.toDouble()),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Terkumpul',
                                    style: pRegular10.copyWith(
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Text(
                                    charity.collectedAmount,
                                    style: pBold12.copyWith(
                                      color: AppColor.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColor.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${charity.percentage}%',
                                  style: pBold10.copyWith(
                                    color: AppColor.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          separatorBuilder: (context, index) => const SizedBox(width: 16),
        );
      }),
    );
  }

  Widget _buildOtherCharitySection(CharityScreenController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildListShimmer();
      }
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final charity = controller.charityList[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Row(
                children: [
                  Container(
                    height: 85,
                    width: 85,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: NetworkImage(charity.coverImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          charity.title,
                          style: pSemiBold12.copyWith(color: Colors.black87),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        _buildProgressBar(
                          charity.percentage.toDouble(),
                          height: 4,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              charity.collectedAmount,
                              style: pBold12.copyWith(
                                color: AppColor.primaryColor,
                              ),
                            ),
                            Text(
                              charity.endDate ?? '-',
                              style: pMedium10.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }, childCount: controller.charityList.length),
        ),
      );
    });
  }

  Widget _buildProgressBar(double percentage, {double height = 6}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: percentage / 100,
        minHeight: height,
        backgroundColor: Colors.grey.shade100,
        valueColor: const AlwaysStoppedAnimation<Color>(AppColor.primaryColor),
      ),
    );
  }

  Widget _buildFeaturedShimmer() {
    return ListView.builder(
      itemCount: 3,
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          width: 260,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }

  Widget _buildListShimmer() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 110,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          childCount: 5,
        ),
      ),
    );
  }
}
