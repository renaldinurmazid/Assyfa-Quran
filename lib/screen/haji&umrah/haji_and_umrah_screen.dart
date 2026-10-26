import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/models/haji_umrah_package_model.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';
import 'package:quran_app/screen/haji&umrah/haji_and_umrah_controller.dart';
import 'package:quran_app/routes/app_routes.dart';

class HajiAndUmrahScreen extends StatelessWidget {
  const HajiAndUmrahScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HajiAndUmrahController());

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        title: Text("Program Umrah", style: pSemiBold16),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(LucideIcons.arrowLeft, color: context.theme.colorScheme.onSurface),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search and Filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: _SearchField(controller: controller),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => Get.bottomSheet(
                      _FilterSheet(controller: controller),
                      isScrollControlled: true,
                    ),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: context.theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColor.globalBorder,
                        ),
                      ),
                      child: const Icon(
                        LucideIcons.slidersHorizontal,
                        color: AppColor.primaryColor,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: Get.width,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Pilih Paket Umrah",
                      style: pSemiBold14.copyWith(
                        color: AppColor.globalTextSecondary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      "Fasilitas premium dengan pembimbing terpercaya",
                      style: pMedium12.copyWith(
                        color: AppColor.globalTextSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Package List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.packagesList.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColor.primaryColor,
                      strokeWidth: 2,
                    ),
                  );
                }

                final packages = controller.packagesList;

                if (packages.isEmpty) {
                  return _EmptyState(controller: controller);
                }

                return RefreshIndicator(
                  onRefresh: () => controller.fetchUmrahPackages(refresh: true),
                  color: AppColor.primaryColor,
                  child: ListView.builder(
                    controller: controller.scrollController,
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    itemCount: packages.length + 1,
                    itemBuilder: (context, index) {
                      if (index == packages.length) {
                        return Obx(() {
                          if (controller.isLoadingMore.value) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColor.primaryColor,
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          }
                          if (!controller.hasMoreData.value && packages.isNotEmpty) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 28, top: 4),
                              child: Center(
                                child: Text(
                                  'Semua paket sudah ditampilkan',
                                  style: pMedium12.copyWith(
                                    color: AppColor.globalTextSecondary,
                                  ),
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        });
                      }

                      return _PackageCard(package: packages[index]);
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
}

class _PackageCard extends StatelessWidget {
  final HajiUmrahPackageModel package;
  
  const _PackageCard({required this.package});

  @override
  Widget build(BuildContext context) {
    double progress = 0.0;
    if (package.quota != null && package.quotaLeft != null && package.quota! > 0) {
      int sold = package.quota! - package.quotaLeft!;
      progress = sold / package.quota!;
    }
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(2),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.globalBorder),
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        onTap: () {
          if (package.id != null) {
            Get.toNamed(Routes.hajiAndUmrahDetail, arguments: package.id);
          }
        },
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: CachedNetworkImage(
                imageUrl: package.bannerImageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 180,
                  color: context.theme.colorScheme.surface,
                ),
                errorWidget: (context, url, error) => Container(
                  height: 180,
                  color: context.theme.colorScheme.surface,
                  child: Icon(LucideIcons.imageOff, color: AppColor.globalTextSecondary),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    package.title ?? '',
                    style: pSemiBold14.copyWith(
                      color: AppColor.globalTextSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        LucideIcons.calendar,
                        color: AppColor.globalTextSecondary,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        package.umrahDetail?.departureDateFormatted ?? 'Jadwal menyusul',
                        style: pMedium12.copyWith(
                          color: AppColor.globalTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        LucideIcons.mapPin,
                        color: AppColor.globalTextSecondary,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        package.departureCity ?? 'Menyusul',
                        style: pMedium12.copyWith(
                          color: AppColor.globalTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  LinearProgressIndicator(
                    borderRadius: BorderRadius.circular(14),
                    color: AppColor.primaryColor,
                    minHeight: 6,
                    value: progress,
                    backgroundColor: AppColor.globalBorder,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Mulai dari",
                            style: pMedium10.copyWith(
                              color: AppColor.globalTextSecondary,
                            ),
                          ),
                          Text(
                            package.priceFormatted ?? 'Hubungi kami',
                            style: pSemiBold14.copyWith(
                              color: AppColor.globalTextSecondary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "Sisa kuota",
                            style: pMedium10.copyWith(
                              color: AppColor.globalTextSecondary,
                            ),
                          ),
                          Text(
                            "${package.quotaLeft ?? 0}",
                            style: pSemiBold14.copyWith(
                              color: package.quotaLeft == 0 ? Colors.red : AppColor.globalTextSecondary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Search Field ──────────────────────────────────────────────────────────────

class _SearchField extends StatelessWidget {
  final HajiAndUmrahController controller;
  const _SearchField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller.searchController,
      style: pMedium14.copyWith(
        color: context.theme.colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        hintText: 'Cari paket umrah',
        hintStyle: pMedium14.copyWith(
          color: AppColor.globalTextSecondary,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(
          LucideIcons.search,
          size: 20,
          color: AppColor.globalTextSecondary,
        ),
        suffixIcon: Obx(
          () => controller.searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    LucideIcons.x,
                    size: 17,
                    color: AppColor.globalTextSecondary,
                  ),
                  onPressed: () {
                    controller.searchController.clear();
                    controller.searchQuery.value = '';
                    controller.fetchUmrahPackages(refresh: true);
                  },
                )
              : const SizedBox.shrink(),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 18,
        ),
        filled: false,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColor.globalBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColor.primaryColor),
        ),
      ),
      onChanged: (v) {
        controller.searchQuery.value = v;
        controller.debounceSearch();
      },
    );
  }
}

// ─── Filter Bottom Sheet ──────────────────────────────────────────────────────

class _FilterSheet extends StatelessWidget {
  final HajiAndUmrahController controller;
  const _FilterSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        8,
        20,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20, top: 4),
              decoration: BoxDecoration(
                color: AppColor.globalBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter & Urutkan',
                style: pSemiBold16.copyWith(
                  color: context.theme.colorScheme.onSurface,
                ),
              ),
              GestureDetector(
                onTap: () {
                  controller.resetFilters();
                  Get.back();
                },
                child: Text(
                  'Reset',
                  style: pSemiBold14.copyWith(
                    color: Colors.red.shade400,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Sort
          Text(
            'Urutkan',
            style: pSemiBold14.copyWith(
              color: context.theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          ...[
            _SortOption('Harga Terendah', 1, controller),
            _SortOption('Keberangkatan Terdekat', 2, controller),
            _SortOption('Keberangkatan Terjauh', 3, controller),
          ],
          const SizedBox(height: 20),

          // Month
          Text(
            'Bulan Keberangkatan',
            style: pSemiBold14.copyWith(
              color: context.theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Obx(
            () => DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: controller.selectedMonthLabel.value,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 13,
                ),
                filled: true,
                fillColor: context.theme.colorScheme.surface,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: AppColor.globalBorder,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColor.primaryColor),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: AppColor.globalBorder,
                  ),
                ),
              ),
              items: [
                DropdownMenuItem<String>(
                  value: 'Semua',
                  child: Text('Semua Bulan', style: pMedium14),
                ),
                ...controller.apiMonths.map((m) {
                  final label = m['label']?.toString() ?? '';
                  return DropdownMenuItem<String>(
                    value: label,
                    child: Text(label, style: pMedium14),
                  );
                }),
              ],
              onChanged: (v) {
                if (v != null) controller.selectedMonthLabel.value = v;
              },
            ),
          ),
          const SizedBox(height: 20),

          // City
          Text(
            'Kota Keberangkatan',
            style: pSemiBold14.copyWith(
              color: context.theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Obx(() {
            final selected = controller.selectedCityId.value;
            final city = controller.apiCities.firstWhereOrNull(
              (c) => c['id']?.toString() == selected,
            );
            final cityName = city?['name']?.toString() ?? 'Semua Kota';

            return GestureDetector(
              onTap: () => Get.bottomSheet(
                CitySearchBottomSheet(controller: controller),
                isScrollControlled: true,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColor.globalBorder,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selected == 'Semua' ? 'Semua Kota' : cityName,
                      style: pMedium14.copyWith(
                        color: context.theme.colorScheme.onSurface,
                      ),
                    ),
                    Icon(
                      LucideIcons.chevronDown,
                      color: AppColor.globalTextSecondary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 24),

          // Apply Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                controller.applyFilter();
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Terapkan',
                style: pSemiBold14.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  final String label;
  final int value;
  final HajiAndUmrahController controller;
  const _SortOption(this.label, this.value, this.controller);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GestureDetector(
        onTap: () => controller.selectedSort.value = value,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: controller.selectedSort.value == value
                      ? AppColor.primaryColor
                      : Colors.transparent,
                  border: Border.all(
                    color: controller.selectedSort.value == value
                        ? AppColor.primaryColor
                        : AppColor.globalBorder,
                    width: 1.5,
                  ),
                ),
                child: controller.selectedSort.value == value
                    ? const Icon(LucideIcons.check, size: 12, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: pMedium14.copyWith(
                  color: context.theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── City Search Bottom Sheet ─────────────────────────────────────────────────

class CitySearchBottomSheet extends StatefulWidget {
  final HajiAndUmrahController controller;
  const CitySearchBottomSheet({super.key, required this.controller});

  @override
  State<CitySearchBottomSheet> createState() => _CitySearchBottomSheetState();
}

class _CitySearchBottomSheetState extends State<CitySearchBottomSheet> {
  late final TextEditingController _searchCtrl;
  final _query = ''.obs;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
      decoration: BoxDecoration(
        color: context.theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20, top: 4),
              decoration: BoxDecoration(
                color: AppColor.globalBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Text(
            'Pilih Kota',
            style: pSemiBold16.copyWith(
              color: context.theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 14),

          // Search
          TextField(
            controller: _searchCtrl,
            style: pMedium14.copyWith(
              color: context.theme.colorScheme.onSurface,
            ),
            onChanged: (v) => _query.value = v,
            decoration: InputDecoration(
              hintText: 'Cari kota...',
              hintStyle: pMedium14.copyWith(color: AppColor.globalTextSecondary),
              prefixIcon: Icon(
                LucideIcons.search,
                size: 19,
                color: AppColor.globalTextSecondary,
              ),
              suffixIcon: Obx(
                () => _query.value.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          LucideIcons.x,
                          size: 17,
                          color: AppColor.globalTextSecondary,
                        ),
                        onPressed: () {
                          _searchCtrl.clear();
                          _query.value = '';
                        },
                      )
                    : const SizedBox.shrink(),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              filled: true,
              fillColor: context.theme.colorScheme.surface,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: AppColor.globalBorder,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColor.primaryColor),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // City List
          Expanded(
            child: Obx(() {
              final q = _query.value.toLowerCase();
              final filtered = widget.controller.apiCities.where((c) {
                return (c['name']?.toString() ?? '')
                    .toLowerCase()
                    .contains(q);
              }).toList();

              final showAll = q.isEmpty ||
                  'semua kota'.contains(q) ||
                  'semua'.contains(q);

              return ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  if (showAll)
                    _CityTile(
                      name: 'Semua Kota',
                      isSelected:
                          widget.controller.selectedCityId.value == 'Semua',
                      onTap: () {
                        widget.controller.selectedCityId.value = 'Semua';
                        Get.back();
                      },
                    ),
                  ...filtered.map((city) {
                    final id = city['id']?.toString() ?? '';
                    final name = city['name']?.toString() ?? '';
                    return _CityTile(
                      name: name,
                      isSelected:
                          widget.controller.selectedCityId.value == id,
                      onTap: () {
                        widget.controller.selectedCityId.value = id;
                        Get.back();
                      },
                    );
                  }),
                  if (filtered.isEmpty && !showAll)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text(
                          'Kota tidak ditemukan',
                          style: pMedium14.copyWith(
                            color: AppColor.globalTextSecondary,
                          ),
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
}

class _CityTile extends StatelessWidget {
  final String name;
  final bool isSelected;
  final VoidCallback onTap;
  const _CityTile({
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      title: Text(
        name,
        style: isSelected
            ? pSemiBold14.copyWith(color: AppColor.primaryColor)
            : pMedium14.copyWith(
                color: context.theme.colorScheme.onSurface,
              ),
      ),
      trailing: isSelected
          ? const Icon(LucideIcons.checkCircle2, color: AppColor.primaryColor, size: 20)
          : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

// ─── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final HajiAndUmrahController controller;
  const _EmptyState({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColor.primaryColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.telescope,
                size: 32,
                color: AppColor.primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Paket Tidak Ditemukan',
              style: pSemiBold16.copyWith(
                color: context.theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coba ubah filter atau kata kunci pencarian Anda.',
              textAlign: TextAlign.center,
              style: pMedium12.copyWith(
                color: AppColor.globalTextSecondary,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  controller.resetFilters();
                  controller.searchController.clear();
                  controller.searchQuery.value = '';
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Reset Filter',
                  style: pSemiBold14.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
