import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:quran_app/controller/mosque_charity_show_controller.dart';
import 'package:quran_app/models/mosque_charity_model.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:quran_app/api/url.dart';
import 'package:url_launcher/url_launcher.dart';

class MosqueCharityShowScreen extends StatelessWidget {
  const MosqueCharityShowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MosqueCharityShowController());

    return Scaffold(
      backgroundColor: context.isDarkMode
          ? Colors.grey.shade900
          : Colors.grey.shade50,
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState(context);
        }

        final mosque = controller.mosque.value;
        if (mosque == null) {
          return const Center(child: Text('Masjid tidak ditemukan'));
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
                        color: context.theme.colorScheme.surface,
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTitleSection(context, mosque),
                            const SizedBox(height: 20),
                            _buildProgressSection(context, mosque),
                            const SizedBox(height: 24),
                            _buildHorizontalStats(context, mosque),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildStorySection(context, mosque),
                      const SizedBox(height: 120), // Space for bottom button
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

  Widget _buildSliverAppBar(BuildContext context, MosqueCharityData mosque) {
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
            Hero(
              tag: 'mosque_${mosque.id}',
              child: Image.network(mosque.coverImage, fit: BoxFit.cover),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.3), Colors.transparent],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection(BuildContext context, MosqueCharityData mosque) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          mosque.name,
          style: pBold18.copyWith(
            color: context.theme.colorScheme.onSurface,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          mosque.address,
          style: pRegular12,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 16),
        Text(
          mosque.collectedAmount,
          style: pBold18.copyWith(
            color: context.isDarkMode
                ? AppColor.primaryColorDark
                : AppColor.primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Terkumpul dari ${mosque.targetAmount ?? 'Tanpa Target'}',
          style: pRegular12.copyWith(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildProgressSection(BuildContext context, MosqueCharityData mosque) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: mosque.percentage / 100,
            minHeight: 10,
            backgroundColor: context.isDarkMode
                ? Colors.grey.shade900
                : Colors.grey.shade100,
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

  Widget _buildHorizontalStats(BuildContext context, MosqueCharityData mosque) {
    return Row(
      children: [
        _buildStatItem(
          Icons.favorite,
          '${mosque.donaturCount}',
          'Donasi',
          context.isDarkMode
              ? AppColor.primaryColorDark
              : AppColor.primaryColor,
          onTap: () => Get.toNamed(
            Routes.mosqueCharityTabs,
            arguments: {'mosqueCharityId': mosque.id, 'initialTab': 0},
          ),
        ),
        _buildVerticalDivider(),
        _buildStatItem(
          Icons.description,
          '',
          'Update',
          context.isDarkMode
              ? AppColor.primaryColorDark
              : AppColor.primaryColor,
          showValue: false,
          onTap: () => Get.toNamed(
            Routes.mosqueCharityTabs,
            arguments: {'mosqueCharityId': mosque.id, 'initialTab': 1},
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
            Routes.mosqueCharityTabs,
            arguments: {'mosqueCharityId': mosque.id, 'initialTab': 2},
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

  Widget _buildStorySection(BuildContext context, MosqueCharityData mosque) {
    return Container(
      color: context.theme.colorScheme.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Tentang Masjid", style: pSemiBold14),
          const SizedBox(height: 12),
          HtmlWidget(
            mosque.description!
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
    MosqueCharityData mosque,
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
                      mosque.shareUrl ?? '${Url.baseUrl}/api/m/${mosque.id}';
                  Share.share(
                    'Yuk bantu pembangunan "${mosque.name}" di Quranuna! Klik link berikut: $shareUrl',
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
                  //   Routes.mosqueCharityPayment,
                  //   arguments: {'id': mosque.id},
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
          Container(height: 250, color: context.theme.colorScheme.surface),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 20,
                  width: double.infinity,
                  color: context.theme.colorScheme.surface,
                ),
                const SizedBox(height: 12),
                Container(
                  height: 20,
                  width: 150,
                  color: context.theme.colorScheme.surface,
                ),
                const SizedBox(height: 24),
                Container(
                  height: 100,
                  width: double.infinity,
                  color: context.theme.colorScheme.surface,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
