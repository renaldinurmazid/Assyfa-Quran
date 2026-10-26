import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:quran_app/screen/event/event_registration_list_controller.dart';
import 'package:quran_app/models/event_registration_list_model.dart';
import 'package:quran_app/models/event_payment_response_model.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EventRegistrationListScreen
    extends GetView<EventRegistrationListController> {
  const EventRegistrationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Aktivitas Event', style: pSemiBold16),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            LucideIcons.arrowLeft,
            color: context.theme.colorScheme.onSurface,
          ),
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
                Icon(
                  LucideIcons.calendarX,
                  size: 64,
                  color: AppColor.globalBorder,
                ),
                const SizedBox(height: 16),
                Text(
                  'Belum ada aktivitas event',
                  style: pMedium14.copyWith(
                    color: AppColor.globalTextSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchRegistrations,
          child: ListView.separated(
            padding: const EdgeInsets.all(14),
            itemCount: controller.registrations.length,
            separatorBuilder: (context, index) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final registration = controller.registrations[index];
              return _buildEventCard(context, registration);
            },
          ),
        );
      }),
    );
  }

  Widget _buildEventCard(
    BuildContext context,
    EventRegistrationItem registration,
  ) {
    final event = registration.event;
    final payment = registration.payment;

    Color statusColor = AppColor.globalTextSecondary;

    if (registration.status == 'approved') {
      statusColor = AppColor.primaryColor; // Green
    } else if (registration.status == 'rejected') {
      statusColor = Colors.red.shade600; // Red
    } else if (registration.status == 'pending') {
      statusColor = AppColor.secondaryColor; // Orange
    }

    return Container(
      width: Get.width,
      height: 142,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.globalBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
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
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      registration.registrationCode,
                      style: pSemiBold12.copyWith(
                        color: AppColor.globalTextSecondary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      registration.status.toUpperCase(),
                      style: pSemiBold12.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Divider(color: AppColor.borderColor),
                const SizedBox(height: 4),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: CachedNetworkImage(
                          imageUrl: event?.thumbnail ?? "",
                          width: 120,
                          height: Get.height,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Container(color: Colors.grey),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey,
                            child: Icon(Icons.error),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event?.title ?? "",
                              style: pSemiBold12.copyWith(
                                color: AppColor.globalTextSecondary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _formatDateRange(
                                registration.event?.startDate,
                                registration.event?.endDate,
                              ),
                              style: pMedium12.copyWith(
                                color: AppColor.globalTextSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateRange(DateTime? start, DateTime? end) {
    if (start == null) return '-';
    final startStr = DateFormat('dd MMM HH:mm').format(start);
    if (end == null) return '$startStr WIB';

    if (start.year == end.year &&
        start.month == end.month &&
        start.day == end.day) {
      return '$startStr - ${DateFormat('HH:mm').format(end)} WIB';
    }

    return '$startStr - ${DateFormat('dd MMM HH:mm').format(end)} WIB';
  }
}
