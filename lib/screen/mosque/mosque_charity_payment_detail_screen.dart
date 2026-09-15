import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/models/mosque_donation_response_model.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';
import 'package:quran_app/widgets/app_toast.dart';

class MosqueCharityPaymentDetailScreen extends StatefulWidget {
  const MosqueCharityPaymentDetailScreen({super.key});

  @override
  State<MosqueCharityPaymentDetailScreen> createState() =>
      _MosqueCharityPaymentDetailScreenState();
}

class _MosqueCharityPaymentDetailScreenState
    extends State<MosqueCharityPaymentDetailScreen> {
  Timer? _countdownTimer;
  Duration _remainingTime = Duration.zero;
  bool _isExpired = false;
  bool _isCheckingStatus = false;
  MosqueDonationData? _donationData;
  bool _isLoadingInitial = false;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    final raw = Get.arguments;
    final data = _extractDonationData(raw);
    if (data != null) {
      _donationData = data;
      _initCountdownTimer(data);
    } else {
      final identifier = (raw is String && raw.isNotEmpty)
          ? raw
          : (raw is int
                ? raw.toString()
                : (Get.parameters['order_id'] ?? Get.parameters['id']));
      if (identifier != null && identifier.isNotEmpty) {
        _fetchDonationData(identifier);
      }
    }
  }

  MosqueDonationData? _extractDonationData(dynamic raw) {
    if (raw == null) return null;
    if (raw is MosqueDonationData) return raw;
    if (raw is MosqueDonationResponseModel) return raw.data;
    if (raw is Map<String, dynamic>) {
      try {
        if (raw.containsKey('donation') && raw.containsKey('payment')) {
          return MosqueDonationData.fromJson(raw);
        } else if (raw.containsKey('data') &&
            raw['data'] is Map<String, dynamic>) {
          return MosqueDonationData.fromJson(raw['data']);
        }
      } catch (e) {
        debugPrint('Error parsing MosqueDonationData: $e');
      }
    }
    return null;
  }

  Future<void> _fetchDonationData(String identifier) async {
    setState(() {
      _isLoadingInitial = true;
    });
    try {
      final response = await Request().get(
        Url.checkMosqueDonationStatus(identifier),
      );
      if (response.statusCode == 200 && response.data != null) {
        final resData = response.data['data'];
        final data = _extractDonationData(resData);
        if (data != null && mounted) {
          setState(() {
            _donationData = data;
          });
          _initCountdownTimer(data);
        }
      }
    } catch (e) {
      debugPrint('Error fetching mosque donation data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingInitial = false;
        });
      }
    }
  }

  void _initCountdownTimer(MosqueDonationData data) {
    try {
      final expiredAt = data.payment.expiredAt;
      final difference = expiredAt.difference(DateTime.now());

      if (difference.isNegative || difference.inSeconds <= 0) {
        _isExpired = true;
        _remainingTime = Duration.zero;
      } else {
        _remainingTime = difference;
        _isExpired = false;
        _countdownTimer?.cancel();
        _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          final currentDiff = expiredAt.difference(DateTime.now());
          if (currentDiff.isNegative || currentDiff.inSeconds <= 0) {
            timer.cancel();
            if (mounted) {
              setState(() {
                _isExpired = true;
                _remainingTime = Duration.zero;
              });
            }
          } else {
            if (mounted) {
              setState(() {
                _remainingTime = currentDiff;
              });
            }
          }
        });
      }
    } catch (_) {
      _remainingTime = Duration.zero;
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  String _formatRemainingTime(Duration duration) {
    if (_isExpired || duration.isNegative || duration.inSeconds <= 0) {
      return 'Waktu Pembayaran Habis';
    }
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours >= 24) {
      final days = duration.inDays;
      final remHours = hours.remainder(24);
      return '$days hari $remHours jam $minutes menit';
    }

    if (hours > 0) {
      return '$hours jam $minutes menit $seconds detik';
    }

    if (minutes > 0) {
      return '$minutes menit $seconds detik';
    }

    return '$seconds detik';
  }

  String _formatAmount(String raw) {
    if (raw.isEmpty) return 'Rp0';
    if (raw.startsWith('Rp')) return raw;
    final clean = raw.replaceAll(RegExp(r'[^0-9]'), '');
    final numVal = double.tryParse(clean);
    if (numVal != null) {
      final formatter = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp',
        decimalDigits: 0,
      );
      return formatter.format(numVal);
    }
    return 'Rp$raw';
  }

  void _copyToClipboard(String text, String successMessage) {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: text));
    AppToast.success(message: successMessage);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingInitial) {
      return Scaffold(
        backgroundColor: context.isDarkMode
            ? const Color(0xFF0F0F10)
            : const Color(0xFFF8FAFC),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final MosqueDonationData? data =
        _donationData ?? _extractDonationData(Get.arguments);
    if (data == null) {
      return _buildEmptyOrError(context);
    }

    final payment = data.payment;
    final donation = data.donation;
    final isDark = context.isDarkMode;

    // Parse instructions if they are JSON string
    List<Instruction> instructions = [];
    try {
      final decoded = json.decode(payment.instructions);
      if (decoded is List) {
        instructions = decoded.map((e) => Instruction.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint("Error parsing instructions: $e");
    }

    String formattedExpired = '';
    try {
      formattedExpired = DateFormat(
        'dd MMM yyyy, HH:mm',
      ).format(payment.expiredAt);
    } catch (_) {
      formattedExpired = payment.expiredAt.toString();
    }

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F0F10)
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Detail Pembayaran',
          style: pBold16.copyWith(
            color: context.theme.colorScheme.onSurface,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
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
            // 1. Modern Minimalist Invoice Header
            _buildInvoiceHeader(
              context,
              payment: payment,
              orderId: donation.orderId,
              formattedExpired: formattedExpired,
            ),
            const SizedBox(height: 20),

            // 2. Adaptive: QRIS or Bank Transfer
            if (payment.isQris)
              _buildModernQrisCard(context, payment)
            else
              _buildModernBankTransferCard(context, payment),
            const SizedBox(height: 20),

            // 3. Instructions
            if (instructions.isNotEmpty) ...[
              _buildInstructions(context, instructions),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomAction(
        context,
        orderId: donation.orderId,
        donationId: donation.id,
        amount: payment.amount,
      ),
    );
  }

  /// Modern Minimalist Invoice Ticket Header
  Widget _buildInvoiceHeader(
    BuildContext context, {
    required MosquePayment payment,
    required String orderId,
    required String formattedExpired,
  }) {
    final isDark = context.isDarkMode;
    final surfaceColor = isDark ? const Color(0xFF18181B) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF27272A)
        : const Color(0xFFE2E8F0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total Pembayaran",
                  style: pRegular12.copyWith(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
                InkWell(
                  onTap: () {
                    final cleanAmount = payment.amount.replaceAll(
                      RegExp(r'[^0-9]'),
                      '',
                    );
                    _copyToClipboard(
                      cleanAmount.isNotEmpty ? cleanAmount : payment.amount,
                      'Nominal tagihan berhasil disalin',
                    );
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatAmount(payment.amount),
                        style: pSemiBold12.copyWith(
                          color: isDark
                              ? AppColor.primaryColorDark
                              : AppColor.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        IconlyLight.document,
                        size: 13,
                        color: isDark
                            ? AppColor.primaryColorDark
                            : AppColor.primaryColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(
            color: isDark ? const Color(0xFF27272A) : Colors.grey.shade300,
            thickness: 0.5,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Bayar Dalam",
                  style: pRegular12.copyWith(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
                Text(
                  _formatRemainingTime(_remainingTime),
                  style: pMedium12.copyWith(
                    color: _isExpired
                        ? Colors.red.shade500
                        : (isDark
                              ? Colors.grey.shade300
                              : Colors.grey.shade800),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Modern Minimalist QRIS Card
  Widget _buildModernQrisCard(BuildContext context, MosquePayment payment) {
    final isDark = context.isDarkMode;
    final surfaceColor = isDark ? const Color(0xFF18181B) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF27272A)
        : const Color(0xFFE2E8F0);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.03),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEA3829).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'QRIS',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFEA3829),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Pembayaran Instan',
                      style: pSemiBold12.copyWith(
                        color: context.theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        size: 12,
                        color: AppColor.primaryColorDark,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Otomatis',
                        style: pRegular10.copyWith(
                          color: isDark
                              ? Colors.grey.shade300
                              : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

          // QR Code Frame
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: GestureDetector(
                onTap: () => _showQrPreviewDialog(context, payment.qrCodeUrl!),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          payment.qrCodeUrl!,
                          width: 210,
                          height: 210,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return SizedBox(
                              width: 210,
                              height: 210,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
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
                            width: 210,
                            height: 210,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image_rounded,
                                    size: 40,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'QR Code tidak tersedia',
                                    style: pRegular12.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Tap to Zoom hint
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.zoom_in_rounded,
                size: 14,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
              ),
              const SizedBox(width: 4),
              Text(
                'Ketuk QR untuk memperbesar',
                style: pRegular10.copyWith(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Supported E-wallets & Banks
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.03)
                  : const Color(0xFFF8FAFC),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
              border: Border(top: BorderSide(color: borderColor, width: 1)),
            ),
            child: Column(
              children: [
                Text(
                  'Mendukung Semua Aplikasi Pembayaran QRIS',
                  style: pSemiBold10.copyWith(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildAppTag(context, 'GoPay'),
                    _buildAppTag(context, 'OVO'),
                    _buildAppTag(context, 'DANA'),
                    _buildAppTag(context, 'ShopeePay'),
                    _buildAppTag(context, 'BCA Mobile'),
                    _buildAppTag(context, 'Livin\''),
                    _buildAppTag(context, 'BRImo'),
                    _buildAppTag(context, '& Lainnya'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppTag(BuildContext context, String title) {
    final isDark = context.isDarkMode;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF27272A) : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E8F0),
          width: 0.8,
        ),
      ),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
        ),
      ),
    );
  }

  void _showQrPreviewDialog(BuildContext context, String qrUrl) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pindai Kode QR',
                    style: pBold14.copyWith(color: const Color(0xFF1E293B)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: Colors.grey.shade700,
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  qrUrl,
                  width: 280,
                  height: 280,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Tunjukkan atau scan langsung menggunakan kamera QRIS aplikasi Anda.',
                textAlign: TextAlign.center,
                style: pRegular12.copyWith(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  /// Modern Minimalist Bank Transfer / VA Card (Fintech Style)
  Widget _buildModernBankTransferCard(
    BuildContext context,
    MosquePayment payment,
  ) {
    final isDark = context.isDarkMode;
    final surfaceColor = isDark ? const Color(0xFF18181B) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF27272A)
        : const Color(0xFFE2E8F0);
    final bankName = payment.paymentMethode?.name ?? 'TRANSFER BANK';
    final accNo = payment.payCode;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.03),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bank Brand Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
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
                          : Icon(
                              IconlyLight.wallet,
                              color: AppColor.primaryColorDark,
                              size: 20,
                            ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bankName,
                          style: pSemiBold14.copyWith(
                            color: context.theme.colorScheme.onSurface,
                            letterSpacing: -0.2,
                          ),
                        ),
                        Text(
                          'Virtual Account / Transfer',
                          style: pRegular10.copyWith(
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

          // Account / VA Number Card Inside
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nomor Rekening / Virtual Account',
                  style: pRegular10.copyWith(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF202024)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF2E2E33)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          accNo,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: context.theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => _copyToClipboard(
                          accNo,
                          'Nomor rekening berhasil disalin',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? AppColor.primaryColorDark
                              : AppColor.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: const Icon(IconlyLight.document, size: 13),
                        label: Text('Salin', style: pBold10),
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

  /// Modern Step-by-Step Payment Instructions
  Widget _buildInstructions(
    BuildContext context,
    List<Instruction> instructions,
  ) {
    final isDark = context.isDarkMode;
    final surfaceColor = isDark ? const Color(0xFF18181B) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF27272A)
        : const Color(0xFFE2E8F0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 14,
              decoration: BoxDecoration(
                color: AppColor.primaryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Panduan Pembayaran',
              style: pSemiBold14.copyWith(
                color: context.theme.colorScheme.onSurface,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...instructions.map(
          (ins) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Theme(
              data: context.theme.copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                shape: const RoundedRectangleBorder(side: BorderSide.none),
                collapsedShape: const RoundedRectangleBorder(
                  side: BorderSide.none,
                ),
                title: Text(
                  ins.title,
                  style: pSemiBold12.copyWith(
                    color: context.theme.colorScheme.onSurface,
                  ),
                ),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: ins.steps
                    .asMap()
                    .entries
                    .map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : const Color(0xFFF1F5F9),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${entry.key + 1}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? Colors.grey.shade300
                                        : Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: pRegular12.copyWith(
                                  color: isDark
                                      ? Colors.grey.shade300
                                      : const Color(0xFF334155),
                                  height: 1.4,
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

  /// Check Payment Status from API
  Future<void> _checkPaymentStatus({
    required String orderId,
    required int donationId,
  }) async {
    if (_isCheckingStatus) return;

    setState(() {
      _isCheckingStatus = true;
    });

    try {
      final response = await Request().get(
        Url.checkMosqueDonationStatus(orderId),
      );
      if (response.statusCode == 200 && response.data != null) {
        final resData = response.data;
        final data = resData['data'];
        final bool isPaid =
            data != null &&
            (data['is_paid'] == true ||
                data['status']?.toString().toLowerCase() == 'success');
        final String status = data != null
            ? (data['status']?.toString().toLowerCase() ?? '')
            : '';

        if (!mounted) return;

        if (isPaid) {
          final targetDonationId = data['donation_id'] is int
              ? data['donation_id'] as int
              : donationId;
          _showPaymentSuccessDialog(targetDonationId);
        } else if (status == 'expired') {
          setState(() {
            _isExpired = true;
            _remainingTime = Duration.zero;
          });
          AppToast.warning(
            message: 'Waktu pembayaran telah berakhir atau kadaluarsa.',
          );
        } else {
          AppToast.info(
            message:
                'Pembayaran belum terverifikasi. Silakan selesaikan pembayaran terlebih dahulu.',
          );
        }
      } else {
        if (!mounted) return;
        AppToast.error(
          message: 'Gagal mengecek status pembayaran. Silakan coba lagi.',
        );
      }
    } catch (e) {
      debugPrint('Error checking mosque payment status: $e');
      if (mounted) {
        AppToast.error(
          message: 'Gagal mengecek status pembayaran: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingStatus = false;
        });
      }
    }
  }

  /// Modern Success Dialog
  void _showPaymentSuccessDialog(int donationId) {
    final isDark = context.isDarkMode;
    final surfaceColor = isDark ? const Color(0xFF18181B) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: surfaceColor,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColor.primaryColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      color: AppColor.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Pembayaran Berhasil!',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Alhamdulillah, infaq masjid Anda telah kami terima dan tercatat dalam sistem. Semoga menjadi amal jariyah.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: textMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    Get.offNamed(
                      Routes.mosqueInfaqActivityDetail,
                      arguments: donationId,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Lihat Detail Infaq',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Get.back();
                    Get.back();
                  },
                  child: Text(
                    'Kembali ke Infaq Masjid',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Modern Bottom Action Bar
  Widget _buildBottomAction(
    BuildContext context, {
    required String orderId,
    required int donationId,
    required String amount,
  }) {
    final isDark = context.isDarkMode;
    final surfaceColor = isDark ? const Color(0xFF18181B) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF27272A)
        : const Color(0xFFE2E8F0);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(top: BorderSide(color: borderColor, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isCheckingStatus
                  ? null
                  : () => _checkPaymentStatus(
                      orderId: orderId,
                      donationId: donationId,
                    ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColor.primaryColor.withValues(
                  alpha: 0.6,
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isCheckingStatus
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          IconlyLight.shield_done,
                          size: 18,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Cek status pembayaran',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// Modern Empty / Error State
  Widget _buildEmptyOrError(BuildContext context) {
    final isDark = context.isDarkMode;
    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F0F10)
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Detail Pembayaran',
          style: pBold16.copyWith(
            color: context.theme.colorScheme.onSurface,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.04),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    IconlyLight.document,
                    size: 36,
                    color: context.theme.colorScheme.onSurface.withValues(
                      alpha: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Data Pembayaran Tidak Ditemukan',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: context.theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Silakan kembali ke halaman sebelumnya atau lakukan donasi kembali.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: context.theme.colorScheme.onSurface.withValues(
                    alpha: 0.6,
                  ),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 160,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Kembali',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
