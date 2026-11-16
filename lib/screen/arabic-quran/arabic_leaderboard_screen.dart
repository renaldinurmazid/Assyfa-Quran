import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/models/arabic_learning/arabic_leaderboard_model.dart';
import 'package:quran_app/screen/arabic-quran/arabic_leaderboard_controller.dart';
import 'package:quran_app/screen/arabic-quran/arabic_widgets.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';

const _gold = Color(0xFFF5B301);
const _silver = Color(0xFF9AA5B1);
const _bronze = Color(0xFFCD7F32);

/// XP ranking of all learners in the Arabic course.
class ArabicLeaderboardScreen extends StatefulWidget {
  const ArabicLeaderboardScreen({super.key});

  @override
  State<ArabicLeaderboardScreen> createState() =>
      _ArabicLeaderboardScreenState();
}

class _ArabicLeaderboardScreenState extends State<ArabicLeaderboardScreen> {
  final controller = Get.put(ArabicLeaderboardController());
  final scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    scroll.addListener(() {
      if (scroll.position.extentAfter < 300) controller.loadMore();
    });
  }

  @override
  void dispose() {
    scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Get.back(),
        ),
        title: Text('Leaderboard', style: pSemiBold16),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshBoard,
        child: Obx(() {
          if (controller.isLoading.value && controller.entries.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: const [
                ArabicShimmerBox(height: 120),
                ArabicShimmerBox(height: 64),
                ArabicShimmerBox(height: 64),
                ArabicShimmerBox(height: 64),
              ],
            );
          }

          if (controller.entries.isEmpty) {
            return _EmptyState(
              failed: controller.failed.value,
              onRetry: controller.refreshBoard,
            );
          }

          final myId = controller.myStat.value?.userId;
          return ListView(
            controller: scroll,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
            children: [
              if (controller.myStat.value != null)
                ArabicReveal(
                  child: _MyRankCard(stat: controller.myStat.value!),
                ),
              const SizedBox(height: 22),
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 10),
                child: Text(
                  '${controller.total.value} pelajar',
                  style: pSemiBold12.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              for (final entry in controller.entries)
                _EntryTile(entry: entry, isMe: entry.userId == myId),
              if (controller.isLoadingMore.value)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool failed;
  final Future<void> Function() onRetry;
  const _EmptyState({required this.failed, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      failed ? LucideIcons.wifiOff : LucideIcons.trophy,
                      size: 32,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    failed
                        ? 'Leaderboard belum bisa dimuat'
                        : 'Belum ada peringkat',
                    style: pBold16,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    failed
                        ? 'Periksa koneksi internet, lalu coba lagi.'
                        : 'Selesaikan pelajaran untuk mendapat XP dan masuk peringkat.',
                    style: pMedium12.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (failed) ...[
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: onRetry,
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Coba lagi',
                        style: pSemiBold14.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The caller's own standing, shown above the list.
class _MyRankCard extends StatelessWidget {
  final ArabicLeaderboardEntry stat;
  const _MyRankCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    final base = context.isDarkMode
        ? AppColor.primaryColorDark
        : AppColor.primaryColor;
    final ranked = stat.rank != null;

    return ArabicGradientCard(
      color: base,
      child: Row(
        children: [
          _Avatar(entry: stat, size: 52, ring: Colors.white),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Peringkat kamu',
                  style: pMedium12.copyWith(
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
                Text(
                  ranked ? '#${stat.rank}' : 'Belum berperingkat',
                  style: pBold24.copyWith(
                    color: Colors.white,
                    fontSize: ranked ? 32 : 18,
                    height: 1.15,
                  ),
                ),
                if (!ranked)
                  Text(
                    'Selesaikan pelajaran untuk mendapat XP',
                    style: pMedium10.copyWith(
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text(
                    '${stat.totalXp}',
                    style: pBold20.copyWith(color: Colors.white),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    LucideIcons.zap,
                    size: 18,
                    color: AppColor.secondaryColor,
                  ),
                ],
              ),
              Text(
                'Total XP',
                style: pMedium10.copyWith(
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  final ArabicLeaderboardEntry entry;
  final bool isMe;
  const _EntryTile({required this.entry, required this.isMe});

  Color? get _medal => switch (entry.rank) {
    1 => _gold,
    2 => _silver,
    3 => _bronze,
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final primary = colorScheme.primary;
    final medal = _medal;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: arabicCardDecoration(
        context,
        accent: isMe ? primary : medal,
        radius: 18,
      ).copyWith(color: isMe ? primary.withValues(alpha: 0.08) : null),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: medal != null
                ? Icon(LucideIcons.trophy, size: 22, color: medal)
                : Text(
                    '${entry.rank}',
                    textAlign: TextAlign.center,
                    style: pBold14.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          _Avatar(entry: entry, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isMe ? '${entry.name} (kamu)' : entry.name,
              style: pSemiBold14,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text('${entry.totalXp}', style: pBold14.copyWith(color: primary)),
          const SizedBox(width: 3),
          Icon(LucideIcons.zap, size: 14, color: AppColor.secondaryColor),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final ArabicLeaderboardEntry entry;
  final double size;
  final Color? ring;
  const _Avatar({required this.entry, required this.size, this.ring});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final initial = entry.name.isEmpty ? '?' : entry.name[0].toUpperCase();
    final fallback = Center(
      child: Text(
        initial,
        style: pBold16.copyWith(
          color: colorScheme.primary,
          fontSize: size * 0.4,
        ),
      ),
    );
    final url = entry.profilePicture;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.primary.withValues(alpha: 0.12),
        border: ring == null ? null : Border.all(color: ring!, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: url == null || url.isEmpty
          ? fallback
          : CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => fallback,
              placeholder: (_, __) => fallback,
            ),
    );
  }
}
