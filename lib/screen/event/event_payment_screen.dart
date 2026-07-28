import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quran_app/controller/event/event_payment_controller.dart';
import 'package:quran_app/theme/font.dart';

class EventPaymentScreen extends StatelessWidget {
  const EventPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EventPaymentController());

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Pembayaran Event', style: pSemiBold16),
        centerTitle: true,
        backgroundColor: context.theme.scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Obx(() {
        if (controller.event.value == null) return const SizedBox();
        final event = controller.event.value!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: context.isDarkMode
                        ? Colors.grey.shade800
                        : Colors.grey.shade200,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: pSemiBold14.copyWith(
                        color: context.theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Tagihan',
                          style: pRegular12.copyWith(
                            color: context.theme.hintColor,
                          ),
                        ),
                        Text(
                          event.formattedPrice ?? 'Rp 0',
                          style: pBold14.copyWith(
                            color: context.theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Payment Method Selection
              Text(
                'Metode Pembayaran',
                style: pSemiBold14.copyWith(
                  color: context.theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () => _showPaymentMethodBottomSheet(context, controller),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: controller.selectedPaymentMethod.value != null
                          ? context.theme.colorScheme.primary
                          : context.isDarkMode
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      if (controller.selectedPaymentMethod.value != null) ...[
                        if (controller.selectedPaymentMethod.value!.logo.isNotEmpty)
                          Container(
                            width: 48,
                            height: 32,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: context.theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SvgPicture.network(
                              controller.selectedPaymentMethod.value!.logo,
                              placeholderBuilder: (_) => const Center(
                                child: SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            ),
                          )
                        else
                          const Icon(IconlyLight.wallet, size: 24, color: Colors.grey),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            controller.selectedPaymentMethod.value!.name,
                            style: pMedium14.copyWith(
                              color: context.theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ] else ...[
                        Icon(
                          IconlyLight.wallet,
                          size: 24,
                          color: context.theme.hintColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Pilih Metode Pembayaran',
                            style: pMedium14.copyWith(
                              color: context.theme.hintColor,
                            ),
                          ),
                        ),
                      ],
                      Icon(
                        IconlyLight.arrow_right_2,
                        size: 20,
                        color: context.theme.hintColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
      bottomNavigationBar: Obx(() {
        if (controller.event.value == null) return const SizedBox.shrink();
        
        return Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).padding.bottom + 16,
          ),
          decoration: BoxDecoration(
            color: context.theme.scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, -5),
                blurRadius: 10,
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: controller.isRegistering.value || controller.selectedPaymentMethod.value == null
                ? null
                : () => controller.registerAndPay(),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.theme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: controller.isRegistering.value
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Bayar Sekarang',
                    style: pBold14.copyWith(color: Colors.white),
                  ),
          ),
        );
      }),
    );
  }
}

void _showPaymentMethodBottomSheet(
  BuildContext context,
  EventPaymentController controller,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: context.theme.scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    isScrollControlled: true,
    builder: (_) {
      return DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Text(
                      'Pilih Metode Pembayaran',
                      style: pBold16.copyWith(
                        color: context.theme.colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.close,
                        color: context.theme.colorScheme.onSurfaceVariant,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: context.theme.colorScheme.primary,
                      ),
                    );
                  }
                  return ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    itemCount: controller.paymentMethods.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final method = controller.paymentMethods[index];
                      return Obx(() {
                        final isSelected = controller.selectedPaymentMethod.value?.id == method.id;
                        return GestureDetector(
                          onTap: () {
                            controller.selectPaymentMethod(method);
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: context.theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? context.theme.colorScheme.primary
                                    : Colors.transparent,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: context.theme.colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: method.logo.isNotEmpty
                                      ? SvgPicture.network(
                                          method.logo,
                                          errorBuilder: (context, error, stackTrace) => const Center(
                                            child: Icon(IconlyLight.image, color: Colors.grey, size: 16),
                                          ),
                                          placeholderBuilder: (context) => const Center(
                                            child: SizedBox(
                                              width: 12, height: 12,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            ),
                                          ),
                                        )
                                      : const Icon(IconlyLight.wallet, size: 20, color: Colors.grey),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    method.name,
                                    style: pSemiBold14.copyWith(
                                      color: isSelected
                                          ? context.theme.colorScheme.primary
                                          : context.theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    IconlyBold.tick_square,
                                    color: context.theme.colorScheme.primary,
                                    size: 24,
                                  ),
                              ],
                            ),
                          ),
                        );
                      });
                    },
                  );
                }),
              ),
            ],
          );
        },
      );
    },
  );
}
