import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:quran_app/controller/charity/infaq_activity_detail_controller.dart';
import 'package:quran_app/models/donation_detail_model.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';
import 'package:shimmer/shimmer.dart';

class InfaqActivityDetailScreen extends StatelessWidget {
  const InfaqActivityDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final int donationId = Get.arguments;
    final controller = Get.put(
      InfaqActivityDetailController(donationId: donationId),
    );

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Detail Infaq',
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
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState();
        }

        final donation = controller.donationDetail.value;
        if (donation == null) {
          return const Center(child: Text("Data tidak ditemukan"));
        }

        final payment = donation.payment;

        return SingleChildScrollView(
          child: Column(
            children: [
              _buildStatusHeader(donation),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCampaignCard(donation.campaign),
                    const SizedBox(height: 20),
                    _buildPaymentSummary(payment),
                    const SizedBox(height: 24),
                    if (payment.status == 'UNPAID') ...[
                      _buildPaymentInfo(payment),
                      const SizedBox(height: 24),
                      _buildInstructions(payment.instructions),
                    ],
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatusHeader(DonationDetailItem donation) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (donation.status.toLowerCase()) {
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'Menunggu Pembayaran';
        statusIcon = IconlyBold.time_circle;
        break;
      case 'success':
        statusColor = AppColor.primaryColor;
        statusText = 'Pembayaran Berhasil';
        statusIcon = IconlyBold.tick_square;
        break;
      default:
        statusColor = Colors.red;
        statusText = donation.status;
        statusIcon = IconlyBold.danger;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, color: statusColor, size: 16),
                const SizedBox(width: 8),
                Text(statusText, style: pBold12.copyWith(color: statusColor)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            donation.formattedAmount,
            style: pBold24.copyWith(color: AppColor.primaryColor, fontSize: 32),
          ),
          const SizedBox(height: 8),
          Text(
            'Order ID: ${donation.orderId}',
            style: pMedium12.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignCard(CampaignShort campaign) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              campaign.coverImage,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Donasi Untuk:',
                  style: pMedium10.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  campaign.title,
                  style: pBold14,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(PaymentDetail payment) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
              Text('Detail Pembayaran', style: pBold14),
              Text(
                DateFormat('dd MMM yyyy, HH:mm').format(payment.createdAt),
                style: pRegular10.copyWith(color: Colors.grey),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(),
          ),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: payment.paymentMethode?.logo != null
                    ? (payment.paymentMethode!.logo.contains('.svg')
                          ? SvgPicture.network(payment.paymentMethode!.logo)
                          : Image.network(payment.paymentMethode!.logo))
                    : const Icon(IconlyLight.wallet, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment.paymentMethode?.name ?? 'Metode Pembayaran',
                      style: pBold14,
                    ),
                    Text(
                      payment.paymentMethode?.accountName ?? '',
                      style: pRegular12.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _summaryRow(
            'Status Pembayaran',
            payment.status,
            isStatus: true,
            color: payment.status == 'PAID'
                ? AppColor.primaryColor
                : Colors.orange,
          ),
          _summaryRow('Total Bayar', payment.formattedAmount, isBold: true),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    bool isStatus = false,
    Color? color,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: pMedium12.copyWith(color: Colors.grey)),
          if (isStatus)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (color ?? Colors.grey).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(value, style: pBold10.copyWith(color: color)),
            )
          else
            Text(
              value,
              style: isBold
                  ? pBold14.copyWith(color: AppColor.primaryColor)
                  : pSemiBold12,
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo(PaymentDetail payment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Nomor Rekening / Virtual Account', style: pBold14),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColor.primaryColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColor.primaryColor.withOpacity(0.1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                payment.payCode,
                style: pBold20.copyWith(
                  color: AppColor.primaryColor,
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
                    backgroundColor: AppColor.primaryColor,
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
                    color: AppColor.primaryColor,
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

  Widget _buildInstructions(List<InstructionItem> instructions) {
    if (instructions.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Instruksi Pembayaran', style: pBold14),
        const SizedBox(height: 16),
        ...instructions.map(
          (ins) => Theme(
            data: ThemeData().copyWith(dividerColor: Colors.transparent),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ExpansionTile(
                title: Text(ins.title, style: pSemiBold14),
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
                              decoration: const BoxDecoration(
                                color: AppColor.primaryColor,
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
                              child: Text(entry.value, style: pRegular12),
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

  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(height: 150, color: Colors.white),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
