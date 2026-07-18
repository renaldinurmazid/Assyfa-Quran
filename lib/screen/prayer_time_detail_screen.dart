import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:quran_app/controller/pick_location_controller.dart';
import 'package:quran_app/controller/prayer_time_detail_controller.dart';
import 'package:quran_app/theme/font.dart';
import 'package:quran_app/controller/global/auth_controller.dart';

class PrayerTimeDetailScreen extends StatelessWidget {
  const PrayerTimeDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PrayerTimeDetailController());

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Stack(
              children: [
                // Header Background Image & Gradient
                Obx(() {
                  final auth = AuthController.to;
                  final bgUrl = auth.userData['selected_background_path_url'];

                  return Container(
                    height: 320,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image:
                            (auth.isLogin.value &&
                                bgUrl != null &&
                                bgUrl.isNotEmpty)
                            ? NetworkImage(bgUrl) as ImageProvider
                            : const AssetImage(
                                'assets/images/png/bg-palestine.png',
                              ),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.9),
                            Colors.black.withValues(alpha: 0.5),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  );
                }),

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
                            Material(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: const CircleBorder(),
                              child: InkWell(
                                onTap: () => Get.back(),
                                customBorder: const CircleBorder(),
                                child: const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: Icon(
                                    IconlyLight.arrow_left,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                            Material(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(100),
                              child: InkWell(
                                onTap: () {
                                  final pickController = Get.put(
                                    PickLocationController(),
                                  );
                                  pickController.useCurrentLocation();
                                },
                                borderRadius: BorderRadius.circular(100),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      IconlyBold.location,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 8),
                                    Obx(
                                      () => Text(
                                        controller.kabKota.value,
                                        style: pSemiBold12.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(
                                      IconlyLight.swap,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  ],
                                ),
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
                            style: pMedium14.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Obx(
                          () => Text(
                            controller.nextPrayerTime.value,
                            style: pBold24.copyWith(
                              color: Colors.white,
                              fontSize: 56,
                              height: 1.1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Obx(
                          () => AnimatedOpacity(
                            opacity: controller.isPrayerArrived.value
                                ? (controller.showHeartbeat.value ? 1.0 : 0.5)
                                : 1.0,
                            duration: const Duration(milliseconds: 400),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                controller.countdown.value,
                                style: pSemiBold14.copyWith(
                                  color: Colors.white,
                                  letterSpacing: 0.5,
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
                    height: 32,
                    decoration: BoxDecoration(
                      color: context.theme.scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
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
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: context.isDarkMode
                        ? Colors.grey.shade800
                        : Colors.grey.shade100,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.theme.colorScheme.primary.withValues(alpha: 
                          0.1,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        IconlyLight.calendar,
                        color: context.theme.colorScheme.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(
                            () => Text(
                              controller.calendarToday.value,
                              style: pSemiBold16.copyWith(
                                color: context.theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Obx(
                            () => Text(
                              controller.calendarMasehi.value,
                              style: pRegular12.copyWith(
                                color:
                                    context.theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Prayer Times Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      color: context.theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Jadwal Waktu Sholat', style: pSemiBold16),
                ],
              ),
            ),

            const SizedBox(height: 16),

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
                  padding: const EdgeInsets.only(bottom: 40),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: prayerTimes.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final prayerTime = prayerTimes[index];
                    final isNext =
                        controller.nextPrayerName.value.toLowerCase() ==
                        (prayerTime['name'] as String).toLowerCase();

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isNext
                            ? context.theme.colorScheme.primary.withValues(alpha: 
                                0.05,
                              )
                            : context.theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isNext
                              ? context.theme.colorScheme.primary.withValues(alpha: 
                                  0.3,
                                )
                              : context.isDarkMode
                              ? Colors.grey.shade800
                              : Colors.grey.shade100,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isNext
                                  ? context.theme.colorScheme.primary
                                  : context.theme.colorScheme.primary
                                        .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              prayerTime['icon'] as IconData,
                              color: isNext
                                  ? Colors.white
                                  : context.theme.colorScheme.primary,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            prayerTime['name'] as String,
                            style: pSemiBold14.copyWith(
                              color: isNext
                                  ? context.theme.colorScheme.primary
                                  : context.theme.colorScheme.onSurface,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            prayerTime['time'] as String,
                            style: pSemiBold14.copyWith(
                              color: isNext
                                  ? context.theme.colorScheme.primary
                                  : context.theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: 16),
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

                            return IconButton(
                              onPressed: () {
                                Get.dialog(
                                  _selectNotification(context, prayerName),
                                );
                              },
                              icon: Icon(
                                iconData,
                                color: context.theme.colorScheme.primary,
                                size: 20,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 44,
                                minHeight: 44,
                              ),
                              padding: EdgeInsets.zero,
                              tooltip: 'Atur Notifikasi',
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

  Widget _selectNotification(BuildContext context, String prayerName) {
    final controller = Get.find<PrayerTimeDetailController>();
    bool isImsakOrTerbit = controller.isImsakOrTerbit(prayerName);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: context.theme.colorScheme.surface,
      child: Padding(
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
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: context.theme.colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      IconlyBold.notification,
                      color: context.theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Notifikasi $prayerName', style: pBold16),
                        const SizedBox(height: 2),
                        Text(
                          'Pilih suara untuk jadwal sholat',
                          style: pRegular12.copyWith(
                            color: context.theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildNotificationOption(
                context: context,
                title: 'Diam (Tanpa Suara)',
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
              const SizedBox(height: 10),
              _buildNotificationOption(
                context: context,
                title: 'Beep (Suara Pendek)',
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
                const SizedBox(height: 10),
                _buildNotificationOption(
                  context: context,
                  title: 'Adzan (Suara Penuh)',
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
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Get.back(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Tutup',
                    style: pSemiBold14.copyWith(
                      color: context.theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildNotificationOption({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String value,
    required String groupValue,
    required Function(String?) onChanged,
  }) {
    final isSelected = value == groupValue;
    return Material(
      color: isSelected
          ? context.theme.colorScheme.primary.withValues(alpha: 0.05)
          : context.theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? context.theme.colorScheme.primary
                  : context.isDarkMode
                  ? Colors.grey.shade800
                  : Colors.grey.shade100,
              width: 1.5,
            ),
          ),
          child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? context.theme.colorScheme.primary
                  : context.theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: isSelected
                    ? pSemiBold14.copyWith(
                        color: context.theme.colorScheme.primary,
                      )
                    : pMedium14.copyWith(
                        color: context.theme.colorScheme.onSurface,
                      ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: context.theme.colorScheme.primary,
                size: 18,
              ),
          ],
        ),
      ),
    ),
  );
}
}
