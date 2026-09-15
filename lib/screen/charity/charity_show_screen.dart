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

// ─── Color tokens (same as CharityPaymentDetailScreen) ───────────────────────
const _kBgDark = Color(0xFF0F0F10);
const _kBgLight = Color(0xFFF8FAFC);
const _kSurfaceDark = Color(0xFF18181B);
const _kSurfaceLight = Colors.white;
const _kBorderDark = Color(0xFF27272A);
const _kBorderLight = Color(0xFFE2E8F0);

class CharityShowScreen extends StatelessWidget {
  const CharityShowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (Get.isRegistered<CharityShowController>()) {
      Get.delete<CharityShowController>();
    }
    final controller = Get.put(CharityShowController());

    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? _kBgDark : _kBgLight,
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState(context);
        }

        final campaign = controller.campaign.value;
        if (campaign == null) {
          return SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: _buildCircleBackButton(context),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Data infaq tidak ditemukan',
                      style: pRegular14.copyWith(
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
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
                      // Main info card
                      Container(
                        color: isDark ? _kSurfaceDark : _kSurfaceLight,
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTitleSection(context, campaign),
                            const SizedBox(height: 20),
                            _buildAmountCard(context, campaign),
                            const SizedBox(height: 16),
                            _buildProgressSection(context, campaign),
                            const SizedBox(height: 20),
                            _buildStatsRow(context, campaign),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildStorySection(context, campaign),
                      const SizedBox(height: 120),
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

  // ── Back button (circle) ───────────────────────────────────────────────────

  Widget _buildCircleBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.back(),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: const Icon(
          IconlyLight.arrow_left,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }

  // ── Sliver App Bar ─────────────────────────────────────────────────────────

  Widget _buildSliverAppBar(BuildContext context, CampaignData campaign) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: context.isDarkMode ? _kSurfaceDark : _kSurfaceLight,
      leading: Container(
        margin: const EdgeInsets.all(8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: _buildCircleBackButton(context),
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: GestureDetector(
                onTap: () {
                  final shareUrl =
                      campaign.shareUrl ??
                      '${Url.baseUrl}/api/c/${campaign.id}';
                  SharePlus.instance.share(
                    ShareParams(
                      text:
                          'Yuk bantu kampanye "${campaign.title}" di Quranuna! Klik link berikut: $shareUrl',
                    ),
                  );
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                  child: const Icon(
                    IconlyLight.send,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(campaign.coverImage, fit: BoxFit.cover),
            // Subtle bottom gradient for readability
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.transparent],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Title section ──────────────────────────────────────────────────────────

  Widget _buildTitleSection(BuildContext context, CampaignData campaign) {
    // final isDark = context.isDarkMode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // // Category badge
        // if (campaign.category?.name != null)
        //   Container(
        //     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        //     decoration: BoxDecoration(
        //       color: (AppColor.primaryColor)
        //           .withValues(alpha: 0.1),
        //       borderRadius: BorderRadius.circular(6),
        //       border: Border.all(
        //         color: (isDark
        //                 ? AppColor.primaryColorDark
        //                 : AppColor.primaryColor)
        //             .withValues(alpha: 0.25),
        //       ),
        //     ),
        //     child: Text(
        //       campaign.category!.name.toUpperCase(),
        //       style: pSemiBold10.copyWith(
        //         color: AppColor.primaryColor,
        //         letterSpacing: 0.5,
        //       ),
        //     ),
        //   ),
        // const SizedBox(height: 12),
        Text(
          campaign.title,
          style: pBold18.copyWith(
            color: context.theme.colorScheme.onSurface,
            height: 1.4,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  // ── Amount card ────────────────────────────────────────────────────────────

  Widget _buildAmountCard(BuildContext context, CampaignData campaign) {
    final isDark = context.isDarkMode;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF27272A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? _kBorderDark : _kBorderLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dana Terkumpul',
                  style: pRegular12.copyWith(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  campaign.collectedAmount,
                  style: pBold20.copyWith(
                    color: context.isDarkMode
                        ? AppColor.primaryColorDark
                        : AppColor.primaryColor,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'dari target ${campaign.targetAmount}',
                  style: pRegular10.copyWith(
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? _kBorderDark : _kBorderLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  IconlyLight.calendar,
                  size: 14,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                const SizedBox(width: 5),
                _buildRemainingDays(context, campaign),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemainingDays(BuildContext context, CampaignData campaign) {
    final isDark = context.isDarkMode;
    final label = campaign.endDate == 'Infinity'
        ? 'Tak Terbatas'
        : '${campaign.endDate}';
    return Text(
      label,
      style: pSemiBold10.copyWith(
        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
      ),
    );
  }

  // ── Progress section ───────────────────────────────────────────────────────

  Widget _buildProgressSection(BuildContext context, CampaignData campaign) {
    final isDark = context.isDarkMode;
    final double progress = (campaign.percentage / 100).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Terkumpul',
              style: pRegular12.copyWith(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            Text(
              '${campaign.percentage}%',
              style: pSemiBold12.copyWith(
                color: isDark ? AppColor.primaryColorDark : AppColor.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 5,
            backgroundColor: isDark ? _kBorderDark : _kBorderLight,
            valueColor: AlwaysStoppedAnimation<Color>(
              isDark ? AppColor.primaryColorDark : AppColor.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  // ── Stats row ──────────────────────────────────────────────────────────────

  Widget _buildStatsRow(BuildContext context, CampaignData campaign) {
    final isDark = context.isDarkMode;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF27272A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? _kBorderDark : _kBorderLight),
      ),
      child: Row(
        children: [
          _buildStatItem(
            context,
            icon: IconlyLight.heart,
            value: '${campaign.donaturCount}',
            label: 'Donatur',
            onTap: () => Get.toNamed(
              Routes.charityCampaignTabs,
              arguments: {'campaignId': campaign.id, 'initialTab': 0},
            ),
          ),
          _buildStatDivider(isDark),
          _buildStatItem(
            context,
            icon: IconlyLight.document,
            label: 'Kabar Terbaru',
            onTap: () => Get.toNamed(
              Routes.charityCampaignTabs,
              arguments: {'campaignId': campaign.id, 'initialTab': 1},
            ),
          ),
          _buildStatDivider(isDark),
          _buildStatItem(
            context,
            icon: IconlyLight.wallet,
            label: 'Fundraiser',
            onTap: () => Get.toNamed(
              Routes.charityCampaignTabs,
              arguments: {'campaignId': campaign.id, 'initialTab': 2},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider(bool isDark) {
    return Container(
      height: 36,
      width: 1,
      color: isDark ? _kBorderDark : _kBorderLight,
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    String? value,
    required String label,
    VoidCallback? onTap,
  }) {
    final isDark = context.isDarkMode;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: isDark ? AppColor.primaryColorDark : AppColor.primaryColor,
                  ),
                  if (value != null) ...[
                    const SizedBox(width: 5),
                    Text(
                      value,
                      style: pBold14.copyWith(
                        color: context.theme.colorScheme.onSurface,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: pRegular10.copyWith(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Description section ────────────────────────────────────────────────────

  Widget _buildStorySection(BuildContext context, CampaignData campaign) {
    final isDark = context.isDarkMode;
    return Container(
      color: isDark ? _kSurfaceDark : _kSurfaceLight,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  color: isDark ? AppColor.primaryColorDark : AppColor.primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Deskripsi Program',
                style: pSemiBold14.copyWith(
                  color: context.theme.colorScheme.onSurface,
                  letterSpacing: -0.2,
                ),
              ),
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
              height: 1.7,
              color: context.theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
            customStylesBuilder: (element) => {'word-break': 'normal'},
          ),
        ],
      ),
    );
  }

  // ── Bottom action bar ──────────────────────────────────────────────────────

  Widget _buildStickyBottomButtons(
    BuildContext context,
    CampaignData campaign,
  ) {
    final isDark = context.isDarkMode;
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          MediaQuery.of(context).padding.bottom + 12,
        ),
        decoration: BoxDecoration(
          color: isDark ? _kSurfaceDark : Colors.white,
          border: Border(
            top: BorderSide(color: isDark ? _kBorderDark : _kBorderLight),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
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
                    backgroundColor: isDark ? AppColor.primaryColorDark : AppColor.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Infaq Sekarang',
                    style: pSemiBold14.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Loading shimmer ────────────────────────────────────────────────────────

  Widget _buildLoadingState(BuildContext context) {
    final isDark = context.isDarkMode;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
      highlightColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 260, color: Colors.white),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 12, width: 80, color: Colors.white),
                const SizedBox(height: 12),
                Container(
                  height: 22,
                  width: double.infinity,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Container(height: 22, width: 220, color: Colors.white),
                const SizedBox(height: 24),
                Container(
                  height: 90,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 5,
                  width: double.infinity,
                  color: Colors.white,
                ),
                const SizedBox(height: 20),
                Container(
                  height: 60,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
