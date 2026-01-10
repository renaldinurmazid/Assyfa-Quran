import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/controller/list_doa_screen_controller.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';

class ListDoaScreen extends StatelessWidget {
  const ListDoaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ListDoaScreenController());
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        title: Text('Kumpulan Doa', style: pMedium16),
        centerTitle: true,
        backgroundColor: AppColor.backgroundColor,
        elevation: 1,
        surfaceTintColor: AppColor.backgroundColor,
        shadowColor: AppColor.primaryColor,
        iconTheme: const IconThemeData(color: AppColor.primaryColor),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColor.primaryColor),
          );
        }

        if (controller.data.isEmpty) {
          return Center(child: Text('Tidak ada data doa', style: pRegular14));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final doa = controller.data[index];
            return _DoaCard(doa: doa);
          },
          separatorBuilder: (context, index) {
            return const SizedBox(height: 12);
          },
          itemCount: controller.data.length,
        );
      }),
    );
  }
}

class _DoaCard extends StatefulWidget {
  final dynamic doa;

  const _DoaCard({required this.doa});

  @override
  State<_DoaCard> createState() => _DoaCardState();
}

class _DoaCardState extends State<_DoaCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.backgroundColor,
        border: Border.all(color: AppColor.borderColor),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.doa.nama,
                          style: pSemiBold16.copyWith(
                            color: AppColor.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(widget.doa.grup, style: pRegular12),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColor.primaryColor,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: AppColor.borderColor),
                  const SizedBox(height: 12),
                  // Teks Arab
                  Text(
                    widget.doa.ar,
                    style: pSemiBold18.copyWith(height: 2),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 16),
                  // Transliterasi Latin
                  Text(
                    widget.doa.tr,
                    style: pRegular14.copyWith(fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 12),
                  // Terjemahan Indonesia
                  Text(
                    widget.doa.idn,
                    style: pRegular14,
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 16),
                  // Keterangan/Tentang
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColor.borderColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Keterangan:',
                          style: pSemiBold14.copyWith(
                            color: AppColor.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(widget.doa.tentang, style: pRegular12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
