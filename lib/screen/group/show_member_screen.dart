import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/controller/group/show_member_controller.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';

class ShowMemberScreen extends StatelessWidget {
  const ShowMemberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ShowMemberController());
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColor.backgroundColor,
        title: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Anggota Grup', style: pSemiBold16),
              const SizedBox(height: 2),
              Text(
                '${controller.group.value?.memberCount ?? 0} Anggota',
                style: pRegular12,
              ),
            ],
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColor.primaryColor),
          );
        }

        if (controller.group.value == null ||
            controller.group.value!.groupUser.isEmpty) {
          return Center(child: Text('Belum ada anggota', style: pMedium14));
        }

        return ListView.separated(
          itemCount: controller.group.value?.groupUser.length ?? 0,
          separatorBuilder: (context, index) =>
              Divider(color: Colors.grey.shade300),
          itemBuilder: (context, index) {
            final member = controller.group.value!.groupUser[index];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: member.user.profilePicture.isNotEmpty
                        ? NetworkImage(member.user.profilePicture)
                        : const AssetImage('assets/images/png/user.png')
                              as ImageProvider,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(member.user.name, style: pMedium14),
                        const SizedBox(height: 2),
                        Text('Peringkat ${member.rank}', style: pRegular12),
                      ],
                    ),
                  ),
                  Text('${member.totalPages} Hlm', style: pSemiBold14),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
