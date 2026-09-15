import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:quran_app/screen/mosque/pick_location_controller.dart';
import 'package:quran_app/screen/prayer_time/prayer_time_detail_controller.dart';
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
                                      color: Colors.white.withValues(
                                        alpha: 0.3,
                                      ),
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
                        color: context.theme.colorScheme.primary.withValues(
                          alpha: 0.1,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        IconlyLight.calendar,
                        color: context.theme.colorScheme.primary,
                        size: 20,
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
                              style: pSemiBold14.copyWith(
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

            // Battery & Alarm Optimization Banner (if restricted on Android)
            Obx(() {
              final needsBattery = controller.isBatteryOptimized.value;
              final needsAlarm = !controller.isExactAlarmGranted.value;

              if (!needsBattery && !needsAlarm) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.amber.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.amber,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Optimasi Notifikasi Adzan',
                            style: pSemiBold14.copyWith(
                              color: context.isDarkMode
                                  ? Colors.amber.shade200
                                  : Colors.amber.shade900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Agar suara adzan selalu bunyi tepat waktu meski aplikasi ditutup, matikan penghemat baterai dan izinkan alarm tepat.',
                        style: pRegular12.copyWith(
                          color: context.theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (needsBattery)
                            ElevatedButton.icon(
                              onPressed: () => controller
                                  .requestDisableBatteryOptimization(),
                              icon: const Icon(Icons.battery_saver, size: 16),
                              label: const Text('Matikan Hemat Baterai'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    context.theme.colorScheme.primary,
                                foregroundColor: Colors.white,
                                textStyle: pMedium12,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          if (needsAlarm)
                            OutlinedButton.icon(
                              onPressed: () =>
                                  controller.checkAndRequestExactAlarm(),
                              icon: const Icon(Icons.alarm, size: 16),
                              label: const Text('Izinkan Alarm Tepat'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor:
                                    context.theme.colorScheme.primary,
                                textStyle: pMedium12,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),

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
                  Text('Jadwal Waktu Sholat', style: pSemiBold14),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Prayer Times List Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: context.isDarkMode
                        ? Colors.grey.shade800
                        : Colors.grey.shade200,
                  ),
                ),
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
                      'icon': Icons.alarm_rounded,
                      'time': jadwal['dhuhr'] ?? '-',
                    },
                    {
                      'name': 'Asar',
                      'icon': Icons.cloud_outlined,
                      'time': jadwal['asr'] ?? '-',
                    },
                    {
                      'name': 'Maghrib',
                      'icon': Icons.nightlight_round,
                      'time': jadwal['maghrib'] ?? '-',
                    },
                    {
                      'name': 'Isya',
                      'icon': IconlyLight.discovery,
                      'time': jadwal['isha'] ?? '-',
                    },
                  ];

                  return Column(
                    children: List.generate(prayerTimes.length, (index) {
                      final prayerTime = prayerTimes[index];
                      final prayerName = prayerTime['name'] as String;
                      final isLast = index == prayerTimes.length - 1;

                      final defaultValue =
                          controller.isImsakOrTerbit(prayerName)
                          ? 'silent'
                          : 'adzan';
                      final currentSetting =
                          controller.notificationSettings[prayerName] ??
                          defaultValue;
                      final isEnabled = currentSetting != 'silent';

                      return Column(
                        children: [
                          InkWell(
                            onTap: () {
                              Get.dialog(
                                _selectNotification(context, prayerName),
                              );
                            },
                            borderRadius: BorderRadius.vertical(
                              top: index == 0
                                  ? const Radius.circular(24)
                                  : Radius.zero,
                              bottom: isLast
                                  ? const Radius.circular(24)
                                  : Radius.zero,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 14,
                              ),
                              child: Row(
                                children: [
                                  // Squircle Icon
                                  Container(
                                    height: 44,
                                    width: 44,
                                    decoration: BoxDecoration(
                                      color: isEnabled
                                          ? context.theme.colorScheme.primary
                                                .withValues(alpha: 0.1)
                                          : (context.isDarkMode
                                                ? Colors.grey.shade800
                                                : const Color(0xFFF3F4F6)),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      prayerTime['icon'] as IconData,
                                      color: isEnabled
                                          ? context.theme.colorScheme.primary
                                          : (context.isDarkMode
                                                ? Colors.grey.shade500
                                                : Colors.grey.shade400),
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  // Prayer Name and Time
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          prayerName,
                                          style: pSemiBold14.copyWith(
                                            color: context
                                                .theme
                                                .colorScheme
                                                .onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          prayerTime['time'] as String,
                                          style: pMedium12.copyWith(
                                            color: context
                                                .theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Toggle Switch
                                  Transform.scale(
                                    scale: 0.88,
                                    child: Switch(
                                      value: isEnabled,
                                      activeColor: Colors.white,
                                      activeTrackColor:
                                          context.theme.colorScheme.primary,
                                      inactiveThumbColor: Colors.white,
                                      inactiveTrackColor: context.isDarkMode
                                          ? Colors.grey.shade700
                                          : const Color(0xFFE5E7EB),
                                      trackOutlineColor:
                                          WidgetStateProperty.all(
                                            Colors.transparent,
                                          ),
                                      onChanged: (val) {
                                        if (val) {
                                          controller.saveNotificationSetting(
                                            prayerName,
                                            controller.isImsakOrTerbit(
                                                  prayerName,
                                                )
                                                ? 'beep'
                                                : 'adzan',
                                          );
                                        } else {
                                          controller.saveNotificationSetting(
                                            prayerName,
                                            'silent',
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (!isLast)
                            Divider(
                              height: 1,
                              thickness: 1,
                              indent: 76,
                              endIndent: 18,
                              color: context.isDarkMode
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade100,
                            ),
                        ],
                      );
                    }),
                  );
                }),
              ),
            ),
            const SizedBox(height: 40),
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
                      color: context.theme.colorScheme.primary.withValues(
                        alpha: 0.1,
                      ),
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
