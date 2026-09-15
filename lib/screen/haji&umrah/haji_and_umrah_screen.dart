import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:quran_app/models/haji_umrah_package_model.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';
import 'package:quran_app/screen/haji&umrah/haji_and_umrah_controller.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:iconly/iconly.dart';

// ─── Design Tokens ─────────────────────────────────────────────────────────────
const _kSurfaceDark = Color(0xFF16161A);
const _kSurfaceLight = Colors.white;
const _kBorderDark = Color(0xFF242428);
const _kBorderLight = Color(0xFFEAECF0);
const _kSubtleDark = Color(0xFF1E1E24);
const _kSubtleLight = Color(0xFFF0F2F5);
const _kPrimary = AppColor.primaryColorDark;

class HajiAndUmrahScreen extends StatelessWidget {
  const HajiAndUmrahScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HajiAndUmrahController());
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0D0F) : const Color(0xFFF6F7F9),
      appBar: AppBar(
        title: Text(
          'Program Umrah',
          style: pSemiBold16.copyWith(
            color: context.theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF0D0D0F) : const Color(0xFFF6F7F9),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Center(
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isDark ? _kSubtleDark : _kSubtleLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                IconlyLight.arrow_left,
                size: 18,
                color: context.theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pilih Paket Umrah',
                    style: pBold20.copyWith(
                      color: context.theme.colorScheme.onSurface,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Fasilitas premium dengan pembimbing terpercaya.',
                    style: pRegular12.copyWith(
                      color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),

            // ── Search + Filter ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: _SearchField(
                      controller: controller,
                      isDark: isDark,
                    ),
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
                        color: isDark ? _kSurfaceDark : _kSurfaceLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? _kBorderDark : _kBorderLight,
                        ),
                      ),
                      child: const Icon(
                        IconlyLight.filter,
                        color: _kPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Quick Filter Chips ──────────────────────────────────────────
            Obx(() {
              final sort = controller.selectedSort.value;
              final city = controller.selectedCityId.value;
              final month = controller.selectedMonthLabel.value;
              final chips = <_ChipData>[
                _ChipData(
                  label: 'Semua',
                  selected: sort == 1 && city == 'Semua' && month == 'Semua',
                  onTap: controller.resetFilters,
                ),
                _ChipData(
                  label: 'Harga Termurah',
                  selected: sort == 1 &&
                      (city != 'Semua' || month != 'Semua' || sort == 1),
                  onTap: () {
                    controller.selectedSort.value = 1;
                    controller.applyFilter();
                  },
                ),
                _ChipData(
                  label: 'Terdekat',
                  selected: sort == 2,
                  onTap: () {
                    controller.selectedSort.value = 2;
                    controller.applyFilter();
                  },
                ),
                if (city != 'Semua')
                  _ChipData(
                    label: '× $city',
                    selected: true,
                    onTap: () {
                      controller.selectedCityId.value = 'Semua';
                      controller.applyFilter();
                    },
                  ),
                if (month != 'Semua')
                  _ChipData(
                    label: '× $month',
                    selected: true,
                    onTap: () {
                      controller.selectedMonthLabel.value = 'Semua';
                      controller.applyFilter();
                    },
                  ),
              ];
              return SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: chips.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => _QuickChip(
                    data: chips[i],
                    isDark: isDark,
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),

            // ── Package List ────────────────────────────────────────────────
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value &&
                    controller.packagesList.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: _kPrimary,
                      strokeWidth: 2,
                    ),
                  );
                }

                final packages = controller.packagesList;

                if (packages.isEmpty) {
                  return _EmptyState(controller: controller, isDark: isDark);
                }

                return RefreshIndicator(
                  onRefresh: () =>
                      controller.fetchUmrahPackages(refresh: true),
                  color: _kPrimary,
                  child: CustomScrollView(
                    controller: controller.scrollController,
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: 0.56,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (ctx, i) => _PackageCard(
                              package: packages[i],
                              isDark: isDark,
                            ),
                            childCount: packages.length,
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Obx(() {
                          if (controller.isLoadingMore.value) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: _kPrimary,
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          }
                          if (!controller.hasMoreData.value &&
                              packages.isNotEmpty) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 28, top: 4),
                              child: Center(
                                child: Text(
                                  'Semua paket sudah ditampilkan',
                                  style: pRegular12.copyWith(
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
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
}

// ─── Search Field ──────────────────────────────────────────────────────────────

class _SearchField extends StatelessWidget {
  final HajiAndUmrahController controller;
  final bool isDark;
  const _SearchField({required this.controller, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller.searchController,
      style: pRegular14.copyWith(
        color: context.theme.colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        hintText: 'Cari paket Umrah...',
        hintStyle: pRegular14.copyWith(
          color: Colors.grey.shade500,
        ),
        prefixIcon: Icon(
          IconlyLight.search,
          size: 19,
          color: Colors.grey.shade500,
        ),
        suffixIcon: Obx(
          () => controller.searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    size: 17,
                    color: Colors.grey.shade500,
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
          vertical: 13,
          horizontal: 18,
        ),
        filled: true,
        fillColor: isDark ? _kSurfaceDark : _kSurfaceLight,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? _kBorderDark : _kBorderLight,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _kPrimary),
        ),
      ),
      onChanged: (v) {
        controller.searchQuery.value = v;
        controller.debounceSearch();
      },
    );
  }
}

// ─── Quick Chip ────────────────────────────────────────────────────────────────

class _ChipData {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ChipData({
    required this.label,
    required this.selected,
    required this.onTap,
  });
}

class _QuickChip extends StatelessWidget {
  final _ChipData data;
  final bool isDark;
  const _QuickChip({required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: data.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
        decoration: BoxDecoration(
          color: data.selected
              ? _kPrimary
              : (isDark ? _kSurfaceDark : _kSurfaceLight),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: data.selected
                ? _kPrimary
                : (isDark ? _kBorderDark : _kBorderLight),
          ),
        ),
        child: Text(
          data.label,
          style: pSemiBold12.copyWith(
            color: data.selected
                ? Colors.white
                : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

// ─── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final HajiAndUmrahController controller;
  final bool isDark;
  const _EmptyState({required this.controller, required this.isDark});

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
                color: _kPrimary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                IconlyLight.discovery,
                size: 32,
                color: _kPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Paket Tidak Ditemukan',
              style: pBold16.copyWith(
                color: context.theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coba ubah filter atau kata kunci pencarian Anda.',
              textAlign: TextAlign.center,
              style: pRegular12.copyWith(
                color: Colors.grey.shade500,
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
                  backgroundColor: _kPrimary,
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

// ─── Package Card ──────────────────────────────────────────────────────────────

class _PackageCard extends StatelessWidget {
  final HajiUmrahPackageModel package;
  final bool isDark;
  const _PackageCard({required this.package, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final quotaLeft = package.quotaLeft ?? 0;
    final isLowQuota = quotaLeft > 0 && quotaLeft <= 5;
    final isSoldOut = quotaLeft == 0;

    return GestureDetector(
      onTap: () {
        if (package.id != null) {
          Get.toNamed(Routes.hajiAndUmrahDetail, arguments: package.id);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? _kSurfaceDark : _kSurfaceLight,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? _kBorderDark : _kBorderLight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Banner Image ─────────────────────────────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(17),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: package.bannerImageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      height: 120,
                      color: isDark ? _kBorderDark : _kBorderLight,
                    ),
                    errorWidget: (_, __, ___) => Container(
                      height: 120,
                      color: isDark ? _kBorderDark : _kBorderLight,
                      child: Icon(
                        Icons.broken_image_outlined,
                        size: 28,
                        color:
                            isDark ? Colors.grey.shade700 : Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),
                // Duration badge
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
                        color: _kPrimary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${package.durationDays}H',
                        style: pBold10.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                // Flight badge
                if (package.flightDetail != null &&
                    package.flightDetail!.isNotEmpty)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        package.flightDetail!,
                        style: pSemiBold10.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
            ),

            // ── Content ──────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      package.title ?? '',
                      style: pSemiBold12.copyWith(
                        color: context.theme.colorScheme.onSurface,
                        height: 1.4,
                        fontSize: 12.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Location row
                    _iconRow(
                      icon: IconlyLight.location,
                      label: (package.departureCity != null &&
                              package.departureCity!.isNotEmpty)
                          ? package.departureCity!
                          : 'Menyusul',
                    ),
                    const SizedBox(height: 4),

                    // Date row
                    _iconRow(
                      icon: IconlyLight.calendar,
                      label: package.umrahDetail?.departureDateFormatted ??
                          'Jadwal menyusul',
                    ),

                    const Spacer(),

                    // Divider
                    Divider(
                      height: 1,
                      color: isDark ? _kBorderDark : _kBorderLight,
                    ),
                    const SizedBox(height: 10),

                    // Quota
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sisa Slot',
                          style: pRegular10.copyWith(
                            color: Colors.grey.shade500,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          isSoldOut
                              ? 'Habis'
                              : '$quotaLeft slot',
                          style: pSemiBold10.copyWith(
                            color: isSoldOut
                                ? Colors.red.shade400
                                : isLowQuota
                                    ? Colors.amber.shade700
                                    : _kPrimary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Price
                    Text(
                      'Mulai dari',
                      style: pRegular10.copyWith(
                        color: Colors.grey.shade500,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      (package.priceFormatted != null &&
                              package.priceFormatted!.isNotEmpty)
                          ? package.priceFormatted!
                          : 'Hubungi kami',
                      style: pBold14.copyWith(
                        color: _kPrimary,
                        height: 1.2,
                        fontSize: 13.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

  Widget _iconRow({required IconData icon, required String label}) {
    return Row(
      children: [
        Icon(icon, size: 11, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            label,
            style: pRegular10.copyWith(
              color: Colors.grey.shade500,
              fontSize: 10.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ─── Filter Bottom Sheet ──────────────────────────────────────────────────────

class _FilterSheet extends StatelessWidget {
  final HajiAndUmrahController controller;
  const _FilterSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        8,
        20,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16161A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: isDark ? _kBorderDark : _kBorderLight,
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
                fillColor: isDark ? _kSubtleDark : _kSubtleLight,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: isDark ? _kBorderDark : _kBorderLight,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _kPrimary),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              items: [
                DropdownMenuItem<String>(
                  value: 'Semua',
                  child: Text('Semua Bulan', style: pRegular14),
                ),
                ...controller.apiMonths.map((m) {
                  final label = m['label']?.toString() ?? '';
                  return DropdownMenuItem<String>(
                    value: label,
                    child: Text(label, style: pRegular14),
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
                  color: isDark ? _kSubtleDark : _kSubtleLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? _kBorderDark : _kBorderLight,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selected == 'Semua' ? 'Semua Kota' : cityName,
                      style: pRegular14.copyWith(
                        color: context.theme.colorScheme.onSurface,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.grey.shade500,
                      size: 22,
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
                backgroundColor: _kPrimary,
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
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: controller.selectedSort.value == value
                      ? _kPrimary
                      : Colors.transparent,
                  border: Border.all(
                    color: controller.selectedSort.value == value
                        ? _kPrimary
                        : Colors.grey.shade400,
                    width: 1.5,
                  ),
                ),
                child: controller.selectedSort.value == value
                    ? const Icon(Icons.check, size: 12, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: pRegular14.copyWith(
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
    final isDark = context.isDarkMode;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16161A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: isDark ? _kBorderDark : _kBorderLight,
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
            style: pRegular14.copyWith(
              color: context.theme.colorScheme.onSurface,
            ),
            onChanged: (v) => _query.value = v,
            decoration: InputDecoration(
              hintText: 'Cari kota...',
              hintStyle: pRegular14.copyWith(color: Colors.grey.shade500),
              prefixIcon: Icon(
                IconlyLight.search,
                size: 19,
                color: Colors.grey.shade500,
              ),
              suffixIcon: Obx(
                () => _query.value.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          size: 17,
                          color: Colors.grey.shade500,
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
              fillColor: isDark ? _kSubtleDark : _kSubtleLight,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: isDark ? _kBorderDark : _kBorderLight,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _kPrimary),
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
                          style: pRegular14.copyWith(
                            color: Colors.grey.shade500,
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
            ? pSemiBold14.copyWith(color: _kPrimary)
            : pRegular14.copyWith(
                color: context.theme.colorScheme.onSurface,
              ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: _kPrimary, size: 20)
          : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
