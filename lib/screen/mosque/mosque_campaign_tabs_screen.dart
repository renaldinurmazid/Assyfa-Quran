import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:quran_app/controller/mosque_charity_donatur_controller.dart';
import 'package:quran_app/controller/mosque_charity_show_controller.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class MosqueCampaignTabsScreen extends StatefulWidget {
  const MosqueCampaignTabsScreen({super.key});

  @override
  State<MosqueCampaignTabsScreen> createState() =>
      _MosqueCampaignTabsScreenState();
}

class _MosqueCampaignTabsScreenState extends State<MosqueCampaignTabsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late int mosqueCharityId;
  late int initialTab;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    mosqueCharityId = args['mosqueCharityId'];
    initialTab = args['initialTab'] ?? 0;

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
        title: Text('Aktivitas Masjid', style: pSemiBold16),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            IconlyLight.arrow_left,
            color: context.theme.colorScheme.onSurface,
          ),
          onPressed: () => Get.back(),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColor.primaryColorDark,
          labelColor: AppColor.primaryColorDark,
          unselectedLabelColor: Colors.grey,
          labelStyle: pSemiBold14,
          unselectedLabelStyle: pMedium14,
          tabs: const [
            Tab(text: 'Donatur'),
            Tab(text: 'Update'),
            Tab(text: 'Fundraiser'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDonaturTab(mosqueCharityId),
          _buildUpdatesTab(),
          _buildFundraiserTab(),
        ],
      ),
    );
  }

  Widget _buildDonaturTab(int mosqueId) {
    final donaturController = Get.put(
      MosqueCharityDonaturController(),
      tag: 'mosque_donatur_$mosqueId',
    );

    return Obx(() {
      if (donaturController.isLoading.value) {
        return _buildShimmerList();
      }

      if (donaturController.donaturList.isEmpty) {
        return _buildEmptyState('Belum ada donatur', IconlyLight.heart);
      }

      return RefreshIndicator(
        onRefresh: () => donaturController.refreshData(),
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount:
              donaturController.donaturList.length +
              (donaturController.hasMore.value ? 1 : 0),
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            if (index == donaturController.donaturList.length) {
              donaturController.fetchDonaturList(loadMore: true);
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final donatur = donaturController.donaturList[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: context.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColor.primaryColorDark.withOpacity(0.1),
                    child: const Icon(
                      IconlyLight.user,
                      color: AppColor.primaryColorDark,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Expanded(
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       Text(donatur.name, style: pSemiBold14),
                  //       const SizedBox(height: 4),
                  //       Text(donatur.createdAtFormatted, style: pRegular10.copyWith(color: Colors.grey)),
                  //     ],
                  //   ),
                  // ),
                  Text(
                    donatur.amount,
                    style: pSemiBold14.copyWith(
                      color: AppColor.primaryColorDark,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildUpdatesTab() {
    final showController = Get.find<MosqueCharityShowController>();
    final mosque = showController.mosque.value;

    if (mosque == null || mosque.updates.isEmpty) {
      return _buildEmptyState('Belum ada update', IconlyLight.info_square);
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: mosque.updates.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final update = mosque.updates[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
            ),
          ),
          child: Column(
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
                  const SizedBox(width: 8),
                  Text(
                    update.createdAtFormatted,
                    style: pSemiBold12.copyWith(
                      color: AppColor.primaryColorDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(update.title, style: pSemiBold14),
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
        );
      },
    );
  }

  Widget _buildFundraiserTab() {
    final showController = Get.find<MosqueCharityShowController>();
    final mosque = showController.mosque.value;

    if (mosque == null || mosque.fundraisers.isEmpty) {
      return _buildEmptyState('Belum ada fundraiser', IconlyLight.star);
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: mosque.fundraisers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final fundraiser = mosque.fundraisers[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  IconlyLight.star,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
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
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  fundraiser.totalCollected,
                  style: pSemiBold10.copyWith(color: Colors.orange.shade800),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: context.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: pMedium14.copyWith(
              color: context.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerList() {
    return Shimmer.fromColors(
      baseColor: context.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200,
      highlightColor: context.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: context.theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}
