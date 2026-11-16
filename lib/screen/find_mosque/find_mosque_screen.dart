import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/theme/font.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/screen/find_mosque/find_mosque_controller.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class FindMosqueScreen extends GetView<FindMosqueController> {
  const FindMosqueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(
            LucideIcons.arrowLeft,
            color: context.theme.colorScheme.onSurface,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text('Masjid Terdekat', style: pSemiBold16.copyWith()),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              if (controller.latitude.value != 0.0 &&
                  controller.longitude.value != 0.0) {
                final url =
                    'https://www.google.com/maps/search/?api=1&query=Masjid+terdekat&center=${controller.latitude.value},${controller.longitude.value}';
                launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              } else {
                controller.getLocationAndFetch();
              }
            },
            icon: Icon(
              LucideIcons.map,
              color: context.theme.colorScheme.onSurface,
            ),
            tooltip: 'Lihat Peta',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildCurrentLocation(context),
            const SizedBox(height: 18),
            _buildListMosque(context),
          ],
        ),
      ),
    );
  }

  Widget _buildListMosque(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Daftar Masjid Terdekat",
              style: pSemiBold14.copyWith(
                color: AppColor.globalTextSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Obx(() {
                if (controller.isPermissionError.value) {
                  return _buildPermissionDeniedView(context);
                }

                if (controller.errorMessage.isNotEmpty) {
                  return _buildErrorView(context);
                }

                if (controller.isLoading.value && controller.mosques.isEmpty) {
                  return _buildShimmerLoading(context);
                }

                if (controller.mosques.isEmpty) {
                  return _buildEmptyStateView(context);
                }

                return RefreshIndicator(
                  onRefresh: () => controller.fetchNearbyMosques(
                    controller.latitude.value,
                    controller.longitude.value,
                  ),
                  color: AppColor.primaryColor,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: controller.mosques.length,
                    itemBuilder: (context, index) {
                      final mosque = controller.mosques[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColor.globalBorder),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: InkWell(
                          onTap: () {
                             final url = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(mosque.name)}+${mosque.latitude},${mosque.longitude}';
                             launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                          },
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(mosque.name, style: pSemiBold12),
                                    const SizedBox(height: 4),
                                    Text(
                                      mosque.address,
                                      style: pSemiBold10.copyWith(
                                        color: AppColor.globalTextSecondary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Text(
                                          mosque.distance < 1000
                                              ? '${mosque.distance.toStringAsFixed(0)}m'
                                              : '${(mosque.distance / 1000).toStringAsFixed(1)}km',
                                          style: pSemiBold10,
                                        ),
                                        const SizedBox(width: 6),
                                        Icon(
                                          Icons.star_rounded,
                                          size: 14,
                                          color: AppColor.secondaryColor,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(mosque.rating?.toString() ?? "-", style: pSemiBold10),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 22),
                              InkWell(
                                onTap: () {
                                   final url = 'https://www.google.com/maps/dir/?api=1&destination=${mosque.latitude},${mosque.longitude}';
                                   launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColor.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(LucideIcons.send, size: 18, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentLocation(BuildContext context) {
    return Container(
      width: Get.width,
      margin: const EdgeInsets.all(14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.globalBorder),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Lokasi kamu sekarang", style: pMedium12),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Obx(
                  () => Text(
                    controller.currentAddress.value.isEmpty 
                      ? "Mencari lokasi..." 
                      : controller.currentAddress.value,
                    style: pSemiBold12.copyWith(
                      color: AppColor.globalTextSecondary,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 22),
              Obx(() {
                 if (controller.isLocating.value) {
                    return SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColor.globalTextSecondary),
                      ),
                    );
                 }
                 return InkWell(
                  onTap: () => controller.getLocationAndFetch(),
                  child: Icon(
                    LucideIcons.refreshCcw,
                    color: AppColor.globalTextSecondary,
                    size: 18,
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.isDarkMode
          ? Colors.grey.shade800
          : Colors.grey.shade200,
      highlightColor: context.isDarkMode
          ? Colors.grey.shade700
          : Colors.grey.shade100,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColor.globalBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: 150,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 12,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 22),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPermissionDeniedView(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.mapPinOff,
                color: AppColor.globalTextSecondary,
                size: 54,
              ),
              const SizedBox(height: 24),
              Text(
                'Akses Lokasi Dibutuhkan',
                style: pSemiBold16.copyWith(
                  color: context.theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                controller.errorMessage.value,
                style: pMedium14.copyWith(color: AppColor.globalTextSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => controller.getLocationAndFetch(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Coba Lagi',
                  style: pSemiBold14.copyWith(color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => controller.openAppSettings(),
                child: Text(
                  'Buka Pengaturan',
                  style: pSemiBold14.copyWith(color: AppColor.primaryColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyStateView(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.mapPinOff,
                color: AppColor.globalTextSecondary,
                size: 54,
              ),
              const SizedBox(height: 24),
              Text(
                'Masjid Tidak Ditemukan',
                style: pSemiBold16.copyWith(
                  color: context.theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Tidak ditemukan masjid terdekat di area sekitar Anda.',
                style: pMedium14.copyWith(color: AppColor.globalTextSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => controller.getLocationAndFetch(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Muat Ulang',
                  style: pSemiBold14.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.info,
                color: Colors.red,
                size: 54,
              ),
              const SizedBox(height: 24),
              Text(
                'Terjadi Kesalahan',
                style: pSemiBold16.copyWith(
                  color: context.theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                controller.errorMessage.value,
                style: pMedium14.copyWith(color: AppColor.globalTextSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => controller.getLocationAndFetch(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Coba Lagi',
                  style: pSemiBold14.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
