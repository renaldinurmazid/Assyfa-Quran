import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/controller/popup_controller.dart';
import 'package:quran_app/models/popup_model.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';
import 'package:url_launcher/url_launcher.dart';

class PopupWidget {
  static bool _isShowing = false;

  /// Show popups sequentially starting from the highest priority
  static Future<void> showPopups() async {
    if (_isShowing) return;

    final controller = PopupController.to;
    final popup = controller.getNextPopup();

    if (popup == null) return;

    _isShowing = true;
    controller.markAsShown(popup.id);

    // Record view
    controller.recordView(popup.id);

    await Get.dialog(
      _PopupDialog(popup: popup),
      barrierDismissible: popup.isDismissible,
      barrierColor: Colors.black54,
    );

    _isShowing = false;

    // Show next popup if available (with small delay for smooth UX)
    await Future.delayed(const Duration(milliseconds: 500));
    showPopups();
  }
}

class _PopupDialog extends StatelessWidget {
  final PopupData popup;

  const _PopupDialog({required this.popup});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          constraints: const BoxConstraints(maxWidth: 380),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image with rounded corners
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: _buildImage(),
              ),
              // Buttons below image
              _buildContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (popup.image == null || popup.image!.isEmpty) {
      return _buildDefaultHeader();
    }

    return Stack(
      children: [
        // Popup Image
        AspectRatio(
          aspectRatio: 3 / 4,
          child: Image.network(
            popup.image!,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: AppColor.primaryColor.withOpacity(0.05),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColor.primaryColor,
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return _buildDefaultHeader();
            },
          ),
        ),
        // Close button overlay
        if (popup.isDismissible)
          Positioned(top: 10, right: 10, child: _buildCloseButton()),
        // Type badge
        Positioned(top: 10, left: 10, child: _buildTypeBadge()),
      ],
    );
  }

  Widget _buildDefaultHeader() {
    return Stack(
      children: [
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColor.primaryColor,
                AppColor.primaryColor.withOpacity(0.7),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                top: -30,
                right: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
              Positioned(
                bottom: -20,
                left: -10,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),
              ),
              Center(
                child: Icon(
                  _getTypeIcon(),
                  color: Colors.white.withOpacity(0.9),
                  size: 48,
                ),
              ),
            ],
          ),
        ),
        if (popup.isDismissible)
          Positioned(top: 10, right: 10, child: _buildCloseButton()),
        Positioned(top: 10, left: 10, child: _buildTypeBadge()),
      ],
    );
  }

  Widget _buildCloseButton() {
    return GestureDetector(
      onTap: () {
        PopupController.to.recordDismiss(popup.id);
        PopupController.to.removePopup(popup.id);
        Get.back();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.close_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeBadge() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _getTypeColor().withOpacity(0.85),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_getTypeIcon(), color: Colors.white, size: 12),
              const SizedBox(width: 4),
              Text(
                _getTypeLabel(),
                style: pSemiBold10.copyWith(
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // CTA Button
          if (popup.actionUrl != null &&
              popup.actionUrl!.isNotEmpty &&
              popup.actionText != null &&
              popup.actionText!.isNotEmpty) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  PopupController.to.recordClick(popup.id);

                  final url = Uri.tryParse(popup.actionUrl!);
                  if (url != null && await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }

                  PopupController.to.removePopup(popup.id);
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                child: Text(
                  popup.actionText!,
                  style: pSemiBold14.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],

          // Dismiss text button (if dismissible and no CTA)
          if (popup.isDismissible &&
              (popup.actionUrl == null || popup.actionUrl!.isEmpty)) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                PopupController.to.recordDismiss(popup.id);
                PopupController.to.removePopup(popup.id);
                Get.back();
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
              ),
              child: Text(
                'Tutup',
                style: pMedium14.copyWith(color: Colors.grey[500]),
              ),
            ),
          ],

          // Dismiss text below CTA
          if (popup.isDismissible &&
              popup.actionUrl != null &&
              popup.actionUrl!.isNotEmpty) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                PopupController.to.recordDismiss(popup.id);
                PopupController.to.removePopup(popup.id);
                Get.back();
              },
              child: Text(
                'Nanti saja',
                style: pRegular12.copyWith(
                  color: Colors.grey[400],
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.grey[400],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getTypeIcon() {
    switch (popup.type) {
      case 'promo':
        return Icons.local_offer_rounded;
      case 'announcement':
        return Icons.campaign_rounded;
      case 'update':
        return Icons.system_update_rounded;
      case 'event':
        return Icons.event_rounded;
      case 'warning':
        return Icons.warning_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  Color _getTypeColor() {
    switch (popup.type) {
      case 'promo':
        return const Color(0xFFE65100);
      case 'announcement':
        return const Color(0xFF1565C0);
      case 'update':
        return AppColor.primaryColor;
      case 'event':
        return const Color(0xFF6A1B9A);
      case 'warning':
        return const Color(0xFFEF6C00);
      default:
        return AppColor.primaryColor;
    }
  }

  String _getTypeLabel() {
    switch (popup.type) {
      case 'promo':
        return 'Promo';
      case 'announcement':
        return 'Pengumuman';
      case 'update':
        return 'Update';
      case 'event':
        return 'Event';
      case 'warning':
        return 'Peringatan';
      default:
        return 'Info';
    }
  }
}
