import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/screen/mosque/mosque_charity_payment_controller.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';

// ─── Color tokens (same as CharityPaymentDetailScreen) ───────────────────────
const _kBgDark = Color(0xFF0F0F10);
const _kBgLight = Color(0xFFF8FAFC);
const _kSurfaceDark = Color(0xFF18181B);
const _kSurfaceLight = Colors.white;
const _kBorderDark = Color(0xFF27272A);
const _kBorderLight = Color(0xFFE2E8F0);

class CurrencyMosqueInputFormatter extends TextInputFormatter {
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

class MosqueCharityPaymentScreen extends StatelessWidget {
  const MosqueCharityPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<MosqueCharityPaymentController>()
        ? Get.find<MosqueCharityPaymentController>()
        : Get.put(MosqueCharityPaymentController());

    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? _kBgDark : _kBgLight,
      appBar: AppBar(
        title: Text(
          'Infaq Masjid',
          style: pBold16.copyWith(
            color: context.theme.colorScheme.onSurface,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.04),
              shape: BoxShape.circle,
            ),
            child: Icon(
              IconlyLight.arrow_left,
              size: 20,
              color: context.theme.colorScheme.onSurface,
            ),
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step 1: Nominal Infaq
            _buildSection(
              context: context,
              label: '01',
              title: 'Nominal Infaq',
              child: _buildNominalSection(context, controller),
            ),

            const SizedBox(height: 16),

            // Step 2: Donor Data
            _buildSection(
              context: context,
              label: '02',
              title: 'Data Donatur',
              child: _buildDonorSection(context, controller),
            ),

            const SizedBox(height: 16),

            // Step 3: Payment Method
            _buildSection(
              context: context,
              label: '03',
              title: 'Metode Pembayaran',
              child: _buildPaymentMethodSection(context, controller),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context, controller, isDark),
    );
  }

  // ── Section wrapper ────────────────────────────────────────────────────────

  Widget _buildSection({
    required BuildContext context,
    required String label,
    required String title,
    required Widget child,
  }) {
    final isDark = context.isDarkMode;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? _kSurfaceDark : _kSurfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? _kBorderDark : _kBorderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Text(
              title,
              style: pSemiBold14.copyWith(
                color: context.theme.colorScheme.onSurface,
                letterSpacing: -0.2,
              ),
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: isDark ? _kBorderDark : _kBorderLight,
          ),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }

  // ── Input field ────────────────────────────────────────────────────────────

  Widget _buildInputField({
    required BuildContext context,
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
  }) {
    final isDark = context.isDarkMode;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF27272A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF3F3F46) : _kBorderLight,
        ),
      ),
      child: TextField(
        controller: controller,
        cursorColor: isDark ? AppColor.primaryColorDark : AppColor.primaryColor,
        style: pSemiBold14.copyWith(color: context.theme.colorScheme.onSurface),
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: pRegular14.copyWith(
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
        ),
      ),
    );
  }

  // ── Nominal section ────────────────────────────────────────────────────────

  Widget _buildNominalSection(
    BuildContext context,
    MosqueCharityPaymentController controller,
  ) {
    final isDark = context.isDarkMode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF27272A) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF3F3F46) : _kBorderLight,
            ),
          ),
          child: Row(
            children: [
              Text(
                'Rp',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColor.primaryColorDark
                      : AppColor.primaryColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller.nominalController,
                  cursorColor: isDark
                      ? AppColor.primaryColorDark
                      : AppColor.primaryColor,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: context.theme.colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.end,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    CurrencyMosqueInputFormatter(),
                  ],
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? Colors.grey.shade700
                          : Colors.grey.shade300,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
              ),
              Obx(() {
                if (controller.selectedNominal.value.isNotEmpty) {
                  return GestureDetector(
                    onTap: () => controller.nominalController.clear(),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Icon(
                        Icons.cancel_rounded,
                        size: 18,
                        color: isDark
                            ? Colors.grey.shade600
                            : Colors.grey.shade400,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Pilihan Cepat',
          style: pRegular12.copyWith(
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChip(context, controller, 'Rp10.000', '10000'),
            _buildChip(context, controller, 'Rp25.000', '25000'),
            _buildChip(context, controller, 'Rp50.000', '50000'),
            _buildChip(context, controller, 'Rp100.000', '100000'),
            _buildChip(context, controller, 'Rp250.000', '250000'),
            _buildChip(context, controller, 'Rp500.000', '500000'),
          ],
        ),
      ],
    );
  }

  Widget _buildChip(
    BuildContext context,
    MosqueCharityPaymentController controller,
    String label,
    String value,
  ) {
    final isDark = context.isDarkMode;
    return Obx(() {
      final isSelected =
          controller.selectedNominal.value.replaceAll('.', '') == value;
      return GestureDetector(
        onTap: () {
          final formatted = NumberFormat.decimalPattern(
            'id',
          ).format(double.parse(value));
          controller.nominalController.text = formatted;
          controller.nominalController.selection = TextSelection.collapsed(
            offset: formatted.length,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppColor.primaryColorDark : AppColor.primaryColor)
                : (isDark ? const Color(0xFF27272A) : Colors.white),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? (isDark ? AppColor.primaryColorDark : AppColor.primaryColor)
                  : (isDark ? const Color(0xFF3F3F46) : _kBorderLight),
            ),
          ),
          child: Text(
            label,
            style: pSemiBold12.copyWith(
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
            ),
          ),
        ),
      );
    });
  }

  // ── Donor section ──────────────────────────────────────────────────────────

  Widget _buildDonorSection(
    BuildContext context,
    MosqueCharityPaymentController controller,
  ) {
    final isDark = context.isDarkMode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputField(
          context: context,
          controller: controller.nameController,
          hintText: 'Nama Lengkap',
        ),
        const SizedBox(height: 10),
        Obx(
          () => InkWell(
            onTap: () =>
                controller.isAnonymous.value = !controller.isAnonymous.value,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF27272A)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: controller.isAnonymous.value
                      ? (isDark
                            ? AppColor.primaryColorDark
                            : AppColor.primaryColor)
                      : (isDark ? const Color(0xFF3F3F46) : _kBorderLight),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sembunyikan nama (Hamba Allah)',
                          style: pSemiBold12.copyWith(
                            color: context.theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Nama tidak akan ditampilkan ke publik',
                          style: pRegular10.copyWith(
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Switch.adaptive(
                    value: controller.isAnonymous.value,
                    onChanged: (val) => controller.isAnonymous.value = val,
                    activeColor: isDark
                        ? AppColor.primaryColorDark
                        : AppColor.primaryColor,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _buildInputField(
          context: context,
          controller: controller.phoneController,
          hintText: 'Nomor WhatsApp',
          keyboardType: TextInputType.phone,
        ),
        if (AuthController.to.userData['phone_number'] == null) ...[
          const SizedBox(height: 10),
          _buildInfoBanner(
            isDark: isDark,
            message:
                'Lengkapi nomor telepon di profil agar transaksi berikutnya lebih praktis.',
            color: Colors.amber,
          ),
        ],
      ],
    );
  }

  // ── Payment method section ─────────────────────────────────────────────────

  Widget _buildPaymentMethodSection(
    BuildContext context,
    MosqueCharityPaymentController controller,
  ) {
    final isDark = context.isDarkMode;
    return Column(
      children: [
        Obx(() {
          final selected = controller.selectedPaymentMethod.value;
          return InkWell(
            onTap: () => _showPaymentMethodBottomSheet(context, controller),
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF27272A)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected != null
                      ? (isDark
                            ? AppColor.primaryColorDark
                            : AppColor.primaryColor)
                      : (isDark ? const Color(0xFF3F3F46) : _kBorderLight),
                  width: selected != null ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  if (selected != null) ...[
                    _buildPaymentLogo(isDark, selected.logo),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selected.name,
                            style: pSemiBold14.copyWith(
                              color: context.theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'Ketuk untuk mengubah',
                            style: pRegular12.copyWith(
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            (isDark
                                    ? AppColor.primaryColorDark
                                    : AppColor.primaryColor)
                                .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Ubah',
                        style: pSemiBold10.copyWith(
                          color: isDark
                              ? AppColor.primaryColorDark
                              : AppColor.primaryColor,
                        ),
                      ),
                    ),
                  ] else ...[
                    Container(
                      width: 40,
                      height: 30,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF3F3F46) : _kBorderLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.wallet_rounded,
                        size: 16,
                        color: isDark
                            ? Colors.grey.shade500
                            : Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pilih Metode Pembayaran',
                            style: pSemiBold14.copyWith(
                              color: context.theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'Virtual Account, QRIS, Transfer Bank',
                            style: pRegular12.copyWith(
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: isDark
                          ? Colors.grey.shade600
                          : Colors.grey.shade400,
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
        _buildInfoBanner(
          isDark: isDark,
          message:
              'Dana disalurkan secara amanah untuk masjid, bebas dari pencucian uang, terorisme, dan tindak pidana lainnya.',
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildPaymentLogo(bool isDark, String? logoUrl) {
    return Container(
      width: 44,
      height: 32,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF27272A) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF3F3F46) : _kBorderLight,
        ),
      ),
      child: logoUrl != null && logoUrl.isNotEmpty
          ? (logoUrl.contains('.svg')
                ? SvgPicture.network(
                    logoUrl,
                    fit: BoxFit.contain,
                    placeholderBuilder: (_) => const Center(
                      child: SizedBox(
                        width: 10,
                        height: 10,
                        child: CircularProgressIndicator(strokeWidth: 1.5),
                      ),
                    ),
                  )
                : Image.network(
                    logoUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      IconlyLight.wallet,
                      size: 16,
                      color: isDark
                          ? Colors.grey.shade600
                          : Colors.grey.shade400,
                    ),
                  ))
          : Icon(
              IconlyLight.wallet,
              size: 16,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
    );
  }

  // ── Info banner ────────────────────────────────────────────────────────────

  Widget _buildInfoBanner({
    required bool isDark,
    required String message,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.08 : 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: isDark ? 0.2 : 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 14,
            color: color.withValues(alpha: isDark ? 0.7 : 0.8),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: pRegular10.copyWith(
                color: color.withValues(alpha: isDark ? 0.7 : 0.85),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom bar ─────────────────────────────────────────────────────────────

  Widget _buildBottomBar(
    BuildContext context,
    MosqueCharityPaymentController controller,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: isDark ? _kSurfaceDark : Colors.white,
        border: Border(
          top: BorderSide(color: isDark ? _kBorderDark : _kBorderLight),
        ),
      ),
      child: Obx(() {
        final isReady = controller.isFormValid && !controller.isLoading.value;
        return Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Pembayaran',
                    style: pRegular12.copyWith(
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    controller.selectedNominal.value.isEmpty
                        ? 'Rp 0'
                        : 'Rp ${controller.selectedNominal.value}',
                    style: pBold18.copyWith(
                      color: isDark
                          ? AppColor.primaryColorDark
                          : AppColor.primaryColor,
                      letterSpacing: -0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: isReady ? controller.submitDonation : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                  disabledBackgroundColor: AppColor.primaryColor.withValues(
                    alpha: 0.4,
                  ),
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white.withValues(alpha: 0.5),
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
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
                        'Lanjutkan',
                        style: pSemiBold14.copyWith(color: Colors.white),
                      ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ─── Payment Method Bottom Sheet ─────────────────────────────────────────────

void _showPaymentMethodBottomSheet(
  BuildContext context,
  MosqueCharityPaymentController controller,
) {
  final isDark = context.isDarkMode;

  showModalBottomSheet(
    context: context,
    backgroundColor: isDark ? _kSurfaceDark : Colors.white,
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
                  color: isDark
                      ? const Color(0xFF3F3F46)
                      : Colors.grey.shade300,
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
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
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
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.04),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: isDark ? _kBorderDark : _kBorderLight),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: isDark
                            ? AppColor.primaryColorDark
                            : AppColor.primaryColor,
                        strokeWidth: 2,
                      ),
                    );
                  }
                  return ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: controller.paymentMethods.length,
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
                                  ? (isDark
                                        ? AppColor.primaryColor.withValues(
                                            alpha: 0.12,
                                          )
                                        : AppColor.primaryColor.withValues(
                                            alpha: 0.04,
                                          ))
                                  : (isDark
                                        ? const Color(0xFF27272A)
                                        : const Color(0xFFF8FAFC)),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? (isDark
                                          ? AppColor.primaryColorDark
                                          : AppColor.primaryColor)
                                    : (isDark
                                          ? const Color(0xFF3F3F46)
                                          : _kBorderLight),
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
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF18181B)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isDark
                                          ? const Color(0xFF3F3F46)
                                          : _kBorderLight,
                                    ),
                                  ),
                                  child:
                                      method.logo != null &&
                                          method.logo!.isNotEmpty
                                      ? (method.logo!.contains('.svg')
                                            ? SvgPicture.network(
                                                method.logo!,
                                                fit: BoxFit.contain,
                                                errorBuilder: (_, __, ___) =>
                                                    Icon(
                                                      IconlyLight.wallet,
                                                      size: 16,
                                                      color: isDark
                                                          ? Colors.grey.shade600
                                                          : Colors
                                                                .grey
                                                                .shade400,
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
                                                      IconlyLight.wallet,
                                                      size: 16,
                                                      color: isDark
                                                          ? Colors.grey.shade600
                                                          : Colors
                                                                .grey
                                                                .shade400,
                                                    ),
                                              ))
                                      : Icon(
                                          IconlyLight.wallet,
                                          size: 16,
                                          color: isDark
                                              ? Colors.grey.shade600
                                              : Colors.grey.shade400,
                                        ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    method.name,
                                    style: pSemiBold14.copyWith(
                                      color: isSelected
                                          ? (isDark
                                                ? AppColor.primaryColorDark
                                                : AppColor.primaryColor)
                                          : context.theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                // Radio indicator
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? (isDark
                                              ? AppColor.primaryColorDark
                                              : AppColor.primaryColor)
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected
                                          ? (isDark
                                                ? AppColor.primaryColorDark
                                                : AppColor.primaryColor)
                                          : (isDark
                                                ? Colors.grey.shade600
                                                : Colors.grey.shade400),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                          Icons.check,
                                          size: 13,
                                          color: Colors.white,
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
