import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:quran_app/models/donation_response_model.dart';
import 'package:quran_app/theme/font.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quran_app/widgets/app_toast.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class CharityPaymentDetailScreen extends StatelessWidget {
  const CharityPaymentDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DonationData data = Get.arguments;
    final payment = data.payment;

    // Parse instructions if they are JSON string
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
                  // 1. Status & Total Header
                  _buildStatusHeader(context, payment, data.donation.orderId),
                  const SizedBox(height: 20),

                  // 2. Virtual Account Section
                  _buildPaymentInfo(context, payment),
                  const SizedBox(height: 20),

                  // 3. Payment Method Details
                  _buildPaymentMethod(context, payment),
                  const SizedBox(height: 24),

                  // 4. Instructions
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

  Widget _buildStatusHeader(
    BuildContext context,
    Payment payment,
    String orderId,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: context.isDarkMode
              ? Colors.grey.shade800
              : Colors.grey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  IconlyBold.time_circle,
                  color: Colors.orange,
                  size: 14,
                ),
                const SizedBox(width: 8),
                Text(
                  'Menunggu Pembayaran',
                  style: pBold12.copyWith(color: Colors.orange),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Total Tagihan',
            style: pRegular12.copyWith(
              color: context.theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            payment.amount,
            style: pBold24.copyWith(
              color: context.theme.colorScheme.primary,
              fontSize: 32,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Divider(
            color: context.isDarkMode
                ? Colors.grey.shade800
                : Colors.grey.shade100,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Order ID: ', style: pRegular12),
              Text(orderId, style: pSemiBold12),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo(BuildContext context, Payment payment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text('Salin Kode Pembayaran', style: pSemiBold14),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.theme.colorScheme.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: context.theme.colorScheme.primary.withOpacity(0.1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nomor Rekening',
                    style: pRegular10.copyWith(
                      color: context.theme.colorScheme.primary.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    payment.payCode,
                    style: pBold20.copyWith(
                      color: context.theme.colorScheme.primary,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: payment.payCode));
                  AppToast.success(message: 'Nomor Rekening berhasil disalin');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.copy, color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Salin',
                        style: pBold12.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethod(BuildContext context, Payment payment) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.isDarkMode
              ? Colors.grey.shade800
              : Colors.grey.shade100,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: payment.paymentMethode?.logo != null
                ? (payment.paymentMethode!.logo.contains('.svg')
                      ? SvgPicture.network(payment.paymentMethode!.logo)
                      : Image.network(payment.paymentMethode!.logo))
                : const Icon(IconlyLight.wallet),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dibayar melalui', style: pRegular10),
                Text(
                  payment.paymentMethode?.name ?? 'Metode Pembayaran',
                  style: pBold14,
                ),
                if (payment.paymentMethode?.accountName != null)
                  Text(
                    payment.paymentMethode!.accountName,
                    style: pRegular12.copyWith(
                      color: context.theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions(
    BuildContext context,
    List<Instruction> instructions,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text('Instruksi Pembayaran', style: pSemiBold14),
        ),
        ...instructions.map(
          (ins) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: context.theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: context.isDarkMode
                    ? Colors.grey.shade800
                    : Colors.grey.shade100,
              ),
            ),
            child: ExpansionTile(
              shape: const RoundedRectangleBorder(side: BorderSide.none),
              collapsedShape: const RoundedRectangleBorder(
                side: BorderSide.none,
              ),
              title: Text(ins.title, style: pSemiBold14),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: ins.steps
                  .asMap()
                  .entries
                  .map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: context.theme.colorScheme.primary
                                  .withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${entry.key + 1}',
                              style: pBold10.copyWith(
                                color: context.theme.colorScheme.primary,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: pRegular12.copyWith(height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: context.isDarkMode
                ? Colors.grey.shade900
                : Colors.grey.shade100,
          ),
        ),
      ),
      child: ElevatedButton(
        onPressed: () async {
          const String phoneNumber = "6285797890027";
          const String message =
              "Halo Admin, saya ingin konfirmasi pembayaran untuk order saya.";
          final Uri whatsappUrl = Uri.parse(
            "https://wa.me/$phoneNumber?text=${Uri.encodeFull(message)}",
          );
          if (await canLaunchUrl(whatsappUrl)) {
            await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: context.theme.colorScheme.primary,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          'Konfirmasi Pembayaran',
          style: pMedium14.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
