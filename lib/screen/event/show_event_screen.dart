import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:iconly/iconly.dart';
import 'package:quran_app/screen/event/event_detail_controller.dart';
import 'package:quran_app/theme/font.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/screen/home/home_screen_controller.dart';
import 'package:quran_app/screen/home/home_screen.dart';
class ShowEventScreen extends StatelessWidget {
  const ShowEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EventDetailController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'Detail Event',
          style: pSemiBold16.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingShimmer(context);
        }

        final event = controller.event.value;
        if (event == null) {
          return Center(
            child: Text(
              'Gagal memuat data event.',
              style: pRegular14.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              if (event.thumbnail != null && event.thumbnail!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: event.thumbnail!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                      highlightColor: isDark
                          ? Colors.grey[700]!
                          : Colors.grey[100]!,
                      child: Container(height: 200, color: Colors.white),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 200,
                      color: isDark ? Colors.grey[800] : Colors.grey[300],
                      child: const Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              if (event.thumbnail != null && event.thumbnail!.isNotEmpty)
                const SizedBox(height: 24),

              // Title
              Text(
                event.title,
                style: pBold20.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),

              // Date & Time
              if (event.startDate != null) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      IconlyLight.calendar,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _formatDateRange(event.startDate, event.endDate),
                        style: pMedium12.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Location
              if (event.location != null && event.location!.isNotEmpty) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      IconlyLight.location,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        event.location!,
                        style: pMedium12.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Quota
              if (event.maxQuota != null && event.maxQuota! > 0) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Kuota: ${event.maxQuota} Orang',
                        style: pMedium12.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Price
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    IconlyLight.ticket,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Harga: ${event.formattedPrice ?? 'Gratis'}',
                      style: pMedium12.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text('Deskripsi Event', style: pSemiBold14),
              const SizedBox(height: 8),
              if (event.content != null && event.content!.isNotEmpty)
                Builder(
                  builder: (context) {
                    // Remove hardcoded inline colors (rgb and hex) from the rich text editor
                    final cleanContent = event.content!
                        .replaceAll(RegExp(r'color:\s*rgb\([0-9,\s]+\);?'), '')
                        .replaceAll(RegExp(r'color:\s*#[0-9a-fA-F]+;?'), '');

                    return HtmlWidget(
                      cleanContent,
                      textStyle: pRegular12.copyWith(
                        height: 1.6,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      customStylesBuilder: (element) {
                        return {'color': isDark ? '#E5E5E5' : '#2F2F2F'};
                      },
                    );
                  },
                )
              else if (event.excerpt != null && event.excerpt!.isNotEmpty)
                Text(
                  event.excerpt!,
                  style: pRegular12.copyWith(
                    height: 1.6,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
      bottomNavigationBar: Obx(() {
        if (controller.isLoading.value || controller.event.value == null) {
          return const SizedBox.shrink();
        }

        final event = controller.event.value!;
        final isRegistered = event.isRegistered;
        // final isFull =
        //     false; // We can handle this through backend validation or add a specific check if we want

        return Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).padding.bottom + 16,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, -5),
                blurRadius: 10,
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: isRegistered || controller.isRegistering.value
                ? null
                : () {
                    if (!AuthController.to.isLogin.value) {
                      final homeController = Get.put(HomeScreenController());
                      homeController.isEmailLogin.value = false;
                      Get.dialog(
                          const HomeScreen().buildLoginDialog(homeController));
                    } else {
                      controller.registerEvent();
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: isRegistered
                  ? Colors.grey
                  : Theme.of(context).primaryColor,
              disabledBackgroundColor: Colors.grey[400],
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
                    isRegistered ? 'Sudah Terdaftar' : 'Daftar Sekarang',
                    style: pBold14.copyWith(color: Colors.white),
                  ),
          ),
        );
      }),
    );
  }

  String _formatDateRange(DateTime? start, DateTime? end) {
    if (start == null) return '-';
    final startStr = DateFormat('dd MMM yyyy, HH:mm').format(start);
    if (end == null) return startStr;

    // If same day, just show time range
    if (start.year == end.year &&
        start.month == end.month &&
        start.day == end.day) {
      final endTimeStr = DateFormat('HH:mm').format(end);
      return '$startStr - $endTimeStr';
    }

    final endStr = DateFormat('dd MMM yyyy, HH:mm').format(end);
    return '$startStr - $endStr';
  }

  Widget _buildLoadingShimmer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 24),
            Container(height: 24, width: double.infinity, color: Colors.white),
            const SizedBox(height: 8),
            Container(height: 24, width: 200, color: Colors.white),
            const SizedBox(height: 16),
            Container(height: 20, width: 150, color: Colors.white),
            const SizedBox(height: 12),
            Container(height: 20, width: 200, color: Colors.white),
            const SizedBox(height: 32),
            Container(height: 16, width: double.infinity, color: Colors.white),
            const SizedBox(height: 8),
            Container(height: 16, width: double.infinity, color: Colors.white),
            const SizedBox(height: 8),
            Container(height: 16, width: 250, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
