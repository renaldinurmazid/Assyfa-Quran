import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/screen/theme/theme_controller.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';
import 'package:quran_app/controller/global/auth_controller.dart';

// ─── Color tokens ─────────────────────────────────────────────────────────────
const _kBgDark = Color(0xFF0F0F10);
const _kBgLight = Color(0xFFF8FAFC);
const _kSurfaceDark = Color(0xFF18181B);
const _kSurfaceLight = Colors.white;
const _kBorderDark = Color(0xFF27272A);
const _kBorderLight = Color(0xFFE2E8F0);

class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ThemeController.to;
    final isDark = context.isDarkMode;
    final primary = isDark ? AppColor.primaryColorDark : AppColor.primaryColor;

    return Scaffold(
      backgroundColor: isDark ? _kBgDark : _kBgLight,
      appBar: AppBar(
        title: Text(
          'Pengaturan Tema',
          style: pSemiBold16.copyWith(
            color: context.theme.colorScheme.onSurface,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            LucideIcons.arrowLeft,
            size: 18,
            color: context.theme.colorScheme.onSurface,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? _kSurfaceDark : _kSurfaceLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? _kBorderDark : _kBorderLight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isDark
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      color: primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mode Gelap',
                          style: pSemiBold12.copyWith(
                            color: context.theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Aktifkan untuk kenyamanan mata di malam hari',
                          style: pRegular10.copyWith(
                            color: isDark
                                ? Colors.grey.shade500
                                : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Obx(
                    () => Switch(
                      value: controller.isDarkMode,
                      onChanged: (_) => controller.toggleTheme(),
                      activeColor: primary,
                      activeTrackColor: primary.withValues(alpha: 0.25),
                      inactiveThumbColor: Colors.grey.shade400,
                      inactiveTrackColor: isDark
                          ? const Color(0xFF3F3F46)
                          : Colors.grey.shade200,
                    ),
                  ),
                ],
              ),
            ),

            // Background section (only for logged-in users)
            Obx(() {
              if (!AuthController.to.isLogin.value) {
                return const SizedBox.shrink();
              }

              return Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Text(
                          'Background Pilihan',
                          style: pSemiBold14.copyWith(
                            color: context.theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      child: Obx(() {
                        if (controller.isLoadingBackgrounds.value &&
                            controller.backgrounds.isEmpty) {
                          return Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  primary,
                                ),
                              ),
                            ),
                          );
                        }

                        return RefreshIndicator(
                          onRefresh: () async => controller.fetchBackgrounds(),
                          color: primary,
                          backgroundColor: isDark
                              ? _kSurfaceDark
                              : _kSurfaceLight,
                          child: controller.backgrounds.isEmpty
                              ? ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  children: [
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                          0.35,
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 64,
                                              height: 64,
                                              decoration: BoxDecoration(
                                                color: isDark
                                                    ? const Color(0xFF27272A)
                                                    : const Color(0xFFF8FAFC),
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: isDark
                                                      ? _kBorderDark
                                                      : _kBorderLight,
                                                ),
                                              ),
                                              child: Icon(
                                                IconlyLight.image,
                                                size: 26,
                                                color: isDark
                                                    ? Colors.grey.shade600
                                                    : Colors.grey.shade400,
                                              ),
                                            ),
                                            const SizedBox(height: 14),
                                            Text(
                                              'Tidak ada background tersedia',
                                              style: pSemiBold12.copyWith(
                                                color: isDark
                                                    ? Colors.grey.shade500
                                                    : Colors.grey.shade500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : GridView.builder(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        childAspectRatio: 0.75,
                                        mainAxisSpacing: 10,
                                        crossAxisSpacing: 10,
                                      ),
                                  itemCount: controller.backgrounds.length,
                                  itemBuilder: (context, index) {
                                    final bg = controller.backgrounds[index];
                                    final isSelected =
                                        bg['is_selected'] ?? false;

                                    return GestureDetector(
                                      onTap: () =>
                                          controller.selectBackground(bg['id']),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: isSelected
                                                ? primary
                                                : isDark
                                                ? _kBorderDark
                                                : _kBorderLight,
                                            width: isSelected ? 2.5 : 1,
                                          ),
                                          image: DecorationImage(
                                            image: NetworkImage(bg['path']),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        child: isSelected
                                            ? Align(
                                                alignment: Alignment.topRight,
                                                child: Container(
                                                  margin: const EdgeInsets.all(
                                                    6,
                                                  ),
                                                  width: 22,
                                                  height: 22,
                                                  decoration: BoxDecoration(
                                                    color: primary,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.check_rounded,
                                                    color: Colors.white,
                                                    size: 14,
                                                  ),
                                                ),
                                              )
                                            : null,
                                      ),
                                    );
                                  },
                                ),
                        );
                      }),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
