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
                Container(
                  height: 280,
                  alignment: Alignment.center,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/png/bg-palestine.png'),
                      colorFilter: ColorFilter.mode(
                        Color.fromARGB(120, 0, 0, 0),
                        BlendMode.srcOver,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Obx(
                        () => Text(
                          controller.nextPrayerName.value,
                          style: pMedium16.copyWith(color: Colors.white),
                        ),
                      ),
                      Obx(
                        () => Text(
                          controller.nextPrayerTime.value,
                          style: pBold24.copyWith(
                            color: Colors.white,
                            fontSize: 32,
                          ),
                        ),
                      ),
                      Obx(
                        () => AnimatedOpacity(
                          opacity: controller.isPrayerArrived.value
                              ? (controller.showHeartbeat.value ? 1.0 : 0.3)
                              : 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            controller.countdown.value,
                            style: pRegular16.copyWith(
                              color: Colors.white,
                              fontWeight: controller.isPrayerArrived.value
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            IconlyBold.location,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 5),
                          Obx(
                            () => Text(
                              '${controller.kabKota.value}, ${controller.provinsi.value}',
                              style: pRegular16.copyWith(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Get.dialog(_selectOptionLocation());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: const BorderSide(color: Colors.white),
                          maximumSize: const Size(100, 30),
                          minimumSize: const Size(100, 30),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                        ),
                        child: Text(
                          'Ubah Lokasi',
                          style: pMedium10.copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 80,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, AppColor.backgroundColor],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Obx(() => Text(controller.calendarToday.value, style: pMedium16)),
            const SizedBox(height: 5),
            Obx(() => Text(controller.calendarMasehi.value, style: pRegular12)),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Obx(() {
                final jadwal = controller.jadwalToday;
                final prayerTimes = [
                  {
                    'name': 'Imsak',
                    'icon': Icons.nightlight_round,
                    'time': jadwal['imsak'] ?? '-',
                  },
                  {
                    'name': 'Subuh',
                    'icon': Icons.wb_twilight,
                    'time': jadwal['subuh'] ?? '-',
                  },
                  {
                    'name': 'Terbit',
                    'icon': Icons.wb_sunny_outlined,
                    'time': jadwal['terbit'] ?? '-',
                  },
                  {
                    'name': 'Dhuhur',
                    'icon': Icons.wb_sunny,
                    'time': jadwal['dzuhur'] ?? '-',
                  },
                  {
                    'name': 'Asar',
                    'icon': Icons.wb_sunny_outlined,
                    'time': jadwal['ashar'] ?? '-',
                  },
                  {
                    'name': 'Maghrib',
                    'icon': Icons.wb_twilight,
                    'time': jadwal['maghrib'] ?? '-',
                  },
                  {
                    'name': 'Isya',
                    'icon': Icons.nightlight,
                    'time': jadwal['isya'] ?? '-',
                  },
                ];

                return ListView.separated(
                  padding: const EdgeInsets.all(0),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final prayerTime = prayerTimes[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Icon(
                            prayerTime['icon'] as IconData,
                            color: AppColor.primaryColor,
                          ),
                          const SizedBox(width: 10),
                          Text(prayerTime['name'] as String, style: pMedium16),
                          const Spacer(),
                          Text(prayerTime['time'] as String, style: pMedium16),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 10);
                  },
                  itemCount: prayerTimes.length,
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
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColor.backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Pilih Lokasi', style: pMedium16),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final pickController = Get.put(PickLocationController());
                pickController.useCurrentLocation();
              },
              style: ButtonStyle(
                maximumSize: WidgetStatePropertyAll(
                  const Size(double.infinity, 40),
                ),
                minimumSize: WidgetStatePropertyAll(
                  const Size(double.infinity, 40),
                ),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                backgroundColor: WidgetStatePropertyAll(AppColor.primaryColor),
              ),
              child: Text(
                'Lokasi Terkini',
                style: pRegular14.copyWith(color: AppColor.backgroundColor),
              ),
            ),
            const SizedBox(height: 6),
            ElevatedButton(
              onPressed: () {
                Get.back();
                Get.bottomSheet(_searchLocation());
              },
              style: ButtonStyle(
                maximumSize: WidgetStatePropertyAll(
                  const Size(double.infinity, 40),
                ),
                minimumSize: WidgetStatePropertyAll(
                  const Size(double.infinity, 40),
                ),
                side: WidgetStatePropertyAll(
                  const BorderSide(color: AppColor.primaryColor),
                ),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                backgroundColor: WidgetStatePropertyAll(
                  AppColor.backgroundColor,
                ),
              ),
              child: Text(
                'Cari Lokasi',
                style: pRegular14.copyWith(color: AppColor.primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchLocation() {
    final controller = Get.put(PickLocationController());
    return Container(
      height: Get.size.height * 0.6,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.backgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextInput(
            controller: controller.searchController,
            hintText: 'Cari Lokasi',
            onChanged: controller.onSearch,
          ),
          const SizedBox(height: 20),
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: AppColor.primaryColor),
              );
            } else {
              return Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: controller.listCity.length,
                  itemBuilder: (context, index) {
                    final city = controller.listCity[index];
                    return ListTile(
                      title: Text(
                        city.lokasi,
                        style: pMedium14.copyWith(color: AppColor.primaryColor),
                      ),
                      onTap: () {
                        Get.back();
                        controller.saveIdCity(city.id);
                      },
                    );
                  },
                ),
              );
            }
          }),
        ],
      ),
    );
  }
}
