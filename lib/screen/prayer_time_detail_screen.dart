import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:quran_app/controller/pick_location_controller.dart';
import 'package:quran_app/controller/prayer_time_detail_controller.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';

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
                              onTap: () {
                                final pickController = Get.put(
                                  PickLocationController(),
                                );
                                pickController.useCurrentLocation();
                              },
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
                                      IconlyLight.swap,
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
                    'time': jadwal['fajr'] ?? '-',
                  },
                  {
                    'name': 'Terbit',
                    'icon': Icons.wb_sunny_outlined,
                    'time': jadwal['sunrise'] ?? '-',
                  },
                  {
                    'name': 'Dhuhur',
                    'icon': Icons.wb_sunny_rounded,
                    'time': jadwal['dhuhr'] ?? '-',
                  },
                  {
                    'name': 'Asar',
                    'icon': Icons.wb_cloudy_rounded,
                    'time': jadwal['asr'] ?? '-',
                  },
                  {
                    'name': 'Maghrib',
                    'icon': Icons.wb_twilight_outlined,
                    'time': jadwal['maghrib'] ?? '-',
                  },
                  {
                    'name': 'Isya',
                    'icon': IconlyLight.discovery,
                    'time': jadwal['isha'] ?? '-',
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
                          const SizedBox(width: 18),
                          Obx(() {
                            final prayerName = prayerTime['name'] as String;
                            final defaultValue =
                                controller.isImsakOrTerbit(prayerName)
                                ? 'silent'
                                : 'adzan';
                            final setting =
                                controller.notificationSettings[prayerName] ??
                                defaultValue;

                            IconData iconData;
                            if (setting == 'silent') {
                              iconData = IconlyBold.volume_off;
                            } else if (setting == 'beep') {
                              iconData = IconlyBold.volume_up;
                            } else {
                              iconData = IconlyBold.voice;
                            }

                            return InkWell(
                              onTap: () {
                                Get.dialog(_selectNotification(prayerName));
                              },
                              child: Icon(
                                iconData,
                                color: AppColor.primaryColor,
                                size: 20,
                              ),
                            );
                          }),
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

  Widget _selectNotification(String prayerName) {
    final controller = Get.find<PrayerTimeDetailController>();
    bool isImsakOrTerbit = controller.isImsakOrTerbit(prayerName);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Obx(() {
          final currentSetting =
              controller.notificationSettings[prayerName] ??
              (isImsakOrTerbit ? 'silent' : 'adzan');

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      IconlyBold.notification,
                      color: AppColor.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notifikasi $prayerName',
                          style: pBold16.copyWith(color: AppColor.textColor),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pilih suara notifikasi waktu sholat',
                          style: pRegular12.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildNotificationOption(
                title: 'Diam',
                icon: IconlyBold.volume_off,
                value: 'silent',
                groupValue: currentSetting,
                onChanged: (val) {
                  if (val != null) {
                    controller.saveNotificationSetting(prayerName, val);
                    Get.back();
                  }
                },
              ),
              const SizedBox(height: 12),
              _buildNotificationOption(
                title: 'Beep',
                icon: IconlyBold.volume_up,
                value: 'beep',
                groupValue: currentSetting,
                onChanged: (val) {
                  if (val != null) {
                    controller.saveNotificationSetting(prayerName, val);
                    Get.back();
                  }
                },
              ),
              if (!isImsakOrTerbit) ...[
                const SizedBox(height: 12),
                _buildNotificationOption(
                  title: 'Adzan',
                  icon: IconlyBold.voice,
                  value: 'adzan',
                  groupValue: currentSetting,
                  onChanged: (val) {
                    if (val != null) {
                      controller.saveNotificationSetting(prayerName, val);
                      Get.back();
                    }
                  },
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: pSemiBold14.copyWith(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildNotificationOption({
    required String title,
    required IconData icon,
    required String value,
    required String groupValue,
    required Function(String?) onChanged,
  }) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColor.primaryColor.withOpacity(0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColor.primaryColor : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColor.primaryColor : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: isSelected
                    ? pSemiBold14.copyWith(color: AppColor.primaryColor)
                    : pMedium14.copyWith(color: AppColor.textColor),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColor.primaryColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
