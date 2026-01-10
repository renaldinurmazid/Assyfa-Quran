import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/controller/group/add_member_group_controller.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';

class AddMemberGroupScreen extends StatelessWidget {
  const AddMemberGroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddMemberGroupController());
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColor.backgroundColor,
        title: Text('Undang teman', style: pSemiBold16),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: SizedBox(
              width: 360,
              child: Text(
                'Undang teman atau kerabat untuk bergabung ke grupku dengan membagikan link dibawah ini ke media sosial anda',
                style: pRegular12,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade400),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('https://quranapp.id/app190289881', style: pRegular12),
                Icon(Icons.copy, color: AppColor.primaryColor),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text('Atau pilih sobat anda didaftar ini.', style: pRegular12),
          const SizedBox(height: 20),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColor.primaryColor,
                  ),
                );
              }

              if (controller.users.isEmpty) {
                return Center(
                  child: Text('Tidak ada pengguna ditemukan', style: pMedium14),
                );
              }

              return ListView.separated(
                itemCount: controller.users.length,
                itemBuilder: (context, index) {
                  final user = controller.users[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: user.profilePicture.isNotEmpty
                              ? Image.network(
                                  user.profilePicture,
                                  fit: BoxFit.cover,
                                  width: 40,
                                  height: 40,
                                )
                              : Image.asset(
                                  'assets/images/png/user.png',
                                  fit: BoxFit.cover,
                                  width: 40,
                                  height: 40,
                                ),
                        ),
                        const SizedBox(width: 12),
                        Text(user.name, style: pMedium14),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            Get.dialog(_addMemberDialog(controller, user.id));
                          },
                          child: Icon(
                            Icons.add_circle_outline,
                            color: AppColor.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return Divider(color: Colors.grey.shade300);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _addMemberDialog(AddMemberGroupController controller, int userId) {
    return AlertDialog(
      backgroundColor: AppColor.backgroundColor,
      title: Text('Tambah Anggota', style: pMedium16),
      content: Text(
        'Apakah anda yakin ingin menambahkan anggota ini?',
        style: pRegular12,
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('Batal', style: pRegular12),
        ),
        TextButton(
          onPressed: () => controller.addUserToGroup(userId),
          child: Text('Ya', style: pRegular12),
        ),
      ],
    );
  }
}
