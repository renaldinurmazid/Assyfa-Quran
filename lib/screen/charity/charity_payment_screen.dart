import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:quran_app/controller/charity/charity_payment_controller.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';
import 'package:quran_app/widgets/text_input.dart';

class CharityPaymentScreen extends StatelessWidget {
  const CharityPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CharityPaymentController());

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Infaq Sekarang',
          style: pBold18.copyWith(color: AppColor.primaryColor),
        ),
        leading: IconButton(
          icon: const Icon(
            IconlyLight.arrow_left_2,
            color: AppColor.primaryColor,
          ),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Nominal Infaq'),
              const SizedBox(height: 12),
              TextInput(
                controller: controller.nominalController,
                hintText: 'Contoh: 50000',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildFastInput(controller, 'Rp10.000', '10000'),
                  _buildFastInput(controller, 'Rp25.000', '25000'),
                  _buildFastInput(controller, 'Rp50.000', '50000'),
                  _buildFastInput(controller, 'Rp100.000', '100000'),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('Data Diri'),
              const SizedBox(height: 12),
              TextInput(
                controller: controller.nameController,
                hintText: 'Nama Lengkap',
              ),
              const SizedBox(height: 12),
              TextInput(
                controller: controller.phoneController,
                hintText: 'Nomor WhatsApp',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('Pilih Metode Pembayaran'),
              const SizedBox(height: 12),
              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.paymentMethods.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final method = controller.paymentMethods[index];
                    return Obx(() {
                      final isSelected =
                          controller.selectedPaymentMethod.value?.id ==
                          method.id;
                      return GestureDetector(
                        onTap: () => controller.selectPaymentMethod(method),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? AppColor.primaryColor
                                  : Colors.transparent,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: method.logo.isNotEmpty
                                    ? SvgPicture.network(
                                        method.logo,
                                        placeholderBuilder: (context) =>
                                            const Center(
                                              child: SizedBox(
                                                width: 12,
                                                height: 12,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              ),
                                            ),
                                      )
                                    : const Icon(
                                        IconlyLight.wallet,
                                        size: 20,
                                        color: Colors.grey,
                                      ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  method.name,
                                  style: pSemiBold14.copyWith(
                                    color: isSelected
                                        ? AppColor.primaryColor
                                        : AppColor.textColor,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  IconlyBold.tick_square,
                                  color: AppColor.primaryColor,
                                  size: 24,
                                ),
                            ],
                          ),
                        ),
                      );
                    });
                  },
                );
              }),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Obx(
          () => ElevatedButton(
            onPressed: controller.isLoading.value
                ? null
                : controller.submitDonation,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
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
                    'Lanjutkan Pembayaran',
                    style: pBold16.copyWith(color: Colors.white),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: pBold14.copyWith(color: AppColor.textColor.withOpacity(0.8)),
    );
  }

  Widget _buildFastInput(
    CharityPaymentController controller,
    String label,
    String value,
  ) {
    return Obx(() {
      final isSelected = controller.selectedNominal.value == value;
      return GestureDetector(
        onTap: () {
          controller.nominalController.text = value;
          // Trigger reactivity if needed, though controller.text isn't observable
          // But we can check it in the Obx
          controller.nominalController.selection = TextSelection.fromPosition(
            TextPosition(offset: value.length),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColor.primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColor.primaryColor : Colors.grey.shade200,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: AppColor.primaryColor.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Text(
            label,
            style: pSemiBold14.copyWith(
              color: isSelected ? Colors.white : AppColor.primaryColor,
            ),
          ),
        ),
      );
    });
  }
}
