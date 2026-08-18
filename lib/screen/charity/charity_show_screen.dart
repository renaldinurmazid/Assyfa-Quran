import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:quran_app/screen/charity/charity_show_controller.dart';
import 'package:quran_app/models/campaign_detail_model.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/theme/font.dart';

class CharityShowScreen extends StatelessWidget {
  const CharityShowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CharityShowController());

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState(context);
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
                _buildSliverAppBar(context, campaign),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Container(
                        color: context.theme.colorScheme.surface,
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTitleSection(context, campaign),
                            const SizedBox(height: 16),
                            _buildPriceContainer(context, campaign),
                            const SizedBox(height: 16),
                            _buildProgressSection(context, campaign),
                            const SizedBox(height: 16),
                            _buildHorizontalStats(context, campaign),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildStorySection(context, campaign),
                      const SizedBox(
                        height: 120,
                      ), // Space for bottom action bar
                    ],
                  ),
                ),
              ],
            ),
            _buildStickyBottomButtons(context, campaign),
          ],
        );
      }),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, CampaignData campaign) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      elevation: 0,
      backgroundColor: context.theme.colorScheme.surface,
      leading: Container(
        margin: const EdgeInsets.all(8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 16,
                ),
                onPressed: () => Get.back(),
              ),
            ),
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
                    Colors.black.withOpacity(0.35),
                    Colors.transparent,
                    Colors.black.withOpacity(0.25),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection(BuildContext context, CampaignData campaign) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFD4AF37), Color(0xFFC5A880)],
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'INFAQ PILIHAN',
            style: pBold10.copyWith(color: Colors.white),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          campaign.title,
          style: pBold18.copyWith(
            color: context.theme.colorScheme.onSurface,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceContainer(BuildContext context, CampaignData campaign) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: context.isDarkMode
              ? [Colors.grey.shade900, const Color(0xFF0F0F0F)]
              : [const Color(0xFFF9F6F0), const Color(0xFFF0EAE1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.isDarkMode
              ? Colors.grey.shade800
              : const Color(0xFFE5DCD0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dana Terkumpul',
                  style: pMedium12.copyWith(
                    color: context.isDarkMode
                        ? Colors.grey[400]
                        : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  campaign.collectedAmount,
                  style: pBold20.copyWith(color: AppColor.primaryColorDark),
                ),
                const SizedBox(height: 4),
                Text(
                  'dari target ${campaign.targetAmount}',
                  style: pRegular10.copyWith(
                    color: context.isDarkMode
                        ? Colors.grey[500]
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColor.primaryColorDark.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  IconlyLight.calendar,
                  color: AppColor.primaryColorDark,
                  size: 14,
                ),
                const SizedBox(width: 4),
                _buildRemainingDays(campaign),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemainingDays(CampaignData campaign) {
    if (campaign.endDate == 'Infinity') {
      return Text(
        'Tak Terbatas',
        style: pBold10.copyWith(color: AppColor.primaryColorDark),
      );
    }
    return Text(
      '${campaign.endDate}',
      style: pBold10.copyWith(color: AppColor.primaryColorDark),
    );
  }

  Widget _buildProgressSection(BuildContext context, CampaignData campaign) {
    final double progress = (campaign.percentage / 100).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Persentase Terkumpul',
              style: pMedium12.copyWith(color: Colors.grey.shade600),
            ),
            Text(
              '${campaign.percentage}%',
              style: pBold12.copyWith(color: AppColor.primaryColorDark),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: context.isDarkMode
                ? Colors.grey.shade900
                : Colors.grey.shade100,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColor.primaryColorDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalStats(BuildContext context, CampaignData campaign) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: context.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.isDarkMode
              ? Colors.grey.shade800
              : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          _buildStatItem(
            IconlyLight.heart,
            '${campaign.donaturCount}',
            'Donatur',
            AppColor.primaryColorDark,
            onTap: () => Get.toNamed(
              Routes.charityCampaignTabs,
              arguments: {'campaignId': campaign.id, 'initialTab': 0},
            ),
          ),
          _buildVerticalDivider(),
          _buildStatItem(
            IconlyLight.document,
            '',
            'Kabar Terbaru',
            AppColor.primaryColorDark,
            showValue: false,
            onTap: () => Get.toNamed(
              Routes.charityCampaignTabs,
              arguments: {'campaignId': campaign.id, 'initialTab': 1},
            ),
          ),
          _buildVerticalDivider(),
          _buildStatItem(
            IconlyLight.wallet,
            '',
            'Fundraiser',
            AppColor.primaryColorDark,
            showValue: false,
            onTap: () => Get.toNamed(
              Routes.charityCampaignTabs,
              arguments: {'campaignId': campaign.id, 'initialTab': 2},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Get.context!.isDarkMode
          ? Colors.grey.shade800
          : Colors.grey.shade200,
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String value,
    String label,
    Color color, {
    bool showValue = true,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: color),
                if (showValue) ...[
                  const SizedBox(width: 6),
                  Text(value, style: pBold14),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: pMedium10.copyWith(
                color: Get.context!.isDarkMode
                    ? Colors.grey[400]
                    : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorySection(BuildContext context, CampaignData campaign) {
    return Container(
      color: context.theme.colorScheme.surface,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColor.primaryColorDark,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text("Deskripsi Program", style: pBold14),
            ],
          ),
          const SizedBox(height: 16),
          HtmlWidget(
            campaign.description
                .replaceAll('&nbsp;', ' ')
                .replaceAll('\u00A0', ' ')
                .replaceAll('word-break: break-all', 'word-break: normal')
                .replaceAll('word-break: break-word', 'word-break: normal'),
            textStyle: pRegular14.copyWith(
              height: 1.6,
              color: context.theme.colorScheme.onSurface.withOpacity(0.85),
            ),
            customStylesBuilder: (element) {
              return {'word-break': 'normal'};
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStickyBottomButtons(
    BuildContext context,
    CampaignData campaign,
  ) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            decoration: BoxDecoration(
              color: context.theme.colorScheme.surface.withOpacity(0.85),
              border: Border(
                top: BorderSide(
                  color: context.isDarkMode
                      ? Colors.grey.shade900
                      : Colors.grey.shade200,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      final shareUrl =
                          campaign.shareUrl ??
                          '${Url.baseUrl}/api/c/${campaign.id}';
                      Share.share(
                        'Yuk bantu kampanye "${campaign.title}" di Quranuna! Klik link berikut: $shareUrl',
                      );
                    },
                    icon: Icon(
                      IconlyLight.send,
                      size: 18,
                      color: AppColor.primaryColorDark,
                    ),
                    label: Text(
                      "Bagikan",
                      style: pBold12.copyWith(color: AppColor.primaryColorDark),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColor.primaryColorDark,
                      side: const BorderSide(
                        color: AppColor.primaryColorDark,
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      // if (Platform.isIOS) {
                      //   launchUrl(
                      //     Uri.parse('https://aksipeduli.id'),
                      //     mode: LaunchMode.externalApplication,
                      //   );
                      //   return;
                      // }
                      Get.toNamed(
                        Routes.charityPayment,
                        arguments: {
                          'id': campaign.id,
                          'formType': campaign.formType,
                          'qurbanPrice': campaign.qurbanPrice,
                          'campaignOptions': campaign.campaignOptions,
                          'withOption': campaign.withOption,
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryColorDark,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Infaq Sekarang',
                      style: pSemiBold14.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.isDarkMode
          ? Colors.grey.shade900
          : Colors.grey.shade200,
      highlightColor: context.isDarkMode
          ? Colors.grey.shade800
          : Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 250, color: Colors.white),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 20,
                  width: double.infinity,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                Container(height: 20, width: 150, color: Colors.white),
                const SizedBox(height: 24),
                Container(
                  height: 100,
                  width: double.infinity,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
