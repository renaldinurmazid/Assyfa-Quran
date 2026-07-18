import 'package:flutter/material.dart';
import 'package:flutter/services.dart' hide TextInput;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';
import 'package:quran_app/widgets/app_toast.dart';
import 'package:quran_app/widgets/text_input.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:quran_app/screen/haji&umrah/register/register_controller.dart';

class HajiAndUmrahRegisterScreen extends StatelessWidget {
  const HajiAndUmrahRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HajiAndUmrahRegisterController());
    final currencyFormat = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Obx(() {
      if (controller.isSuccess.value) {
        return _buildSuccessView(context, controller, currencyFormat);
      }

      return Scaffold(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text('Pendaftaran Umrah', style: pBold16),
          backgroundColor: context.theme.scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: context.theme.colorScheme.onSurface,
              size: 18,
            ),
            onPressed: () => Get.back(),
          ),
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPackageHeader(context, controller, currencyFormat),
                const SizedBox(height: 16),
                _buildOrderTypeSection(context, controller),
                const SizedBox(height: 16),
                _buildJemaahListSection(context, controller),
                const SizedBox(height: 16),
                _buildContactSection(context, controller),
                const SizedBox(height: 16),
                _buildPaymentTypeSection(context, controller, currencyFormat),
                const SizedBox(height: 16),
                _buildPaymentMethodSection(context, controller),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomButton(
          context,
          controller,
          currencyFormat,
        ),
      );
    });
  }

  // --- STEP HEADER BUILDER ---
  Widget _buildStepHeader(BuildContext context, String step, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColor.primaryColorDark,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(step, style: pBold10.copyWith(color: Colors.white)),
        ),
        const SizedBox(width: 10),
        Text(title, style: pBold14),
      ],
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildPackageHeader(
    BuildContext context,
    HajiAndUmrahRegisterController controller,
    NumberFormat currencyFormat,
  ) {
    final package = controller.package;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: context.isDarkMode
              ? [Colors.grey.shade900, const Color(0xFF0F0F0F)]
              : [
                  AppColor.primaryColor.withOpacity(0.06),
                  AppColor.primaryColorDark.withOpacity(0.04),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.primaryColorDark.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColor.primaryColorDark.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              IconlyLight.info_square,
              color: AppColor.primaryColorDark,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  package.title ?? 'Paket Umrah',
                  style: pBold14.copyWith(
                    color: context.theme.colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  currencyFormat.format(controller.packagePriceAmount),
                  style: pBold16.copyWith(color: AppColor.primaryColorDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTypeSection(
    BuildContext context,
    HajiAndUmrahRegisterController controller,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.isDarkMode
              ? Colors.grey.shade900
              : Colors.grey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(context, "Langkah 1", "Tipe Pesanan"),
          const SizedBox(height: 16),
          Obx(() {
            final isPerorangan = controller.orderType.value == 'Perorangan';
            return Row(
              children: [
                Expanded(
                  child: _buildSelectableCard(
                    context: context,
                    isSelected: isPerorangan,
                    title: 'Perorangan',
                    icon: IconlyLight.user,
                    onTap: () => controller.setOrderType('Perorangan'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSelectableCard(
                    context: context,
                    isSelected: !isPerorangan,
                    title: 'Keluarga',
                    icon: IconlyLight.user_1,
                    onTap: () => controller.setOrderType('Keluarga'),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSelectableCard({
    required BuildContext context,
    required bool isSelected,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final activeColor = AppColor.primaryColorDark;
    final inactiveBorderColor = context.isDarkMode
        ? Colors.grey.shade800
        : Colors.grey.shade200;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withOpacity(0.04)
              : context.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? activeColor : inactiveBorderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? activeColor.withOpacity(0.1)
                    : (context.isDarkMode
                          ? Colors.grey.shade900
                          : Colors.grey.shade100),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? activeColor : Colors.grey,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: pBold12.copyWith(
                  color: isSelected
                      ? activeColor
                      : context.theme.colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? activeColor : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: activeColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJemaahListSection(
    BuildContext context,
    HajiAndUmrahRegisterController controller,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.isDarkMode
              ? Colors.grey.shade900
              : Colors.grey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildStepHeader(
                  context,
                  "Langkah 2",
                  "Data Calon Jemaah",
                ),
              ),
              Obx(() {
                if (controller.orderType.value == 'Keluarga') {
                  return TextButton.icon(
                    onPressed: () =>
                        _showJemaahBottomSheet(context, controller),
                    icon: const Icon(
                      Icons.add,
                      size: 16,
                      color: AppColor.primaryColorDark,
                    ),
                    label: Text(
                      'Tambah',
                      style: pBold12.copyWith(color: AppColor.primaryColorDark),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.jemaahList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final jemaah = controller.jemaahList[index];
                final isValid = jemaah.isValid;

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isValid
                          ? AppColor.primaryColorDark.withOpacity(0.2)
                          : Colors.amber.shade300.withOpacity(0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.01),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isValid
                              ? AppColor.primaryColorDark.withOpacity(0.1)
                              : Colors.amber.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isValid
                              ? Icons.check_circle
                              : Icons.error_outline_rounded,
                          color: isValid
                              ? AppColor.primaryColorDark
                              : Colors.amber.shade900,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isValid
                                  ? jemaah.name
                                  : 'Lengkapi Data Jemaah ${index + 1}',
                              style: pBold14.copyWith(
                                color: context.theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isValid
                                  ? '${jemaah.relationship} • ${jemaah.gender == 'male' ? 'Laki-laki' : 'Perempuan'}'
                                  : 'Harap isi data calon jemaah',
                              style: pRegular12.copyWith(
                                color: isValid
                                    ? context.theme.colorScheme.onSurfaceVariant
                                    : Colors.amber.shade900,
                                fontStyle: isValid
                                    ? FontStyle.normal
                                    : FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              IconlyLight.edit,
                              color: AppColor.primaryColorDark,
                              size: 20,
                            ),
                            onPressed: () => _showJemaahBottomSheet(
                              context,
                              controller,
                              index: index,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColor.primaryColorDark
                                  .withOpacity(0.06),
                              padding: const EdgeInsets.all(8),
                            ),
                          ),
                          if (controller.jemaahList.length > 1) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(
                                IconlyLight.delete,
                                color: Colors.red,
                                size: 20,
                              ),
                              onPressed: () => controller.removeJemaah(index),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.red.withOpacity(0.06),
                                padding: const EdgeInsets.all(8),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildContactSection(
    BuildContext context,
    HajiAndUmrahRegisterController controller,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.isDarkMode
              ? Colors.grey.shade900
              : Colors.grey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(context, "Langkah 3", "Kontak Penanggung Jawab"),
          const SizedBox(height: 16),
          Text('Nama Lengkap Kontak', style: pBold12),
          const SizedBox(height: 8),
          TextInput(
            controller: controller.contactNameController,
            hintText: 'Nama Lengkap Kontak',
          ),
          const SizedBox(height: 16),
          Text('Nomor WhatsApp Kontak', style: pBold12),
          const SizedBox(height: 8),
          TextInput(
            controller: controller.contactPhoneController,
            hintText: 'Nomor WhatsApp Kontak',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          Text('Catatan Khusus (Opsional)', style: pBold12),
          const SizedBox(height: 8),
          TextInput(
            controller: controller.notesController,
            hintText: 'Misal: Minta kamar dekat lift / kursi roda',
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentTypeSection(
    BuildContext context,
    HajiAndUmrahRegisterController controller,
    NumberFormat currencyFormat,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.isDarkMode
              ? Colors.grey.shade900
              : Colors.grey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(context, "Langkah 4", "Tipe Pembayaran"),
          const SizedBox(height: 16),
          Obx(() {
            final isLunas = controller.paymentType.value == 'Lunas';
            return Column(
              children: [
                _buildPaymentTypeCard(
                  context: context,
                  isSelected: isLunas,
                  title: 'Lunas',
                  subtitle: 'Bayar penuh biaya paket Umrah',
                  onTap: () => controller.paymentType.value = 'Lunas',
                ),
                const SizedBox(height: 12),
                _buildPaymentTypeCard(
                  context: context,
                  isSelected: !isLunas,
                  title: 'Bertahap (DP)',
                  subtitle: 'Bayar uang muka (DP) minimal terlebih dahulu',
                  onTap: () => controller.paymentType.value = 'Bertahap',
                ),
                if (isLunas) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: context.isDarkMode
                          ? Colors.grey.shade900
                          : AppColor.primaryColorDark.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColor.primaryColorDark.withOpacity(0.15),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Harga Paket',
                          style: pBold12.copyWith(
                            color: context.theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '${controller.jemaahList.length} x ${currencyFormat.format(controller.packagePriceAmount)}',
                          style: pBold14.copyWith(
                            color: AppColor.primaryColorDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPaymentTypeCard({
    required BuildContext context,
    required bool isSelected,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final activeColor = AppColor.primaryColorDark;
    final inactiveBorderColor = context.isDarkMode
        ? Colors.grey.shade800
        : Colors.grey.shade200;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withOpacity(0.04)
              : context.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? activeColor : inactiveBorderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: pBold14.copyWith(
                      color: isSelected
                          ? activeColor
                          : context.theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: pRegular12.copyWith(
                      color: context.theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? activeColor : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: activeColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSection(
    BuildContext context,
    HajiAndUmrahRegisterController controller,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.isDarkMode
              ? Colors.grey.shade900
              : Colors.grey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(context, "Langkah 5", "Metode Pembayaran"),
          const SizedBox(height: 16),
          Obx(() {
            final selected = controller.selectedPaymentMethod.value;
            return GestureDetector(
              onTap: () => _showPaymentMethodBottomSheet(context, controller),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected != null
                        ? AppColor.primaryColorDark
                        : (context.isDarkMode
                              ? Colors.grey.shade800
                              : Colors.grey.shade200),
                    width: selected != null ? 2 : 1,
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
                              ? Colors.grey.shade900
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: context.isDarkMode
                                ? Colors.grey.shade800
                                : Colors.grey.shade200,
                          ),
                        ),
                        child: selected.logo.isNotEmpty
                            ? (selected.logo.contains('.svg')
                                  ? SvgPicture.network(
                                      selected.logo,
                                      fit: BoxFit.contain,
                                      placeholderBuilder: (_) => const Center(
                                        child: SizedBox(
                                          width: 12,
                                          height: 12,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Image.network(
                                      selected.logo,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        IconlyLight.wallet,
                                        size: 20,
                                        color: Colors.grey,
                                      ),
                                    ))
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
                          style: pBold14.copyWith(
                            color: AppColor.primaryColorDark,
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
                            color: context.theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                    const Icon(
                      IconlyLight.arrow_right_2,
                      size: 20,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottomButton(
    BuildContext context,
    HajiAndUmrahRegisterController controller,
    NumberFormat currencyFormat,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: context.isDarkMode
                ? Colors.grey.shade900
                : Colors.grey.shade200,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Pembayaran',
                  style: pMedium10.copyWith(
                    color: context.theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Obx(() {
                  return Text(
                    currencyFormat.format(controller.totalPrice),
                    style: pBold18.copyWith(color: AppColor.primaryColorDark),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Obx(() {
            final isValid = controller.isFormValid;
            final isLoading = controller.isLoading.value;

            return ElevatedButton(
              onPressed: (isLoading || !isValid)
                  ? null
                  : controller.submitBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryColorDark,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                elevation: 0,
                disabledBackgroundColor: Colors.grey.shade300,
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Pesan Sekarang',
                      style: pBold14.copyWith(color: Colors.white),
                    ),
            );
          }),
        ],
      ),
    );
  }

  // --- DIALOGS AND BOTTOM SHEETS ---

  void _showJemaahBottomSheet(
    BuildContext context,
    HajiAndUmrahRegisterController controller, {
    int? index,
  }) {
    final isEditing = index != null;
    final sourceJemaah = isEditing
        ? controller.jemaahList[index]
        : JemaahInput();

    final nameController = TextEditingController(text: sourceJemaah.name);
    final phoneController = TextEditingController(
      text: sourceJemaah.phoneNumber,
    );
    final nikController = TextEditingController(
      text: sourceJemaah.identityNumber,
    );
    final genderRx = sourceJemaah.gender.obs;
    final relationshipRx =
        (sourceJemaah.relationship.isEmpty
                ? 'Diri Sendiri'
                : sourceJemaah.relationship)
            .obs;

    final relationships = [
      'Diri Sendiri',
      'Suami',
      'Istri',
      'Anak',
      'Orang Tua',
      'Saudara',
      'Teman',
      'Lainnya',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: context.theme.scaffoldBackgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditing ? 'Edit Calon Jemaah' : 'Tambah Calon Jemaah',
                      style: pBold16,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(height: 12),
                const SizedBox(height: 16),
                Text('Nama Lengkap (sesuai KTP/Paspor)', style: pSemiBold12),
                const SizedBox(height: 8),
                TextInput(controller: nameController, hintText: 'Nama Lengkap'),
                const SizedBox(height: 16),
                Text('Nomor NIK KTP', style: pSemiBold12),
                const SizedBox(height: 8),
                TextInput(
                  controller: nikController,
                  hintText: '16 Digit NIK KTP',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Text('Nomor WhatsApp (Opsional)', style: pSemiBold12),
                const SizedBox(height: 8),
                TextInput(
                  controller: phoneController,
                  hintText: 'Contoh: 081234567890',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                Text('Jenis Kelamin', style: pSemiBold12),
                const SizedBox(height: 8),
                Obx(() {
                  final isMale = genderRx.value == 'male';
                  return Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => genderRx.value = 'male',
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: isMale
                                  ? AppColor.primaryColorDark
                                  : Colors.grey.shade300,
                              width: isMale ? 2 : 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: isMale
                                ? AppColor.primaryColorDark.withOpacity(0.05)
                                : Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            'Laki-laki',
                            style: pSemiBold14.copyWith(
                              color: isMale
                                  ? AppColor.primaryColorDark
                                  : context.theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => genderRx.value = 'female',
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: !isMale
                                  ? AppColor.primaryColorDark
                                  : Colors.grey.shade300,
                              width: !isMale ? 2 : 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: !isMale
                                ? AppColor.primaryColorDark.withOpacity(0.05)
                                : Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            'Perempuan',
                            style: pSemiBold14.copyWith(
                              color: !isMale
                                  ? AppColor.primaryColorDark
                                  : context.theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 16),
                Text('Hubungan Keluarga', style: pSemiBold12),
                const SizedBox(height: 8),
                Obx(() {
                  return DropdownButtonFormField<String>(
                    initialValue: relationshipRx.value,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
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
                          color: AppColor.primaryColorDark,
                        ),
                      ),
                    ),
                    items: relationships.map((e) {
                      return DropdownMenuItem<String>(
                        value: e,
                        child: Text(e, style: pMedium14),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) relationshipRx.value = val;
                    },
                  );
                }),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (nameController.text.trim().isEmpty) {
                        AppToast.warning(message: 'Nama lengkap harus diisi');
                        return;
                      }

                      final input = JemaahInput(
                        name: nameController.text.trim(),
                        gender: genderRx.value,
                        identityNumber: nikController.text.trim(),
                        phoneNumber: phoneController.text.trim(),
                        relationship: relationshipRx.value,
                      );

                      if (isEditing) {
                        controller.updateJemaah(index, input);
                      } else {
                        controller.addJemaah(input);
                      }

                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryColorDark,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Simpan',
                      style: pSemiBold14.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPaymentMethodBottomSheet(
    BuildContext context,
    HajiAndUmrahRegisterController controller,
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
                paddingHeader(context),
                const Divider(height: 1),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColor.primaryColorDark,
                        ),
                      );
                    }
                    if (controller.paymentMethods.isEmpty) {
                      return const Center(
                        child: Text('Tidak ada metode pembayaran'),
                      );
                    }
                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.all(20),
                      itemCount: controller.paymentMethods.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final method = controller.paymentMethods[index];
                        final isSelected =
                            controller.selectedPaymentMethod.value?.id ==
                            method.id;

                        return GestureDetector(
                          onTap: () {
                            controller.selectedPaymentMethod.value = method;
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: context.theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? AppColor.primaryColorDark
                                    : Colors.transparent,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
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
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: context.isDarkMode
                                        ? Colors.grey.shade900
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: context.isDarkMode
                                          ? Colors.grey.shade800
                                          : Colors.grey.shade200,
                                    ),
                                  ),
                                  child: method.logo.isNotEmpty
                                      ? (method.logo.contains('.svg')
                                            ? SvgPicture.network(
                                                method.logo,
                                                fit: BoxFit.contain,
                                                placeholderBuilder: (_) =>
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
                                            : Image.network(
                                                method.logo,
                                                fit: BoxFit.contain,
                                                errorBuilder: (_, __, ___) =>
                                                    const Icon(
                                                      IconlyLight.wallet,
                                                      size: 20,
                                                      color: Colors.grey,
                                                    ),
                                              ))
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
                                    style: pBold14.copyWith(
                                      color: isSelected
                                          ? AppColor.primaryColorDark
                                          : context.theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle,
                                    color: AppColor.primaryColorDark,
                                    size: 24,
                                  ),
                              ],
                            ),
                          ),
                        );
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

  Widget paddingHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Text(
            'Pilih Metode Pembayaran',
            style: pBold16.copyWith(color: context.theme.colorScheme.onSurface),
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
    );
  }

  // --- SUCCESS VIEW SCREEN (Upgraded Ticket style mockup) ---

  Widget _buildSuccessView(
    BuildContext context,
    HajiAndUmrahRegisterController controller,
    NumberFormat currencyFormat,
  ) {
    final result = controller.bookingResult;
    final booking = result['booking'] ?? {};
    final payment = result['payment'] ?? {};
    final paymentMethod = payment['payment_methode'] ?? {};
    final instructionsList = result['instructions'] as List<dynamic>? ?? [];

    final String bookingCode = booking['booking_code'] ?? '-';
    final double totalAmount =
        double.tryParse(booking['total_amount']?.toString() ?? '') ?? 0.0;
    final String contactName = booking['contact_name'] ?? '-';

    final String bankName = paymentMethod['bank_name'] ?? '-';
    final String accNo = paymentMethod['account_number'] ?? '-';
    final String accName = paymentMethod['account_name'] ?? '-';

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Pendaftaran Selesai', style: pBold16),
        backgroundColor: context.theme.scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: context.theme.colorScheme.onSurface),
            onPressed: () {
              Get.back();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColor.primaryColorDark.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColor.primaryColorDark,
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Pendaftaran Berhasil!',
                style: pBold20.copyWith(
                  color: context.theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Satu langkah lagi untuk konfirmasi pendaftaran. Silakan lakukan pembayaran sesuai petunjuk berikut.',
                style: pRegular12.copyWith(
                  color: context.theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Booking details card (Styled as a receipt/ticket)
              Container(
                padding: const EdgeInsets.all(16),
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
                      color: Colors.black.withOpacity(0.01),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildSuccessRow(
                      context,
                      label: 'Kode Booking',
                      value: bookingCode,
                      isCopyable: true,
                    ),
                    const Divider(height: 24),
                    _buildSuccessRow(
                      context,
                      label: 'Nama Pendaftar',
                      value: contactName,
                    ),
                    const Divider(height: 24),
                    _buildSuccessRow(
                      context,
                      label: 'Total Pembayaran',
                      value: currencyFormat.format(totalAmount),
                      isCopyable: true,
                      rawValue: totalAmount.toStringAsFixed(0),
                      valueColor: AppColor.primaryColorDark,
                      isBold: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Premium credit-card mockup for transfer destination
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF123524), Color(0xFF1E563B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.primaryColor.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'REKENING TUJUAN TRANSFER',
                          style: pBold10.copyWith(
                            color: const Color(0xFFD4AF37),
                            letterSpacing: 1.2,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            bankName,
                            style: pBold12.copyWith(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            accNo,
                            style: GoogleFonts.shareTechMono(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: accNo));
                            AppToast.success(message: 'Nomor rekening disalin');
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              IconlyLight.document,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ATAS NAMA',
                              style: pRegular10.copyWith(
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              accName,
                              style: pBold14.copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                        const Icon(
                          Icons.verified_user_outlined,
                          color: Color(0xFFD4AF37),
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Instructions list
              if (instructionsList.isNotEmpty) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Petunjuk Transfer', style: pBold14),
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: instructionsList.length,
                  itemBuilder: (context, idx) {
                    final instruction = instructionsList[idx];
                    final String title = instruction['title'] ?? 'Langkah';
                    final steps = instruction['steps'] as List<dynamic>? ?? [];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: context.isDarkMode
                              ? Colors.grey.shade900
                              : Colors.grey.shade100,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: pBold12.copyWith(
                              color: AppColor.primaryColorDark,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...steps.asMap().entries.map((entry) {
                            final stepIdx = entry.key + 1;
                            final stepText = entry.value.toString();

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$stepIdx. ',
                                    style: pBold12.copyWith(
                                      color: AppColor.primaryColorDark,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      stepText,
                                      style: pRegular12.copyWith(
                                        color:
                                            context.theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  },
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
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
        child: ElevatedButton.icon(
          onPressed: () async {
            const String adminPhone = "6285797890027";
            final String waMessage =
                "Assalamu'alaikum Admin Assyfa, saya ingin konfirmasi pembayaran untuk pendaftaran Umrah.\n\n"
                "Kode Booking: $bookingCode\n"
                "Nama Kontak: $contactName\n"
                "Total Pembayaran: ${currencyFormat.format(totalAmount)}\n\n"
                "Saya akan melampirkan bukti transfernya.";

            final Uri whatsappUrl = Uri.parse(
              "https://wa.me/$adminPhone?text=${Uri.encodeFull(waMessage)}",
            );

            if (await canLaunchUrl(whatsappUrl)) {
              await launchUrl(
                whatsappUrl,
                mode: LaunchMode.externalApplication,
              );
            } else {
              AppToast.error(message: 'Tidak dapat membuka WhatsApp');
            }
          },
          icon: const Icon(
            Icons.chat_bubble_outline_rounded,
            color: Colors.white,
            size: 20,
          ),
          label: Text(
            'Konfirmasi Pembayaran via WhatsApp',
            style: pSemiBold14.copyWith(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primaryColorDark,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            elevation: 0,
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessRow(
    BuildContext context, {
    required String label,
    required String value,
    bool isCopyable = false,
    String? rawValue,
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: pMedium12.copyWith(
              color: context.theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  value,
                  style: (isBold ? pBold14 : pSemiBold14).copyWith(
                    color: valueColor ?? context.theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
              if (isCopyable) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: rawValue ?? value));
                    AppToast.success(message: '$label disalin ke papan klip');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColor.primaryColorDark.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      IconlyLight.document,
                      color: AppColor.primaryColorDark,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
