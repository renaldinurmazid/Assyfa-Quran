import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:quran_app/theme/font.dart';
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
        backgroundColor: context.theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            IconlyLight.arrow_left_2,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Masjid Terdekat',
          style: pBold16.copyWith(color: Theme.of(context).primaryColor),
        ),
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
            icon: Icon(Icons.map, color: Theme.of(context).primaryColor),
            tooltip: 'Lihat Peta',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Location Card
              _buildLocationHeaderCard(context),
              const SizedBox(height: 20),

              // Title Section
              Text(
                "Daftar Masjid Terdekat",
                style: pBold14.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),

              // List View / States (Loading, Error, Permission, Empty, Data)
              Expanded(
                child: Obx(() {
                  if (controller.isPermissionError.value) {
                    return _buildPermissionDeniedView(context);
                  }

                  if (controller.errorMessage.isNotEmpty) {
                    return _buildErrorView(context);
                  }

                  if (controller.isLoading.value &&
                      controller.mosques.isEmpty) {
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
                    color: Theme.of(context).primaryColor,
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: controller.mosques.length,
                      itemBuilder: (context, index) {
                        final mosque = controller.mosques[index];
                        return Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: context.isDarkMode
                                  ? Colors.grey.shade900
                                  : Colors.grey.shade200,
                            ),
                          ),
                          margin: const EdgeInsets.only(bottom: 12),
                          color: context.theme.colorScheme.surfaceContainer,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              final url =
                                  'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(mosque.name)}+${mosque.latitude},${mosque.longitude}';
                              launchUrl(
                                Uri.parse(url),
                                mode: LaunchMode.externalApplication,
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.mosque,
                                      color: Theme.of(context).primaryColor,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          mosque.name,
                                          style: pSemiBold14.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                            height: 1.2,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.location_on_outlined,
                                              size: 14,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                mosque.address,
                                                style: pRegular12.copyWith(
                                                  color: Colors.grey,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            // Distance Badge
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Theme.of(
                                                  context,
                                                ).primaryColor.withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                mosque.distance < 1000
                                                    ? '${mosque.distance.toStringAsFixed(0)} m'
                                                    : '${(mosque.distance / 1000).toStringAsFixed(1)} km',
                                                style: pBold10.copyWith(
                                                  color: Theme.of(
                                                    context,
                                                  ).primaryColor,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            // Rating
                                            if (mosque.rating != null) ...[
                                              const Icon(
                                                Icons.star_rounded,
                                                color: Colors.amber,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 2),
                                              Text(
                                                '${mosque.rating}',
                                                style: pBold12.copyWith(
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.onSurface,
                                                ),
                                              ),
                                              const SizedBox(width: 2),
                                              Text(
                                                '(${mosque.userRatingsTotal})',
                                                style: pRegular10.copyWith(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ] else ...[
                                              const Icon(
                                                Icons.star_border_rounded,
                                                color: Colors.grey,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 2),
                                              Text(
                                                'Belum ada penilaian',
                                                style: pRegular10.copyWith(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Directions Action Column
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          final url =
                                              'https://www.google.com/maps/dir/?api=1&destination=${mosque.latitude},${mosque.longitude}';
                                          launchUrl(
                                            Uri.parse(url),
                                            mode:
                                                LaunchMode.externalApplication,
                                          );
                                        },
                                        icon: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Theme.of(
                                              context,
                                            ).primaryColor,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.navigation_rounded,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                        tooltip: 'Rute',
                                      ),
                                      Text(
                                        'Rute',
                                        style: pMedium10.copyWith(
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
      ),
    );
  }

  Widget _buildLocationHeaderCard(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withOpacity(0.15), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(IconlyBold.location, color: primaryColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Lokasi Anda Saat Ini",
                  style: pMedium12.copyWith(
                    color: context.isDarkMode
                        ? Colors.grey.shade400
                        : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Obx(
                  () => Text(
                    controller.currentAddress.value,
                    style: pBold14.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Obx(() {
            if (controller.isLocating.value) {
              return SizedBox(
                width: 36,
                height: 36,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              );
            }
            return IconButton(
              onPressed: () => controller.getLocationAndFetch(),
              icon: Icon(
                Icons.refresh_rounded,
                color: Theme.of(context).primaryColor,
                size: 22,
              ),
              tooltip: 'Perbarui Lokasi',
            );
          }),
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
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: 150,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            height: 20,
                            width: 60,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            height: 16,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
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
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_off_rounded,
                  color: Colors.red,
                  size: 54,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Akses Lokasi Dibutuhkan',
                style: pBold16.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                controller.errorMessage.value,
                style: pRegular14.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => controller.getLocationAndFetch(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Coba Lagi',
                  style: pBold14.copyWith(color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => controller.openAppSettings(),
                child: Text(
                  'Buka Pengaturan',
                  style: pSemiBold14.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
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
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.mosque_outlined,
                  color: Theme.of(context).primaryColor,
                  size: 54,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Masjid Tidak Ditemukan',
                style: pBold16.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Tidak ditemukan masjid terdekat di area sekitar Anda.',
                style: pRegular14.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => controller.getLocationAndFetch(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Muat Ulang',
                  style: pBold14.copyWith(color: Colors.white),
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
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: Colors.red,
                  size: 54,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Terjadi Kesalahan',
                style: pBold16.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                controller.errorMessage.value,
                style: pRegular14.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => controller.getLocationAndFetch(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Coba Lagi',
                  style: pBold14.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
