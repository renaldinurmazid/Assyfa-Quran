import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:quran_app/models/event_model.dart';
import 'package:quran_app/screen/event/event_detail_controller.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/screen/home/home_screen_controller.dart';
import 'package:quran_app/screen/home/home_screen.dart';
import 'package:quran_app/services/deep_link_service.dart';
import 'package:quran_app/theme/font.dart';
import 'package:quran_app/theme/app_color.dart';

class ShowEventScreen extends StatelessWidget {
  const ShowEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (Get.isRegistered<EventDetailController>()) {
      Get.delete<EventDetailController>();
    }
    final controller = Get.put(EventDetailController());

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Obx(() {
          final event = controller.event.value;
          return Text(
            event?.title ?? 'Detail Event',
            style: pSemiBold16,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        }),
        centerTitle: false,
        backgroundColor: context.theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(LucideIcons.arrowLeft),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return _buildShimmer();
          }
          final event = controller.event.value;
          if (event == null) return _buildError(context);

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildEventInfo(context, event),
                // _buildInfoSection(context, event),
                if (event.hasVideo) ...[
                  const SizedBox(height: 16),
                  _buildVideoCard(context, event),
                ],
                if (event.groupLink != null && event.groupLink!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildGroupCard(context, event),
                ],
                const SizedBox(height: 16),
                _buildDescription(context, event),
                const SizedBox(height: 32),
              ],
            ),
          );
        }),
      ),
      bottomNavigationBar: Obx(() {
        final event = controller.event.value;
        if (event == null || controller.isLoading.value) {
          return const SizedBox.shrink();
        }
        return _buildBottomBar(context, event, controller);
      }),
    );
  }

  // ─── Event Info (Image + Title) ──────────────────────────────────────────

  Widget _buildEventInfo(BuildContext context, EventModel event) {
    final primary = context.theme.colorScheme.primary;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.only(left: 2, top: 2, right: 2, bottom: 18),
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.globalBorder),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (event.thumbnail != null && event.thumbnail!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: event.thumbnail!,
                height: 180,
                width: Get.width,
                fit: BoxFit.cover,
                placeholder: (c, _) => Container(color: AppColor.globalBorder),
                errorWidget: (c, _, __) => Container(
                  color: AppColor.globalBorder,
                  height: 180,
                  width: Get.width,
                  child: const Icon(LucideIcons.imageOff, color: Colors.grey),
                ),
              ),
            )
          else
            Container(
              height: 180,
              width: Get.width,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(LucideIcons.calendar, size: 40, color: primary),
            ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              event.title,
              style: pBold16.copyWith(color: AppColor.globalTextSecondary),
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 2.8,
              mainAxisSpacing: 16,
              crossAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Waktu",
                      style: pSemiBold14.copyWith(
                        color: AppColor.globalTextSecondary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDateRange(event.startDate, event.endDate),
                      style: pMedium12.copyWith(
                        color: context.theme.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Lokasi",
                      style: pSemiBold14.copyWith(
                        color: AppColor.globalTextSecondary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      (event.location != null && event.location!.isNotEmpty)
                          ? event.location!
                          : 'Online / Belum ditentukan',
                      style: pMedium12.copyWith(
                        color: context.theme.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Kuota",
                      style: pSemiBold14.copyWith(
                        color: AppColor.globalTextSecondary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      (event.maxQuota != null && event.maxQuota! > 0)
                          ? '${event.maxQuota} Peserta'
                          : 'Tanpa batas',
                      style: pMedium12.copyWith(
                        color: context.theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Biaya",
                      style: pSemiBold14.copyWith(
                        color: AppColor.globalTextSecondary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      (event.price == null || event.price == 0)
                          ? 'Gratis'
                          : (event.formattedPrice ?? 'Rp ${event.price}'),
                      style: pMedium12.copyWith(
                        color: context.theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Recording (finished events) ──────────────────────────────────────────

  Future<void> _openVideo(String url) async {
    final uri = Uri.tryParse(url.trim());
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildVideoCard(BuildContext context, EventModel event) {
    final primary = context.theme.colorScheme.primary;
    return GestureDetector(
      onTap: () => _openVideo(event.videoUrl!),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: primary.withValues(alpha: context.isDarkMode ? 0.1 : 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: primary.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                LucideIcons.circlePlay,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rekaman Event',
                    style: pSemiBold14.copyWith(
                      color: context.theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tonton ulang acara ini',
                    style: pRegular12.copyWith(
                      color: AppColor.globalTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.externalLink,
              size: 18,
              color: primary.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }

  /// Replaces "Daftar Sekarang" once the event is over.
  Widget _buildEndedAction(BuildContext context, EventModel event) {
    final primary = context.theme.colorScheme.primary;
    final hasVideo = event.hasVideo;
    return SizedBox(
      height: 48,
      child: ElevatedButton.icon(
        onPressed: hasVideo ? () => _openVideo(event.videoUrl!) : null,
        icon: Icon(
          hasVideo ? LucideIcons.circlePlay : LucideIcons.calendarCheck,
          size: 18,
          color: Colors.white,
        ),
        label: Text(
          hasVideo ? 'Tonton Rekaman' : 'Event Telah Selesai',
          style: pSemiBold14.copyWith(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primary,
          disabledBackgroundColor: primary.withValues(alpha: 0.5),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // ─── WhatsApp Group Card ──────────────────────────────────────────────────

  Widget _buildGroupCard(BuildContext context, EventModel event) {
    return GestureDetector(
      onTap: () async {
        final groupLink = event.groupLink;
        if (groupLink != null && groupLink.isNotEmpty) {
          final url = Uri.tryParse(groupLink);
          if (url != null && await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(
            0xFF25D366,
          ).withValues(alpha: context.isDarkMode ? 0.07 : 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF25D366).withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF25D366),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                LucideIcons.messageCircle,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Grup Komunitas',
                    style: pSemiBold14.copyWith(
                      color: context.theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Bergabung ke grup diskusi peserta',
                    style: pRegular12.copyWith(
                      color: AppColor.globalTextSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              size: 18,
              color: const Color(0xFF25D366).withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Description ──────────────────────────────────────────────────────────

  Widget _buildDescription(BuildContext context, EventModel event) {
    return Container(
      width: Get.width,
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.globalBorder),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tentang Event',
            style: pSemiBold14.copyWith(
              color: AppColor.globalTextSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          (event.content != null && event.content!.isNotEmpty)
              ? Builder(
                  builder: (ctx) {
                    final clean = (event.content ?? '')
                        .replaceAll(RegExp(r'color:\s*rgb\([0-9,\s]+\);?'), '')
                        .replaceAll(RegExp(r'color:\s*#[0-9a-fA-F]+;?'), '')
                        .replaceAll('&nbsp;', ' ')
                        .replaceAll(' ', ' ')
                        .replaceAll(
                          'word-break: break-all',
                          'word-break: normal',
                        )
                        .replaceAll(
                          'word-break: break-word',
                          'word-break: normal',
                        );
                    return HtmlWidget(
                      clean,
                      textStyle: pRegular14.copyWith(
                        height: 1.7,
                        color: Get.context!.theme.colorScheme.onSurface
                            .withValues(alpha: 0.8),
                      ),
                      customStylesBuilder: (_) => {'word-break': 'normal'},
                    );
                  },
                )
              : Text(
                  event.excerpt ?? 'Tidak ada deskripsi untuk event ini.',
                  style: pRegular14.copyWith(
                    height: 1.7,
                    color: Get.context!.theme.colorScheme.onSurface.withValues(
                      alpha: 0.8,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  // ─── Bottom Bar ───────────────────────────────────────────────────────────

  Widget _buildBottomBar(
    BuildContext context,
    EventModel event,
    EventDetailController controller,
  ) {
    final isRegistered = event.isRegistered;
    final primary = context.theme.colorScheme.primary;

    return Container(
      width: Get.width,
      padding: EdgeInsets.only(
        left: 14,
        right: 14,
        top: 18,
        bottom: MediaQuery.of(context).padding.bottom > 0
            ? MediaQuery.of(context).padding.bottom
            : 18,
      ),
      decoration: BoxDecoration(
        color: context.theme.scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: AppColor.globalBorder, width: 1)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              final shareUrl = DeepLinkService.createEventShareLink(
                event.slug.isNotEmpty ? event.slug : event.id.toString(),
              );
              final dateStr = event.startDate != null
                  ? '${DateFormat('dd MMMM yyyy, HH:mm').format(event.startDate!)} WIB'
                  : null;

              final shareText = StringBuffer();
              shareText.writeln('📢 Ikuti Event "${event.title}" di Quranuna!');
              if (dateStr != null) {
                shareText.writeln('🗓️ Waktu: $dateStr');
              }
              if (event.location != null && event.location!.isNotEmpty) {
                shareText.writeln('📍 Lokasi: ${event.location}');
              }
              shareText.writeln();
              shareText.writeln(
                'Buka atau daftar langsung melalui link berikut:',
              );
              shareText.write(shareUrl);

              SharePlus.instance.share(
                ShareParams(text: shareText.toString(), subject: event.title),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
              decoration: BoxDecoration(
                border: Border.all(color: AppColor.globalBorder),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.share2, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    'Bagikan',
                    style: pRegular12.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: event.hasEnded
                ? _buildEndedAction(context, event)
                : Obx(() {
                    final registering = controller.isRegistering.value;
                    return SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isRegistered || registering
                            ? null
                            : () {
                                if (!AuthController.to.isLogin.value) {
                                  final hc = Get.put(HomeScreenController());
                                  hc.isEmailLogin.value = false;
                                  Get.dialog(
                                    const HomeScreen().buildLoginDialog(hc),
                                  );
                                } else {
                                  controller.registerEvent();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: primary,
                          disabledBackgroundColor: primary.withValues(
                            alpha: 0.5,
                          ),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: registering
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (isRegistered) ...[
                                    const Icon(
                                      LucideIcons.checkCircle2,
                                      size: 17,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 7),
                                    Text(
                                      'Sudah Terdaftar',
                                      style: pSemiBold14.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ] else ...[
                                    Text(
                                      'Daftar Sekarang',
                                      style: pSemiBold14.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                      ),
                    );
                  }),
          ),
        ],
      ),
    );
  }

  // ─── Error State ──────────────────────────────────────────────────────────

  Widget _buildError(BuildContext context) {
    final primary = context.theme.colorScheme.primary;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(LucideIcons.alertTriangle, size: 32, color: primary),
            ),
            const SizedBox(height: 20),
            Text(
              'Event Tidak Ditemukan',
              style: pBold16.copyWith(
                color: context.theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Data event mungkin telah dihapus\\natau koneksi terputus.',
              textAlign: TextAlign.center,
              style: pRegular14.copyWith(
                color: AppColor.globalTextSecondary,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: primary,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Kembali',
                  style: pSemiBold14.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Shimmer Loading ──────────────────────────────────────────────────────

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.all(14),
              height: 240,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14),
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14),
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

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
