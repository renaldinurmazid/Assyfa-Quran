import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:quran_app/controller/mosque_charity_payment_controller.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/theme/app_color.dart';
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
        centerTitle: true,
        backgroundColor: context.theme.scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: context.theme.colorScheme.onSurface,
            size: 18,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step 1: Nominal Infaq
              _buildStepCard(
                context: context,
                stepNumber: '1',
                title: 'Nominal Infaq',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: controller.nominalController,
                      cursorColor: AppColor.primaryColor,
                      style: pBold20.copyWith(color: AppColor.primaryColor),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.end,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        CurrencyInputFormatter(),
                      ],
                      decoration: InputDecoration(
                        hintText: '0',
                        hintStyle: pBold20.copyWith(color: Colors.grey.shade400),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Text(
                            'Rp',
                            style: pBold20.copyWith(color: AppColor.primaryColor),
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 0,
                          minHeight: 0,
                        ),
                        filled: true,
                        fillColor: context.isDarkMode
                            ? Colors.grey.shade900
                            : Colors.grey.shade50,
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
                          borderSide: const BorderSide(
                            color: AppColor.primaryColor,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _buildFastInput(context, controller, 'Rp10.000', '10000'),
                        _buildFastInput(context, controller, 'Rp25.000', '25000'),
                        _buildFastInput(context, controller, 'Rp50.000', '50000'),
                        _buildFastInput(context, controller, 'Rp100.000', '100000'),
                      ],
                    ),
                  ],
                ),
              ),

              // Step 2: Personal Information
              _buildStepCard(
                context: context,
                stepNumber: '2',
                title: 'Data Diri Donatur',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextInput(
                      controller: controller.nameController,
                      hintText: 'Nama Lengkap',
                    ),
                    const SizedBox(height: 12),
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
                              activeColor: AppColor.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              side: BorderSide(
                                color: AppColor.primaryColor.withOpacity(0.4),
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
                    const SizedBox(height: 16),
                    TextInput(
                      controller: controller.phoneController,
                      hintText: 'Nomor WhatsApp',
                      keyboardType: TextInputType.phone,
                    ),
                    if (AuthController.to.userData['phone_number'] == null) ...[
                      const SizedBox(height: 12),
                      Container(
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
                      ),
                    ],
                  ],
                ),
              ),

              // Step 3: Payment Method
              _buildStepCard(
                context: context,
                stepNumber: '3',
                title: 'Pilih Metode Pembayaran',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() {
                      final selected = controller.selectedPaymentMethod.value;
                      return GestureDetector(
                        onTap: () =>
                            _showPaymentMethodBottomSheet(context, controller),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: context.isDarkMode
                                ? Colors.grey.shade900
                                : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selected != null
                                  ? AppColor.primaryColor
                                  : (context.isDarkMode
                                        ? Colors.grey.shade800
                                        : Colors.grey.shade200),
                              width: selected != null ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              if (selected != null) ...[
                                Container(
                                  width: 48,
                                  height: 32,
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: context.isDarkMode
                                        ? Colors.grey.shade800
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: context.isDarkMode
                                          ? Colors.grey.shade700
                                          : Colors.grey.shade200,
                                    ),
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
                                      color: context.theme.colorScheme.onSurface,
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
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.05),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            size: 18,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Dana donasi yang terhimpun di Quranuna bukan untuk tujuan pencucian uang, terorisme maupun tindak kejahatan lainnya.',
                              style: pRegular10.copyWith(
                                color: context.isDarkMode
                                    ? Colors.orange.shade200
                                    : Colors.orange.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: BoxDecoration(
          color: context.theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
          border: Border(
            top: BorderSide(
              color: context.isDarkMode
                  ? Colors.grey.shade900
                  : Colors.grey.shade100,
              width: 1,
            ),
          ),
        ),
        child: Obx(
          () => ElevatedButton(
            onPressed: (controller.isLoading.value || !controller.isFormValid)
                ? null
                : controller.submitDonation,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
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

  Widget _buildStepCard({
    required BuildContext context,
    required String stepNumber,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.isDarkMode
              ? Colors.grey.shade800
              : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(context.isDarkMode ? 0.2 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD4AF37), Color(0xFFC5A880)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    stepNumber,
                    style: pBold12.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: pBold14.copyWith(
                      color: context.theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: context.isDarkMode
                ? Colors.grey.shade800
                : Colors.grey.shade100,
          ),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColor.primaryColor
                : (context.isDarkMode ? Colors.grey.shade900 : Colors.white),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColor.primaryColor
                  : (context.isDarkMode
                        ? Colors.grey.shade800
                        : Colors.grey.shade200),
              width: 1,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: AppColor.primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              else
                BoxShadow(
                  color: Colors.black.withOpacity(0.01),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Text(
            label,
            style: pBold12.copyWith(
              color: isSelected
                  ? Colors.white
                  : (context.isDarkMode ? Colors.grey[300] : Colors.grey[700]),
            ),
          ),
        ),
      );
    });
  }
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
