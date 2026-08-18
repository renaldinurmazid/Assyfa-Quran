import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:quran_app/screen/charity/infaq_activity_detail_controller.dart';
import 'package:quran_app/models/donation_detail_model.dart';
import 'package:quran_app/theme/font.dart';
import 'package:quran_app/widgets/app_toast.dart';
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
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Detail Infaq', style: pSemiBold16),
        centerTitle: true,
        backgroundColor: context.theme.scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState(context);
        }

        final donation = controller.donationDetail.value;
        if (donation == null) {
          return Center(
            child: Text(
              "Data tidak ditemukan",
              style: pMedium14.copyWith(
                color: context.theme.colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }

        final payment = donation.payment;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Status & Amount
                _buildStatusHeader(context, donation),
                const SizedBox(height: 20),

                // 2. Campaign Info
                _buildCampaignCard(context, donation.campaign),
                const SizedBox(height: 20),

                // 3. Virtual Account (if unpaid)
                if (payment.status == 'UNPAID') ...[
                  _buildPaymentInfo(context, payment),
                  const SizedBox(height: 20),
                ],

                // 4. Payment Method
                _buildPaymentMethod(context, payment),
                const SizedBox(height: 20),

                // 5. Payment Summary
                _buildPaymentSummary(context, payment),
                const SizedBox(height: 24),

                // 6. Instructions (if unpaid)
                if (payment.status == 'UNPAID')
                  _buildInstructions(context, payment.instructions),

                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStatusHeader(BuildContext context, DonationDetailItem donation) {
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
        statusColor = context.theme.colorScheme.primary;
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
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, color: statusColor, size: 14),
                const SizedBox(width: 8),
                Text(statusText, style: pBold12.copyWith(color: statusColor)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Jumlah Donasi',
            style: pRegular12.copyWith(
              color: context.theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            donation.formattedAmount,
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
              Text(donation.orderId, style: pSemiBold12),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignCard(BuildContext context, CampaignShort campaign) {
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
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              campaign.coverImage,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(IconlyLight.image, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Donasi Untuk', style: pRegular10),
                const SizedBox(height: 4),
                Text(
                  campaign.title,
                  style: pBold14.copyWith(
                    color: context.theme.colorScheme.onSurface,
                    height: 1.3,
                  ),
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

  Widget _buildPaymentInfo(BuildContext context, PaymentDetail payment) {
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

  Widget _buildPaymentMethod(BuildContext context, PaymentDetail payment) {
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
                ? (payment.paymentMethode!.logo!.contains('.svg')
                      ? SvgPicture.network(payment.paymentMethode!.logo!)
                      : Image.network(payment.paymentMethode!.logo!))
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
                    payment.paymentMethode!.accountName!,
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

  Widget _buildPaymentSummary(BuildContext context, PaymentDetail payment) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.isDarkMode
              ? Colors.grey.shade800
              : Colors.grey.shade100,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ringkasan Pembayaran', style: pSemiBold14),
              Text(
                DateFormat('dd MMM yyyy, HH:mm').format(payment.createdAt),
                style: pRegular10.copyWith(
                  color: context.theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _summaryRow(
            context,
            'Status',
            payment.status,
            isStatus: true,
            color: payment.status == 'PAID'
                ? context.theme.colorScheme.primary
                : Colors.orange,
          ),
          _summaryRow(context, 'Metode', payment.paymentMethode?.name ?? '-'),
          Divider(
            color: context.isDarkMode
                ? Colors.grey.shade800
                : Colors.grey.shade100,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Bayar', style: pSemiBold14),
              Text(
                payment.formattedAmount,
                style: pBold16.copyWith(
                  color: context.theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    BuildContext context,
    String label,
    String value, {
    bool isStatus = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: pRegular12.copyWith(
              color: context.theme.colorScheme.onSurfaceVariant,
            ),
          ),
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
            Text(value, style: pSemiBold12),
        ],
      ),
    );
  }

  Widget _buildInstructions(
    BuildContext context,
    List<InstructionItem> instructions,
  ) {
    if (instructions.isEmpty) return const SizedBox();
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

  Widget _buildLoadingState(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.isDarkMode
          ? Colors.grey.shade900
          : Colors.grey.shade200,
      highlightColor: context.isDarkMode
          ? Colors.grey.shade800
          : Colors.grey.shade100,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 140,
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
