import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:quran_app/screen/charity/charity_donatur_controller.dart';
import 'package:quran_app/screen/charity/charity_show_controller.dart';
import 'package:quran_app/models/campaign_donatur_model.dart';
import 'package:quran_app/theme/font.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:shimmer/shimmer.dart';

class CampaignTabsScreen extends StatefulWidget {
  const CampaignTabsScreen({super.key});

  @override
  State<CampaignTabsScreen> createState() => _CampaignTabsScreenState();
}

class _CampaignTabsScreenState extends State<CampaignTabsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final int initialTab = Get.arguments['initialTab'] ?? 0;
  final int campaignId = Get.arguments['campaignId'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: initialTab,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: context.theme.colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            IconlyLight.arrow_left,
            color: context.theme.colorScheme.onSurface,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Detail Penggalangan",
          style: pSemiBold16.copyWith(color: context.theme.colorScheme.onSurface),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColor.primaryColorDark,
          labelColor: AppColor.primaryColorDark,
          unselectedLabelColor: Colors.grey,
          labelStyle: pSemiBold14,
          unselectedLabelStyle: pRegular14,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(text: "Donasi"),
            Tab(text: "Kabar Terbaru"),
            Tab(text: "Fundraiser"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _DonationTab(campaignId: campaignId),
          _UpdatesTab(campaignId: campaignId),
          _FundraiserTab(campaignId: campaignId),
        ],
      ),
    );
  }
}

class _DonationTab extends StatelessWidget {
  final int campaignId;
  const _DonationTab({required this.campaignId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      CharityDonaturController(),
      tag: 'tab_$campaignId',
    );

    return Obx(() {
      if (controller.isLoading.value) {
        return _buildShimmerLoading();
      }

      if (controller.donaturList.isEmpty) {
        return _buildEmptyState("Belum Ada Donasi", IconlyLight.heart);
      }

      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: controller.donaturList.length,
        separatorBuilder: (_, __) => Divider(
          height: 24,
          thickness: 0.5,
          color: context.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
        ),
        itemBuilder: (context, index) {
          final donatur = controller.donaturList[index];
          return Row(
            children: [
              _buildAvatar(donatur),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(donatur.name, style: pSemiBold14),
                    const SizedBox(height: 4),
                    Text(
                      donatur.time,
                      style: pRegular10.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Text(
                donatur.amount,
                style: pBold14.copyWith(color: AppColor.primaryColorDark),
              ),
            ],
          );
        },
      );
    });
  }

  Widget _buildAvatar(DonaturItem donatur) {
    final initials = donatur.name.isNotEmpty
        ? donatur.name[0].toUpperCase()
        : '?';
    return CircleAvatar(
      radius: 20,
      backgroundColor: AppColor.primaryColorDark.withOpacity(0.1),
      child: Text(
        initials,
        style: pBold14.copyWith(color: AppColor.primaryColorDark),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Get.context!.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200,
      highlightColor: Get.context!.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 8,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Get.context!.theme.colorScheme.surface,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 12,
                  color: Get.context!.theme.colorScheme.surface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpdatesTab extends StatelessWidget {
  final int campaignId;
  const _UpdatesTab({required this.campaignId});

  @override
  Widget build(BuildContext context) {
    final showController = Get.find<CharityShowController>();
    final updates = showController.campaign.value?.updates ?? [];

    if (updates.isEmpty) {
      return _buildEmptyState(
        "Belum Ada Kabar Terbaru",
        IconlyLight.info_square,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: updates.length,
      separatorBuilder: (_, __) => const SizedBox(height: 24),
      itemBuilder: (context, index) {
        final update = updates[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColor.primaryColorDark,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  update.createdAtFormatted,
                  style: pBold12.copyWith(color: AppColor.primaryColorDark),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: context.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(update.title, style: pBold14),
                  const SizedBox(height: 8),
                  HtmlWidget(
                    update.content,
                    textStyle: pRegular12.copyWith(
                      color: context.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                      height: 1.5,
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
}

class _FundraiserTab extends StatelessWidget {
  final int campaignId;
  const _FundraiserTab({required this.campaignId});

  @override
  Widget build(BuildContext context) {
    final showController = Get.find<CharityShowController>();
    final fundraisers = showController.campaign.value?.fundraisers ?? [];

    if (fundraisers.isEmpty) {
      return _buildEmptyState("Belum Ada Fundraiser", IconlyLight.star);
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: fundraisers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final fundraiser = fundraisers[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
            ),
          ),
          child: Row(
            children: [
              _buildFundraiserAvatar(fundraiser.name),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(fundraiser.name, style: pSemiBold14),
                    const SizedBox(height: 4),
                    Text(
                      '${fundraiser.totalReferral} orang diajak',
                      style: pRegular10.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColor.primaryColorDark.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  fundraiser.totalCollected,
                  style: pBold10.copyWith(color: AppColor.primaryColorDark),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFundraiserAvatar(String name) {
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.orange.shade50,
      child: Text(
        initials,
        style: pBold14.copyWith(color: Colors.orange.shade700),
      ),
    );
  }
}

Widget _buildEmptyState(String message, IconData icon) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 64,
          color: Get.context!.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
        ),
        const SizedBox(height: 16),
        Text(
          message,
          style: pMedium14.copyWith(
            color: Get.context!.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade400,
          ),
        ),
      ],
    ),
  );
}
