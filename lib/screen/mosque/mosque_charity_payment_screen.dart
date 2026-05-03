import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:quran_app/controller/mosque_charity_payment_controller.dart';
import 'package:quran_app/controller/global/auth_controller.dart';

import 'package:quran_app/theme/font.dart';
import 'package:quran_app/widgets/text_input.dart';
import 'package:flutter/services.dart' hide TextInput;
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Remove all dots for parsing
    String cleanText = newValue.text.replaceAll('.', '');

    // Handle the case where the input is not a number
    double? value = double.tryParse(cleanText);
    if (value == null) return oldValue;

    final formatter = NumberFormat.decimalPattern('id');
    String newText = formatter.format(value);

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class MosqueCharityPaymentScreen extends StatelessWidget {
  const MosqueCharityPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MosqueCharityPaymentController());

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Infaq Sekarang', style: pSemiBold16),
        backgroundColor: context.theme.scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            IconlyLight.arrow_left_2,
            color: context.theme.colorScheme.onSurface,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(context, 'Nominal Infaq'),
              const SizedBox(height: 12),
              TextField(
                controller: controller.nominalController,
                cursorColor: context.theme.colorScheme.primary,
                style: pSemiBold14,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.end,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CurrencyInputFormatter(),
                ],
                decoration: InputDecoration(
                  hintText: '0',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text('Rp ', style: pSemiBold14),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 0,
                    minHeight: 0,
                  ),
                  hintStyle: pMedium12,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: context.isDarkMode
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: context.isDarkMode
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: context.isDarkMode
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildFastInput(context, controller, 'Rp10.000', '10000'),
                  _buildFastInput(context, controller, 'Rp25.000', '25000'),
                  _buildFastInput(context, controller, 'Rp50.000', '50000'),
                  _buildFastInput(context, controller, 'Rp100.000', '100000'),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Data Diri'),
              const SizedBox(height: 18),
              TextInput(
                controller: controller.nameController,
                hintText: 'Nama Lengkap',
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Obx(
                    () => SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: controller.isAnonymous.value,
                        onChanged: (value) {
                          controller.isAnonymous.value = value!;
                        },
                        activeColor: context.theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        side: BorderSide(
                          color: context.theme.colorScheme.primary.withOpacity(
                            0.2,
                          ),
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Sembunyikan nama saya (Anonim)',
                    style: pRegular12.copyWith(
                      color: context.theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              TextInput(
                controller: controller.phoneController,
                hintText: 'Nomor WhatsApp',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              AuthController.to.userData['phone_number'] == null
                  ? Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(
                          context.isDarkMode ? 0.05 : 0.1,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.amber.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            IconlyLight.info_square,
                            color: Colors.amber.shade900,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Lengkapi nomor telepon di profilmu yuk, supaya transaksi berikutnya jadi lebih praktis!',
                              style: pRegular12.copyWith(
                                color: context.isDarkMode
                                    ? Colors.amber.shade200
                                    : Colors.amber.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Pilih Metode Pembayaran'),
              const SizedBox(height: 12),
              Obx(() {
                final selected = controller.selectedPaymentMethod.value;
                return GestureDetector(
                  onTap: () =>
                      _showPaymentMethodBottomSheet(context, controller),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected != null
                            ? context.theme.colorScheme.primary
                            : (context.isDarkMode
                                  ? Colors.grey.shade900
                                  : Colors.grey.shade200),
                        width: selected != null ? 2 : 1,
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
                        if (selected != null) ...[
                          Container(
                            width: 48,
                            height: 32,
                            decoration: BoxDecoration(
                              color: context
                                  .theme
                                  .colorScheme
                                  .surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: selected.logo.isNotEmpty
                                ? SvgPicture.network(
                                    selected.logo,
                                    placeholderBuilder: (context) =>
                                        const Center(
                                          child: SizedBox(
                                            width: 12,
                                            height: 12,
                                            child: CircularProgressIndicator(
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
                              selected.name,
                              style: pSemiBold14.copyWith(
                                color: context.theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ] else ...[
                          const Icon(
                            IconlyLight.wallet,
                            size: 22,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Pilih metode pembayaran',
                              style: pRegular14.copyWith(
                                color:
                                    context.theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                        const Icon(
                          IconlyLight.arrow_down_2,
                          size: 20,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.05),
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 18,
                      color: Colors.orange,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Dana donasi yang terhimpun di Quranuna bukan untuk tujuan pencucian uang, terorisme maupun tindak kejahatan lainnya.',
                        style: pRegular12.copyWith(color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.theme.colorScheme.surface,
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
            onPressed: (controller.isLoading.value || !controller.isFormValid)
                ? null
                : controller.submitDonation,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
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
                    style: pSemiBold16.copyWith(color: Colors.white),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: pSemiBold14.copyWith(
        color: context.theme.colorScheme.onSurface.withOpacity(0.8),
      ),
    );
  }

  Widget _buildFastInput(
    BuildContext context,
    MosqueCharityPaymentController controller,
    String label,
    String value,
  ) {
    return Obx(() {
      final isSelected =
          controller.selectedNominal.value.replaceAll('.', '') == value;
      return GestureDetector(
        onTap: () {
          final formatter = NumberFormat.decimalPattern('id');
          final formattedValue = formatter.format(double.parse(value));
          controller.nominalController.text = formattedValue;
          controller.nominalController.selection = TextSelection.fromPosition(
            TextPosition(offset: formattedValue.length),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? context.theme.colorScheme.primary
                : context.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? context.theme.colorScheme.primary
                  : (context.isDarkMode
                        ? Colors.grey.shade900
                        : Colors.grey.shade200),
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: context.theme.colorScheme.primary.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Text(
            label,
            style: pSemiBold14.copyWith(
              color: isSelected ? Colors.white : null,
            ),
          ),
        ),
      );
    });
  }

  void _showPaymentMethodBottomSheet(
    BuildContext context,
    MosqueCharityPaymentController controller,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Drag handle
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Pilih Metode Pembayaran',
                        style: pBold16.copyWith(
                          color: context.theme.colorScheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.close,
                          color: context.theme.colorScheme.onSurfaceVariant,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: context.theme.colorScheme.primary,
                        ),
                      );
                    }
                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.all(20),
                      itemCount: controller.paymentMethods.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final method = controller.paymentMethods[index];
                        return Obx(() {
                          final isSelected =
                              controller.selectedPaymentMethod.value?.id ==
                              method.id;
                          return GestureDetector(
                            onTap: () {
                              controller.selectPaymentMethod(method);
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: context.theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? context.theme.colorScheme.primary
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
                                      color: context
                                          .theme
                                          .colorScheme
                                          .surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: method.logo.isNotEmpty
                                        ? SvgPicture.network(
                                            method.logo,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return const Center(
                                                    child: Icon(
                                                      IconlyLight.image,
                                                      color: Colors.grey,
                                                      size: 16,
                                                    ),
                                                  );
                                                },
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
                                            ? context.theme.colorScheme.primary
                                            : context
                                                  .theme
                                                  .colorScheme
                                                  .onSurface,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      IconlyBold.tick_square,
                                      color: context.theme.colorScheme.primary,
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
                ),
              ],
            );
          },
        );
      },
    );
  }
}
