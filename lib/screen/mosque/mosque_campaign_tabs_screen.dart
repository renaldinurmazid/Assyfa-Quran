import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:quran_app/screen/mosque/mosque_charity_donatur_controller.dart';
import 'package:quran_app/screen/mosque/mosque_charity_show_controller.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

// ─── Color tokens ─────────────────────────────────────────────────────────────
const _kSurfaceDark = Color(0xFF18181B);
const _kSurfaceLight = Colors.white;
const _kBorderDark = Color(0xFF27272A);
const _kBorderLight = Color(0xFFE2E8F0);

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
    final isDark = context.isDarkMode;
    final primary = isDark ? AppColor.primaryColorDark : AppColor.primaryColor;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F10) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? _kSurfaceDark : _kSurfaceLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.04),
              shape: BoxShape.circle,
            ),
            child: Icon(
              IconlyLight.arrow_left,
              size: 18,
              color: context.theme.colorScheme.onSurface,
            ),
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Aktivitas Masjid',
          style: pSemiBold16.copyWith(
            color: context.theme.colorScheme.onSurface,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? _kBorderDark : _kBorderLight,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: primary,
              labelColor: primary,
              unselectedLabelColor:
                  isDark ? Colors.grey.shade600 : Colors.grey.shade400,
              labelStyle: pSemiBold12,
              unselectedLabelStyle: pRegular12,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorWeight: 2,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Donatur'),
                Tab(text: 'Update'),
                Tab(text: 'Fundraiser'),
              ],
            ),
          ),
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

  // ─── Donatur Tab ─────────────────────────────────────────────────────────────

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
        color: context.isDarkMode
            ? AppColor.primaryColorDark
            : AppColor.primaryColor,
        backgroundColor: context.isDarkMode ? _kSurfaceDark : _kSurfaceLight,
        onRefresh: () => donaturController.refreshData(),
        child: ListView.separated(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          itemCount: donaturController.donaturList.length +
              (donaturController.hasMore.value ? 1 : 0),
          separatorBuilder: (_, __) => Divider(
            height: 24,
            thickness: 1,
            color: context.isDarkMode ? _kBorderDark : _kBorderLight,
          ),
          itemBuilder: (context, index) {
            if (index == donaturController.donaturList.length) {
              donaturController.fetchDonaturList(loadMore: true);
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        context.isDarkMode
                            ? AppColor.primaryColorDark
                            : AppColor.primaryColor,
                      ),
                    ),
                  ),
                ),
              );
            }

            final donatur = donaturController.donaturList[index];
            final isDark = context.isDarkMode;
            final primary =
                isDark ? AppColor.primaryColorDark : AppColor.primaryColor;
            final initials = donatur.name.isNotEmpty
                ? donatur.name[0].toUpperCase()
                : '?';

            return Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: primary.withValues(alpha: 0.2)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initials,
                    style: pBold12.copyWith(color: primary),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    donatur.name,
                    style: pSemiBold12.copyWith(
                      color: context.theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                Text(
                  donatur.amount,
                  style: pBold12.copyWith(
                    color: primary,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            );
          },
        ),
      );
    });
  }

  // ─── Updates Tab ──────────────────────────────────────────────────────────────

  Widget _buildUpdatesTab() {
    final showController = Get.find<MosqueCharityShowController>();
    final mosque = showController.mosque.value;

    if (mosque == null || mosque.updates.isEmpty) {
      return _buildEmptyState('Belum ada update', IconlyLight.info_square);
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: mosque.updates.length,
      separatorBuilder: (_, __) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        final update = mosque.updates[index];
        final isDark = context.isDarkMode;
        final primary =
            isDark ? AppColor.primaryColorDark : AppColor.primaryColor;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  update.createdAtFormatted,
                  style: pSemiBold10.copyWith(color: primary),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Content card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? _kSurfaceDark : _kSurfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? _kBorderDark : _kBorderLight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    update.title,
                    style: pSemiBold14.copyWith(
                      color: context.theme.colorScheme.onSurface,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  HtmlWidget(
                    update.content,
                    textStyle: pRegular12.copyWith(
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade700,
                      height: 1.6,
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

  // ─── Fundraiser Tab ───────────────────────────────────────────────────────────

  Widget _buildFundraiserTab() {
    final showController = Get.find<MosqueCharityShowController>();
    final mosque = showController.mosque.value;

    if (mosque == null || mosque.fundraisers.isEmpty) {
      return _buildEmptyState('Belum ada fundraiser', IconlyLight.star);
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: mosque.fundraisers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final fundraiser = mosque.fundraisers[index];
        final isDark = context.isDarkMode;
        final primary =
            isDark ? AppColor.primaryColorDark : AppColor.primaryColor;
        final rank = index + 1;
        final initials = fundraiser.name.isNotEmpty
            ? fundraiser.name[0].toUpperCase()
            : '?';

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? _kSurfaceDark : _kSurfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? _kBorderDark : _kBorderLight),
          ),
          child: Row(
            children: [
              // Rank badge
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: rank <= 3
                      ? primary.withValues(alpha: 0.12)
                      : (isDark ? _kBorderDark : _kBorderLight),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$rank',
                  style: pSemiBold10.copyWith(
                    color: rank <= 3
                        ? primary
                        : (isDark
                              ? Colors.grey.shade500
                              : Colors.grey.shade500),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Avatar
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: primary.withValues(alpha: 0.2)),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: pBold12.copyWith(color: primary),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fundraiser.name,
                      style: pSemiBold12.copyWith(
                        color: context.theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${fundraiser.totalReferral} orang diajak',
                      style: pRegular10.copyWith(
                        color: isDark
                            ? Colors.grey.shade500
                            : Colors.grey.shade500,
                      ),
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
                  color: primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: primary.withValues(alpha: 0.2)),
                ),
                child: Text(
                  fundraiser.totalCollected,
                  style: pSemiBold10.copyWith(color: primary),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Empty state ──────────────────────────────────────────────────────────────

  Widget _buildEmptyState(String message, IconData icon) {
    final isDark = context.isDarkMode;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF27272A)
                  : const Color(0xFFF8FAFC),
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? _kBorderDark : _kBorderLight,
              ),
            ),
            child: Icon(
              icon,
              size: 28,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: pSemiBold12.copyWith(
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Shimmer ──────────────────────────────────────────────────────────────────

  Widget _buildShimmerList() {
    final isDark = context.isDarkMode;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
      highlightColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: 6,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 12, width: double.infinity, color: Colors.white),
                    const SizedBox(height: 6),
                    Container(height: 10, width: 80, color: Colors.white),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(height: 12, width: 60, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
