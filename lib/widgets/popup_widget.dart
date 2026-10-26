import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/controller/popup_controller.dart';
import 'package:quran_app/models/popup_model.dart';
import 'package:quran_app/services/deep_link_service.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';

enum _PopupResult { dismissed, clicked }

class PopupWidget {
  static bool _isShowing = false;

  @visibleForTesting
  static void resetForTest() => _isShowing = false;

  /// Show popups sequentially starting from the highest priority
  static Future<void> showPopups() async {
    if (_isShowing) return;

    final controller = PopupController.to;
    final popup = controller.getNextPopup();

    if (popup == null) return;

    _isShowing = true;
    controller.markAsShown(popup.id);
    controller.recordView(popup.id);

    final result = await Get.dialog<_PopupResult>(
      _PopupDialog(popup: popup),
      barrierDismissible: popup.isDismissible,
      barrierColor: Colors.black54,
    );

    _isShowing = false;

    if (result == _PopupResult.clicked) {
      controller.recordClick(popup.id);
      final actionUrl = popup.actionUrl ?? '';
      if (actionUrl.isNotEmpty) {
        await DeepLinkService.handlePayload(actionUrl);
      }
      // The visitor acted on this popup; do not stack the next one on the page they just opened.
      return;
    }

    // Close button, "Nanti saja", a tap outside the card or Android back (no result) all count as dismissing.
    controller.recordDismiss(popup.id);

    // Show next popup if available (with small delay for smooth UX)
    await Future.delayed(const Duration(milliseconds: 500));
    showPopups();
  }
}

class _PopupDialog extends StatelessWidget {
  final PopupData popup;

  const _PopupDialog({required this.popup});

  bool get _hasCta => (popup.actionUrl ?? '').isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final scheme = context.theme.colorScheme;

    // Material: dialog content has none, and Text without it renders with debug underlines.
    return Material(
      type: MaterialType.transparency,
      child: PopScope(
        canPop: popup.isDismissible,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutBack,
                builder: (context, value, child) => Transform.scale(
                  scale: value,
                  child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [_buildHeader(context), _buildContent(context)],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final hasImage = popup.image != null && popup.image!.isNotEmpty;

    return Stack(
      children: [
        hasImage ? _buildImage(context) : _buildDefaultHeader(),
        if (popup.isDismissible)
          Positioned(top: 10, right: 10, child: _buildCloseButton()),
      ],
    );
  }

  Widget _buildImage(BuildContext context) {
    // 3:4 poster, but never taller than half the screen so the text below stays visible.
    final maxHeight = MediaQuery.sizeOf(context).height * 0.5;

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = min(constraints.maxWidth * 4 / 3, maxHeight);
        return SizedBox(
          width: double.infinity,
          height: height,
          child: Image.network(
            popup.image!,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: AppColor.primaryColor.withValues(alpha: 0.05),
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
            errorBuilder: (context, error, stackTrace) => _buildDefaultHeader(),
          ),
        );
      },
    );
  }

  /// Used when there is no image, or it failed to load.
  Widget _buildDefaultHeader() {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.primaryColor,
            AppColor.primaryColor.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(top: -30, right: -20, child: _circle(100, 0.08)),
          Positioned(bottom: -20, left: -10, child: _circle(60, 0.06)),
          Center(
            child: Icon(
              _typeIcon(),
              color: Colors.white.withValues(alpha: 0.9),
              size: 48,
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle(double size, double alpha) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withValues(alpha: alpha),
    ),
  );

  Widget _buildCloseButton() {
    return GestureDetector(
      onTap: () => Get.back(result: _PopupResult.dismissed),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
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

  Widget _buildContent(BuildContext context) {
    final scheme = context.theme.colorScheme;
    final hasTitle = popup.title.trim().isNotEmpty;
    final description = popup.description?.trim() ?? '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasTitle)
            Text(
              popup.title,
              style: pBold16.copyWith(color: scheme.onSurface, height: 1.3),
              textAlign: TextAlign.center,
            ),
          if (description.isNotEmpty) ...[
            SizedBox(height: hasTitle ? 8 : 0),
            Text(
              description,
              style: pMedium12.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          if (_hasCta) ...[
            SizedBox(height: hasTitle || description.isNotEmpty ? 18 : 0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(result: _PopupResult.clicked),
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
                  (popup.actionText ?? '').trim().isNotEmpty
                      ? popup.actionText!.trim()
                      : 'Lihat Selengkapnya',
                  style: pSemiBold14.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],

          if (popup.isDismissible) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Get.back(result: _PopupResult.dismissed),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
              ),
              child: Text(
                _hasCta ? 'Nanti saja' : 'Tutup',
                style: pMedium12.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _typeIcon() {
    switch (popup.type) {
      case 'promo':
        return Icons.local_offer_rounded;
      case 'announcement':
        return Icons.campaign_rounded;
      case 'update':
        return Icons.system_update_rounded;
      default:
        return Icons.info_rounded;
    }
  }
}
