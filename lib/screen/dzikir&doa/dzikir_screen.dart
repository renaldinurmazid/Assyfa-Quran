import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/screen/dzikir&doa/list_doa_screen.dart';
import 'package:quran_app/controller/dzikir_screen_controller.dart';
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
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildMenuVarianDzikir(context),
            const Spacer(),
            _buildTasbih(context, controller),
            const Spacer(),
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
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Get.find<DzikirScreenController>().recordDzikirView(
                    data[index]['slug'] as String,
                    data[index]['title'] as String,
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
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border(
                      bottom: BorderSide(
                        color: context.isDarkMode
                            ? Colors.grey.shade900
                            : Colors.grey.shade400,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: const Icon(
                          IconlyBold.bookmark,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          data[index]['title'] as String,
                          style: pMedium14.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(IconlyBold.show, size: 18),
                          const SizedBox(width: 4),
                          Obx(() {
                            final stats = Get.find<DzikirScreenController>()
                                .dzikirStats;
                            final slug = data[index]['slug'] as String;
                            return Text(
                              '${stats[slug] ?? 0}',
                              style: pMedium10,
                            );
                          }),
                        ],
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
    );
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
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Get.find<DzikirScreenController>().recordDzikirView(
                    data[index]['slug'] as String,
                    data[index]['title'] as String,
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
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border(
                      bottom: BorderSide(
                        color: context.isDarkMode
                            ? Colors.grey.shade900
                            : Colors.grey.shade400,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: const Icon(
                          IconlyBold.bookmark,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          data[index]['title'] as String,
                          style: pMedium14.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(IconlyBold.show, size: 18),
                          const SizedBox(width: 4),
                          Obx(() {
                            final stats = Get.find<DzikirScreenController>()
                                .dzikirStats;
                            final slug = data[index]['slug'] as String;
                            return Text(
                              '${stats[slug] ?? 0}',
                              style: pMedium10,
                            );
                          }),
                        ],
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
    );
  }

  Widget _buildMenuVarianDzikir(BuildContext context) {
    final menu = [
      {
        'assets': 'assets/images/svg/ic-doa.svg',
        'title': 'Dzikir Shalat',
        'isBottomSheet': true,
        'bottomSheet': _bottomSheetDzikir(context),
      },
      {
        'assets': 'assets/images/svg/ic-alma.svg',
        'title': 'Al-Matsurat',
        'isBottomSheet': true,
        'bottomSheet': _bottomSheetAlmasurat(context),
      },
      {
        'assets': 'assets/images/svg/ic-prayer.svg',
        'title': 'Doa',
        'isBottomSheet': false,
        'bottomSheet': ListDoaScreen(),
      },
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2,
      ),
      itemCount: menu.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            if (menu[index]['isBottomSheet'] as bool) {
              Get.bottomSheet(menu[index]['bottomSheet'] as Widget);
            } else {
              Get.toNamed(Routes.listDoa);
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  height: 20,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      menu[index]['title'] as String,
                      style: pSemiBold14.copyWith(color: Colors.white),
                    ),
                  ),
                ),
                Positioned(
                  right: -28,
                  bottom: -28,
                  child: SvgPicture.asset(
                    menu[index]['assets'] as String,
                    height: 110,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTasbih(BuildContext context, DzikirScreenController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'TASBIH DIGITAL',
          style: pSemiBold16.copyWith(color: Theme.of(context).primaryColor),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton.filled(
              onPressed: () {
                controller.dzikirCount.value = 0;
              },
              icon: const Icon(Icons.replay_rounded, size: 24),
              style: IconButton.styleFrom(
                fixedSize: const Size(40, 40),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Obx(() {
              final progress = controller.maxDzikirCount.value > 0
                  ? controller.dzikirCount.value /
                        controller.maxDzikirCount.value
                  : 0.0;
              return SizedBox(
                height: 160,
                width: 160,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(160, 160),
                      painter: CircularProgressPainter(
                        progress: progress,
                        progressColor: Theme.of(context).primaryColor,
                        backgroundColor: Theme.of(context).dividerColor,
                        strokeWidth: 3.0,
                      ),
                    ),
                    SizedBox(
                      height: 136,
                      width: 136,
                      child: TextButton(
                        onPressed: () {
                          controller.increment();
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          alignment: Alignment.center,
                          shape: const CircleBorder(),
                        ),
                        child: Text(
                          controller.dzikirCount.value.toString(),
                          style: pSemiBold24.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(width: 12),
            Obx(
              () => TextButton(
                onPressed: () {
                  controller.dzikirInputController.clear();
                  Get.dialog(_buildListDzikir(context, controller));
                },
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  fixedSize: const Size(40, 40),
                  alignment: Alignment.center,
                  shape: const CircleBorder(),
                ),
                child: Text(
                  controller.maxDzikirCount.value.toString(),
                  style: pSemiBold14.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildListDzikir(
    BuildContext context,
    DzikirScreenController controller,
  ) {
    return Dialog(
      alignment: Alignment.center,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Masukan Jumlah Dzikir',
              style: pRegular14.copyWith(color: Theme.of(context).primaryColor),
            ),
            const SizedBox(height: 16),
            TextInput(
              controller: controller.dzikirInputController,
              hintText: 'Exm. 100',
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
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
                            ? pSemiBold12.copyWith(color: Colors.white)
                            : pSemiBold12.copyWith(
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
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      controller.dzikirInputController.clear();
                      controller.dzikirInputText.value = '';
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      side: BorderSide(color: Theme.of(context).primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Batal',
                      style: pRegular14.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      controller.maxDzikirCount.value = int.parse(
                        controller.dzikirInputController.text,
                      );
                      controller.dzikirInputController.clear();
                      controller.dzikirInputText.value = '';
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      side: BorderSide(color: Theme.of(context).primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Simpan',
                      style: pRegular14.copyWith(color: Colors.white),
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
