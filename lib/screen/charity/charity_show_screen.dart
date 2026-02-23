import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:quran_app/controller/charity/charity_show_controller.dart';
import 'package:quran_app/models/campaign_detail_model.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';

class CharityShowScreen extends StatelessWidget {
  const CharityShowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CharityShowController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState();
        }

        final campaign = controller.campaign.value;
        if (campaign == null) {
          return const Center(child: Text('Campaign not found'));
        }

        return Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverAppBar(campaign),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTitleSection(campaign),
                        const SizedBox(height: 24),
                        _buildProgressSection(campaign),
                        const SizedBox(height: 24),
                        _buildStatsSection(campaign),
                        const Divider(
                          height: 48,
                          thickness: 1,
                          color: Color(0xFFF1F1F1),
                        ),
                        _buildTabSection(controller),
                        const SizedBox(height: 24),
                        Obx(() {
                          final tab = controller.selectedTab.value;
                          if (tab == 0)
                            return _buildDescriptionSection(campaign);
                          if (tab == 1) return _buildUpdatesSection(campaign);
                          return _buildFundraiserSection(campaign);
                        }),
                        const SizedBox(height: 100), // Space for bottom button
                      ],
                    ),
                  ),
                ),
              ],
            ),
            _buildStickyBottomButton(campaign),
          ],
        );
      }),
    );
  }

  Widget _buildSliverAppBar(campaign) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColor.primaryColor,
      leadingWidth: 70,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.black.withOpacity(0.3),
          child: IconButton(
            icon: const Icon(
              IconlyLight.arrow_left_2,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => Get.back(),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.black.withOpacity(0.3),
            child: IconButton(
              icon: const Icon(Icons.share, color: Colors.white, size: 20),
              onPressed: () {
                final shareUrl =
                    campaign.shareUrl ?? '${Url.baseUrl}/api/c/${campaign.id}';
                Share.share(
                  'Yuk bantu kampanye "${campaign.title}" di Assyfa Quran! Klik link berikut: $shareUrl',
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              campaign.coverImage,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[100],
                  child: const Center(
                    child: Icon(
                      IconlyLight.image,
                      color: Colors.grey,
                      size: 40,
                    ),
                  ),
                );
              },
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                    Colors.black.withOpacity(0.1),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection(campaign) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          campaign.title,
          style: pBold20.copyWith(color: AppColor.textColor, height: 1.4),
        ),
      ],
    );
  }

  Widget _buildProgressSection(campaign) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Terkumpul',
                style: pMedium12.copyWith(color: Colors.grey[600]),
              ),
              Text(
                campaign.endDate ?? '',
                style: pMedium12.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                campaign.collectedAmount,
                style: pBold18.copyWith(color: AppColor.primaryColor),
              ),
              const SizedBox(width: 8),
              Text(
                'dari ${campaign.targetAmount}',
                style: pRegular12.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: campaign.percentage / 100,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColor.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${campaign.percentage}% Terpenuhi',
                style: pSemiBold12.copyWith(color: AppColor.primaryColor),
              ),
              Text(
                'Target: ${campaign.targetAmount}',
                style: pMedium10.copyWith(color: Colors.grey[500]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(CampaignData campaign) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              Get.toNamed(Routes.charityDonatur, arguments: campaign.id);
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColor.primaryColor.withOpacity(0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColor.primaryColor.withOpacity(0.12),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      IconlyBold.heart,
                      color: AppColor.primaryColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${campaign.donaturCount}',
                          style: pBold16.copyWith(color: AppColor.primaryColor),
                        ),
                        Text(
                          'Donatur',
                          style: pRegular10.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    IconlyLight.arrow_right_2,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: () {
              // Switch to fundraiser tab
              final controller = Get.find<CharityShowController>();
              controller.selectedTab.value = 2;
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0).withOpacity(0.6),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.orange.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      IconlyBold.star,
                      color: Colors.orange,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${campaign.fundraiserCount}',
                          style: pBold16.copyWith(color: Colors.orange[800]),
                        ),
                        Text(
                          'Fundraiser',
                          style: pRegular10.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    IconlyLight.arrow_right_2,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabSection(CharityShowController controller) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F1F1), width: 1)),
      ),
      child: Row(
        children: [
          _buildTabItem(label: 'Deskripsi', index: 0, controller: controller),
          _buildTabItem(
            label: 'Update',
            index: 1,
            controller: controller,
            showBadge: true,
          ),
          _buildTabItem(label: 'Fundraiser', index: 2, controller: controller),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required String label,
    required int index,
    required CharityShowController controller,
    bool showBadge = false,
  }) {
    return Obx(() {
      final isSelected = controller.selectedTab.value == index;
      return Expanded(
        child: GestureDetector(
          onTap: () => controller.selectedTab.value = index,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isSelected
                      ? AppColor.primaryColor
                      : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: isSelected
                      ? pBold14.copyWith(color: AppColor.primaryColor)
                      : pMedium14.copyWith(color: Colors.grey[500]),
                ),
                if (showBadge &&
                    controller.campaign.value!.updates.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColor.primaryColor
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${controller.campaign.value!.updates.length}',
                      style: pBold10.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildDescriptionSection(campaign) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HtmlWidget(
          campaign.description,
          textStyle: pRegular14.copyWith(
            height: 1.6,
            color: AppColor.textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildUpdatesSection(CampaignData campaign) {
    if (campaign.updates.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              Icon(IconlyLight.info_square, size: 48, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'Belum ada update kampanye',
                style: pMedium14.copyWith(color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: campaign.updates.length,
      separatorBuilder: (context, index) => const SizedBox(height: 24),
      itemBuilder: (context, index) {
        final update = campaign.updates[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: AppColor.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  update.createdAtFormatted,
                  style: pBold12.copyWith(color: AppColor.primaryColor),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    update.title,
                    style: pBold14.copyWith(color: AppColor.textColor),
                  ),
                  const SizedBox(height: 12),
                  HtmlWidget(
                    update.content,
                    textStyle: pRegular12.copyWith(
                      height: 1.5,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFundraiserSection(CampaignData campaign) {
    if (campaign.fundraisers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              Icon(IconlyLight.star, size: 48, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'Belum ada fundraiser',
                style: pMedium14.copyWith(color: Colors.grey[500]),
              ),
              const SizedBox(height: 8),
              Text(
                'Bagikan campaign ini dan jadilah\nfundraiser pertama!',
                textAlign: TextAlign.center,
                style: pRegular12.copyWith(
                  color: Colors.grey[400],
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: campaign.fundraisers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final fundraiser = campaign.fundraisers[index];
        final rank = index + 1;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: rank <= 3
                ? const Color(0xFFFFF8E1).withOpacity(0.5)
                : const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: rank <= 3
                  ? Colors.orange.withOpacity(0.15)
                  : const Color(0xFFEEEEEE),
            ),
          ),
          child: Row(
            children: [
              // Rank badge
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: rank == 1
                      ? Colors.amber
                      : rank == 2
                      ? Colors.grey[400]
                      : rank == 3
                      ? Colors.orange[300]
                      : Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$rank',
                  style: pBold12.copyWith(
                    color: rank <= 3 ? Colors.white : Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Avatar
              _buildFundraiserAvatar(fundraiser.name),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fundraiser.name,
                      style: pSemiBold14.copyWith(color: AppColor.textColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          IconlyLight.user_1,
                          size: 13,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${fundraiser.totalReferral} orang diajak',
                          style: pRegular10.copyWith(
                            color: Colors.grey[500],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Amount collected
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  fundraiser.totalCollected,
                  style: pSemiBold10.copyWith(color: Colors.orange[800]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFundraiserAvatar(String name) {
    final initials = name.isNotEmpty
        ? name
              .split(' ')
              .take(2)
              .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
              .join()
        : '?';

    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withOpacity(0.7),
            Colors.deepOrange.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(initials, style: pBold12.copyWith(color: Colors.white)),
    );
  }

  Widget _buildStickyBottomButton(campaign) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            Get.toNamed(Routes.charityPayment, arguments: {'id': campaign.id});
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Text(
            'Infaq Sekarang',
            style: pSemiBold16.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 300, color: Colors.white),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 20, width: 100, color: Colors.white),
                const SizedBox(height: 12),
                Container(
                  height: 30,
                  width: double.infinity,
                  color: Colors.white,
                ),
                const SizedBox(height: 24),
                Container(
                  height: 150,
                  width: double.infinity,
                  color: Colors.white,
                ),
                const SizedBox(height: 24),
                Container(height: 20, width: 200, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
