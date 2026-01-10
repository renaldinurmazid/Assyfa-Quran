import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/controller/group/show_group_controller.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';
import 'package:quran_app/widgets/text_input.dart';

class ShowGroupScreen extends StatelessWidget {
  const ShowGroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ShowGroupController());
    return Obx(
      () => Scaffold(
        backgroundColor: AppColor.backgroundColor,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(controller),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _buildStatsCard(),
                        const SizedBox(height: 24),
                        _buildAnggotaSection(controller),
                        // const SizedBox(height: 32),
                        // _buildInspirasiSection(),
                        const SizedBox(height: 100), // Spacing for FABs
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: controller.group.value?.isMyGroup == true
            ? _buildFloatingButtons(controller)
            : null,
      ),
    );
  }

  Widget _buildHeader(ShowGroupController controller) {
    return Obx(
      () => Container(
        height: 240,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: controller.group.value?.coverImage != null
                ? NetworkImage(controller.group.value!.coverImage)
                : const AssetImage('assets/images/jpg/bg-group.jpg')
                      as ImageProvider,
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Color.fromARGB(150, 0, 0, 0),
              BlendMode.srcOver,
            ),
          ),
        ),
        child: Stack(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(
                      () => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () => Get.back(),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                          ),
                          controller.group.value?.isMyGroup == true
                              ? PopupMenuButton<String>(
                                  color: AppColor.backgroundColor,
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      controller.nameController.text =
                                          controller.group.value!.name;
                                      Get.dialog(
                                        Dialog(
                                          child: _buildEditGroup(controller),
                                        ),
                                      );
                                    } else if (value == 'change_cover') {
                                      controller.pickAndUploadCoverImage();
                                    } else if (value == 'delete') {
                                      Get.dialog(_buildDeleteGroup(controller));
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.more_vert,
                                    color: Colors.white,
                                  ),
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          const Icon(Icons.edit, size: 18),
                                          const SizedBox(width: 8),
                                          Text('Edit Grup', style: pRegular12),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'change_cover',
                                      child: Row(
                                        children: [
                                          const Icon(Icons.image, size: 18),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Ganti Cover',
                                            style: pRegular12,
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Hapus Grup',
                                            style: pRegular12.copyWith(
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : const SizedBox.shrink(),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Obx(
                      () => Text(
                        controller.group.value?.name ?? '-',
                        style: pBold24.copyWith(color: Colors.white),
                      ),
                    ),
                    Obx(
                      () => Text(
                        'Dibuat oleh ${controller.group.value?.createdBy.name ?? '-'}',
                        style: pRegular14.copyWith(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
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
                    colors: [Colors.transparent, Color(0xFF1A1B23)],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteGroup(ShowGroupController controller) {
    return AlertDialog(
      backgroundColor: AppColor.backgroundColor,
      title: Text('Hapus Grup', style: pMedium16),
      content: Text(
        'Apakah Anda yakin ingin menghapus grup ini?',
        style: pRegular14,
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('Batal', style: pRegular14),
        ),
        TextButton(
          onPressed: () => controller.deleteGroup(),
          child: Text('Hapus', style: pMedium14),
        ),
      ],
    );
  }

  Widget _buildEditGroup(ShowGroupController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColor.backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(child: Text('Edit Info Grup', style: pMedium16)),
          const SizedBox(height: 12),
          TextInput(
            controller: controller.nameController,
            hintText: 'Masukkan nama grup',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Set Private Grup', style: pSemiBold12),
                    Text(
                      'Informasi grup hanya bisa dilihat oleh anggota grup',
                      style: pRegular10,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Obx(
                () => Switch(
                  value: controller.isPrivate.value,
                  onChanged: (value) {
                    controller.isPrivate.value = value;
                  },
                  activeColor: AppColor.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(
            () => ElevatedButton(
              onPressed: controller.isLoading.value
                  ? null
                  : () => controller.updateGroup(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryColor,
                fixedSize: const Size(double.maxFinite, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: controller.isLoading.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Simpan',
                      style: pMedium14.copyWith(
                        color: AppColor.backgroundColor,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Statistik Ngaji', style: pSemiBold14),
                  Text('4 Jan 2026 - 10 Jan 2026', style: pRegular10),
                ],
              ),
              const Icon(Icons.arrow_circle_up, color: Colors.green, size: 24),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildBar('Aha'),
                    _buildBar('Sen'),
                    _buildBar('Sel'),
                    _buildBar('Rab'),
                    _buildBar('Kam'),
                    _buildBar('Jum'),
                    _buildBar('Sab'),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 60,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                color: Colors.grey.shade700,
              ),
              Column(
                children: [
                  Text('0', style: pBold24),
                  Text('Halaman', style: pSemiBold14),
                  Text(
                    'Bulan Ini',
                    style: pRegular10.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String day) {
    return Column(
      children: [
        Container(
          width: 8,
          height: 10,
          decoration: BoxDecoration(
            color: Colors.grey.shade700,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(day, style: pRegular10.copyWith(color: Colors.grey)),
      ],
    );
  }

  Widget _buildAnggotaSection(ShowGroupController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(
              () => Text(
                '${controller.group.value?.groupUser.length ?? 0} Anggota',
                style: pBold16,
              ),
            ),
            TextButton(
              onPressed: () {
                Get.toNamed(
                  Routes.showMemberGroup,
                  arguments: controller.group.value!.id,
                );
              },
              child: Row(
                children: [
                  Text(
                    'Selengkapnya',
                    style: pRegular12.copyWith(color: const Color(0xFFD81B60)),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Color(0xFFD81B60),
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(
          height: 60,
          width: double.infinity,
          child: Obx(
            () => ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: controller.group.value?.groupUser.length ?? 0,
              itemBuilder: (context, index) {
                return Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade400, width: 2),
                    image: DecorationImage(
                      image:
                          controller
                                  .group
                                  .value
                                  ?.groupUser[index]
                                  .user
                                  .profilePicture !=
                              null
                          ? NetworkImage(
                              controller
                                      .group
                                      .value
                                      ?.groupUser[index]
                                      .user
                                      .profilePicture ??
                                  '',
                            )
                          : const AssetImage('assets/images/png/user.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return const SizedBox(width: 8);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInspirasiSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Inspirasi Harian', style: pBold16),
        const SizedBox(height: 16),
        CustomPaint(
          painter: DashedRectPainter(color: Colors.grey.shade600),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.black, size: 40),
                ),
                const SizedBox(height: 16),
                Text('Belum ada inspirasi harian di grup ini', style: pBold14),
                Text('Kamu bisa tambahkan disini', style: pRegular12),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingButtons(ShowGroupController controller) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // FloatingActionButton(
        //   heroTag: 'chat_fab',
        //   onPressed: () {},
        //   backgroundColor: const Color(0xFF00C853),
        //   child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
        // ),
        // const SizedBox(height: 16),
        PopupMenuButton<String>(
          color: AppColor.backgroundColor,
          offset: const Offset(0, -110),
          onSelected: (value) {
            if (value == 'add_member') {
              Get.toNamed(
                Routes.addMemberGroup,
                arguments: controller.group.value!.id,
              );
            }
          },
          itemBuilder: (context) => [
            // PopupMenuItem(
            //   value: 'add_inspiration',
            //   child: Row(
            //     children: [
            //       const Icon(Icons.lightbulb_outline, size: 20),
            //       const SizedBox(width: 12),
            //       Text('Tambah Inspirasi', style: pMedium12),
            //     ],
            //   ),
            // ),
            PopupMenuItem(
              value: 'add_member',
              child: Row(
                children: [
                  const Icon(Icons.person_add, size: 20),
                  const SizedBox(width: 12),
                  Text('Tambah Anggota', style: pMedium12),
                ],
              ),
            ),
          ],
          child: FloatingActionButton(
            heroTag: 'add_fab',
            onPressed: null, // PopupMenuButton handles the tap
            backgroundColor: const Color(0xFFD81B60),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  DashedRectPainter({
    this.color = Colors.grey,
    this.strokeWidth = 1.0,
    this.dashWidth = 5.0,
    this.dashSpace = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    var path = Path();
    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(12),
      ),
    );

    Path dashPath = Path();
    double distance = 0.0;
    for (var metric in path.computeMetrics()) {
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
