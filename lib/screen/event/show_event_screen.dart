import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:iconly/iconly.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:quran_app/models/event_model.dart';
import 'package:quran_app/screen/event/event_detail_controller.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/screen/home/home_screen_controller.dart';
import 'package:quran_app/screen/home/home_screen.dart';
import 'package:quran_app/theme/font.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
const _kBgDark = Color(0xFF0D0D0F);
const _kBgLight = Color(0xFFF6F7F9);
const _kSurfaceDark = Color(0xFF16161A);
const _kSurfaceLight = Colors.white;
const _kBorderDark = Color(0xFF242428);
const _kBorderLight = Color(0xFFEAECF0);
const _kSubtleDark = Color(0xFF1E1E24);
const _kSubtleLight = Color(0xFFF0F2F5);
const _kGreen = Color(0xFF25D366);

class ShowEventScreen extends StatelessWidget {
  const ShowEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<EventDetailController>()
        ? Get.find<EventDetailController>()
        : Get.put(EventDetailController());
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? _kBgDark : _kBgLight,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        child: Obx(() {
          if (controller.isLoading.value) {
            return _buildShimmer(context, isDark);
          }
          final event = controller.event.value;
          if (event == null) return _buildError(context, isDark);

          return Stack(
            children: [
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildAppBar(context, event, isDark),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildHeader(context, event, isDark),
                        const SizedBox(height: 24),
                        _buildInfoSection(context, event, isDark),
                        if (event.groupLink != null &&
                            event.groupLink!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _buildGroupCard(context, event, isDark),
                        ],
                        const SizedBox(height: 28),
                        _buildDescription(context, event, isDark),
                      ]),
                    ),
                  ),
                ],
              ),
              _buildBottomBar(context, event, controller, isDark),
            ],
          );
        }),
      ),
    );
  }

  // ─── App Bar ──────────────────────────────────────────────────────────────

  Widget _buildAppBar(BuildContext context, EventModel event, bool isDark) {
    final hasThumbnail = event.thumbnail != null && event.thumbnail!.isNotEmpty;
    final isFree = event.price == null || event.price == 0;

    return SliverAppBar(
      expandedHeight: hasThumbnail ? 300 : 0,
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: isDark ? _kSurfaceDark : _kSurfaceLight,
      leading: Padding(
        padding: const EdgeInsets.all(10),
        child: _glassButton(
          icon: IconlyLight.arrow_left,
          onTap: () => Get.back(),
          hasThumbnail: hasThumbnail,
          isDark: isDark,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: _glassButton(
            icon: IconlyLight.send,
            onTap: () => SharePlus.instance.share(
              ShareParams(
                text:
                    'Yuk ikuti event "${event.title}" di Quranuna!\n\nSimak info selengkapnya di aplikasi.',
              ),
            ),
            hasThumbnail: hasThumbnail,
            isDark: isDark,
          ),
        ),
      ],
      flexibleSpace: hasThumbnail
          ? FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: event.thumbnail!,
                    fit: BoxFit.cover,
                    placeholder: (c, _) => Container(
                      color: isDark ? _kSurfaceDark : const Color(0xFFEEEFF2),
                    ),
                    errorWidget: (c, _, __) => Container(
                      color: isDark ? _kSurfaceDark : const Color(0xFFEEEFF2),
                      child: Icon(
                        Icons.broken_image_outlined,
                        size: 40,
                        color: isDark ? _kBorderDark : _kBorderLight,
                      ),
                    ),
                  ),
                  // Gradient overlay
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.35),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.72),
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                  // Bottom overlay badges
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (event.startDate != null)
                          _pillBadge(
                            icon: IconlyLight.calendar,
                            label: DateFormat('dd MMM yyyy').format(
                              event.startDate!,
                            ),
                            bgColor: Colors.white,
                            textColor: const Color(0xFF1A1A2E),
                            context: context,
                          )
                        else
                          const SizedBox.shrink(),
                        _pillBadge(
                          label: isFree
                              ? 'Gratis'
                              : (event.formattedPrice ?? 'Rp ${event.price}'),
                          bgColor: context.theme.colorScheme.primary,
                          textColor: Colors.white,
                          context: context,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _glassButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool hasThumbnail,
    required bool isDark,
  }) {
    if (!hasThumbnail) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isDark ? _kSubtleDark : _kSubtleLight,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 18,
            color: isDark ? Colors.white70 : const Color(0xFF1A1A2E),
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
              ),
            ),
            child: Icon(icon, size: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _pillBadge({
    IconData? icon,
    required String label,
    required Color bgColor,
    required Color textColor,
    required BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: textColor),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: pSemiBold12.copyWith(color: textColor, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ─── Header (Title + Badge) ───────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, EventModel event, bool isDark) {
    final primary = context.theme.colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: primary.withValues(alpha: 0.15)),
              ),
              child: Text(
                'Event & Kajian',
                style: pSemiBold12.copyWith(color: primary, fontSize: 11),
              ),
            ),
            if (event.isRegistered)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 12,
                      color: Color(0xFF10B981),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Terdaftar',
                      style: pSemiBold12.copyWith(
                        color: const Color(0xFF10B981),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          event.title,
          style: pBold20.copyWith(
            fontSize: 22,
            height: 1.35,
            color: context.theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  // ─── Info Section ─────────────────────────────────────────────────────────

  Widget _buildInfoSection(BuildContext context, EventModel event, bool isDark) {
    final dividerColor = isDark ? _kBorderDark : _kBorderLight;
    final subtleText = isDark ? Colors.grey.shade500 : Colors.grey.shade500;
    final mainText = context.theme.colorScheme.onSurface;

    final rows = <_InfoRow>[
      _InfoRow(
        icon: IconlyLight.calendar,
        iconColor: context.theme.colorScheme.primary,
        label: 'Waktu',
        value: _formatDateRange(event.startDate, event.endDate),
      ),
      _InfoRow(
        icon: IconlyLight.location,
        iconColor: const Color(0xFFF97316),
        label: 'Lokasi',
        value: (event.location != null && event.location!.isNotEmpty)
            ? event.location!
            : 'Online / Belum ditentukan',
      ),
      _InfoRow(
        icon: IconlyLight.user_1,
        iconColor: const Color(0xFF6366F1),
        label: 'Kuota',
        value: (event.maxQuota != null && event.maxQuota! > 0)
            ? '${event.maxQuota} peserta'
            : 'Tanpa batas',
      ),
      _InfoRow(
        icon: IconlyLight.ticket,
        iconColor: const Color(0xFF10B981),
        label: 'Biaya',
        value: (event.price == null || event.price == 0)
            ? 'Gratis'
            : (event.formattedPrice ?? 'Rp ${event.price}'),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? _kSurfaceDark : _kSurfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: dividerColor),
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: rows[i].iconColor.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      rows[i].icon,
                      size: 18,
                      color: rows[i].iconColor,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rows[i].label,
                          style: pRegular12.copyWith(
                            color: subtleText,
                            fontSize: 11,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          rows[i].value,
                          style: pMedium14.copyWith(
                            color: mainText,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (i < rows.length - 1)
              Divider(
                height: 1,
                indent: 70,
                endIndent: 0,
                color: dividerColor,
              ),
          ],
        ],
      ),
    );
  }

  // ─── WhatsApp Group Card ──────────────────────────────────────────────────

  Widget _buildGroupCard(BuildContext context, EventModel event, bool isDark) {
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
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: _kGreen.withValues(alpha: isDark ? 0.07 : 0.06),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _kGreen.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _kGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
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
                      color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              IconlyLight.arrow_right_2,
              size: 18,
              color: _kGreen.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Description ──────────────────────────────────────────────────────────

  Widget _buildDescription(
    BuildContext context,
    EventModel event,
    bool isDark,
  ) {
    final subtleText = isDark ? Colors.grey.shade500 : Colors.grey.shade500;
    final contentColor = isDark ? Colors.grey.shade300 : const Color(0xFF374151);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tentang Event',
          style: pSemiBold16.copyWith(
            color: context.theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Informasi lengkap mengenai event ini',
          style: pRegular12.copyWith(color: subtleText, fontSize: 12),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? _kSurfaceDark : _kSurfaceLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? _kBorderDark : _kBorderLight,
            ),
          ),
          child: (event.content != null && event.content!.isNotEmpty)
              ? Builder(
                  builder: (ctx) {
                    final clean = (event.content ?? '')
                        .replaceAll(
                          RegExp(r'color:\s*rgb\([0-9,\s]+\);?'),
                          '',
                        )
                        .replaceAll(RegExp(r'color:\s*#[0-9a-fA-F]+;?'), '');
                    return HtmlWidget(
                      clean,
                      textStyle: pRegular14.copyWith(
                        height: 1.75,
                        color: contentColor,
                        fontSize: 13.5,
                      ),
                      customStylesBuilder: (_) => {
                        'color': isDark ? '#D1D5DB' : '#374151',
                        'line-height': '1.75',
                      },
                    );
                  },
                )
              : Text(
                  event.excerpt ?? 'Tidak ada deskripsi untuk event ini.',
                  style: pRegular14.copyWith(
                    height: 1.75,
                    color: contentColor,
                    fontSize: 13.5,
                  ),
                ),
        ),
      ],
    );
  }

  // ─── Bottom Bar ───────────────────────────────────────────────────────────

  Widget _buildBottomBar(
    BuildContext context,
    EventModel event,
    EventDetailController controller,
    bool isDark,
  ) {
    final isRegistered = event.isRegistered;
    final isFree = event.price == null || event.price == 0;
    final primary = context.theme.colorScheme.primary;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: MediaQuery.of(context).padding.bottom + 16,
            ),
            decoration: BoxDecoration(
              color: (isDark ? _kSurfaceDark : _kSurfaceLight).withValues(
                alpha: 0.9,
              ),
              border: Border(
                top: BorderSide(
                  color: isDark ? _kBorderDark : _kBorderLight,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                // Price
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Biaya',
                      style: pRegular12.copyWith(
                        color: isDark
                            ? Colors.grey.shade500
                            : Colors.grey.shade500,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isFree
                          ? 'Gratis'
                          : (event.formattedPrice ?? 'Rp ${event.price}'),
                      style: pBold16.copyWith(
                        color: primary,
                        fontSize: 18,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),

                // CTA Button
                Expanded(
                  child: Obx(() {
                    final registering = controller.isRegistering.value;
                    return SizedBox(
                      height: 52,
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
                          backgroundColor: isRegistered
                              ? (isDark
                                    ? _kSubtleDark
                                    : _kSubtleLight)
                              : primary,
                          disabledBackgroundColor: isRegistered
                              ? (isDark ? _kSubtleDark : _kSubtleLight)
                              : primary.withValues(alpha: 0.55),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: isRegistered
                                ? BorderSide(
                                    color: isDark
                                        ? _kBorderDark
                                        : _kBorderLight,
                                  )
                                : BorderSide.none,
                          ),
                        ),
                        child: registering
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: isRegistered
                                      ? (isDark
                                            ? Colors.white54
                                            : Colors.black38)
                                      : Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (isRegistered) ...[
                                    Icon(
                                      Icons.check_circle_rounded,
                                      size: 17,
                                      color: isDark
                                          ? Colors.grey.shade400
                                          : Colors.grey.shade500,
                                    ),
                                    const SizedBox(width: 7),
                                    Text(
                                      'Sudah Terdaftar',
                                      style: pSemiBold14.copyWith(
                                        color: isDark
                                            ? Colors.grey.shade400
                                            : Colors.grey.shade500,
                                      ),
                                    ),
                                  ] else ...[
                                    Text(
                                      'Daftar Sekarang',
                                      style: pSemiBold14.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(
                                      IconlyLight.arrow_right,
                                      size: 16,
                                      color: Colors.white,
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
          ),
        ),
      ),
    );
  }

  // ─── Error State ──────────────────────────────────────────────────────────

  Widget _buildError(BuildContext context, bool isDark) {
    final primary = context.theme.colorScheme.primary;
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.topLeft,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark ? _kSubtleDark : _kSubtleLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    IconlyLight.arrow_left,
                    size: 18,
                    color: context.theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
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
                      child: Icon(
                        IconlyLight.danger,
                        size: 32,
                        color: primary,
                      ),
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
                      'Data event mungkin telah dihapus\natau koneksi terputus.',
                      textAlign: TextAlign.center,
                      style: pRegular14.copyWith(
                        color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
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
            ),
          ),
        ],
      ),
    );
  }

  // ─── Shimmer Loading ──────────────────────────────────────────────────────

  Widget _buildShimmer(BuildContext context, bool isDark) {
    final base = isDark
        ? (Colors.grey[800] ?? const Color(0xFF27272A))
        : (Colors.grey[200] ?? const Color(0xFFE5E7EB));
    final highlight = isDark
        ? (Colors.grey[700] ?? const Color(0xFF3F3F46))
        : (Colors.grey[50] ?? const Color(0xFFF9FAFB));

    shimmerBox({double? w, double h = 16, double r = 10}) => Container(
          width: w ?? double.infinity,
          height: h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(r),
          ),
        );

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 300, width: double.infinity, color: Colors.white),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  shimmerBox(w: 80, h: 24, r: 100),
                  const SizedBox(height: 16),
                  shimmerBox(h: 26),
                  const SizedBox(height: 8),
                  shimmerBox(w: 200, h: 26),
                  const SizedBox(height: 28),
                  Container(
                    width: double.infinity,
                    height: 210,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(height: 28),
                  shimmerBox(w: 110, h: 20),
                  const SizedBox(height: 8),
                  shimmerBox(w: 200, h: 14),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ],
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
    final startStr = DateFormat('dd MMM yyyy, HH:mm').format(start);
    if (end == null) return startStr;

    if (start.year == end.year &&
        start.month == end.month &&
        start.day == end.day) {
      return '$startStr – ${DateFormat('HH:mm').format(end)} WIB';
    }

    return '$startStr – ${DateFormat('dd MMM yyyy, HH:mm').format(end)} WIB';
  }
}

// ─── Data class for info rows ──────────────────────────────────────────────

class _InfoRow {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });
}
