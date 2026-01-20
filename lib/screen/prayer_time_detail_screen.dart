import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:quran_app/controller/pick_location_controller.dart';
import 'package:quran_app/controller/prayer_time_detail_controller.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';
import 'package:quran_app/widgets/text_input.dart';

class PrayerTimeDetailScreen extends StatelessWidget {
  const PrayerTimeDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PrayerTimeDetailController());

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                // Header Background Image & Gradient
                Container(
                  height: 320,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/png/bg-palestine.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          AppColor.primaryColor.withOpacity(0.9),
                          AppColor.primaryColor.withOpacity(0.4),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Header Content
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        // Top Bar (Back Button & Location)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () => Get.back(),
                              icon: const Icon(
                                IconlyLight.arrow_left,
                                color: Colors.white,
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.2),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Get.dialog(_selectOptionLocation()),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      IconlyBold.location,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Obx(
                                      () => Text(
                                        '${controller.kabKota.value}',
                                        style: pMedium12.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      IconlyLight.arrow_down_2,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        // Next Prayer Info
                        Obx(
                          () => Text(
                            controller.nextPrayerName.value,
                            style: pMedium16.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Obx(
                          () => Text(
                            controller.nextPrayerTime.value,
                            style: pBold24.copyWith(
                              color: Colors.white,
                              fontSize: 48,
                              height: 1.1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Obx(
                          () => AnimatedOpacity(
                            opacity: controller.isPrayerArrived.value
                                ? (controller.showHeartbeat.value ? 1.0 : 0.4)
                                : 1.0,
                            duration: const Duration(milliseconds: 400),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Text(
                                controller.countdown.value,
                                style: pSemiBold14.copyWith(
                                  color: Colors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Transition
                Positioned(
                  bottom: -1,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 30,
                    decoration: const BoxDecoration(
                      color: AppColor.backgroundColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Date & Calendar Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColor.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        IconlyLight.calendar,
                        color: AppColor.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                          () => Text(
                            controller.calendarToday.value,
                            style: pSemiBold16.copyWith(
                              color: AppColor.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Obx(
                          () => Text(
                            controller.calendarMasehi.value,
                            style: pRegular12.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Prayer Times Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Jadwal Waktu Sholat',
                    style: pSemiBold18.copyWith(color: AppColor.primaryColor),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // Prayer Times List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Obx(() {
                final jadwal = controller.jadwalToday;
                final prayerTimes = [
                  {
                    'name': 'Imsak',
                    'icon': IconlyLight.time_circle,
                    'time': jadwal['imsak'] ?? '-',
                  },
                  {
                    'name': 'Subuh',
                    'icon': Icons.wb_twilight_rounded,
                    'time': jadwal['subuh'] ?? '-',
                  },
                  {
                    'name': 'Terbit',
                    'icon': Icons.wb_sunny_outlined,
                    'time': jadwal['terbit'] ?? '-',
                  },
                  {
                    'name': 'Dhuhur',
                    'icon': Icons.wb_sunny_rounded,
                    'time': jadwal['dzuhur'] ?? '-',
                  },
                  {
                    'name': 'Asar',
                    'icon': Icons.wb_cloudy_rounded,
                    'time': jadwal['ashar'] ?? '-',
                  },
                  {
                    'name': 'Maghrib',
                    'icon': Icons.wb_twilight_outlined,
                    'time': jadwal['maghrib'] ?? '-',
                  },
                  {
                    'name': 'Isya',
                    'icon': IconlyLight.discovery,
                    'time': jadwal['isya'] ?? '-',
                  },
                ];

                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: 30),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: prayerTimes.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final prayerTime = prayerTimes[index];
                    final isNext =
                        controller.nextPrayerName.value.toLowerCase() ==
                        (prayerTime['name'] as String).toLowerCase();

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isNext
                            ? AppColor.primaryColor.withOpacity(0.05)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isNext
                              ? AppColor.primaryColor.withOpacity(0.2)
                              : Colors.grey.shade100,
                          width: 1.5,
                        ),
                        boxShadow: [
                          if (!isNext)
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isNext
                                  ? AppColor.primaryColor
                                  : AppColor.primaryColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              prayerTime['icon'] as IconData,
                              color: isNext
                                  ? Colors.white
                                  : AppColor.primaryColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            prayerTime['name'] as String,
                            style: pMedium16.copyWith(
                              color: isNext
                                  ? AppColor.primaryColor
                                  : AppColor.textColor,
                              fontWeight: isNext
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            prayerTime['time'] as String,
                            style: pSemiBold16.copyWith(
                              color: isNext
                                  ? AppColor.primaryColor
                                  : AppColor.textColor,
                            ),
                          ),
                          if (isNext) ...[
                            const SizedBox(width: 8),
                            const Icon(
                              IconlyBold.volume_up,
                              color: AppColor.primaryColor,
                              size: 16,
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _selectOptionLocation() {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColor.backgroundColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColor.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                IconlyBold.location,
                color: AppColor.primaryColor,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            Text('Pilih Lokasi', style: pBold18),
            const SizedBox(height: 8),
            Text(
              'Tentukan lokasi untuk mendapatkan\njadwal sholat yang akurat',
              textAlign: TextAlign.center,
              style: pRegular12.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Get.back();
                final pickController = Get.put(PickLocationController());
                pickController.useCurrentLocation();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              child: Text(
                'Gunakan Lokasi Saat Ini',
                style: pSemiBold14.copyWith(color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                Get.back();
                Get.bottomSheet(_searchLocation(), isScrollControlled: true);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColor.primaryColor,
                side: const BorderSide(
                  color: AppColor.primaryColor,
                  width: 1.5,
                ),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text('Cari Kota Manual', style: pSemiBold14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchLocation() {
    final controller = Get.put(PickLocationController());
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppColor.backgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text('Cari Lokasi Kota', style: pBold18),
              const SizedBox(height: 20),
              TextInput(
                controller: controller.searchController,
                hintText: 'Masukkan nama kota...',
                onChanged: controller.onSearch,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColor.primaryColor,
                      ),
                    );
                  } else if (controller.listCity.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            IconlyLight.info_circle,
                            size: 48,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Kota tidak ditemukan',
                            style: pRegular14.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: controller.listCity.length,
                      itemBuilder: (context, index) {
                        final city = controller.listCity[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColor.primaryColor.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              IconlyLight.location,
                              color: AppColor.primaryColor,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            city.lokasi,
                            style: pMedium14.copyWith(
                              color: AppColor.primaryColor,
                            ),
                          ),
                          trailing: const Icon(
                            IconlyLight.arrow_right_2,
                            size: 16,
                            color: Colors.grey,
                          ),
                          onTap: () {
                            Get.back();
                            controller.saveIdCity(city.id);
                          },
                        );
                      },
                    );
                  }
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
