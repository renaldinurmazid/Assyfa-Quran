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

class HajiAndUmrahDetailScreen extends StatelessWidget {
  const HajiAndUmrahDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HajiAndUmrahDetailController());

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState(context);
        }

        final package = controller.package.value;
        if (package == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detail Paket')),
            body: const Center(child: Text('Paket tidak ditemukan')),
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
                      // Header Section (Title, Price, Quota)
                      Container(
                        color: context.theme.colorScheme.surface,
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTitleSection(context, package),
                            const SizedBox(height: 16),
                            _buildPriceContainer(context, package),
                            const SizedBox(height: 16),
                            _buildQuotaSection(context, package),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildPackageInfoSection(context, package),
                      const SizedBox(height: 10),
                      _buildDescriptionSection(context, package),
                      const SizedBox(height: 130), // Space for bottom floating bar
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

  Widget _buildSliverAppBar(
    BuildContext context,
    HajiUmrahPackageModel package,
  ) {
    return SliverAppBar(
      expandedHeight: 240,
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
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
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
            CachedNetworkImage(
              imageUrl: package.bannerImageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: context.isDarkMode ? Colors.grey[900] : Colors.grey[100],
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColor.primaryColorDark,
                    ),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: context.isDarkMode ? Colors.grey[900] : Colors.grey[100],
                child: const Center(
                  child: Icon(Icons.image_not_supported, size: 40),
                ),
              ),
            ),
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

  Widget _buildTitleSection(
    BuildContext context,
    HajiUmrahPackageModel package,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
                'PAKET PILIHAN',
                style: pBold10.copyWith(color: Colors.white),
              ),
            ),
            if (package.status != null && package.status!.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColor.primaryColorDark.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColor.primaryColorDark.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  package.status!.toUpperCase(),
                  style: pBold10.copyWith(color: AppColor.primaryColorDark),
                ),
              ),
            ]
          ],
        ),
        const SizedBox(height: 12),
        Text(
          package.title ?? '',
          style: pBold18.copyWith(
            color: context.theme.colorScheme.onSurface,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceContainer(
    BuildContext context,
    HajiUmrahPackageModel package,
  ) {
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Harga Mulai',
                style: pMedium12.copyWith(
                  color: context.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                (package.priceFormatted != null && package.priceFormatted!.isNotEmpty)
                    ? package.priceFormatted!
                    : 'Hubungi Kami',
                style: pBold20.copyWith(
                  color: AppColor.primaryColorDark,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColor.primaryColorDark.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.payments_outlined,
              color: AppColor.primaryColorDark,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuotaSection(
    BuildContext context,
    HajiUmrahPackageModel package,
  ) {
    final int quota = package.quota ?? 0;
    final int quotaLeft = package.quotaLeft ?? 0;
    final double progress = quota > 0 ? (quotaLeft / quota) : 0.0;
    final bool isLowQuota = quotaLeft > 0 && quotaLeft <= 5;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.isDarkMode
              ? Colors.grey.shade800
              : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    IconlyLight.user_1,
                    size: 18,
                    color: isLowQuota ? Colors.amber.shade900 : AppColor.primaryColorDark,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Sisa Slot Keberangkatan',
                    style: pBold12.copyWith(
                      color: context.theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isLowQuota
                      ? Colors.amber.shade100
                      : AppColor.primaryColorDark.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$quotaLeft dari $quota Slot',
                  style: pBold10.copyWith(
                    color: isLowQuota
                        ? Colors.amber.shade900
                        : AppColor.primaryColorDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: context.isDarkMode
                  ? Colors.grey.shade800
                  : Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(
                isLowQuota ? Colors.amber.shade700 : AppColor.primaryColorDark,
              ),
            ),
          ),
          if (isLowQuota) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.flash_on, size: 12, color: Colors.amber.shade900),
                const SizedBox(width: 4),
                Text(
                  'Segera daftar! Kuota hampir habis.',
                  style: pSemiBold10.copyWith(color: Colors.amber.shade900),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPackageInfoSection(
    BuildContext context,
    HajiUmrahPackageModel package,
  ) {
    final infoItems = [
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
        label: 'Tanggal Keberangkatan',
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
      color: context.theme.colorScheme.surface,
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
              Text("Informasi Perjalanan", style: pBold14),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildGridItem(context, infoItems[0])),
              const SizedBox(width: 12),
              Expanded(child: _buildGridItem(context, infoItems[1])),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildGridItem(context, infoItems[2])),
              const SizedBox(width: 12),
              Expanded(child: _buildGridItem(context, infoItems[3])),
            ],
          ),
          const SizedBox(height: 12),
          _buildGridItem(context, infoItems[4]),
        ],
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, _InfoItem item) {
    return Container(
      padding: const EdgeInsets.all(12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColor.primaryColorDark.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(item.icon, size: 18, color: AppColor.primaryColorDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: pMedium10.copyWith(
                    color: context.isDarkMode
                        ? Colors.grey[400]
                        : Colors.grey[500],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  item.value,
                  style: pSemiBold12.copyWith(
                    color: context.theme.colorScheme.onSurface,
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

  Widget _buildDescriptionSection(
    BuildContext context,
    HajiUmrahPackageModel package,
  ) {
    final String description = package.description ?? '';
    if (description.isEmpty) return const SizedBox.shrink();

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
            description
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
    HajiUmrahPackageModel package,
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mulai Dari',
                        style: pMedium10.copyWith(
                          color: context.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        (package.priceFormatted != null && package.priceFormatted!.isNotEmpty)
                            ? package.priceFormatted!
                            : 'Hubungi Kami',
                        style: pBold16.copyWith(
                          color: AppColor.primaryColorDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    Get.toNamed(Routes.hajiAndUmrahRegister, arguments: package);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaryColorDark,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Daftar Sekarang',
                    style: pSemiBold14.copyWith(color: Colors.white),
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
          Container(height: 240, color: Colors.white),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 24,
                  width: double.infinity,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                Container(height: 20, width: 150, color: Colors.white),
                const SizedBox(height: 24),
                Container(
                  height: 12,
                  width: double.infinity,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Container(height: 12, width: 200, color: Colors.white),
                const SizedBox(height: 24),
                Container(
                  height: 150,
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

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;

  _InfoItem({required this.icon, required this.label, required this.value});
}

