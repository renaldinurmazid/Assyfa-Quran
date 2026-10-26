import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/theme/app_color.dart';
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
    if (Get.isRegistered<CharityShowController>()) {
      Get.delete<CharityShowController>();
    }
    final controller = Get.put(CharityShowController());

    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final campaign = controller.campaign.value;
          return Text(
            campaign?.title ?? 'Detail Program',
            style: pSemiBold16,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        }),
        centerTitle: false,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(LucideIcons.arrowLeft),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          final campaign = controller.campaign.value;
          if (campaign == null) {
            return const Center(child: Text('Data infaq tidak ditemukan'));
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildProgramInfo(campaign),
                const SizedBox(height: 16),
                _buildProgramDesc(campaign),
                const SizedBox(height: 32),
              ],
            ),
          );
        }),
      ),
      bottomNavigationBar: Obx(() {
        final campaign = controller.campaign.value;
        if (campaign == null || controller.isLoading.value) {
          return const SizedBox.shrink();
        }
        return _buildActionButton(campaign);
      }),
    );
  }

  Widget _buildActionButton(CampaignData campaign) {
    return Container(
      width: Get.width,
      margin: EdgeInsets.symmetric(horizontal: 14),
      padding: EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              final shareUrl =
                  campaign.shareUrl ?? '${Url.baseUrl}/api/c/${campaign.id}';
              SharePlus.instance.share(
                ShareParams(
                  text:
                      'Yuk bantu kampanye "${campaign.title}" di Quranuna! Klik link berikut: $shareUrl',
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 14),
              decoration: BoxDecoration(
                border: Border.all(color: AppColor.globalBorder),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(LucideIcons.share2, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    'Bagikan',
                    style: pRegular12.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
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
                backgroundColor: AppColor.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Infaq Sekarang",
                style: pMedium14.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgramDesc(CampaignData campaign) {
    return Container(
      width: Get.width,
      margin: EdgeInsets.symmetric(horizontal: 14),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.globalBorder),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Deskripsi Program",
            style: pSemiBold14.copyWith(
              color: AppColor.globalTextSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          HtmlWidget(
            campaign.description
                .replaceAll('&nbsp;', ' ')
                .replaceAll('\u00A0', ' ')
                .replaceAll('word-break: break-all', 'word-break: normal')
                .replaceAll('word-break: break-word', 'word-break: normal'),
            textStyle: pRegular14.copyWith(
              height: 1.7,
              color: Get.context!.theme.colorScheme.onSurface.withValues(
                alpha: 0.8,
              ),
            ),
            customStylesBuilder: (element) => {'word-break': 'normal'},
          ),
        ],
      ),
    );
  }

  Widget _buildProgramInfo(CampaignData campaign) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 14),
      padding: EdgeInsets.only(left: 2, top: 2, right: 2, bottom: 18),
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.globalBorder),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              campaign.coverImage,
              height: 180,
              width: Get.width,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 180,
                width: Get.width,
                color: Colors.grey.shade300,
                child: const Icon(LucideIcons.image, size: 40),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  campaign.title,
                  style: pSemiBold14.copyWith(
                    color: AppColor.globalTextSecondary,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            campaign.collectedAmount,
                            style: pSemiBold14.copyWith(
                              color: AppColor.globalTextSecondary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Terkumpul dari ${campaign.targetAmount}',
                            style: pRegular10.copyWith(
                              color: AppColor.globalTextSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      campaign.endDate == 'Infinity'
                          ? 'Tak Terbatas'
                          : 'Sisa ${campaign.endDate}',
                      style: pRegular10.copyWith(
                        color: AppColor.globalTextSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  borderRadius: BorderRadius.circular(12),
                  value: (campaign.percentage / 100).clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: AppColor.globalBorder,
                  color: AppColor.primaryColor,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => Get.toNamed(
                        Routes.charityCampaignTabs,
                        arguments: {'campaignId': campaign.id, 'initialTab': 0},
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Icon(
                                LucideIcons.heart,
                                size: 16,
                                color: AppColor.primaryColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "${campaign.donaturCount}",
                                style: pSemiBold12.copyWith(
                                  color: AppColor.globalTextSecondary,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Donasi",
                            style: pRegular10.copyWith(
                              color: AppColor.globalTextSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.toNamed(
                        Routes.charityCampaignTabs,
                        arguments: {'campaignId': campaign.id, 'initialTab': 1},
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Icon(
                                LucideIcons.newspaper,
                                size: 16,
                                color: AppColor.primaryColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "${campaign.updates.length}",
                                style: pSemiBold12.copyWith(
                                  color: AppColor.globalTextSecondary,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Kabar Terbaru",
                            style: pRegular10.copyWith(
                              color: AppColor.globalTextSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.toNamed(
                        Routes.charityCampaignTabs,
                        arguments: {'campaignId': campaign.id, 'initialTab': 2},
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Icon(
                                LucideIcons.users,
                                size: 16,
                                color: AppColor.primaryColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "${campaign.fundraiserCount}",
                                style: pSemiBold12.copyWith(
                                  color: AppColor.globalTextSecondary,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Fundraiser",
                            style: pRegular10.copyWith(
                              color: AppColor.globalTextSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
