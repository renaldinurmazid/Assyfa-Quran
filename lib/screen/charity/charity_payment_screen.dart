import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:quran_app/screen/charity/charity_payment_controller.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';

// ─── Color tokens matching CharityPaymentDetailScreen ───────────────────────

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue.copyWith(text: '');
    final cleanText = newValue.text.replaceAll('.', '');
    final value = double.tryParse(cleanText);
    if (value == null) return oldValue;
    final newText = NumberFormat.decimalPattern('id').format(value);
    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class CharityPaymentScreen extends StatelessWidget {
  const CharityPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<CharityPaymentController>()
        ? Get.find<CharityPaymentController>()
        : Get.put(CharityPaymentController());

    return Scaffold(
      appBar: AppBar(
        title: Text("Infaq", style: pSemiBold16),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Get.back(),
        ),
      ),
      // The checkout bar lives in the body (not Scaffold.bottomNavigationBar):
      // only the body is lifted above the keyboard, so the button stays reachable.
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                // iOS number/phone keyboards have no "Done" key: dragging the form closes it.
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  children: [
                    if (!controller.isGeneral) ...[
                      if (controller.hasOptions) ...[
                        _buildPilihOpsi(),
                        const SizedBox(height: 18),
                      ],
                      _buildPeserta(),
                      const SizedBox(height: 18),
                    ],
                    _buildNominalInfaq(),
                    const SizedBox(height: 18),
                    _buildInfoDonatur(),
                    const SizedBox(height: 18),
                    _buildMetodePembayaran(),
                    const SizedBox(height: 18),
                    Container(
                      width: Get.width,
                      margin: EdgeInsets.symmetric(horizontal: 14),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.isDarkMode
                            ? Colors.orange.shade400.withOpacity(0.3)
                            : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade400),
                      ),
                      child: Text(
                        "Dana donasi yang terhimpun di Quranuna BUKAN untuk tujuan pencucian uang, terorisme maupun tindak kejahatan lainnya",
                        style: pMedium10.copyWith(
                          color: Colors.orange.shade500,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
            _buildCheckoutAction(),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutAction() {
    final controller = Get.find<CharityPaymentController>();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.globalBorder, width: 0.5),
      ),
      child: Obx(() {
        final isReady = controller.isFormValid && !controller.isLoading.value;
        final totalText = controller.selectedNominal.value.isEmpty
            ? '0'
            : controller.selectedNominal.value;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Total Infaq",
                  style: pSemiBold12.copyWith(
                    color: AppColor.globalTextSecondary,
                  ),
                ),
                Text(
                  "Rp$totalText",
                  style: pSemiBold14.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColor.primaryColor,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryColor,
                disabledBackgroundColor: AppColor.primaryColor.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: isReady ? controller.submitDonation : null,
              child: controller.isLoading.value
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      "Lanjutkan Pembayaran",
                      style: pMedium12.copyWith(color: Colors.white),
                    ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildMetodePembayaran() {
    final controller = Get.find<CharityPaymentController>();
    return Container(
      width: Get.width,
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.globalBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Metode Pembayaran",
            style: pSemiBold14.copyWith(
              color: AppColor.globalTextSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Obx(() {
            final selected = controller.selectedPaymentMethod.value;
            return GestureDetector(
              onTap: () =>
                  _showPaymentMethodBottomSheet(Get.context!, controller),
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColor.globalBorder, width: 0.5),
                ),
                child: Row(
                  children: [
                    if (selected != null && selected.logo != null) ...[
                      selected.logo!.contains('.svg')
                          ? SvgPicture.network(
                              selected.logo!,
                              width: 30,
                              height: 20,
                            )
                          : Image.network(
                              selected.logo!,
                              width: 30,
                              height: 20,
                            ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          selected.name,
                          style: pSemiBold14.copyWith(
                            color: AppColor.globalTextSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        "Ubah",
                        style: pSemiBold12.copyWith(
                          color: AppColor.primaryColor,
                        ),
                      ),
                    ] else ...[
                      Icon(
                        LucideIcons.wallet,
                        size: 20,
                        color: AppColor.globalTextSecondary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Pilih Pembayaran",
                          style: pSemiBold14.copyWith(
                            color: AppColor.globalTextSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        LucideIcons.chevronRight,
                        size: 18,
                        color: AppColor.globalTextSecondary,
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInfoDonatur() {
    final controller = Get.find<CharityPaymentController>();
    return Container(
      width: Get.width,
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.globalBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Informasi Donatur",
            style: pSemiBold14.copyWith(
              color: AppColor.globalTextSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller.nameController,
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            style: pMedium14.copyWith(
              color: AppColor.globalTextSecondary,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              hintText: "Nama Lengkap",
              hintStyle: pRegular12.copyWith(
                color: AppColor.globalTextSecondary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColor.globalBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColor.globalBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColor.globalBorder),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Sembunyikan nama saya (anonim)",
                style: pMedium12.copyWith(color: AppColor.globalTextSecondary),
              ),
              Obx(
                () => Switch(
                  value: controller.isAnonymous.value,
                  onChanged: (value) => controller.isAnonymous.value = value,
                  activeColor: AppColor.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller.phoneController,
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            keyboardType: TextInputType.phone,
            style: pMedium14.copyWith(
              color: AppColor.globalTextSecondary,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              hintText: "Nomor WhatsApp",
              hintStyle: pRegular12.copyWith(
                color: AppColor.globalTextSecondary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColor.globalBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColor.globalBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColor.globalBorder),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      hintText: hint,
      hintStyle: pRegular12.copyWith(color: AppColor.globalTextSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColor.globalBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColor.globalBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColor.globalBorder),
      ),
    );
  }

  Widget _buildPilihOpsi() {
    final controller = Get.find<CharityPaymentController>();
    final isPatungan = controller.formType == 'patungan';
    final formatter = NumberFormat.decimalPattern('id');

    return Container(
      width: Get.width,
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.globalBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Pilih Opsi",
            style: pSemiBold14.copyWith(
              color: AppColor.globalTextSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          ...controller.campaignOptions!.map((option) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Obx(() {
                final isSelected =
                    controller.selectedOption.value?.id == option.id;
                return GestureDetector(
                  onTap: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    controller.selectOption(option);
                  },
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColor.primaryColor.withOpacity(0.06)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppColor.primaryColor
                            : AppColor.globalBorder,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                option.name,
                                style: pSemiBold14.copyWith(
                                  color: isSelected
                                      ? AppColor.primaryColor
                                      : AppColor.globalTextSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Rp${formatter.format(controller.parsePrice(option.price))}"
                                "${isPatungan ? ' • maks. ${option.slot} nama' : ' / unit'}",
                                style: pMedium12.copyWith(
                                  color: AppColor.globalTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            LucideIcons.check,
                            size: 16,
                            color: AppColor.primaryColor,
                          ),
                      ],
                    ),
                  ),
                );
              }),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStepperButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColor.globalBorder),
        ),
        child: Icon(icon, size: 16, color: AppColor.globalTextSecondary),
      ),
    );
  }

  /// Patungan: nama peserta (maks. sesuai slot). Satuan: jumlah unit + nama per unit.
  Widget _buildPeserta() {
    final controller = Get.find<CharityPaymentController>();
    final isPatungan = controller.formType == 'patungan';

    return Container(
      width: Get.width,
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.globalBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPatungan ? "Peserta Patungan" : "Jumlah Donasi",
                      style: pSemiBold14.copyWith(
                        color: AppColor.globalTextSecondary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (isPatungan)
                      Obx(() {
                        // Slot depends on the selected option.
                        controller.selectedOption.value;
                        return Text(
                          "Maksimal ${controller.maxParticipants} nama",
                          style: pRegular12.copyWith(
                            color: AppColor.globalTextSecondary,
                          ),
                        );
                      }),
                  ],
                ),
              ),
              _buildStepperButton(
                LucideIcons.minus,
                controller.decrementQuantity,
              ),
              SizedBox(
                width: 40,
                child: Obx(
                  () => Text(
                    "${controller.quantity.value}",
                    textAlign: TextAlign.center,
                    style: pSemiBold14.copyWith(
                      color: AppColor.globalTextSecondary,
                    ),
                  ),
                ),
              ),
              _buildStepperButton(
                LucideIcons.plus,
                controller.incrementQuantity,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            isPatungan ? "Nama peserta" : "Atas nama",
            style: pMedium12.copyWith(
              color: AppColor.globalTextSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Obx(
            () => Column(
              children: [
                for (
                  var i = 0;
                  i < controller.qurbanNameControllers.length;
                  i++
                )
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: TextField(
                      controller: controller.qurbanNameControllers[i],
                      onTapOutside: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      textCapitalization: TextCapitalization.words,
                      style: pMedium14.copyWith(
                        color: AppColor.globalTextSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: _fieldDecoration(
                        isPatungan ? "Nama peserta ${i + 1}" : "Nama ${i + 1}",
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNominalInfaq() {
    final controller = Get.find<CharityPaymentController>();
    final isFixed = controller.isNominalFixed;
    final List<int> nominalInfaq = [25000, 50000, 100000, 200000];

    return Container(
      width: Get.width,
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.globalBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isFixed ? "Total Infaq" : "Pilih Nominal Infaq",
            style: pSemiBold14.copyWith(
              color: AppColor.globalTextSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          if (!isFixed)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: nominalInfaq.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 3.8,
              ),
              itemBuilder: (context, index) {
                final valString = nominalInfaq[index].toString();
                return Obx(() {
                  final isSelected =
                      controller.selectedNominal.value.replaceAll('.', '') ==
                      valString;
                  return GestureDetector(
                    onTap: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      final formatted = NumberFormat.decimalPattern(
                        'id',
                      ).format(nominalInfaq[index]);
                      controller.nominalController.text = formatted;
                      controller.nominalController.selection =
                          TextSelection.collapsed(offset: formatted.length);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColor.primaryColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? AppColor.primaryColor
                              : AppColor.globalBorder,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        "Rp${NumberFormat.decimalPattern('id').format(nominalInfaq[index])}",
                        style: pMedium12.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : AppColor.globalTextSecondary,
                        ),
                      ),
                    ),
                  );
                });
              },
            ),
          if (!isFixed) ...[
            const SizedBox(height: 14),
            Text(
              "Nominal lainnya",
              style: pMedium12.copyWith(
                color: AppColor.globalTextSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
          ],
          TextField(
            controller: controller.nominalController,
            readOnly: isFixed,
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              CurrencyInputFormatter(),
            ],
            keyboardType: TextInputType.number,
            style: pMedium16.copyWith(
              color: AppColor.globalTextSecondary,
              fontWeight: FontWeight.w800,
            ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              hintText: "Masukkan nominal",
              hintStyle: pRegular12.copyWith(
                color: AppColor.globalTextSecondary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColor.globalBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColor.globalBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColor.globalBorder),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Payment Method Bottom Sheet ─────────────────────────────────────────────

void _showPaymentMethodBottomSheet(
  BuildContext context,
  CharityPaymentController controller,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: context.theme.colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    isScrollControlled: true,
    builder: (_) {
      return DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.35,
        maxChildSize: 0.85,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColor.globalBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 16, 12),
                child: Row(
                  children: [
                    Text(
                      'Metode Pembayaran',
                      style: pBold16.copyWith(
                        color: context.theme.colorScheme.onSurface,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: context.theme.colorScheme.onSurface
                              .withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: AppColor.globalTextSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: AppColor.globalBorder),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppColor.primaryColor,
                        strokeWidth: 2,
                      ),
                    );
                  }
                  return ListView.separated(
                    controller: scrollController,
                    itemCount: controller.paymentMethods.length,
                    padding: const EdgeInsets.all(12),
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final method = controller.paymentMethods[index];
                      return Obx(() {
                        final isSelected =
                            controller.selectedPaymentMethod.value?.id ==
                            method.id;
                        return InkWell(
                          onTap: () {
                            controller.selectPaymentMethod(method);
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColor.primaryColor.withOpacity(0.04)
                                  : context.theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? (AppColor.primaryColor)
                                    : (AppColor.globalBorder),
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Logo
                                Container(
                                  width: 44,
                                  height: 32,
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(),
                                  child:
                                      method.logo != null &&
                                          method.logo!.isNotEmpty
                                      ? (method.logo!.contains('.svg')
                                            ? SvgPicture.network(
                                                method.logo!,
                                                fit: BoxFit.contain,
                                                errorBuilder: (_, __, ___) =>
                                                    Icon(
                                                      LucideIcons.wallet,
                                                      size: 16,
                                                      color: AppColor
                                                          .globalTextSecondary,
                                                    ),
                                                placeholderBuilder: (_) =>
                                                    const Center(
                                                      child: SizedBox(
                                                        width: 10,
                                                        height: 10,
                                                        child:
                                                            CircularProgressIndicator(
                                                              strokeWidth: 1.5,
                                                            ),
                                                      ),
                                                    ),
                                              )
                                            : Image.network(
                                                method.logo!,
                                                fit: BoxFit.contain,
                                                errorBuilder: (_, __, ___) =>
                                                    Icon(
                                                      LucideIcons.wallet,
                                                      size: 16,
                                                      color: AppColor
                                                          .globalTextSecondary,
                                                    ),
                                              ))
                                      : Icon(
                                          LucideIcons.wallet,
                                          size: 16,
                                          color: AppColor.globalTextSecondary,
                                        ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    method.name,
                                    style: pSemiBold14.copyWith(
                                      color: isSelected
                                          ? (AppColor.primaryColor)
                                          : context.theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                // Radio indicator
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: isSelected
                                      ? const Icon(
                                          LucideIcons.check,
                                          size: 13,
                                          color: AppColor.primaryColor,
                                        )
                                      : null,
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
