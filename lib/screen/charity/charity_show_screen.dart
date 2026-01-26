import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:shimmer/shimmer.dart';
import 'package:quran_app/controller/charity/charity_show_controller.dart';
import 'package:quran_app/routes/app_routes.dart';
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
                        _buildDonaturSection(campaign),
                        const Divider(
                          height: 48,
                          thickness: 1,
                          color: Color(0xFFF1F1F1),
                        ),
                        _buildDescriptionSection(campaign),
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
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(campaign.coverImage, fit: BoxFit.cover),
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColor.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Kemanusiaan',
            style: pSemiBold12.copyWith(color: AppColor.primaryColor),
          ),
        ),
        const SizedBox(height: 12),
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

  Widget _buildDonaturSection(campaign) {
    return Row(
      children: [
        const Icon(IconlyLight.user_1, color: AppColor.primaryColor, size: 20),
        const SizedBox(width: 12),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '${campaign.donaturCount} ',
                style: pBold14.copyWith(color: AppColor.textColor),
              ),
              TextSpan(
                text: 'Donatur telah bergabung',
                style: pRegular14.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(campaign) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cerita Kebaikan',
          style: pBold16.copyWith(color: AppColor.textColor),
        ),
        const SizedBox(height: 12),
        HtmlWidget(campaign.description, textStyle: pRegular12),
      ],
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
            style: pBold16.copyWith(color: Colors.white),
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
