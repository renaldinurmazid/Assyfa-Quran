import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:quran_app/models/donation_response_model.dart';
import 'package:quran_app/theme/font.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
        title: Text('Instruksi Pembayaran', style: pSemiBold16),
        backgroundColor: context.theme.scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildStatusHeader(context, payment),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPaymentSummary(context, payment),
                  const SizedBox(height: 24),
                  _buildPaymentInfo(context, payment),
                  const SizedBox(height: 24),
                  _buildInstructions(context, instructions),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomAction(context),
    );
  }

  Widget _buildStatusHeader(BuildContext context, Payment payment) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  IconlyBold.time_circle,
                  color: Colors.orange,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Menunggu Pembayaran',
                  style: pBold12.copyWith(color: Colors.orange),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${payment.amount}',
            style: pBold24.copyWith(
              color: context.theme.colorScheme.primary,
              fontSize: 32,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Order ID: ${payment.payCode}',
            style: pMedium12.copyWith(
              color: context.theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(BuildContext context, Payment payment) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Pembayaran',
                style: pMedium14.copyWith(
                  color: context.theme.colorScheme.onSurface,
                ),
              ),
              Text(
                '${payment.amount}',
                style: pBold16.copyWith(
                  color: context.theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(
              color: context.isDarkMode
                  ? Colors.grey.shade900
                  : Colors.grey.shade100,
            ),
          ),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: payment.paymentMethode?.logo != null
                    ? (payment.paymentMethode!.logo.contains('.svg')
                          ? SvgPicture.network(payment.paymentMethode!.logo)
                          : Image.network(payment.paymentMethode!.logo))
                    : Icon(
                        IconlyLight.wallet,
                        color: context.theme.colorScheme.onSurfaceVariant,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment.paymentMethode?.name ?? 'Metode Pembayaran',
                      style: pBold14.copyWith(
                        color: context.theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      payment.paymentMethode?.accountName ?? '',
                      style: pRegular12.copyWith(
                        color: context.theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
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
        Text(
          'Nomor Rekening / Virtual Account',
          style: pBold14.copyWith(color: context.theme.colorScheme.onSurface),
        ),
        const SizedBox(height: 12),
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
              Text(
                payment.payCode,
                style: pBold20.copyWith(
                  color: context.theme.colorScheme.primary,
                  letterSpacing: 1.2,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: payment.payCode));
                  Get.snackbar(
                    'Berhasil',
                    'Nomor berhasil disalin',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: context.theme.colorScheme.primary,
                    colorText: Colors.white,
                    margin: const EdgeInsets.all(20),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Salin',
                    style: pBold12.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInstructions(
    BuildContext context,
    List<Instruction> instructions,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Instruksi Pembayaran',
          style: pBold14.copyWith(color: context.theme.colorScheme.onSurface),
        ),
        const SizedBox(height: 16),
        ...instructions.map(
          (ins) => Theme(
            data: ThemeData().copyWith(dividerColor: Colors.transparent),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: context.theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ExpansionTile(
                title: Text(
                  ins.title,
                  style: pSemiBold14.copyWith(
                    color: context.theme.colorScheme.onSurface,
                  ),
                ),
                childrenPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                children: ins.steps
                    .asMap()
                    .entries
                    .map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: context.theme.colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${entry.key + 1}',
                                  style: pBold10.copyWith(color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: pRegular12.copyWith(
                                  color: context.theme.colorScheme.onSurface
                                      .withOpacity(0.8),
                                ),
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
        ),
      ],
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    return Container(
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
      child: ElevatedButton(
        onPressed: () async {
          const String phoneNumber = "6285797890027";
          const String message =
              "Halo Admin, saya ingin konfirmasi pembayaran.";
          final Uri whatsappUrl = Uri.parse(
            "https://wa.me/$phoneNumber?text=${Uri.encodeFull(message)}",
          );
          if (await canLaunchUrl(whatsappUrl)) {
            await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
          } else {
            Get.snackbar(
              'Gagal',
              'Tidak dapat membuka WhatsApp',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: context.theme.colorScheme.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          'Konfirmasi Pembayaran',
          style: pBold16.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
