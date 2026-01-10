import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:quran_app/controller/group/group_ngaji_screen_controller.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';

class GroupNgajiScreen extends StatelessWidget {
  const GroupNgajiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GroupNgajiScreenController());
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColor.backgroundColor,
        title: Text('Grup Ngaji', style: pSemiBold16),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [_searchGroup(), _createGroup(), _listGroup(controller)],
        ),
      ),
    );
  }

  Widget _listGroup(GroupNgajiScreenController controller) {
    return Column(
      children: [
        Obx(
          () => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    controller.isGroupSaya.value = true;
                    controller.pageController.animateToPage(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: controller.isGroupSaya.value
                              ? AppColor.primaryColor
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text('Grup Saya', style: pMedium12),
                  ),
                ),
                SizedBox(width: 12),
                InkWell(
                  onTap: () {
                    controller.isGroupSaya.value = false;
                    controller.pageController.animateToPage(
                      1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: controller.isGroupSaya.value
                              ? Colors.transparent
                              : AppColor.primaryColor,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text('Browse Group', style: pMedium12),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: Get.height * 0.68,
          child: PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: controller.pageController,
            onPageChanged: (index) {
              controller.isGroupSaya.value = index == 0;
            },
            children: [_listViewMyGroup(controller), _listViewBrowseGroup()],
          ),
        ),
      ],
    );
  }

  Widget _listViewMyGroup(GroupNgajiScreenController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColor.primaryColor),
        );
      }

      if (controller.myGroups.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text('Belum ada grup ngaji', style: pMedium14)],
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemCount: controller.myGroups.length,
        itemBuilder: (context, index) {
          final group = controller.myGroups[index];
          return InkWell(
            onTap: () {
              Get.toNamed(Routes.showGroup, arguments: group.id);
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                color: Colors.grey.shade100,
              ),
              child: Column(
                children: [
                  Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: group.coverImage != null
                            ? NetworkImage(group.coverImage)
                            : const AssetImage('assets/images/jpg/bg-group.jpg')
                                  as ImageProvider,
                        fit: BoxFit.cover,
                        colorFilter: const ColorFilter.mode(
                          Color.fromARGB(120, 0, 0, 0),
                          BlendMode.srcOver,
                        ),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 40,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          left: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                group.name,
                                style: pSemiBold16.copyWith(
                                  color: AppColor.backgroundColor,
                                ),
                              ),
                              Text(
                                'Dibuat oleh ${group.createdBy.name}',
                                style: pRegular12.copyWith(
                                  color: AppColor.backgroundColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade300,
                          ),
                          child: group.createdBy.profilePicture.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.network(
                                    group.createdBy.profilePicture,
                                    width: 26,
                                    height: 26,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Icon(
                                  Icons.person,
                                  color: Colors.grey.shade800,
                                  size: 16,
                                ),
                        ),
                        const SizedBox(width: 8),
                        Text('${group.memberCount} Anggota', style: pMedium12),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColor.primaryColor,
                          ),
                          child: Icon(
                            Icons.share,
                            color: AppColor.backgroundColor,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _listViewBrowseGroup() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset('assets/images/svg/maintenance.svg', width: 300),
          Text('Kita lagi nyiapin sesuatu', style: pBold16),
          SizedBox(
            width: 300,
            child: Text(
              'Sabar ya, coba fitur lain selagi kami menyiapkan ini',
              style: pRegular14,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _createGroup() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Soleh bareng-bareng yuk!', style: pSemiBold14),
              Text('Buat grup ngaji bareng temanmu', style: pRegular12),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              Get.toNamed(Routes.createGroupNgaji);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: Text(
              'Buat Grup',
              style: pMedium12.copyWith(color: AppColor.backgroundColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchGroup() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: TextField(
        cursorColor: Colors.grey.shade500,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: Colors.grey.shade500),
          ),
          hintText: 'Cari Grup Ngaji',
          hintStyle: pRegular12.copyWith(color: Colors.grey.shade500),
        ),
      ),
    );
  }
}
