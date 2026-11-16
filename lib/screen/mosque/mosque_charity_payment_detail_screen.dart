import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
      return Scaffold(body: const Center(child: CircularProgressIndicator()));
    }

    final MosqueDonationData? data =
        _donationData ?? _extractDonationData(Get.arguments);
    if (data == null) {
      return _buildEmptyOrError(context);
    }

    final payment = data.payment;
    final donation = data.donation;

    // Parse instructions
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
      appBar: AppBar(
        title: Text('Detail Pembayaran', style: pSemiBold16),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 14),
              _buildInvoiceHeader(
                context,
                payment: payment,
                orderId: donation.orderId,
                formattedExpired: formattedExpired,
              ),
              const SizedBox(height: 18),
              if (payment.isQris)
                _buildModernQrisCard(context, payment)
              else
                _buildModernBankTransferCard(context, payment),
              const SizedBox(height: 18),
              if (instructions.isNotEmpty) ...[
                _buildInstructions(context, instructions),
                const SizedBox(height: 18),
              ],
            ],
          ),
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

  Widget _buildInvoiceHeader(
    BuildContext context, {
    required MosquePayment payment,
    required String orderId,
    required String formattedExpired,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.globalBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Pembayaran",
                style: pMedium12.copyWith(color: AppColor.globalTextSecondary),
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
                child: Row(
                  children: [
                    Text(
                      _formatAmount(payment.amount),
                      style: pSemiBold14.copyWith(
                        color: AppColor.globalTextSecondary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      LucideIcons.copy,
                      size: 14,
                      color: AppColor.primaryColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: AppColor.globalBorder, height: 1, thickness: 0.5),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Bayar Dalam",
                style: pMedium12.copyWith(color: AppColor.globalTextSecondary),
              ),
              Text(
                _formatRemainingTime(_remainingTime),
                style: pSemiBold12.copyWith(
                  color: _isExpired ? Colors.red : AppColor.globalTextSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernQrisCard(BuildContext context, MosquePayment payment) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.globalBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('QRIS', style: pBold12.copyWith(color: Colors.red)),
              ),
              const SizedBox(width: 8),
              Text(
                'Pembayaran Instan',
                style: pSemiBold14.copyWith(
                  color: AppColor.globalTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: AppColor.globalBorder, height: 1, thickness: 0.5),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _showQrPreviewDialog(context, payment.qrCodeUrl!),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColor.globalBorder, width: 0.5),
              ),
              child: Center(
                child: payment.qrCodeUrl != null
                    ? Image.network(
                        payment.qrCodeUrl!,
                        width: 200,
                        height: 200,
                        fit: BoxFit.contain,
                      )
                    : const Icon(LucideIcons.imageOff, size: 50),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.zoomIn,
                  size: 14,
                  color: AppColor.globalTextSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Ketuk QR untuk memperbesar',
                  style: pMedium10.copyWith(
                    color: AppColor.globalTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showQrPreviewDialog(BuildContext context, String qrUrl) {
    Get.dialog(
      Dialog(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Pindai Kode QR', style: pSemiBold14),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 20),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColor.globalBorder, width: 0.5),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    qrUrl,
                    width: 250,
                    height: 250,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Tunjukkan atau scan langsung menggunakan kamera QRIS aplikasi Anda.',
                textAlign: TextAlign.center,
                style: pMedium12.copyWith(color: AppColor.globalTextSecondary),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernBankTransferCard(BuildContext context, MosquePayment payment) {
    final bankName = payment.paymentMethode?.name ?? 'TRANSFER BANK';
    final accNo = payment.payCode;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.globalBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    : const Icon(LucideIcons.wallet, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  bankName,
                  style: pSemiBold14.copyWith(
                    color: AppColor.globalTextSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: AppColor.globalBorder, height: 1, thickness: 0.5),
          const SizedBox(height: 12),
          Text(
            'Nomor Rekening / Virtual Account',
            style: pMedium12.copyWith(color: AppColor.globalTextSecondary),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColor.globalBorder, width: 0.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    accNo,
                    style: pSemiBold14.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => _copyToClipboard(
                    accNo,
                    'Nomor rekening berhasil disalin',
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Salin',
                      style: pSemiBold12.copyWith(color: AppColor.primaryColor),
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

  Widget _buildInstructions(
    BuildContext context,
    List<Instruction> instructions,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.globalBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Panduan Cara Pembayaran',
            style: pSemiBold14.copyWith(
              color: AppColor.globalTextSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          ...instructions.map((ins) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColor.globalBorder, width: 0.5),
              ),
              child: Theme(
                data: context.theme.copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: Text(
                    ins.title,
                    style: pMedium12.copyWith(
                      color: AppColor.globalTextSecondary,
                    ),
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: ins.steps.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: AppColor.primaryColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${entry.key + 1}',
                                style: pBold10.copyWith(
                                  color: AppColor.primaryColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: pMedium12.copyWith(
                                color: AppColor.globalTextSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _checkPaymentStatus({
    required String orderId,
    required int donationId,
  }) async {
    if (_isCheckingStatus) return;

    setState(() {
      _isCheckingStatus = true;
    });

    try {
      final response = await Request().get(Url.checkMosqueDonationStatus(orderId));
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
      debugPrint('Error checking payment status: $e');
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

  void _showPaymentSuccessDialog(int donationId) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColor.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: AppColor.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.check,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Pembayaran Berhasil!', style: pBold16),
              const SizedBox(height: 8),
              Text(
                'Alhamdulillah, infaq masjid Anda telah kami terima dan tercatat dalam sistem. Semoga menjadi amal jariyah.',
                textAlign: TextAlign.center,
                style: pMedium12.copyWith(color: AppColor.globalTextSecondary),
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
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Lihat Detail Infaq',
                    style: pMedium12.copyWith(color: Colors.white),
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
                    style: pMedium12.copyWith(
                      color: AppColor.globalTextSecondary,
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

  Widget _buildBottomAction(
    BuildContext context, {
    required String orderId,
    required int donationId,
    required String amount,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.globalBorder, width: 0.5),
      ),
      child: ElevatedButton(
        onPressed: _isCheckingStatus
            ? null
            : () =>
                  _checkPaymentStatus(orderId: orderId, donationId: donationId),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primaryColor,
          disabledBackgroundColor: AppColor.primaryColor.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: _isCheckingStatus
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    LucideIcons.shieldCheck,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Cek status pembayaran',
                    style: pMedium12.copyWith(color: Colors.white),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildEmptyOrError(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Pembayaran', style: pSemiBold16),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Get.back(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.fileX, size: 48, color: Colors.grey),
              const SizedBox(height: 20),
              Text('Data Pembayaran Tidak Ditemukan', style: pBold14),
              const SizedBox(height: 8),
              Text(
                'Silakan kembali ke halaman sebelumnya atau lakukan donasi kembali.',
                textAlign: TextAlign.center,
                style: pMedium12.copyWith(color: AppColor.globalTextSecondary),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 160,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Kembali',
                    style: pMedium12.copyWith(color: Colors.white),
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
