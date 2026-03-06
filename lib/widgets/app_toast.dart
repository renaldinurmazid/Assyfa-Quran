import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';
import 'package:quran_app/theme/font.dart';

class AppToast {
  static void show({
    BuildContext? context,
    required String message,
    String? title,
    ToastificationType type = ToastificationType.success,
    Duration duration = const Duration(seconds: 3),
  }) {
    final effectiveContext = context ?? Get.context;
    if (effectiveContext == null) return;

    toastification.show(
      context: effectiveContext,
      type: type,
      style: ToastificationStyle.flat,
      autoCloseDuration: duration,
      title: title != null
          ? Text(title, style: pBold14)
          : Text(
              type == ToastificationType.success
                  ? 'Berhasil'
                  : type == ToastificationType.error
                  ? 'Error'
                  : (type == ToastificationType.warning
                        ? 'Peringatan'
                        : 'Informasi'),
              style: pBold14,
            ),
      description: Text(message, style: pRegular12),
      alignment: Alignment.topCenter,
      direction: TextDirection.ltr,
      animationDuration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: BorderRadius.circular(12),
      showProgressBar: true,
      closeButtonShowType: CloseButtonShowType.none,
      closeOnClick: true,
      pauseOnHover: true,
      dragToClose: true,
    );
  }

  static void success({
    BuildContext? context,
    required String message,
    String? title,
  }) {
    show(
      context: context,
      message: message,
      title: title,
      type: ToastificationType.success,
    );
  }

  static void error({
    BuildContext? context,
    required String message,
    String? title,
  }) {
    show(
      context: context,
      message: message,
      title: title,
      type: ToastificationType.error,
    );
  }

  static void warning({
    BuildContext? context,
    required String message,
    String? title,
  }) {
    show(
      context: context,
      message: message,
      title: title,
      type: ToastificationType.warning,
    );
  }

  static void info({
    BuildContext? context,
    required String message,
    String? title,
  }) {
    show(
      context: context,
      message: message,
      title: title,
      type: ToastificationType.info,
    );
  }
}
