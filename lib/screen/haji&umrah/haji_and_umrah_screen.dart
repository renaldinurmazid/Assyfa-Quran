import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:quran_app/models/haji_umrah_package_model.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';
import 'package:quran_app/screen/haji&umrah/haji_and_umrah_controller.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:iconly/iconly.dart';

class HajiAndUmrahScreen extends StatelessWidget {
  const HajiAndUmrahScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HajiAndUmrahController());

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Program Umrah', style: pBold16),
        centerTitle: true,
        backgroundColor: context.theme.scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Hero Banner
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.primaryColorDark.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: AppColor.primaryColorDark.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.verified_rounded,
                              size: 12,
                              color: AppColor.primaryColorDark,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Assyfa Tour & Travel Partner',
                              style: pSemiBold10.copyWith(
                                color: AppColor.primaryColorDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pilih Paket Umrah Terbaik',
                    style: pBold20.copyWith(
                      color: context.theme.colorScheme.onSurface,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Layanan Ibadah Umrah dengan fasilitas premium & pembimbing terpercaya.',
                    style: pRegular12.copyWith(
                      color: context.theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar & Filter Button Inline
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: controller.searchController,
                        style: pRegular14,
                        decoration: InputDecoration(
                          hintText: 'Cari paket Umrah...',
                          hintStyle: pRegular14.copyWith(
                            color: context.isDarkMode
                                ? Colors.grey[500]
                                : Colors.grey[400],
                          ),
                          prefixIcon: Icon(
                            IconlyLight.search,
                            size: 20,
                            color: context.isDarkMode
                                ? Colors.grey[500]
                                : Colors.grey[400],
                          ),
                          suffixIcon: Obx(
                            () => controller.searchQuery.value.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      size: 18,
                                      color: context.isDarkMode
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                    ),
                                    onPressed: () {
                                      controller.searchController.clear();
                                      controller.searchQuery.value = '';
                                      controller.fetchUmrahPackages(
                                        refresh: true,
                                      );
                                    },
                                  )
                                : const SizedBox.shrink(),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 20,
                          ),
                          filled: true,
                          fillColor: context.theme.colorScheme.surface,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(100),
                            borderSide: BorderSide(
                              color: context.isDarkMode
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade200,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(100),
                            borderSide: const BorderSide(
                              color: AppColor.primaryColorDark,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          controller.searchQuery.value = value;
                          controller.debounceSearch();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: context.theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: context.isDarkMode
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {
                        Get.bottomSheet(
                          _bottomSheetFilter(context, controller),
                          isScrollControlled: true,
                        );
                      },
                      icon: Icon(
                        IconlyLight.filter,
                        color: AppColor.primaryColorDark,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Horizontal Filter Chips
            Obx(() {
              final sort = controller.selectedSort.value;
              final city = controller.selectedCityId.value;
              final month = controller.selectedMonthLabel.value;
              return Container(
                height: 38,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildFilterChip(
                      context: context,
                      label: 'Semua',
                      isSelected:
                          sort == 1 && city == 'Semua' && month == 'Semua',
                      onTap: () {
                        controller.resetFilters();
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      context: context,
                      label: 'Harga Terendah',
                      isSelected:
                          sort == 1 &&
                          (city != 'Semua' || month != 'Semua' || sort == 1),
                      onTap: () {
                        controller.selectedSort.value = 1;
                        controller.applyFilter();
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      context: context,
                      label: 'Keberangkatan Terdekat',
                      isSelected: sort == 2,
                      onTap: () {
                        controller.selectedSort.value = 2;
                        controller.applyFilter();
                      },
                    ),
                    const SizedBox(width: 8),
                    if (city != 'Semua') ...[
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        context: context,
                        label: 'Kota: $city',
                        isSelected: true,
                        onTap: () {
                          controller.selectedCityId.value = 'Semua';
                          controller.applyFilter();
                        },
                      ),
                    ],
                    if (month != 'Semua') ...[
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        context: context,
                        label: 'Bulan: $month',
                        isSelected: true,
                        onTap: () {
                          controller.selectedMonthLabel.value = 'Semua';
                          controller.applyFilter();
                        },
                      ),
                    ],
                  ],
                ),
              );
            }),

            // Package List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value &&
                    controller.packagesList.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColor.primaryColorDark,
                      ),
                    ),
                  );
                }

                final packages = controller.packagesList;

                if (packages.isEmpty) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Container(
                      height: context.height * 0.6,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColor.primaryColorDark.withOpacity(
                                0.05,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              IconlyLight.info_square,
                              size: 48,
                              color: AppColor.primaryColorDark,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text('Tidak Ada Paket', style: pBold16),
                          const SizedBox(height: 8),
                          Text(
                            'Tidak ada paket Umrah yang sesuai dengan filter atau kata kunci pencarian Anda.',
                            textAlign: TextAlign.center,
                            style: pRegular12.copyWith(
                              color: context.theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              controller.resetFilters();
                              controller.searchController.clear();
                              controller.searchQuery.value = '';
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.primaryColorDark,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                            child: Text(
                              'Reset Pencarian & Filter',
                              style: pMedium14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => controller.fetchUmrahPackages(refresh: true),
                  color: AppColor.primaryColorDark,
                  child: CustomScrollView(
                    controller: controller.scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 0.54,
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final package = packages[index];
                            return _buildPackageCard(context, package);
                          }, childCount: packages.length),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Obx(() {
                          if (controller.isLoadingMore.value) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColor.primaryColorDark,
                                  ),
                                ),
                              ),
                            );
                          } else if (!controller.hasMoreData.value &&
                              packages.isNotEmpty) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: 24,
                                top: 8,
                              ),
                              child: Center(
                                child: Text(
                                  'Sudah menampilkan semua paket',
                                  style: pRegular12.copyWith(
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        }),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColor.primaryColor
              : (context.isDarkMode
                    ? Colors.grey.shade900
                    : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected
                ? AppColor.primaryColor
                : (context.isDarkMode
                      ? Colors.grey.shade800
                      : Colors.grey.shade200),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: pSemiBold12.copyWith(
            color: isSelected
                ? Colors.white
                : context.theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildPackageCard(
    BuildContext context,
    HajiUmrahPackageModel package,
  ) {
    // final int quota = package.quota ?? 0;
    final int quotaLeft = package.quotaLeft ?? 0;
    final bool isLowQuota = quotaLeft > 0 && quotaLeft <= 5;

    return GestureDetector(
      onTap: () {
        if (package.id != null) {
          Get.toNamed(Routes.hajiAndUmrahDetail, arguments: package.id);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: context.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: context.isDarkMode
                ? Colors.grey.shade800
                : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Image & Badges
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: package.bannerImageUrl,
                    height: 125,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 125,
                      color: context.isDarkMode
                          ? Colors.grey[900]
                          : Colors.grey[100],
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColor.primaryColorDark,
                            ),
                          ),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 125,
                      color: context.isDarkMode
                          ? Colors.grey[900]
                          : Colors.grey[100],
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 24),
                      ),
                    ),
                  ),
                ),
                // Top-Left Badge (Duration) - Styled elegantly with gold/green theme
                if (package.durationDays != null && package.durationDays! > 0)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.primaryColor,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '${package.durationDays} Hari',
                        style: pBold10.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                // Top-Right Badge (Flight Detail / Airline Logo abbreviation)
                if (package.flightDetail != null &&
                    package.flightDetail!.isNotEmpty)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        package.flightDetail!,
                        style: pSemiBold10.copyWith(color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title
                    Text(
                      package.title ?? '',
                      style: pSemiBold12.copyWith(
                        color: context.theme.colorScheme.onSurface,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Location Info Row
                        Row(
                          children: [
                            Icon(
                              IconlyLight.location,
                              size: 12,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                (package.departureCity != null &&
                                        package.departureCity!.isNotEmpty)
                                    ? package.departureCity!
                                    : 'Kota Info menyusul',
                                style: pMedium10.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Calendar Info Row
                        Row(
                          children: [
                            Icon(
                              IconlyLight.calendar,
                              size: 12,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                package.umrahDetail?.departureDateFormatted ??
                                    'Jadwal menyusul',
                                style: pRegular10.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const Divider(height: 12, thickness: 0.5),

                    // Quota and Pricing Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Quota badge/text (Series A Urgency feature)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Sisa Slot',
                              style: pRegular10.copyWith(
                                color: Colors.grey.shade500,
                              ),
                            ),
                            Text(
                              quotaLeft > 0 ? '$quotaLeft Slot' : 'Habis',
                              style: pBold10.copyWith(
                                color: isLowQuota
                                    ? Colors.amber.shade900
                                    : AppColor.primaryColorDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Pricing
                        Text(
                          'Harga Mulai',
                          style: pRegular10.copyWith(color: Colors.grey[500]),
                        ),
                        Text(
                          (package.priceFormatted != null &&
                                  package.priceFormatted!.isNotEmpty)
                              ? package.priceFormatted!
                              : 'Hubungi kami',
                          style: pBold14.copyWith(
                            color: AppColor.primaryColorDark,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomSheetFilter(
    BuildContext context,
    HajiAndUmrahController controller,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 48,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header with Reset
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filter & Urutkan', style: pBold16),
              TextButton(
                onPressed: () {
                  controller.resetFilters();
                  Get.back();
                },
                child: Text(
                  'Reset Semua',
                  style: pBold14.copyWith(color: Colors.red.shade700),
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          const SizedBox(height: 8),
          Text('Urutkan Berdasarkan', style: pSemiBold14),
          const SizedBox(height: 8),
          _buildSortOption(controller, "Harga Terendah", 1),
          _buildSortOption(controller, "Waktu berangkat paling awal", 2),
          _buildSortOption(controller, "Waktu berangkat paling akhir", 3),
          const SizedBox(height: 16),
          Text('Bulan Keberangkatan', style: pSemiBold14),
          const SizedBox(height: 8),
          Obx(
            () => DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: controller.selectedMonthLabel.value,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: context.isDarkMode
                        ? Colors.grey.shade800
                        : Colors.grey.shade200,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: context.isDarkMode
                        ? Colors.grey.shade800
                        : Colors.grey.shade200,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColor.primaryColorDark,
                  ),
                ),
                filled: true,
                fillColor: context.isDarkMode
                    ? Colors.grey.shade900
                    : Colors.grey.shade50,
              ),
              items: [
                DropdownMenuItem<String>(
                  value: 'Semua',
                  child: Text('Semua Bulan', style: pMedium14),
                ),
                ...controller.apiMonths.map((month) {
                  final label = month['label']?.toString() ?? '';
                  return DropdownMenuItem<String>(
                    value: label,
                    child: Text(label, style: pRegular14),
                  );
                }),
              ],
              onChanged: (value) {
                if (value != null) {
                  controller.selectedMonthLabel.value = value;
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          Text('Kota Keberangkatan', style: pSemiBold14),
          const SizedBox(height: 8),
          Obx(() {
            final cityName = _getSelectedCityName(controller);
            return InkWell(
              onTap: () {
                Get.bottomSheet(
                  CitySearchBottomSheet(controller: controller),
                  isScrollControlled: true,
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: context.isDarkMode
                      ? Colors.grey.shade900
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: context.isDarkMode
                        ? Colors.grey.shade800
                        : Colors.grey.shade200,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      cityName,
                      style: pRegular14.copyWith(
                        color: context.theme.colorScheme.onSurface,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.grey.shade500,
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColorDark,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              elevation: 0,
            ),
            onPressed: () {
              controller.applyFilter();
              Get.back();
            },
            child: Text(
              'Terapkan Filter',
              style: pSemiBold14.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortOption(
    HajiAndUmrahController controller,
    String label,
    int value,
  ) {
    return InkWell(
      onTap: () {
        controller.selectedSort.value = value;
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: pRegular14),
            Obx(
              () => Radio<int>(
                value: value,
                groupValue: controller.selectedSort.value,
                activeColor: AppColor.primaryColorDark,
                onChanged: (val) {
                  if (val != null) {
                    controller.selectedSort.value = val;
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSelectedCityName(HajiAndUmrahController controller) {
    final selectedId = controller.selectedCityId.value;
    if (selectedId == 'Semua') {
      return 'Semua Kota';
    }
    final city = controller.apiCities.firstWhereOrNull(
      (c) => c['id']?.toString() == selectedId,
    );
    return city?['name']?.toString() ?? 'Semua Kota';
  }
}

class CitySearchBottomSheet extends StatefulWidget {
  final HajiAndUmrahController controller;
  const CitySearchBottomSheet({super.key, required this.controller});

  @override
  State<CitySearchBottomSheet> createState() => _CitySearchBottomSheetState();
}

class _CitySearchBottomSheetState extends State<CitySearchBottomSheet> {
  late final TextEditingController _searchController;
  final RxString _searchCityQuery = ''.obs;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 48,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text('Pilih Kota Keberangkatan', style: pBold16),
          const SizedBox(height: 12),
          // Search Input Field
          TextField(
            controller: _searchController,
            onChanged: (val) => _searchCityQuery.value = val,
            decoration: InputDecoration(
              hintText: 'Cari kota...',
              prefixIcon: const Icon(IconlyLight.search, size: 20),
              suffixIcon: Obx(() {
                if (_searchCityQuery.value.isNotEmpty) {
                  return IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      _searchController.clear();
                      _searchCityQuery.value = '';
                    },
                  );
                }
                return const SizedBox.shrink();
              }),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100),
                borderSide: BorderSide(
                  color: context.isDarkMode
                      ? Colors.grey.shade800
                      : Colors.grey.shade200,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100),
                borderSide: BorderSide(
                  color: context.isDarkMode
                      ? Colors.grey.shade800
                      : Colors.grey.shade200,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100),
                borderSide: const BorderSide(color: AppColor.primaryColorDark),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // List of Cities
          Expanded(
            child: Obx(() {
              final query = _searchCityQuery.value.toLowerCase();
              final filteredCities = widget.controller.apiCities.where((city) {
                final name = (city['name']?.toString() ?? '').toLowerCase();
                return name.contains(query);
              }).toList();

              return ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  // 'Semua Kota' option, matching search query if it fits
                  if (query.isEmpty ||
                      'semua kota'.contains(query) ||
                      'semua'.contains(query))
                    _buildCityListTile(
                      context: context,
                      name: 'Semua Kota',
                      isSelected: widget.controller.selectedCityId.value == 'Semua',
                      onTap: () {
                        widget.controller.selectedCityId.value = 'Semua';
                        Get.back();
                      },
                    ),

                  ...filteredCities.map((city) {
                    final id = city['id']?.toString() ?? '';
                    final name = city['name']?.toString() ?? '';
                    final isSelected = widget.controller.selectedCityId.value == id;
                    return _buildCityListTile(
                      context: context,
                      name: name,
                      isSelected: isSelected,
                      onTap: () {
                        widget.controller.selectedCityId.value = id;
                        Get.back();
                      },
                    );
                  }),

                  if (filteredCities.isEmpty &&
                      query.isNotEmpty &&
                      !('semua kota'.contains(query) ||
                          'semua'.contains(query)))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32.0),
                      child: Center(
                        child: Text(
                          'Kota tidak ditemukan',
                          style: pRegular14.copyWith(color: Colors.grey),
                        ),
                      ),
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCityListTile({
    required BuildContext context,
    required String name,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      title: Text(
        name,
        style: isSelected
            ? pSemiBold14.copyWith(color: AppColor.primaryColorDark)
            : pRegular14,
      ),
      trailing: isSelected
          ? const Icon(
              Icons.check_circle,
              color: AppColor.primaryColorDark,
              size: 20,
            )
          : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
