import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/screen/dzikir&doa/list_doa_screen.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';
import 'package:quran_app/controller/dzikir_screen_controller.dart';
import 'package:quran_app/widgets/circular_progress_painter.dart';
import 'package:quran_app/widgets/text_input.dart';

class DzikirScreen extends StatelessWidget {
  const DzikirScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DzikirScreenController());

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        title: Text('Panduan Dzikir', style: pMedium16),
        centerTitle: true,
        backgroundColor: AppColor.backgroundColor,
        elevation: 1,
        surfaceTintColor: AppColor.backgroundColor,
        iconTheme: const IconThemeData(color: AppColor.primaryColor),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildMenuVarianDzikir(),
            const Spacer(),
            _buildTasbih(controller),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _bottomSheetDzikir() {
    final data = [
      {
        'title': 'Dzikir Shalat Pendek',
        'data': 'assets/data/dzikir-pendek.json',
      },
      {
        'title': 'Dzikir Shalat Panjang',
        'data': 'assets/data/dzikir-panjang.json',
      },
    ];
    return Container(
      decoration: BoxDecoration(
        color: AppColor.backgroundColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              height: 2,
              width: 100,
              decoration: BoxDecoration(
                color: AppColor.primaryColor,
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
                    color: AppColor.backgroundColor,
                    border: Border(
                      bottom: BorderSide(color: AppColor.borderColor),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColor.primaryColor,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Icon(
                          IconlyBold.bookmark,
                          color: AppColor.backgroundColor,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(data[index]['title'] as String, style: pMedium14),
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

  Widget _bottomSheetAlmasurat() {
    final data = [
      {
        'title': 'Al-Matsurat Sugro Pagi',
        'data': 'assets/data/sugro-pagi.json',
      },
      {
        'title': 'Al-Matsurat Sugro Petang',
        'data': 'assets/data/sugro-petang.json',
      },
      {
        'title': 'Al-Matsurat Kubro Pagi',
        'data': 'assets/data/kubro-pagi.json',
      },
      {
        'title': 'Al-Matsurat Kubro Petang',
        'data': 'assets/data/kubro-petang.json',
      },
    ];
    return Container(
      decoration: BoxDecoration(
        color: AppColor.backgroundColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              height: 2,
              width: 100,
              decoration: BoxDecoration(
                color: AppColor.primaryColor,
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
                    color: AppColor.backgroundColor,
                    border: Border(
                      bottom: BorderSide(color: AppColor.borderColor),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColor.primaryColor,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Icon(
                          IconlyBold.bookmark,
                          color: AppColor.backgroundColor,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(data[index]['title'] as String, style: pMedium14),
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

  Widget _buildMenuVarianDzikir() {
    final menu = [
      {
        'assets': 'assets/images/svg/ic-doa.svg',
        'title': 'Dzikir Shalat',
        'isBottomSheet': true,
        'bottomSheet': _bottomSheetDzikir(),
      },
      {
        'assets': 'assets/images/svg/ic-alma.svg',
        'title': 'Al-Matsurat',
        'isBottomSheet': true,
        'bottomSheet': _bottomSheetAlmasurat(),
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
                    color: AppColor.primaryColor,
                    border: Border.all(color: AppColor.borderColor),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      menu[index]['title'] as String,
                      style: pSemiBold14.copyWith(
                        color: AppColor.backgroundColor,
                      ),
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

  Widget _buildTasbih(DzikirScreenController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'TASBIH DIGITAL',
          style: pSemiBold16.copyWith(color: AppColor.primaryColor),
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
              icon: Icon(Icons.replay_rounded, size: 24),
              style: IconButton.styleFrom(
                fixedSize: const Size(40, 40),
                backgroundColor: AppColor.primaryColor,
                foregroundColor: AppColor.backgroundColor,
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
                        progressColor: AppColor.primaryColor,
                        backgroundColor: AppColor.borderColor,
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
                          backgroundColor: AppColor.primaryColor,
                          foregroundColor: AppColor.backgroundColor,
                          alignment: Alignment.center,
                          shape: const CircleBorder(),
                        ),
                        child: Text(
                          controller.dzikirCount.value.toString(),
                          style: pSemiBold24.copyWith(
                            color: AppColor.backgroundColor,
                          ),
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
                  Get.dialog(_buildListDzikir(controller));
                },
                style: TextButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                  foregroundColor: AppColor.backgroundColor,
                  fixedSize: const Size(40, 40),
                  alignment: Alignment.center,
                  shape: const CircleBorder(),
                ),
                child: Text(
                  controller.maxDzikirCount.value.toString(),
                  style: pSemiBold14.copyWith(color: AppColor.backgroundColor),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildListDzikir(DzikirScreenController controller) {
    return Dialog(
      alignment: Alignment.center,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: AppColor.backgroundColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Masukan Jumlah Dzikir',
              style: pRegular14.copyWith(color: AppColor.primaryColor),
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
                            ? AppColor.primaryColor
                            : AppColor.backgroundColor,
                        side: BorderSide(color: AppColor.primaryColor),
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
                            ? pSemiBold12.copyWith(
                                color: AppColor.backgroundColor,
                              )
                            : pSemiBold12.copyWith(
                                color: AppColor.primaryColor,
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
                      backgroundColor: AppColor.backgroundColor,
                      side: BorderSide(color: AppColor.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Batal',
                      style: pRegular14.copyWith(color: AppColor.primaryColor),
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
                      backgroundColor: AppColor.primaryColor,
                      side: BorderSide(color: AppColor.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Simpan',
                      style: pRegular14.copyWith(
                        color: AppColor.backgroundColor,
                      ),
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
