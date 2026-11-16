import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:share_plus/share_plus.dart';
import 'package:quran_app/screen/mosque/mosque_charity_show_controller.dart';
import 'package:quran_app/models/mosque_charity_model.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/theme/font.dart';

class MosqueCharityShowScreen extends StatelessWidget {
  const MosqueCharityShowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (Get.isRegistered<MosqueCharityShowController>()) {
      Get.delete<MosqueCharityShowController>();
    }
    final controller = Get.put(MosqueCharityShowController());

    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final mosque = controller.mosque.value;
          return Text(
            mosque?.name ?? 'Detail Masjid',
            style: pSemiBold16,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        }),
        centerTitle: false,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(LucideIcons.arrowLeft, color: AppColor.globalTextSecondary),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          final mosque = controller.mosque.value;
          if (mosque == null) {
            return Center(
              child: Text(
                'Data masjid tidak ditemukan',
                style: pRegular14.copyWith(color: AppColor.globalTextSecondary),
              ),
            );
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildProgramInfo(mosque),
                const SizedBox(height: 16),
                _buildProgramDesc(mosque),
                const SizedBox(height: 32),
              ],
            ),
          );
        }),
      ),
      bottomNavigationBar: Obx(() {
        final mosque = controller.mosque.value;
        if (mosque == null || controller.isLoading.value) {
          return const SizedBox.shrink();
        }
        return _buildActionButton(mosque);
      }),
    );
  }

  Widget _buildActionButton(MosqueCharityData mosque) {
    return Container(
      width: Get.width,
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: [
          GestureDetector(
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
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
              decoration: BoxDecoration(
                border: Border.all(color: AppColor.globalBorder),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.share2, size: 20),
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
                  Routes.mosqueCharityPayment,
                  arguments: {'id': mosque.id},
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

  Widget _buildProgramDesc(MosqueCharityData mosque) {
    return Container(
      width: Get.width,
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.all(14),
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
            "Tentang Masjid",
            style: pSemiBold14.copyWith(
              color: AppColor.globalTextSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          if (mosque.description != null && mosque.description!.isNotEmpty)
            HtmlWidget(
              mosque.description!
                  .replaceAll('&nbsp;', ' ')
                  .replaceAll(' ', ' ')
                  .replaceAll('word-break: break-all', 'word-break: normal')
                  .replaceAll('word-break: break-word', 'word-break: normal'),
              textStyle: pRegular14.copyWith(
                height: 1.7,
                color: Get.context!.theme.colorScheme.onSurface.withValues(
                  alpha: 0.8,
                ),
              ),
              customStylesBuilder: (element) => {'word-break': 'normal'},
            )
          else
            Text(
              'Belum ada deskripsi.',
              style: pRegular14.copyWith(
                color: AppColor.globalTextSecondary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgramInfo(MosqueCharityData mosque) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.only(left: 2, top: 2, right: 2, bottom: 18),
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.globalBorder),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              mosque.coverImage,
              height: 180,
              width: Get.width,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 180,
                width: Get.width,
                color: context.isDarkMode
                    ? Colors.grey.shade900
                    : Colors.grey.shade100,
                child: Icon(
                  LucideIcons.image,
                  size: 40,
                  color: AppColor.globalTextSecondary,
                ),
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
                  mosque.name,
                  style: pSemiBold14.copyWith(
                    color: AppColor.globalTextSecondary,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Icon(
                        LucideIcons.mapPin,
                        size: 12,
                        color: AppColor.globalTextSecondary.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        mosque.address,
                        style: pRegular12.copyWith(
                          color: AppColor.globalTextSecondary.withValues(alpha: 0.8),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
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
                            mosque.collectedAmount,
                            style: pSemiBold14.copyWith(
                              color: AppColor.globalTextSecondary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Terkumpul dari ${mosque.targetAmount ?? 'Tanpa Target'}',
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
                      'Tak Terbatas',
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
                  value: (mosque.percentage / 100).clamp(0.0, 1.0),
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
                        Routes.mosqueCharityTabs,
                        arguments: {'mosqueCharityId': mosque.id, 'initialTab': 0},
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
                                "${mosque.donaturCount}",
                                style: pSemiBold12.copyWith(
                                  color: AppColor.globalTextSecondary,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Donatur",
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
                        Routes.mosqueCharityTabs,
                        arguments: {'mosqueCharityId': mosque.id, 'initialTab': 1},
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
                                "-",
                                style: pSemiBold12.copyWith(
                                  color: AppColor.globalTextSecondary,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Update",
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
                        Routes.mosqueCharityTabs,
                        arguments: {'mosqueCharityId': mosque.id, 'initialTab': 2},
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
                                "-",
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
