import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/screen/dzikir&doa/list_doa_screen.dart';
import 'package:quran_app/screen/dzikir&doa/dzikir_screen_controller.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';
import 'package:quran_app/widgets/circular_progress_painter.dart';
import 'package:quran_app/widgets/text_input.dart';

class DzikirScreen extends StatelessWidget {
  const DzikirScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DzikirScreenController());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Panduan Dzikir', style: pSemiBold16),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Pilihan Dzikir & Doa',
              style: pBold18.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _buildMenuVarianDzikir(context),
            const SizedBox(height: 32),
            _buildTasbih(context, controller),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _bottomSheetDzikir(BuildContext context) {
    final data = [
      {
        'title': 'Dzikir Shalat Pendek',
        'slug': 'dzikir-shalat-pendek',
        'data': 'assets/data/dzikir-pendek.json',
      },
      {
        'title': 'Dzikir Shalat Panjang',
        'slug': 'dzikir-shalat-panjang',
        'data': 'assets/data/dzikir-panjang.json',
      },
    ];
    return _buildBottomSheetLayout(context, 'Dzikir Shalat', data);
  }

  Widget _bottomSheetAlmasurat(BuildContext context) {
    final data = [
      {
        'title': 'Al-Matsurat Sugro Pagi',
        'slug': 'almasurat-sugro-pagi',
        'data': 'assets/data/sugro-pagi.json',
      },
      {
        'title': 'Al-Matsurat Sugro Petang',
        'slug': 'almasurat-sugro-petang',
        'data': 'assets/data/sugro-petang.json',
      },
      {
        'title': 'Al-Matsurat Kubro Pagi',
        'slug': 'almasurat-kubro-pagi',
        'data': 'assets/data/kubro-pagi.json',
      },
      {
        'title': 'Al-Matsurat Kubro Petang',
        'slug': 'almasurat-kubro-petang',
        'data': 'assets/data/kubro-petang.json',
      },
    ];
    return _buildBottomSheetLayout(context, 'Al-Matsurat', data);
  }

  Widget _buildBottomSheetLayout(
    BuildContext context,
    String title,
    List<Map<String, String>> data,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 5,
              width: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: pBold18.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Get.find<DzikirScreenController>().recordDzikirView(
                      data[index]['slug']!,
                      data[index]['title']!,
                    );
                    Get.toNamed(
                      Routes.dzikirShow,
                      arguments: {
                        'title': data[index]['title'],
                        'data': data[index]['data'],
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColor.globalBorder),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            IconlyBold.document,
                            color: Theme.of(context).primaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            data[index]['title']!,
                            style: pSemiBold14.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                IconlyBold.show,
                                size: 14,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 6),
                              Obx(() {
                                final stats = Get.find<DzikirScreenController>()
                                    .dzikirStats;
                                final slug = data[index]['slug']!;
                                return Text(
                                  '${stats[slug] ?? 0}',
                                  style: pBold12.copyWith(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return const SizedBox(height: 12);
              },
              itemCount: data.length,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuVarianDzikir(BuildContext context) {
    final menu = [
      {
        'assets': 'assets/images/svg/ic-doa.svg',
        'title': 'Dzikir Shalat',
        'subtitle': 'Panduan dzikir setelah shalat',
        'isBottomSheet': true,
        'bottomSheet': _bottomSheetDzikir(context),
      },
      {
        'assets': 'assets/images/svg/ic-alma.svg',
        'title': 'Al-Matsurat',
        'subtitle': 'Pagi & Petang',
        'isBottomSheet': true,
        'bottomSheet': _bottomSheetAlmasurat(context),
      },
      {
        'assets': 'assets/images/svg/ic-prayer.svg',
        'title': 'Doa Harian',
        'subtitle': 'Kumpulan doa',
        'isBottomSheet': false,
        'bottomSheet': ListDoaScreen(),
      },
    ];

    return Column(
      children: [
        _buildMenuCard(context, menu[0], isFullWidth: true),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildMenuCard(context, menu[1])),
            const SizedBox(width: 12),
            Expanded(child: _buildMenuCard(context, menu[2])),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    Map<String, dynamic> item, {
    bool isFullWidth = false,
  }) {
    return GestureDetector(
      onTap: () {
        if (item['isBottomSheet'] as bool) {
          Get.bottomSheet(
            item['bottomSheet'] as Widget,
            isScrollControlled: true,
          );
        } else {
          Get.toNamed(Routes.listDoa);
        }
      },
      child: Container(
        height: isFullWidth ? 130 : 160,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: isFullWidth ? -20 : -30,
              bottom: isFullWidth ? -20 : -30,
              child: Opacity(
                opacity: 0.4,
                child: SvgPicture.asset(
                  item['assets'] as String,
                  height: isFullWidth ? 140 : 120,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: isFullWidth
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  if (!isFullWidth) const SizedBox(height: 8),
                  Text(
                    item['title'] as String,
                    style: pBold16.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['subtitle'] as String,
                    style: pMedium12.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasbih(BuildContext context, DzikirScreenController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),

        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Tasbih Digital',
            style: pBold18.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Obx(
            () => Text(
              'Target: ${controller.maxDzikirCount.value}',
              style: pMedium14.copyWith(color: AppColor.globalTextSecondary),
            ),
          ),
          const SizedBox(height: 32),
          Obx(() {
            final progress = controller.maxDzikirCount.value > 0
                ? controller.dzikirCount.value / controller.maxDzikirCount.value
                : 0.0;
            return SizedBox(
              height: 200,
              width: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 200,
                    width: 200,
                    child: CustomPaint(
                      painter: CircularProgressPainter(
                        progress: progress,
                        progressColor: Theme.of(context).primaryColor,
                        backgroundColor: Theme.of(
                          context,
                        ).primaryColor.withOpacity(0.1),
                        strokeWidth: 12.0,
                      ),
                    ),
                  ),
                  Container(
                    height: 160,
                    width: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor.withOpacity(0.8),
                          Theme.of(context).primaryColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          controller.increment();
                        },
                        child: Center(
                          child: Text(
                            controller.dzikirCount.value.toString(),
                            style: pBold24.copyWith(
                              color: Colors.white,
                              fontSize: 48,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTasbihActionButton(
                context,
                icon: Icons.refresh_rounded,
                label: 'Reset',
                onTap: () => controller.dzikirCount.value = 0,
              ),
              _buildTasbihActionButton(
                context,
                icon: Icons.track_changes_rounded,
                label: 'Target',
                onTap: () {
                  controller.dzikirInputController.clear();
                  Get.dialog(_buildListDzikir(context, controller));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTasbihActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Theme.of(context).primaryColor, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: pMedium14.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListDzikir(
    BuildContext context,
    DzikirScreenController controller,
  ) {
    return Dialog(
      alignment: Alignment.center,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Target Tasbih',
              style: pBold18.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Masukkan jumlah target dzikir yang ingin dicapai',
              style: pRegular14.copyWith(color: AppColor.globalTextSecondary),
            ),
            const SizedBox(height: 24),
            TextInput(
              controller: controller.dzikirInputController,
              hintText: '150',
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final data = controller.listData[index];
                  return Obx(
                    () => TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor:
                            controller.dzikirInputText.value ==
                                data['value'].toString()
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).colorScheme.surface,
                        side: BorderSide(color: Theme.of(context).primaryColor),
                        alignment: Alignment.center,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onPressed: () {
                        controller.dzikirInputText.value = data['value']
                            .toString();
                        controller.dzikirInputController.text = data['value']
                            .toString();
                      },
                      child: Text(
                        data['label'] as String,
                        style:
                            controller.dzikirInputText.value ==
                                data['value'].toString()
                            ? pSemiBold14.copyWith(color: Colors.white)
                            : pSemiBold14.copyWith(
                                color: Theme.of(context).primaryColor,
                              ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(width: 8);
                },
                itemCount: controller.listData.length,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      controller.dzikirInputController.clear();
                      controller.dzikirInputText.value = '';
                      Get.back();
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Batal',
                      style: pSemiBold14.copyWith(
                        color: AppColor.globalTextSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (controller.dzikirInputController.text.isNotEmpty) {
                        controller.maxDzikirCount.value = int.parse(
                          controller.dzikirInputController.text,
                        );
                      }
                      controller.dzikirInputController.clear();
                      controller.dzikirInputText.value = '';
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Simpan',
                      style: pSemiBold14.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
