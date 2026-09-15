import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';
import 'package:quran_app/screen/haji&umrah/detail/haji_and_umrah_detail_controller.dart';
import 'package:quran_app/models/haji_umrah_package_model.dart';
import 'package:shimmer/shimmer.dart';
import 'package:iconly/iconly.dart';

// ─── Color tokens (same as CharityShowScreen) ─────────────────────────────────
const _kBgDark = Color(0xFF0F0F10);
const _kBgLight = Color(0xFFF8FAFC);
const _kSurfaceDark = Color(0xFF18181B);
const _kSurfaceLight = Colors.white;
const _kBorderDark = Color(0xFF27272A);
const _kBorderLight = Color(0xFFE2E8F0);

class HajiAndUmrahDetailScreen extends StatelessWidget {
  const HajiAndUmrahDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HajiAndUmrahDetailController());
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? _kBgDark : _kBgLight,
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState(context);
        }

        final package = controller.package.value;
        if (package == null) {
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
                      'Paket tidak ditemukan',
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
                _buildSliverAppBar(context, package),
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
                            _buildTitleSection(context, package),
                            const SizedBox(height: 20),
                            _buildPriceCard(context, package),
                            const SizedBox(height: 16),
                            _buildQuotaSection(context, package),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoSection(context, package),
                      const SizedBox(height: 8),
                      _buildDescriptionSection(context, package),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
            _buildStickyBottomButtons(context, package),
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

  Widget _buildSliverAppBar(
    BuildContext context,
    HajiUmrahPackageModel package,
  ) {
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
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: package.bannerImageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: isDark
                    ? const Color(0xFF27272A)
                    : const Color(0xFFE2E8F0),
              ),
              errorWidget: (_, __, ___) => Container(
                color: isDark
                    ? const Color(0xFF27272A)
                    : const Color(0xFFE2E8F0),
                child: Icon(
                  Icons.broken_image_outlined,
                  size: 40,
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
                ),
              ),
            ),
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

  Widget _buildTitleSection(
    BuildContext context,
    HajiUmrahPackageModel package,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          package.title ?? '',
          style: pBold18.copyWith(
            color: context.theme.colorScheme.onSurface,
            height: 1.4,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  // ── Price card ─────────────────────────────────────────────────────────────

  Widget _buildPriceCard(BuildContext context, HajiUmrahPackageModel package) {
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
                  'Harga Mulai',
                  style: pRegular12.copyWith(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  (package.priceFormatted != null &&
                          package.priceFormatted!.isNotEmpty)
                      ? package.priceFormatted!
                      : 'Hubungi Kami',
                  style: pBold20.copyWith(
                    color: isDark
                        ? AppColor.primaryColorDark
                        : AppColor.primaryColor,
                    letterSpacing: -0.5,
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
                  Icons.payments_outlined,
                  size: 14,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                const SizedBox(width: 5),
                Text(
                  'Per Orang',
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

  // ── Quota section ──────────────────────────────────────────────────────────

  Widget _buildQuotaSection(
    BuildContext context,
    HajiUmrahPackageModel package,
  ) {
    final isDark = context.isDarkMode;
    final quota = package.quota ?? 0;
    final quotaLeft = package.quotaLeft ?? 0;
    final double progress = quota > 0
        ? (quotaLeft / quota).clamp(0.0, 1.0)
        : 0.0;
    final isLow = quotaLeft > 0 && quotaLeft <= 5;
    final isSoldOut = quotaLeft == 0;

    final accentColor = isSoldOut
        ? Colors.red.shade400
        : isLow
        ? Colors.amber.shade700
        : (isDark ? AppColor.primaryColorDark : AppColor.primaryColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Sisa Slot',
              style: pRegular12.copyWith(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            Text(
              isSoldOut ? 'Habis' : '$quotaLeft / $quota Slot',
              style: pSemiBold12.copyWith(color: accentColor),
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
            valueColor: AlwaysStoppedAnimation<Color>(accentColor),
          ),
        ),
        if (isLow) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.flash_on_rounded,
                size: 12,
                color: Colors.amber.shade700,
              ),
              const SizedBox(width: 4),
              Text(
                'Segera daftar! Kuota hampir habis.',
                style: pSemiBold10.copyWith(color: Colors.amber.shade700),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // ── Info section ───────────────────────────────────────────────────────────

  Widget _buildInfoSection(
    BuildContext context,
    HajiUmrahPackageModel package,
  ) {
    final isDark = context.isDarkMode;

    final items = [
      _InfoItem(
        icon: IconlyLight.location,
        label: 'Keberangkatan',
        value: package.departureCity ?? 'Info menyusul',
      ),
      _InfoItem(
        icon: IconlyLight.time_circle,
        label: 'Durasi Perjalanan',
        value: package.durationDays != null
            ? '${package.durationDays} Hari'
            : 'Info menyusul',
      ),
      _InfoItem(
        icon: IconlyLight.calendar,
        label: 'Tanggal Berangkat',
        value: package.umrahDetail?.departureDateFormatted ?? 'Info menyusul',
      ),
      _InfoItem(
        icon: IconlyLight.calendar,
        label: 'Tanggal Kepulangan',
        value: package.umrahDetail?.returnDateFormatted ?? 'Info menyusul',
      ),
      _InfoItem(
        icon: IconlyLight.discovery,
        label: 'Maskapai Penerbangan',
        value: package.flightDetail ?? 'Info menyusul',
      ),
    ];

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
                  color: isDark
                      ? AppColor.primaryColorDark
                      : AppColor.primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Informasi Perjalanan',
                style: pSemiBold14.copyWith(
                  color: context.theme.colorScheme.onSurface,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 2-col grid for first 4, full-width for last
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildInfoTile(context, items[0])),
              const SizedBox(width: 12),
              Expanded(child: _buildInfoTile(context, items[1])),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildInfoTile(context, items[2])),
              const SizedBox(width: 12),
              Expanded(child: _buildInfoTile(context, items[3])),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoTile(context, items[4]),
        ],
      ),
    );
  }

  Widget _buildInfoTile(BuildContext context, _InfoItem item) {
    final isDark = context.isDarkMode;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF27272A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? _kBorderDark : _kBorderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            item.icon,
            size: 16,
            color: isDark ? AppColor.primaryColorDark : AppColor.primaryColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: pRegular10.copyWith(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  item.value,
                  style: pSemiBold12.copyWith(
                    color: context.theme.colorScheme.onSurface,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Description section ────────────────────────────────────────────────────

  Widget _buildDescriptionSection(
    BuildContext context,
    HajiUmrahPackageModel package,
  ) {
    final isDark = context.isDarkMode;
    final description = package.description ?? '';
    if (description.isEmpty) return const SizedBox.shrink();

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
                  color: isDark
                      ? AppColor.primaryColorDark
                      : AppColor.primaryColor,
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
            description
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
    HajiUmrahPackageModel package,
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
            // Price summary
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mulai dari',
                  style: pRegular10.copyWith(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  (package.priceFormatted != null &&
                          package.priceFormatted!.isNotEmpty)
                      ? package.priceFormatted!
                      : 'Hubungi Kami',
                  style: pBold16.copyWith(
                    color: isDark
                        ? AppColor.primaryColorDark
                        : AppColor.primaryColor,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Get.toNamed(
                      Routes.hajiAndUmrahRegister,
                      arguments: package,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? AppColor.primaryColorDark
                        : AppColor.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Daftar Sekarang',
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

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  _InfoItem({required this.icon, required this.label, required this.value});
}
