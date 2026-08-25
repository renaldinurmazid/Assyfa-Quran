import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:quran_app/models/donation_detail_model.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/screen/charity/infaq_activity_detail_controller.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';
import 'package:quran_app/widgets/app_toast.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

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
        title: Text(
          'Detail Infaq',
          style: pBold16.copyWith(
            color: context.theme.colorScheme.onSurface,
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: context.theme.scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            IconlyLight.arrow_left,
            color: context.theme.colorScheme.onSurface,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState(context);
        }

        final donation = controller.donationDetail.value;
        if (donation == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  IconlyLight.document,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                Text(
                  "Data infaq tidak ditemukan",
                  style: pBold14.copyWith(
                    color: context.theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Silakan periksa koneksi Anda atau coba lagi nanti.",
                  style: pRegular12.copyWith(
                    color: context.theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        final payment = donation.payment;
        final bool isUnpaid = payment.status.toUpperCase() == 'UNPAID' ||
            donation.status.toLowerCase() == 'pending';

        return RefreshIndicator(
          color: AppColor.primaryColorDark,
          backgroundColor: context.theme.colorScheme.surface,
          onRefresh: () async {
            await controller.fetchDonationDetail();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Status & Total Header (Ticket style)
                  _buildStatusHeader(context, donation),
                  const SizedBox(height: 16),

                  // 2. Campaign Target Card
                  _buildCampaignCard(context, donation.campaign),
                  const SizedBox(height: 16),

                  // 3. Payment Code / QRIS Card (if unpaid)
                  if (isUnpaid) ...[
                    if (payment.qrUrl != null && payment.qrUrl!.isNotEmpty)
                      _buildQrisPaymentInfo(context, payment)
                    else if (payment.payCode.isNotEmpty)
                      _buildPaymentInfo(context, payment),
                    const SizedBox(height: 16),
                  ],

                  // 4. Payment Method Card
                  _buildPaymentMethod(context, payment),
                  const SizedBox(height: 16),

                  // 5. Transaction Summary Card
                  _buildPaymentSummary(context, donation, payment),
                  const SizedBox(height: 20),

                  // 6. Instructions (if unpaid)
                  if (isUnpaid && payment.instructions.isNotEmpty) ...[
                    _buildInstructions(context, payment.instructions),
                    const SizedBox(height: 20),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      }),
      bottomNavigationBar: Obx(() {
        final donation = controller.donationDetail.value;
        if (donation == null || controller.isLoading.value) {
          return const SizedBox.shrink();
        }
        return _buildBottomAction(context, donation);
      }),
    );
  }

  Widget _buildStatusHeader(BuildContext context, DonationDetailItem donation) {
    final isDark = context.isDarkMode;
    Color statusColor;
    String statusText;
    IconData statusIcon;

    final String statusKey = donation.status.toLowerCase();
    if (statusKey == 'pending' || statusKey == 'unpaid') {
      statusColor = Colors.amber.shade800;
      statusText = 'Menunggu Pembayaran';
      statusIcon = IconlyBold.time_circle;
    } else if (statusKey == 'success' || statusKey == 'paid') {
      statusColor = AppColor.primaryColorDark;
      statusText = 'Infaq Berhasil';
      statusIcon = Icons.verified_rounded;
    } else {
      statusColor = Colors.red.shade600;
      statusText = donation.status.toUpperCase();
      statusIcon = IconlyBold.danger;
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              children: [
                // Status Pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: statusColor.withOpacity(0.3),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: statusColor, size: 13),
                      const SizedBox(width: 6),
                      Text(
                        statusText,
                        style: pBold10.copyWith(color: statusColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  'Nominal Infaq',
                  style: pRegular12.copyWith(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 6),

                // Big Amount
                Text(
                  donation.formattedAmount,
                  style: pBold24.copyWith(
                    color: isDark
                        ? AppColor.primaryColorDark
                        : AppColor.primaryColor,
                    fontSize: 28,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),

          // Dashed Divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: List.generate(
                28,
                (index) => Expanded(
                  child: Container(
                    color: index % 2 == 0
                        ? Colors.transparent
                        : (isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade300),
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ),

          // Order ID Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ID Pesanan (Order ID)',
                  style: pRegular12.copyWith(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: donation.orderId));
                    AppToast.success(message: 'Order ID berhasil disalin');
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Row(
                    children: [
                      Text(
                        donation.orderId,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: context.theme.colorScheme.onSurface,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        IconlyLight.document,
                        size: 14,
                        color: AppColor.primaryColorDark,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignCard(BuildContext context, CampaignShort campaign) {
    final isDark = context.isDarkMode;

    return InkWell(
      onTap: () => Get.toNamed(
        Routes.charityShow,
        arguments: {'id': campaign.id},
      ),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Campaign Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: campaign.coverImage,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 72,
                  height: 72,
                  color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                  child: const Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColor.primaryColorDark,
                        ),
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(IconlyLight.image, size: 24),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Campaign Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Penyaluran Program',
                        style: pBold10.copyWith(
                          color: AppColor.primaryColorDark,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified_rounded,
                        color: Colors.blueAccent,
                        size: 12,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    campaign.title,
                    style: pBold12.copyWith(
                      color: context.theme.colorScheme.onSurface,
                      height: 1.35,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              IconlyLight.arrow_right_2,
              size: 18,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  /// QRIS Info Card (if unpaid)
  Widget _buildQrisPaymentInfo(BuildContext context, PaymentDetail payment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Scan QR Code untuk Pembayaran',
            style: pBold14.copyWith(
              color: context.theme.colorScheme.onSurface,
              letterSpacing: -0.2,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.qr_code_2_rounded,
                            color: Colors.white.withOpacity(0.95),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'QRIS',
                            style: pBold12.copyWith(
                              color: Colors.white,
                              letterSpacing: 1.2,
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
                        color: const Color(0xFFF59E0B).withOpacity(0.18),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFFF59E0B).withOpacity(0.4),
                        ),
                      ),
                      child: Text(
                        payment.paymentMethode?.name.toUpperCase() ?? 'QRIS',
                        style: pBold10.copyWith(color: const Color(0xFFFCD34D)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // QR Code Container
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    payment.qrUrl!,
                    width: double.infinity,
                    height: 230,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => SizedBox(
                      height: 230,
                      child: Center(
                        child: Text(
                          'Gagal memuat QR Code',
                          style: pRegular12.copyWith(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                child: Text(
                  'Buka e-wallet atau m-Banking Anda, lalu scan QR di atas.',
                  textAlign: TextAlign.center,
                  style: pRegular12.copyWith(
                    color: Colors.white.withOpacity(0.7),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Bank Transfer / VA Card (if unpaid)
  Widget _buildPaymentInfo(BuildContext context, PaymentDetail payment) {
    final String bankName = payment.paymentMethode?.name ?? 'METODE PEMBAYARAN';
    final String accNo = payment.payCode;
    final String accName =
        payment.paymentMethode?.accountName ?? 'ASSYFA QURAN';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Nomor Rekening / Kode Pembayaran',
            style: pBold14.copyWith(
              color: context.theme.colorScheme.onSurface,
              letterSpacing: -0.2,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF123524), Color(0xFF1B4D35)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColor.primaryColor.withOpacity(0.3),
                blurRadius: 14,
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
                    'REKENING TUJUAN',
                    style: pBold10.copyWith(
                      color: const Color(0xFFD4AF37),
                      letterSpacing: 1.2,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
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
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      accNo,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: accNo));
                      AppToast.success(
                        message: 'Nomor Rekening berhasil disalin',
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            IconlyLight.document,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Salin',
                            style: pBold10.copyWith(color: Colors.white),
                          ),
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
                          style: pRegular10.copyWith(
                            color: Colors.white.withOpacity(0.65),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          accName.toUpperCase(),
                          style: pBold14.copyWith(
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.verified_user_rounded,
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

  Widget _buildPaymentMethod(BuildContext context, PaymentDetail payment) {
    final isDark = context.isDarkMode;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              ),
            ),
            child: payment.paymentMethode?.logo != null
                ? (payment.paymentMethode!.logo!.contains('.svg')
                    ? SvgPicture.network(
                        payment.paymentMethode!.logo!,
                        fit: BoxFit.contain,
                      )
                    : Image.network(
                        payment.paymentMethode!.logo!,
                        fit: BoxFit.contain,
                      ))
                : const Icon(
                    IconlyLight.wallet,
                    color: AppColor.primaryColorDark,
                    size: 24,
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Metode Pembayaran',
                  style: pRegular10.copyWith(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  payment.paymentMethode?.name ?? 'Metode Pembayaran',
                  style: pBold14.copyWith(
                    color: context.theme.colorScheme.onSurface,
                  ),
                ),
                if (payment.paymentMethode?.accountName != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    payment.paymentMethode!.accountName!,
                    style: pRegular12.copyWith(
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(
    BuildContext context,
    DonationDetailItem donation,
    PaymentDetail payment,
  ) {
    final isDark = context.isDarkMode;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                'Ringkasan Transaksi',
                style: pBold14.copyWith(
                  color: context.theme.colorScheme.onSurface,
                  letterSpacing: -0.2,
                ),
              ),
              Text(
                DateFormat('dd MMM yyyy, HH:mm').format(donation.createdAt),
                style: pRegular10.copyWith(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _summaryRow(
            context,
            'Status Pembayaran',
            payment.status,
            isStatus: true,
            statusColor: payment.status.toUpperCase() == 'PAID'
                ? AppColor.primaryColorDark
                : Colors.amber.shade800,
          ),
          _summaryRow(context, 'Metode', payment.paymentMethode?.name ?? '-'),
          if (donation.guestName.isNotEmpty)
            _summaryRow(context, 'Nama Donatur', donation.guestName),
          Divider(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Infaq',
                style: pBold14.copyWith(
                  color: context.theme.colorScheme.onSurface,
                ),
              ),
              Text(
                donation.formattedAmount,
                style: pBold16.copyWith(
                  color: isDark
                      ? AppColor.primaryColorDark
                      : AppColor.primaryColor,
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
    Color? statusColor,
  }) {
    final isDark = context.isDarkMode;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: pRegular12.copyWith(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          if (isStatus)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: (statusColor ?? Colors.grey).withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                value.toUpperCase(),
                style: pBold10.copyWith(color: statusColor),
              ),
            )
          else
            Text(
              value,
              style: pSemiBold12.copyWith(
                color: context.theme.colorScheme.onSurface,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInstructions(
    BuildContext context,
    List<InstructionItem> instructions,
  ) {
    final isDark = context.isDarkMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'Panduan & Cara Pembayaran',
            style: pBold14.copyWith(
              color: context.theme.colorScheme.onSurface,
              letterSpacing: -0.2,
            ),
          ),
        ),
        ...instructions.map(
          (ins) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: context.theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              ),
            ),
            child: Theme(
              data: context.theme.copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                shape: const RoundedRectangleBorder(side: BorderSide.none),
                collapsedShape: const RoundedRectangleBorder(
                  side: BorderSide.none,
                ),
                title: Text(
                  ins.title,
                  style: pSemiBold14.copyWith(
                    color: context.theme.colorScheme.onSurface,
                  ),
                ),
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
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: AppColor.primaryColorDark.withOpacity(
                                  0.12,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${entry.key + 1}',
                                  style: pBold10.copyWith(
                                    color: AppColor.primaryColorDark,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: pRegular12.copyWith(
                                  color: context.theme.colorScheme.onSurface,
                                  height: 1.5,
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

  Widget _buildBottomAction(BuildContext context, DonationDetailItem donation) {
    final isDark = context.isDarkMode;
    final bool isUnpaid = donation.payment.status.toUpperCase() == 'UNPAID' ||
        donation.status.toLowerCase() == 'pending';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isUnpaid) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  const String phoneNumber = "6283196064151";
                  final String message =
                      "Halo Admin, saya ingin konfirmasi pembayaran untuk pesanan infaq saya (${donation.orderId}).";
                  final Uri whatsappUrl = Uri.parse(
                    "https://wa.me/$phoneNumber?text=${Uri.encodeFull(message)}",
                  );
                  if (await canLaunchUrl(whatsappUrl)) {
                    await launchUrl(
                      whatsappUrl,
                      mode: LaunchMode.externalApplication,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Konfirmasi Pembayaran via WhatsApp',
                  style: pMedium14.copyWith(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Get.offAllNamed(Routes.main),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: Text(
                'Kembali ke Beranda',
                style: pMedium12.copyWith(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final isDark = context.isDarkMode;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
      highlightColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
