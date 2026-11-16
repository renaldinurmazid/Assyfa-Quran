import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:quran_app/models/event_payment_response_model.dart';
import 'package:quran_app/models/donation_response_model.dart' show Instruction;
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quran_app/widgets/app_toast.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

class EventPaymentDetailScreen extends StatelessWidget {
  const EventPaymentDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final EventPaymentData data = Get.arguments;
    final payment = data.payment;

    if (payment == null) {
      return const Scaffold(
        body: Center(child: Text('Data pembayaran tidak ditemukan')),
      );
    }

    // Parse instructions
    List<Instruction> instructions = [];
    try {
      final decoded = json.decode(payment.instructions);
      if (decoded is List) {
        instructions = decoded.map((e) => Instruction.fromJson(e)).toList();
      }
    } catch (e) {
      print("Error parsing instructions: $e");
    }

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Detail Pembayaran', style: pSemiBold16),
        centerTitle: true,
        backgroundColor: context.theme.scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusHeader(context, payment, data.registration.registrationCode),
                  const SizedBox(height: 20),
                  // Adaptive: QRIS or Bank Transfer
                  if (payment.isQris)
                    _buildQrisPaymentInfo(context, payment)
                  else
                    _buildBankTransferPaymentInfo(context, payment),
                  const SizedBox(height: 20),
                  _buildPaymentMethod(context, payment),
                  const SizedBox(height: 24),
                  _buildInstructions(context, instructions),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomAction(context),
    );
  }

  Widget _buildStatusHeader(BuildContext context, payment, String registrationCode) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: context.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
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
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: payment.status == 'PAID'
                        ? AppColor.primaryColor.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        payment.status == 'PAID'
                            ? IconlyBold.shield_done
                            : IconlyBold.time_circle,
                        color: payment.status == 'PAID'
                            ? AppColor.primaryColor
                            : Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        payment.status == 'PAID'
                            ? 'Pembayaran Berhasil'
                            : 'Menunggu Pembayaran',
                        style: pSemiBold14.copyWith(
                          color: payment.status == 'PAID'
                              ? AppColor.primaryColor
                              : Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Total Tagihan',
                  style: pRegular14.copyWith(color: context.theme.hintColor),
                ),
                const SizedBox(height: 8),
                Text(
                  payment.amount,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: context.theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'ID Pendaftaran: $registrationCode',
                  style: pMedium12.copyWith(color: context.theme.hintColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// QRIS Payment Info — shows QR Code image
  Widget _buildQrisPaymentInfo(BuildContext context, EventPayment payment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text('Scan QR Code untuk Pembayaran', style: pSemiBold14),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1A1A2E).withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.qr_code_2, color: Colors.white.withOpacity(0.9), size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'QRIS',
                            style: pBold12.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8B931).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFE8B931).withOpacity(0.3)),
                        ),
                        child: Text(
                          payment.paymentMethode?.name.toUpperCase() ?? 'QRIS',
                          style: pBold10.copyWith(color: const Color(0xFFE8B931)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // QR Code Image
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    payment.qrCodeUrl!,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return SizedBox(
                        height: 250,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            color: AppColor.primaryColor,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => SizedBox(
                      height: 250,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 8),
                            Text('Gagal memuat QR Code', style: pRegular12.copyWith(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Hint text
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Text(
                  'Buka aplikasi e-wallet atau mobile banking, lalu scan QR di atas',
                  textAlign: TextAlign.center,
                  style: pRegular12.copyWith(
                    color: Colors.white.withOpacity(0.6),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Bank Transfer / VA Payment Info — shows VA number with copy
  Widget _buildBankTransferPaymentInfo(BuildContext context, EventPayment payment) {
    final String bankName = payment.paymentMethode?.name ?? 'VIRTUAL ACCOUNT';
    final String accNo = payment.payCode;
    final String accName = payment.paymentMethode?.accountName ?? 'ASSYFA QURAN';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text('Salin Kode Pembayaran', style: pSemiBold14),
        ),
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
                color: AppColor.primaryColor.withOpacity(0.25),
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
                  Expanded(
                    child: Text(
                      'REKENING TUJUAN TRANSFER',
                      style: pBold10.copyWith(
                        color: const Color(0xFFD4AF37),
                        letterSpacing: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        bankName.toUpperCase(),
                        style: pBold10.copyWith(color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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
                      AppToast.success(message: 'Nomor VA berhasil disalin');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(IconlyLight.document, color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text('Salin', style: pBold10.copyWith(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ATAS NAMA',
                          style: pRegular10.copyWith(color: Colors.white.withOpacity(0.6)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          accName.toUpperCase(),
                          style: pBold14.copyWith(color: Colors.white),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
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
      ],
    );
  }

  Widget _buildPaymentMethod(BuildContext context, payment) {
    final method = payment.paymentMethode;
    if (method == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 32,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: context.theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: method.logo != null && method.logo!.isNotEmpty
                ? (method.logo!.contains('.svg')
                      ? SvgPicture.network(
                          method.logo!,
                          placeholderBuilder: (_) => const Center(
                            child: SizedBox(
                              width: 12, height: 12,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorBuilder: (_, __, ___) => const Icon(IconlyLight.image, size: 16),
                        )
                      : Image.network(
                          method.logo!,
                          errorBuilder: (_, __, ___) => const Icon(IconlyLight.image, size: 16),
                        ))
                : const Icon(IconlyLight.wallet, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Metode Pembayaran', style: pMedium12.copyWith(color: context.theme.hintColor)),
                const SizedBox(height: 2),
                Text(
                  method.name,
                  style: pSemiBold14.copyWith(color: context.theme.colorScheme.onSurface),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions(BuildContext context, List<Instruction> instructions) {
    if (instructions.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cara Pembayaran',
          style: pSemiBold16.copyWith(color: context.theme.colorScheme.onSurface),
        ),
        const SizedBox(height: 16),
        ...instructions.map((inst) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            decoration: BoxDecoration(
              color: context.theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: context.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
              ),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: Text(
                  inst.title,
                  style: pSemiBold14.copyWith(color: context.theme.colorScheme.onSurface),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      children: inst.steps.asMap().entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: context.theme.primaryColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${entry.key + 1}',
                                    style: pBold12.copyWith(color: context.theme.primaryColor),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  entry.value,
                                  style: pRegular14.copyWith(
                                    color: context.theme.colorScheme.onSurface,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: context.theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -5),
            blurRadius: 10,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () async {
          const String phoneNumber = "6283196064151";
          const String message =
              "Halo Admin, saya ingin konfirmasi pembayaran event saya.";
          final Uri whatsappUrl = Uri.parse(
            "https://wa.me/$phoneNumber?text=${Uri.encodeFull(message)}",
          );

          if (await canLaunchUrl(whatsappUrl)) {
            await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
          } else {
            AppToast.error(message: 'Tidak dapat membuka WhatsApp');
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF25D366),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(IconlyBold.send, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text('Konfirmasi via WhatsApp', style: pBold14.copyWith(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
