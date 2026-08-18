import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/screen/theme/theme_controller.dart';
import 'package:quran_app/theme/font.dart';
import 'package:quran_app/controller/global/auth_controller.dart';

class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ThemeController.to;

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Pengaturan Tema', style: pSemiBold16),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: context.isDarkMode ? Colors.white : Colors.black87,
            size: 20,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.isDarkMode ? Colors.grey[900] : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.dark_mode_outlined,
                    color: context.theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mode Gelap', style: pSemiBold14),
                        Text(
                          'Aktifkan untuk kenyamanan mata di malam hari',
                          style: pRegular12.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Obx(
                    () => Switch(
                      value: controller.isDarkMode,
                      onChanged: (value) => controller.toggleTheme(),
                      activeThumbColor: context.theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            Obx(() {
              if (!AuthController.to.isLogin.value) {
                return const SizedBox.shrink();
              }

              return Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Text('Background Pilihan', style: pMedium14),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Obx(() {
                        if (controller.isLoadingBackgrounds.value &&
                            controller.backgrounds.isEmpty) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        return RefreshIndicator(
                          onRefresh: () async {
                            await controller.fetchBackgrounds();
                          },
                          color: context.theme.colorScheme.primary,
                          child: controller.backgrounds.isEmpty
                              ? ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  children: [
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                          0.4,
                                      child: const Center(
                                        child: Text(
                                          'Tidak ada background tersedia',
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
                                        childAspectRatio: 0.8,
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
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: isSelected
                                              ? Border.all(
                                                  color: context
                                                      .theme
                                                      .colorScheme
                                                      .primary,
                                                  width: 3,
                                                )
                                              : null,
                                          image: DecorationImage(
                                            image: NetworkImage(bg['path']),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        child: isSelected
                                            ? Align(
                                                alignment: Alignment.topRight,
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: context
                                                        .theme
                                                        .colorScheme
                                                        .primary,
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                          topRight:
                                                              Radius.circular(
                                                                8,
                                                              ),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                8,
                                                              ),
                                                        ),
                                                  ),
                                                  child: const Icon(
                                                    Icons.check,
                                                    color: Colors.white,
                                                    size: 16,
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
