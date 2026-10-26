import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/screen/haji&umrah/detail/haji_and_umrah_detail_controller.dart';
import 'package:quran_app/models/haji_umrah_package_model.dart';

class HajiAndUmrahDetailScreen extends StatelessWidget {
  const HajiAndUmrahDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (Get.isRegistered<HajiAndUmrahDetailController>()) {
      Get.delete<HajiAndUmrahDetailController>();
    }
    final controller = Get.put(HajiAndUmrahDetailController());

    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final package = controller.package.value;
          return Text(
            package?.title ?? 'Detail Paket',
            style: pSemiBold16,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        }),
        centerTitle: false,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(LucideIcons.arrowLeft),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          final package = controller.package.value;
          if (package == null) {
            return const Center(child: Text('Data paket tidak ditemukan'));
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildProgramInfo(package),
                const SizedBox(height: 16),
                _buildInfoSection(package),
                const SizedBox(height: 16),
                _buildDescriptionSection(context, package),
                const SizedBox(height: 32),
              ],
            ),
          );
        }),
      ),
      bottomNavigationBar: Obx(() {
        final package = controller.package.value;
        if (package == null || controller.isLoading.value) {
          return const SizedBox.shrink();
        }
        return _buildActionButton(package);
      }),
    );
  }

  Widget _buildActionButton(HajiUmrahPackageModel package) {
    return Container(
      width: Get.width,
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              final shareUrl = '${Url.baseUrl}/api/umrah/${package.id}';
              SharePlus.instance.share(
                ShareParams(
                  text:
                      'Yuk ikuti program "${package.title}"! Klik link berikut: $shareUrl',
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
                Get.toNamed(Routes.hajiAndUmrahRegister, arguments: package);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Daftar Sekarang",
                style: pMedium14.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgramInfo(HajiUmrahPackageModel package) {
    final quota = package.quota ?? 0;
    final quotaLeft = package.quotaLeft ?? 0;
    final double progress =
        quota > 0 ? ((quota - quotaLeft) / quota).clamp(0.0, 1.0) : 0.0; // progress is based on filled quota, or can just be quotaLeft / quota. Wait, charity was collected / target.

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
              package.bannerImageUrl,
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
                  package.title ?? 'Paket Umrah',
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
                            (package.priceFormatted != null &&
                                    package.priceFormatted!.isNotEmpty)
                                ? package.priceFormatted!
                                : 'Hubungi Kami',
                            style: pSemiBold14.copyWith(
                              color: AppColor.globalTextSecondary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Harga Mulai',
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
                      'Sisa $quotaLeft Slot',
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
                  value: progress,
                  minHeight: 6,
                  backgroundColor: AppColor.globalBorder,
                  color: AppColor.primaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(HajiUmrahPackageModel package) {
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
            "Informasi Perjalanan",
            style: pSemiBold14.copyWith(
              color: AppColor.globalTextSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            LucideIcons.mapPin,
            'Keberangkatan',
            package.departureCity ?? 'Info menyusul',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            LucideIcons.clock,
            'Durasi Perjalanan',
            package.durationDays != null
                ? '${package.durationDays} Hari'
                : 'Info menyusul',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            LucideIcons.calendarDays,
            'Tanggal Berangkat',
            package.umrahDetail?.departureDateFormatted ?? 'Info menyusul',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            LucideIcons.plane,
            'Maskapai Penerbangan',
            package.flightDetail ?? 'Info menyusul',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColor.primaryColor),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: pRegular12.copyWith(
                  color: AppColor.globalTextSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: pSemiBold12.copyWith(
                  color: AppColor.globalTextSecondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(
    BuildContext context,
    HajiUmrahPackageModel package,
  ) {
    final description = package.description ?? '';
    if (description.isEmpty) return const SizedBox.shrink();

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
            "Deskripsi Program",
            style: pSemiBold14.copyWith(
              color: AppColor.globalTextSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          HtmlWidget(
            description
                .replaceAll('&nbsp;', ' ')
                .replaceAll('\u00A0', ' ')
                .replaceAll('word-break: break-all', 'word-break: normal')
                .replaceAll('word-break: break-word', 'word-break: normal'),
            textStyle: pRegular14.copyWith(
              height: 1.7,
              color: Theme.of(context).colorScheme.onSurface.withValues(
                alpha: 0.8,
              ),
            ),
            customStylesBuilder: (element) => {'word-break': 'normal'},
          ),
        ],
      ),
    );
  }
}

