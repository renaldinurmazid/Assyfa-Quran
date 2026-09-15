import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:quran_app/screen/mosque/mosque_charity_show_controller.dart';
import 'package:quran_app/models/mosque_charity_model.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:quran_app/api/url.dart';

// ─── Color tokens ─────────────────────────────────────────────────────────────
const _kBgDark = Color(0xFF0F0F10);
const _kBgLight = Color(0xFFF8FAFC);
const _kSurfaceDark = Color(0xFF18181B);
const _kSurfaceLight = Colors.white;
const _kBorderDark = Color(0xFF27272A);
const _kBorderLight = Color(0xFFE2E8F0);

class MosqueCharityShowScreen extends StatelessWidget {
  const MosqueCharityShowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MosqueCharityShowController());

    return Scaffold(
      backgroundColor: context.isDarkMode ? _kBgDark : _kBgLight,
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState(context);
        }

        final mosque = controller.mosque.value;
        if (mosque == null) {
          final isDark = context.isDarkMode;
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
                      'Masjid tidak ditemukan',
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
                _buildSliverAppBar(context, mosque),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Container(
                        color: context.isDarkMode
                            ? _kSurfaceDark
                            : _kSurfaceLight,
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTitleSection(context, mosque),
                            const SizedBox(height: 20),
                            _buildAmountCard(context, mosque),
                            const SizedBox(height: 16),
                            _buildProgressSection(context, mosque),
                            const SizedBox(height: 20),
                            _buildStatsRow(context, mosque),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildStorySection(context, mosque),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
            _buildStickyBottomButtons(context, mosque),
          ],
        );
      }),
    );
  }

  // ── Circle back button ─────────────────────────────────────────────────────

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

  Widget _buildSliverAppBar(BuildContext context, MosqueCharityData mosque) {
    final isDark = context.isDarkMode;
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: isDark ? _kSurfaceDark : _kSurfaceLight,
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
                      mosque.shareUrl ?? '${Url.baseUrl}/api/m/${mosque.id}';
                  SharePlus.instance.share(
                    ShareParams(
                      text:
                          'Yuk bantu pembangunan "${mosque.name}" di Quranuna! Klik link berikut: $shareUrl',
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
            Image.network(mosque.coverImage, fit: BoxFit.cover),
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

  Widget _buildTitleSection(BuildContext context, MosqueCharityData mosque) {
    final isDark = context.isDarkMode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          mosque.name,
          style: pBold18.copyWith(
            color: context.theme.colorScheme.onSurface,
            height: 1.4,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(
              IconlyLight.location,
              size: 12,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                mosque.address,
                style: pRegular12.copyWith(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Amount card ────────────────────────────────────────────────────────────

  Widget _buildAmountCard(BuildContext context, MosqueCharityData mosque) {
    final isDark = context.isDarkMode;
    final primary = isDark ? AppColor.primaryColorDark : AppColor.primaryColor;
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
                  mosque.collectedAmount,
                  style: pBold20.copyWith(color: primary, letterSpacing: -0.5),
                ),
                const SizedBox(height: 2),
                Text(
                  'dari target ${mosque.targetAmount ?? 'Tanpa Target'}',
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
                Text(
                  'Tak Terbatas',
                  style: pSemiBold10.copyWith(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Progress section ───────────────────────────────────────────────────────

  Widget _buildProgressSection(BuildContext context, MosqueCharityData mosque) {
    final isDark = context.isDarkMode;
    final primary = isDark ? AppColor.primaryColorDark : AppColor.primaryColor;
    final double progress = (mosque.percentage / 100).clamp(0.0, 1.0);
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
              '${mosque.percentage}%',
              style: pSemiBold12.copyWith(color: primary),
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
            valueColor: AlwaysStoppedAnimation<Color>(primary),
          ),
        ),
      ],
    );
  }

  // ── Stats row ──────────────────────────────────────────────────────────────

  Widget _buildStatsRow(BuildContext context, MosqueCharityData mosque) {
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
            value: '${mosque.donaturCount}',
            label: 'Donatur',
            onTap: () => Get.toNamed(
              Routes.mosqueCharityTabs,
              arguments: {'mosqueCharityId': mosque.id, 'initialTab': 0},
            ),
          ),
          _buildStatDivider(isDark),
          _buildStatItem(
            context,
            icon: IconlyLight.document,
            label: 'Update',
            onTap: () => Get.toNamed(
              Routes.mosqueCharityTabs,
              arguments: {'mosqueCharityId': mosque.id, 'initialTab': 1},
            ),
          ),
          _buildStatDivider(isDark),
          _buildStatItem(
            context,
            icon: IconlyLight.wallet,
            label: 'Fundraiser',
            onTap: () => Get.toNamed(
              Routes.mosqueCharityTabs,
              arguments: {'mosqueCharityId': mosque.id, 'initialTab': 2},
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
    final primary = isDark ? AppColor.primaryColorDark : AppColor.primaryColor;
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
                  Icon(icon, size: 16, color: primary),
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

  Widget _buildStorySection(BuildContext context, MosqueCharityData mosque) {
    final isDark = context.isDarkMode;
    final primary = isDark ? AppColor.primaryColorDark : AppColor.primaryColor;
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
                  color: primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Tentang Masjid',
                style: pSemiBold14.copyWith(
                  color: context.theme.colorScheme.onSurface,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (mosque.description != null && mosque.description!.isNotEmpty)
            HtmlWidget(
              mosque.description!
                  .replaceAll('&nbsp;', ' ')
                  .replaceAll('\u00A0', ' ')
                  .replaceAll('word-break: break-all', 'word-break: normal')
                  .replaceAll('word-break: break-word', 'word-break: normal'),
              textStyle: pRegular14.copyWith(
                height: 1.7,
                color: context.theme.colorScheme.onSurface.withValues(
                  alpha: 0.8,
                ),
              ),
              customStylesBuilder: (element) => {'word-break': 'normal'},
            )
          else
            Text(
              'Belum ada deskripsi.',
              style: pRegular14.copyWith(
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
              ),
            ),
        ],
      ),
    );
  }

  // ── Bottom action bar ──────────────────────────────────────────────────────

  Widget _buildStickyBottomButtons(
    BuildContext context,
    MosqueCharityData mosque,
  ) {
    final isDark = context.isDarkMode;
    final primary = isDark ? AppColor.primaryColorDark : AppColor.primaryColor;
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
                  onPressed: () => Get.toNamed(
                    Routes.mosqueCharityPayment,
                    arguments: {'id': mosque.id},
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
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
                Container(
                  height: 22,
                  width: double.infinity,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Container(height: 22, width: 200, color: Colors.white),
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
