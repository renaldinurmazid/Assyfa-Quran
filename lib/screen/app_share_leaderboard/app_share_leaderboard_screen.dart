import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:quran_app/controller/app_share_leaderboard_controller.dart';
import 'package:quran_app/models/leaderboard/app_share_leaderboard_model.dart';
import 'package:quran_app/theme/font.dart';

class AppShareLeaderboardScreen extends StatelessWidget {
  const AppShareLeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AppShareLeaderboardController());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(IconlyLight.arrow_left, color: Colors.white),
        ),
        title: Text(
          'Penyebar Al-Quran',
          style: pSemiBold16.copyWith(color: Colors.white),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Stack(
        children: [
          _buildBackgroundHeader(context),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),
                _buildFilterTabs(context, controller),
                const SizedBox(height: 20),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).primaryColor,
                        ),
                      );
                    }
                    if (controller.leaderboard.isEmpty) {
                      return _buildEmptyState(context);
                    }
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          if (controller.topUsers.isNotEmpty)
                            _buildPodium(controller),
                          const SizedBox(height: 24),
                          if (controller.otherUsers.isNotEmpty)
                            _buildUserList(context, controller),
                          const SizedBox(height: 100), // Space for bottom bar
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          Obx(
            () => controller.myStats.value != null
                ? _buildMyRankFixed(context, controller.myStats.value!)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundHeader(BuildContext context) {
    return Container(
      height: 400,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1B4D3E),
            Theme.of(context).primaryColor,
          ], // Green theme matching primaryColor
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 100),
          Icon(
            IconlyLight.user,
            size: 80,
            color: Theme.of(context).primaryColor.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada data penyebar',
            style: pBold16.copyWith(color: Theme.of(context).primaryColor),
          ),
          const SizedBox(height: 4),
          Text(
            'Ajak teman Anda sekarang!',
            style: pRegular12.copyWith(color: Theme.of(context).primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildPodium(AppShareLeaderboardController controller) {
    final topData = controller.topUsers;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Rank 2
          if (topData.length > 1)
            _buildPodiumItem(topData[1], const Color(0xFFC0C0C0)),
          if (topData.length > 1) const SizedBox(width: 12),
          // Rank 1
          if (topData.isNotEmpty)
            _buildPodiumItem(
              topData[0],
              const Color(0xFFFFD700),
              isWinner: true,
            ),
          // Rank 3
          if (topData.length > 2) const SizedBox(width: 12),
          if (topData.length > 2)
            _buildPodiumItem(topData[2], const Color(0xFFCD7F32)),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(
    LeaderboardEntry user,
    Color crownColor, {
    bool isWinner = false,
  }) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            if (isWinner)
              Transform.translate(
                offset: const Offset(0, -25),
                child: const Icon(
                  IconlyBold.star,
                  color: Color(0xFFFFD700),
                  size: 30,
                ),
              ),
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: crownColor, width: 3),
              ),
              child: CircleAvatar(
                radius: isWinner ? 45 : 35,
                backgroundColor: Colors.white12,
                backgroundImage: user.profilePicture != null
                    ? NetworkImage(user.profilePicture!)
                    : null,
                child: user.profilePicture == null
                    ? const Icon(
                        IconlyBold.profile,
                        color: Colors.white,
                        size: 30,
                      )
                    : null,
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: crownColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${user.rank}',
                  style: pBold12.copyWith(color: Colors.black87),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: isWinner ? 100 : 80,
          child: Text(
            user.name,
            style: pBold14.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          '${user.totalReferral} Teman',
          style: pMedium12.copyWith(color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildUserList(
    BuildContext context,
    AppShareLeaderboardController controller,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.otherUsers.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: !context.isDarkMode ? Colors.grey[300] : Colors.grey[700],
        ),
        itemBuilder: (context, index) {
          final user = controller.otherUsers[index];
          return _buildListTile(context, user);
        },
      ),
    );
  }

  Widget _buildListTile(BuildContext context, LeaderboardEntry user) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              '${user.rank}',
              style: pBold14.copyWith(color: Theme.of(context).hintColor),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 24,
            backgroundColor: Theme.of(context).dividerColor.withOpacity(0.5),
            backgroundImage: user.profilePicture != null
                ? NetworkImage(user.profilePicture!)
                : null,
            child: user.profilePicture == null
                ? Icon(
                    IconlyBold.profile,
                    color: Theme.of(context).disabledColor,
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: pBold14.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'KODE: ${user.referralCode}',
                  style: pRegular12.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${user.totalReferral} Teman',
                style: pBold14.copyWith(color: Theme.of(context).primaryColor),
              ),
              Text(
                '${user.totalShare} Share',
                style: pRegular10.copyWith(color: Theme.of(context).hintColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMyRankFixed(BuildContext context, LeaderboardEntry me) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Row(
          children: [
            Text(
              '${me.rank}',
              style: pBold18.copyWith(color: Theme.of(context).primaryColor),
            ),
            const SizedBox(width: 16),
            CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(context).dividerColor.withOpacity(0.5),
              backgroundImage: me.profilePicture != null
                  ? NetworkImage(me.profilePicture!)
                  : null,
              child: me.profilePicture == null
                  ? Icon(
                      IconlyBold.profile,
                      color: Theme.of(context).disabledColor,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Level Penyebar: ${me.rank > 10 ? 'Pemula' : 'Inspirator'}',
                    style: pBold14.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'Anda telah mengajak ${me.totalReferral} teman',
                    style: pRegular12.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(IconlyLight.send, color: Theme.of(context).primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs(
    BuildContext context,
    AppShareLeaderboardController controller,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Obx(
        () => Row(
          children: [
            _buildTabItem(context, controller, 0, 'Mingguan'),
            _buildTabItem(context, controller, 1, 'Bulanan'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(
    BuildContext context,
    AppShareLeaderboardController controller,
    int index,
    String label,
  ) {
    final isActive = controller.filterIndex.value == index;
    return Expanded(
      child: InkWell(
        onTap: () => controller.changeFilter(index),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: (isActive ? pBold12 : pMedium12).copyWith(
                color: isActive ? Theme.of(context).primaryColor : Colors.white70,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
