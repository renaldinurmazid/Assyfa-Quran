import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:quran_app/controller/event_registration_list_controller.dart';
import 'package:quran_app/models/event_registration_list_model.dart';
import 'package:quran_app/models/event_payment_response_model.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';

class EventRegistrationListScreen extends GetView<EventRegistrationListController> {
  const EventRegistrationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Aktivitas Event', style: pBold16),
        centerTitle: true,
        backgroundColor: context.theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.theme.colorScheme.onSurface),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.registrations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(IconlyLight.ticket, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'Belum ada aktivitas event',
                  style: pMedium14.copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchRegistrations,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.registrations.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final registration = controller.registrations[index];
              return _buildEventCard(context, registration);
            },
          ),
        );
      }),
    );
  }

  Widget _buildEventCard(BuildContext context, EventRegistrationItem registration) {
    final event = registration.event;
    final payment = registration.payment;
    final isDark = context.isDarkMode;

    Color statusColor = Colors.grey;
    String statusText = registration.status.toUpperCase();

    if (registration.status == 'approved') {
      statusColor = Colors.green;
    } else if (registration.status == 'rejected') {
      statusColor = Colors.red;
    } else if (registration.status == 'pending') {
      statusColor = Colors.orange;
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColor.surfaceColorDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (payment != null && payment.status == 'UNPAID') {
              final paymentData = EventPaymentData(
                registration: EventRegistrationData(
                  id: registration.id,
                  eventId: registration.eventId,
                  userId: registration.userId,
                  registrationCode: registration.registrationCode,
                  name: registration.name,
                  email: registration.email,
                  phoneNumber: registration.phoneNumber,
                  status: registration.status,
                  createdAt: registration.createdAt,
                  price: event?.formattedPrice ?? event?.price?.toString(),
                ),
                payment: payment,
              );
              Get.toNamed(Routes.eventPaymentDetail, arguments: paymentData);
            } else if (event != null) {
              Get.toNamed(Routes.showEvent, arguments: event.id);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (event?.thumbnail != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          event!.thumbnail!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey.shade200,
                              child: const Icon(IconlyLight.image, color: Colors.grey),
                            );
                          },
                        ),
                      )
                    else
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: context.theme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(IconlyLight.ticket, color: context.theme.primaryColor),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event?.title ?? 'Event Tidak Diketahui',
                            style: pBold14,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Reg ID: ${registration.registrationCode}',
                            style: pRegular12.copyWith(color: Colors.grey),
                          ),
                          if (event != null && event.startDate != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(IconlyLight.calendar, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat('dd MMM yyyy').format(event.startDate!),
                                  style: pRegular12.copyWith(color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status Pendaftaran', style: pRegular10.copyWith(color: Colors.grey)),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            statusText,
                            style: pBold10.copyWith(color: statusColor),
                          ),
                        ),
                      ],
                    ),
                    if (payment != null) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Status Pembayaran', style: pRegular10.copyWith(color: Colors.grey)),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                payment.status,
                                style: pBold12.copyWith(
                                  color: payment.status == 'UNPAID' ? Colors.orange : Colors.green,
                                ),
                              ),
                              if (payment.status == 'UNPAID') ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.orange),
                              ]
                            ],
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
