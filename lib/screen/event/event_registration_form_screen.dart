import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:quran_app/models/event_model.dart';
import 'package:quran_app/screen/event/event_registration_form_controller.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';
import 'package:url_launcher/url_launcher.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
const _kBgDark = Color(0xFF0D0D0F);
const _kBgLight = Color(0xFFF6F7F9);
const _kSurfaceDark = Color(0xFF16161A);
const _kSurfaceLight = Colors.white;
const _kBorderDark = Color(0xFF242428);
const _kBorderLight = Color(0xFFEAECF0);
const _kSubtleDark = Color(0xFF1E1E24);
const _kSubtleLight = Color(0xFFF3F4F6);
const _kTextMutedDark = Color(0xFF9CA3AF);
const _kTextMutedLight = Color(0xFF6B7280);

class EventRegistrationFormScreen extends StatelessWidget {
  const EventRegistrationFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EventRegistrationFormController());
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? _kBgDark : _kBgLight,
      appBar: AppBar(
        backgroundColor: isDark ? _kSurfaceDark : _kSurfaceLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: isDark ? Colors.white : const Color(0xFF111827),
          ),
        ),
        title: Text(
          'Pendaftaran Event',
          style: pSemiBold16.copyWith(
            color: isDark ? Colors.white : const Color(0xFF111827),
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: isDark ? _kBorderDark : _kBorderLight,
            height: 1,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.event.value == null) {
          return Center(
            child: CircularProgressIndicator(
              color: AppColor.primaryColor,
              strokeWidth: 2.5,
            ),
          );
        }

        final event = controller.event.value!;

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Event Summary Card ──
                      _buildEventSummary(event, isDark),
                      const SizedBox(height: 20),

                      // ── Section 1: Data Pribadi ──
                      _buildCardSection(
                        isDark: isDark,
                        icon: IconlyBold.profile,
                        title: 'Data Pribadi',
                        subtitle: 'Pastikan informasi kontak Anda sesuai dan aktif',
                        children: [
                          _buildTextField(
                            isDark: isDark,
                            controller: controller.nameController,
                            label: 'Nama Lengkap',
                            hint: 'Masukkan nama lengkap Anda',
                            icon: IconlyLight.profile,
                            isRequired: true,
                            validator: (val) => val == null || val.trim().isEmpty
                                ? 'Nama lengkap wajib diisi'
                                : null,
                          ),
                          const SizedBox(height: 14),
                          _buildTextField(
                            isDark: isDark,
                            controller: controller.emailController,
                            label: 'Email Aktif',
                            hint: 'nama@email.com',
                            icon: IconlyLight.message,
                            isRequired: true,
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Email wajib diisi';
                              }
                              if (!GetUtils.isEmail(val.trim())) {
                                return 'Format email tidak valid';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          _buildTextField(
                            isDark: isDark,
                            controller: controller.phoneController,
                            label: 'Nomor WhatsApp',
                            hint: '081234567890',
                            icon: IconlyLight.call,
                            isRequired: true,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (val) => val == null || val.trim().isEmpty
                                ? 'Nomor WhatsApp wajib diisi'
                                : null,
                          ),
                          const SizedBox(height: 14),
                          _buildTextField(
                            isDark: isDark,
                            controller: controller.domicileController,
                            label: 'Domisili / Kota',
                            hint: 'Contoh: Bandung, Jawa Barat',
                            icon: IconlyLight.location,
                          ),
                          const SizedBox(height: 14),
                          _buildTextField(
                            isDark: isDark,
                            controller: controller.jobActivityController,
                            label: 'Pekerjaan / Aktivitas',
                            hint: 'Contoh: Mahasiswa / Karyawan / Wirausaha',
                            icon: IconlyLight.work,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Section 2: Informasi Tambahan ──
                      _buildCardSection(
                        isDark: isDark,
                        icon: IconlyBold.info_square,
                        title: 'Informasi Tambahan',
                        subtitle: 'Bantu kami mengenal Anda lebih dekat',
                        children: [
                          _buildTextField(
                            isDark: isDark,
                            controller: controller.infoSourceController,
                            label: 'Tahu Info Event Dari Mana?',
                            hint: 'Instagram, Teman, WhatsApp Group, dll',
                            icon: IconlyLight.search,
                          ),
                          const SizedBox(height: 14),
                          _buildTextField(
                            isDark: isDark,
                            controller: controller.communityController,
                            label: 'Asal Komunitas',
                            hint: 'Assyifa / ODOJ / Yakesma / dll',
                            icon: IconlyLight.user_1,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Section 3: Donasi & Bukti Transfer ──
                      _buildCardSection(
                        isDark: isDark,
                        icon: IconlyBold.wallet,
                        title: 'Donasi & Bukti Pembayaran',
                        subtitle: 'Dukungan terbaik untuk kelancaran kegiatan dakwah',
                        children: [
                          _buildTextField(
                            isDark: isDark,
                            controller: controller.operationalDonationController,
                            label: 'Donasi Operasional (Opsional)',
                            hint: 'Nominal donasi sukarela (Rp)',
                            icon: IconlyLight.wallet,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildImagePicker(controller, isDark),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Section 4: Media Sosial ──
                      _buildInstagramCard(controller, isDark),
                    ],
                  ),
                ),
              ),
            ),

            // ── Sticky Bottom Action Bar ──
            _buildBottomBar(context, controller, event, isDark),
          ],
        );
      }),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Mini Event Summary Card
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildEventSummary(EventModel event, bool isDark) {
    final dateFormatted = event.startDate != null
        ? '${DateFormat('dd MMMM yyyy, HH:mm').format(event.startDate!)} WIB'
        : null;

    final isPaid = event.price != null && event.price! > 0;
    final priceLabel = isPaid ? (event.formattedPrice ?? 'Rp ${event.price}') : 'Gratis';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? _kSurfaceDark : _kSurfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? _kBorderDark : _kBorderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: event.thumbnail != null && event.thumbnail!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: event.thumbnail!,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _buildFallbackThumbnail(isDark),
                  )
                : _buildFallbackThumbnail(isDark),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isPaid
                            ? Colors.amber.withValues(alpha: 0.15)
                            : AppColor.primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        priceLabel,
                        style: pSemiBold10.copyWith(
                          color: isPaid ? Colors.amber.shade800 : AppColor.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (event.location != null && event.location!.isNotEmpty)
                      Expanded(
                        child: Text(
                          event.location!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: pRegular10.copyWith(
                            color: isDark ? _kTextMutedDark : _kTextMutedLight,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  event.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: pSemiBold14.copyWith(
                    color: isDark ? Colors.white : const Color(0xFF111827),
                    height: 1.3,
                  ),
                ),
                if (dateFormatted != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        IconlyLight.calendar,
                        size: 12,
                        color: isDark ? _kTextMutedDark : _kTextMutedLight,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          dateFormatted,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: pRegular10.copyWith(
                            color: isDark ? _kTextMutedDark : _kTextMutedLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackThumbnail(bool isDark) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: isDark ? _kSubtleDark : _kSubtleLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        IconlyLight.calendar,
        size: 28,
        color: AppColor.primaryColor,
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Card Section Wrapper
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildCardSection({
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? _kSurfaceDark : _kSurfaceLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? _kBorderDark : _kBorderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColor.primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: AppColor.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: pSemiBold14.copyWith(
                        color: isDark ? Colors.white : const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: pRegular12.copyWith(
                        color: isDark ? _kTextMutedDark : _kTextMutedLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Themed Text Input Field
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildTextField({
    required bool isDark,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    bool isRequired = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: pMedium12.copyWith(
                color: isDark ? const Color(0xFFE5E7EB) : const Color(0xFF374151),
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: pSemiBold12.copyWith(color: Colors.redAccent),
              ),
          ],
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          inputFormatters: inputFormatters,
          style: pRegular14.copyWith(
            color: isDark ? Colors.white : const Color(0xFF111827),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: pRegular14.copyWith(
              color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
            ),
            prefixIcon: Icon(
              icon,
              size: 19,
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
            ),
            filled: true,
            fillColor: isDark ? _kSubtleDark : _kSubtleLight,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? _kBorderDark : _kBorderLight,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? _kBorderDark : _kBorderLight,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColor.primaryColor,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Themed Image Picker
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildImagePicker(
    EventRegistrationFormController controller,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Bukti Transfer',
              style: pMedium12.copyWith(
                color: isDark ? const Color(0xFFE5E7EB) : const Color(0xFF374151),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '(Opsional jika ada donasi)',
              style: pRegular12.copyWith(
                color: isDark ? _kTextMutedDark : _kTextMutedLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() {
          final file = controller.transferProof.value;

          if (file != null) {
            return Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColor.primaryColor.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      file,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => controller.pickImage(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                IconlyLight.edit,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Ganti',
                                style: pMedium10.copyWith(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () => controller.transferProof.value = null,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.85),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return InkWell(
            onTap: () => controller.pickImage(),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: isDark ? _kSubtleDark : _kSubtleLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? _kBorderDark : _kBorderLight,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      IconlyLight.image,
                      size: 24,
                      color: AppColor.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Pilih Gambar / Foto Bukti Transfer',
                    style: pMedium12.copyWith(
                      color: isDark ? Colors.white : const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mendukung format JPG, PNG (Maks. 2MB)',
                    style: pRegular10.copyWith(
                      color: isDark ? _kTextMutedDark : _kTextMutedLight,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Instagram Card
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildInstagramCard(
    EventRegistrationFormController controller,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? _kSurfaceDark : _kSurfaceLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? _kBorderDark : _kBorderLight,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Obx(() => Checkbox(
                value: controller.instagramFollowed.value,
                onChanged: (value) {
                  if (value != null) controller.instagramFollowed.value = value;
                },
                activeColor: AppColor.primaryColor,
                checkColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                side: BorderSide(
                  color: isDark ? _kTextMutedDark : const Color(0xFFD1D5DB),
                  width: 1.5,
                ),
              )),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Follow Instagram @quranuna_official',
                  style: pMedium14.copyWith(
                    color: isDark ? Colors.white : const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                InkWell(
                  onTap: () async {
                    final url = Uri.parse(
                      'https://www.instagram.com/quranuna_official?igsh=MWdxdXNjbzI4YmQzZg==',
                    );
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Text(
                    'Kunjungi Akun Instagram ↗',
                    style: pMedium12.copyWith(
                      color: AppColor.primaryColor,
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

  // ──────────────────────────────────────────────────────────────────────────
  // Bottom Sticky Action Bar
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildBottomBar(
    BuildContext context,
    EventRegistrationFormController controller,
    EventModel event,
    bool isDark,
  ) {
    final isPaid = event.price != null && event.price! > 0;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.of(context).padding.bottom + 14,
      ),
      decoration: BoxDecoration(
        color: isDark ? _kSurfaceDark : _kSurfaceLight,
        border: Border(
          top: BorderSide(
            color: isDark ? _kBorderDark : _kBorderLight,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (isPaid) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Biaya Registrasi',
                  style: pRegular12.copyWith(
                    color: isDark ? _kTextMutedDark : _kTextMutedLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  event.formattedPrice ?? 'Rp ${event.price}',
                  style: pBold16.copyWith(
                    color: AppColor.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: controller.isSubmitting.value
                    ? null
                    : () => controller.submitForm(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                  disabledBackgroundColor:
                      AppColor.primaryColor.withValues(alpha: 0.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: controller.isSubmitting.value
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isPaid
                                ? 'Lanjut ke Pembayaran'
                                : 'Konfirmasi Pendaftaran',
                            style: pSemiBold14.copyWith(color: Colors.white),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
