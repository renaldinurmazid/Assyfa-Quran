import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:quran_app/controller/charity/charity_show_controller.dart';
import 'package:quran_app/models/campaign_detail_model.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/theme/font.dart';
import 'package:url_launcher/url_launcher.dart';

class CharityShowScreen extends StatelessWidget {
  const CharityShowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CharityShowController());

    return Scaffold(
      backgroundColor: context.isDarkMode
          ? Colors.grey.shade900
          : Colors.grey.shade50,
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
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTitleSection(context, campaign),
                            const SizedBox(height: 20),
                            _buildProgressSection(context, campaign),
                            const SizedBox(height: 24),
                            _buildHorizontalStats(context, campaign),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildStorySection(context, campaign),
                      const SizedBox(height: 100), // Space for bottom button
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
      leading: IconButton(
        icon: const Icon(IconlyLight.arrow_left, color: Colors.white),
        onPressed: () => Get.back(),
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
                  colors: [Colors.black.withOpacity(0.3), Colors.transparent],
                ),
              ),
            ),
            // Floating title in sample image? No, it's just the image.
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection(BuildContext context, CampaignData campaign) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          campaign.title,
          style: pBold18.copyWith(
            color: context.theme.colorScheme.onSurface,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          campaign.collectedAmount,
          style: pBold18.copyWith(
            color: context.isDarkMode
                ? AppColor.primaryColorDark
                : AppColor.primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Terkumpul dari ${campaign.targetAmount}',
              style: pRegular12.copyWith(color: Colors.grey.shade600),
            ),
            _buildRemainingDays(campaign),
          ],
        ),
      ],
    );
  }

  Widget _buildRemainingDays(CampaignData campaign) {
    if (campaign.endDate == 'Infinity') {
      return const Icon(Icons.all_inclusive, size: 16, color: Colors.grey);
    }
    return Text(
      '${campaign.endDate}',
      style: pRegular12.copyWith(color: Colors.grey.shade600),
    );
  }

  Widget _buildProgressSection(BuildContext context, CampaignData campaign) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: campaign.percentage / 100,
            minHeight: 10,
            backgroundColor: Colors.grey.shade100,
            valueColor: AlwaysStoppedAnimation<Color>(
              context.isDarkMode
                  ? AppColor.primaryColorDark
                  : AppColor.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalStats(BuildContext context, CampaignData campaign) {
    return Row(
      children: [
        _buildStatItem(
          Icons.favorite,
          '${campaign.donaturCount}',
          'Donasi',
          context.isDarkMode
              ? AppColor.primaryColorDark
              : AppColor.primaryColor,
          onTap: () => Get.toNamed(
            Routes.charityCampaignTabs,
            arguments: {'campaignId': campaign.id, 'initialTab': 0},
          ),
        ),
        _buildVerticalDivider(),
        _buildStatItem(
          Icons.description,
          '',
          'Kabar Terbaru',
          context.isDarkMode
              ? AppColor.primaryColorDark
              : AppColor.primaryColor,
          showValue: false,
          onTap: () => Get.toNamed(
            Routes.charityCampaignTabs,
            arguments: {'campaignId': campaign.id, 'initialTab': 1},
          ),
        ),
        _buildVerticalDivider(),
        _buildStatItem(
          Icons.account_balance_wallet,
          '',
          'Fundraiser',
          context.isDarkMode
              ? AppColor.primaryColorDark
              : AppColor.primaryColor,
          showValue: false,
          onTap: () => Get.toNamed(
            Routes.charityCampaignTabs,
            arguments: {'campaignId': campaign.id, 'initialTab': 2},
          ),
        ),
      ],
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
                  const SizedBox(width: 8),
                  Text(value, style: pBold14),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: pRegular12.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorySection(BuildContext context, CampaignData campaign) {
    return Container(
      color: context.theme.colorScheme.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Deskripsi Program", style: pSemiBold14),
          const SizedBox(height: 8),
          HtmlWidget(
            campaign.description
                .replaceAll('&nbsp;', ' ')
                .replaceAll('\u00A0', ' ')
                .replaceAll('word-break: break-all', 'word-break: normal')
                .replaceAll('word-break: break-word', 'word-break: normal'),
            textStyle: pRegular12.copyWith(height: 1.6),
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
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: BoxDecoration(
          color: context.theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(context.isDarkMode ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
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
                icon: const Icon(Icons.share, size: 18),
                label: const Text("Bagikan"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.isDarkMode
                      ? AppColor.primaryColorDark
                      : AppColor.primaryColor,
                  side: BorderSide(
                    color: context.isDarkMode
                        ? AppColor.primaryColorDark
                        : AppColor.primaryColor,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () {
                  // Get.toNamed(
                  //   Routes.charityPayment,
                  //   arguments: {
                  //     'id': campaign.id,
                  //     'formType': campaign.formType,
                  //     'qurbanPrice': campaign.qurbanPrice,
                  //     'campaignOptions': campaign.campaignOptions,
                  //     'withOption': campaign.withOption,
                  //   },
                  // );
                  launchUrl(
                    Uri.parse('https://aksipeduli.id'),
                    mode: LaunchMode.externalApplication,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.isDarkMode
                      ? AppColor.primaryColorDark
                      : AppColor.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
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
