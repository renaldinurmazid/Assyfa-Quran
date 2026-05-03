import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/controller/memorize_leaderboard_controller.dart';
import 'package:quran_app/models/memorization_leaderboard_model.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';
import 'package:shimmer/shimmer.dart';

class MemorizeLeaderboardScreen extends StatelessWidget {
  const MemorizeLeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MemorizeLeaderboardController());
    final colorScheme = context.theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text("Peringkat Hafalan", style: pSemiBold16),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          Obx(() {
            if (controller.isLoading.value &&
                controller.leaderboardData.value == null) {
              return _buildLoadingState(context);
            }

            final data = controller.leaderboardData.value;
            if (data == null || data.leaderboard.isEmpty) {
              return _buildEmptyState(context);
            }

            return RefreshIndicator(
              onRefresh: controller.fetchLeaderboard,
              color: AppColor.primaryColor,
              child: CustomScrollView(
                slivers: [
                  // Top 3 Podium
                  SliverToBoxAdapter(
                    child: _buildPodium(context, data.leaderboard),
                  ),

                  // Leaderboard List
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          // Start from 4th person (index 3) because top 3 are in podium
                          if (data.leaderboard.length <= 3) return null;
                          final listIndex = index + 3;
                          if (listIndex >= data.leaderboard.length) return null;

                          final entry = data.leaderboard[listIndex];
                          return _buildLeaderboardTile(context, entry);
                        },
                        childCount: data.leaderboard.length > 3
                            ? data.leaderboard.length - 3
                            : 0,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          // My Stat Bottom Bar
          Obx(() {
            final myStat = controller.leaderboardData.value?.myStat;
            if (myStat == null) return const SizedBox.shrink();

            return _buildMyStatBar(context, myStat);
          }),
        ],
      ),
    );
  }

  Widget _buildPodium(BuildContext context, List<LeaderboardEntry> entries) {
    if (entries.isEmpty) return const SizedBox.shrink();

    // Reorder for visual podium: 2, 1, 3
    LeaderboardEntry? first = entries.isNotEmpty ? entries[0] : null;
    LeaderboardEntry? second = entries.length > 1 ? entries[1] : null;
    LeaderboardEntry? third = entries.length > 2 ? entries[2] : null;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (second != null) _buildPodiumItem(context, second, 2, 80),
          const SizedBox(width: 12),
          if (first != null) _buildPodiumItem(context, first, 1, 100),
          const SizedBox(width: 12),
          if (third != null) _buildPodiumItem(context, third, 3, 70),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(
    BuildContext context,
    LeaderboardEntry entry,
    int rank,
    double avatarSize,
  ) {
    final isFirst = rank == 1;

    return Expanded(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isFirst ? Colors.amber : Colors.grey.shade400,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isFirst ? Colors.amber : Colors.grey).withValues(
                        alpha: 0.2,
                      ),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: avatarSize / 2,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: entry.user?.profilePicture != null
                      ? CachedNetworkImageProvider(entry.user!.profilePicture!)
                      : null,
                  child: entry.user?.profilePicture == null
                      ? Icon(
                          Icons.person,
                          size: avatarSize / 2,
                          color: Colors.grey,
                        )
                      : null,
                ),
              ),
              Positioned(
                bottom: -5,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isFirst ? Colors.amber : Colors.grey.shade400,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    "$rank",
                    style: pBold12.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            entry.user?.name ?? "User",
            style: pSemiBold12,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColor.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "${entry.totalPoints} Pts",
              style: pBold10.copyWith(
                color: context.isDarkMode
                    ? Colors.white
                    : AppColor.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTile(BuildContext context, LeaderboardEntry entry) {
    final colorScheme = context.theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.isDarkMode ? colorScheme.surfaceContainer : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              "${entry.rank ?? '-'}",
              style: pBold14.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ),
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[200],
            backgroundImage: entry.user?.profilePicture != null
                ? CachedNetworkImageProvider(entry.user!.profilePicture!)
                : null,
            child: entry.user?.profilePicture == null
                ? const Icon(Icons.person, size: 20, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.user?.name ?? "User",
                  style: pSemiBold14,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  entry.highestLevel?.title ?? "Belum ada level",
                  style: pRegular10.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${entry.totalPoints}",
                style: pBold14.copyWith(color: AppColor.primaryColor),
              ),
              Text(
                "Points",
                style: pRegular10.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMyStatBar(BuildContext context, LeaderboardEntry myStat) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColor.primaryColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColor.primaryColor.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Text(
                "${myStat.rank ?? '-'}",
                style: pBold14.copyWith(color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Peringkat Kamu",
                    style: pRegular10.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  Text(
                    "Tetap semangat menghafal!",
                    style: pSemiBold14.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${myStat.totalPoints}",
                  style: pBold16.copyWith(color: Colors.white),
                ),
                Text(
                  "Points",
                  style: pRegular10.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: context.isDarkMode
          ? Colors.grey[700]!
          : Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Container(
                  width: 80,
                  height: 150,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView.builder(
                itemCount: 6,
                itemBuilder: (_, __) => Container(
                  height: 70,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text("Belum ada data peringkat", style: pSemiBold16),
          Text(
            "Mulai menghafal untuk menjadi yang pertama!",
            style: pRegular14.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
