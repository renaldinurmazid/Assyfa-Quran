import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:shimmer/shimmer.dart';
import 'package:quran_app/controller/charity/charity_screen_controller.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/theme/font.dart';

class CharityScreen extends StatelessWidget {
  const CharityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CharityScreenController());
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: () => controller.fetchCharityList(),
        color: context.theme.colorScheme.primary,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(context),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Column(
                  children: [
                    _buildSearchBar(context),
                    const SizedBox(height: 32),
                    _buildSectionHeader(context, 'Infaq Pilihan', () {}),
                    const SizedBox(height: 16),
                    _buildFeaturedSection(context, controller),
                    const SizedBox(height: 32),
                    _buildSectionHeader(context, 'Infaq Lainnya', () {}),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            _buildOtherCharitySection(context, controller),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      stretch: true,
      backgroundColor: context.theme.colorScheme.primary,
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
                    context.theme.colorScheme.primary.withOpacity(0.8),
                    context.theme.colorScheme.primary,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TextField(
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            Get.toNamed(Routes.charitySearch, arguments: value);
          }
        },
        decoration: InputDecoration(
          hintText: 'Cari program kebaikan...',
          hintStyle: pRegular14.copyWith(
            color: context.theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
          ),
          prefixIcon: Icon(
            IconlyLight.search,
            color: context.theme.colorScheme.primary,
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

  Widget _buildSectionHeader(BuildContext context, String title, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: pSemiBold18.copyWith(
            color: context.theme.colorScheme.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedSection(
    BuildContext context,
    CharityScreenController controller,
  ) {
    return SizedBox(
      height: 280,
      child: Obx(() {
        if (controller.isLoading.value) {
          return _buildFeaturedShimmer(context);
        }
        return ListView.separated(
          itemCount: controller.charityList.length,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final charity = controller.charityList[index];
            return GestureDetector(
              onTap: () => Get.toNamed(
                Routes.charityShow,
                arguments: {'id': charity.id},
              ),
              child: Container(
                width: 260,
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: context.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
                  ),
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
                            height: 160,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(24),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(24),
                              ),
                              child: Image.network(
                                charity.coverImage,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: context.theme.colorScheme.surfaceContainerHighest,
                                    child: Icon(
                                      IconlyLight.image,
                                      color: context.theme.colorScheme.onSurfaceVariant,
                                    ),
                                  );
                                },
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
                                color: context.theme.colorScheme.surface.withOpacity(0.9),
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
                                      color: context.theme.colorScheme.onSurface,
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
                              style: pBold14.copyWith(
                                color: context.theme.colorScheme.onSurface,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            _buildProgressBar(
                              context,
                              charity.percentage.toDouble(),
                            ),
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
                                        color: context.theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    Text(
                                      charity.collectedAmount,
                                      style: pBold12.copyWith(
                                        color: context.theme.colorScheme.primary,
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
                                    color: context.theme.colorScheme.primary.withOpacity(
                                      0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${charity.percentage}%',
                                    style: pBold10.copyWith(
                                      color: context.theme.colorScheme.primary,
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
              ),
            );
          },
          separatorBuilder: (context, index) => const SizedBox(width: 16),
        );
      }),
    );
  }

  Widget _buildOtherCharitySection(
    BuildContext context,
    CharityScreenController controller,
  ) {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildListShimmer(context);
      }
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final charity = controller.charityList[index];
            return GestureDetector(
              onTap: () => Get.toNamed(
                Routes.charityShow,
                arguments: {'id': charity.id},
              ),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: context.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 85,
                      width: 85,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          charity.coverImage,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: context.theme.colorScheme.surfaceContainerHighest,
                              child: Icon(
                                IconlyLight.image,
                                color: context.theme.colorScheme.onSurfaceVariant,
                                size: 20,
                              ),
                            );
                          },
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
                            style: pSemiBold12.copyWith(
                              color: context.theme.colorScheme.onSurface,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          _buildProgressBar(
                            context,
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
                                  color: context.theme.colorScheme.primary,
                                ),
                              ),
                              Text(
                                charity.endDate ?? '-',
                                style: pMedium10.copyWith(
                                  color: context.theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
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
            );
          }, childCount: controller.charityList.length),
        ),
      );
    });
  }

  Widget _buildProgressBar(
    BuildContext context,
    double percentage, {
    double height = 6,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: percentage / 100,
        minHeight: height,
        backgroundColor: context.theme.colorScheme.surfaceContainerHighest,
        valueColor: AlwaysStoppedAnimation<Color>(
          context.theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildFeaturedShimmer(BuildContext context) {
    return ListView.builder(
      itemCount: 3,
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: context.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200,
        highlightColor: context.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
        child: Container(
          width: 260,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }

  Widget _buildListShimmer(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => Shimmer.fromColors(
            baseColor: context.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200,
            highlightColor: context.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
            child: Container(
              height: 110,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: context.theme.colorScheme.surface,
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
