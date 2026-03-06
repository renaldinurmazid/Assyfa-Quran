import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:quran_app/controller/leaderboard_controller.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LeaderboardController());

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(IconlyLight.arrow_left, color: Colors.white),
        ),
        title: Text(
          'Peringkat Tilawah',
          style: pSemiBold16.copyWith(color: Colors.white),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Stack(
        children: [
          _buildBackgroundHeader(),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),
                _buildFilterTabs(controller),
                const SizedBox(height: 24),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColor.primaryColor,
                        ),
                      );
                    }
                    if (controller.topUsers.isEmpty &&
                        controller.otherUsers.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              IconlyLight.chart,
                              size: 80,
                              color: AppColor.primaryColor.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada data peringkat',
                              style: pBold16.copyWith(
                                color: AppColor.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Jadilah yang pertama untuk tampil di sini!',
                              style: pRegular12.copyWith(
                                color: AppColor.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          if (controller.topUsers.isNotEmpty)
                            _buildPodium(controller),
                          const SizedBox(height: 24),
                          if (controller.otherUsers.isNotEmpty)
                            _buildUserList(controller),
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
            () => controller.myStats.isNotEmpty
                ? _buildMyRankFixed(controller)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundHeader() {
    return Container(
      height: 380,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1B4D3E), Color(0xFF123524)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
    );
  }

  Widget _buildFilterTabs(LeaderboardController controller) {
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
            _buildTabItem(controller, 0, 'Mingguan'),
            _buildTabItem(controller, 1, 'Bulanan'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(
    LeaderboardController controller,
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
                color: isActive ? AppColor.primaryColor : Colors.white70,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPodium(LeaderboardController controller) {
    return Obx(() {
      final topData = controller.topUsers;
      if (topData.isEmpty) return const SizedBox();

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Rank 2
            if (topData.length > 1)
              _buildPodiumItem(topData[1], 150, const Color(0xFFC0C0C0)),
            if (topData.length > 1) const SizedBox(width: 12),
            // Rank 1
            if (topData.isNotEmpty)
              _buildPodiumItem(
                topData[0],
                190,
                const Color(0xFFFFD700),
                isWinner: true,
              ),
            // Rank 3
            if (topData.length > 2) const SizedBox(width: 12),
            if (topData.length > 2)
              _buildPodiumItem(topData[2], 135, const Color(0xFFCD7F32)),
          ],
        ),
      );
    });
  }

  Widget _buildPodiumItem(
    Map<String, dynamic> user,
    double height,
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
                backgroundImage: user['profile_picture'] != null
                    ? NetworkImage(user['profile_picture'])
                    : null,
                child: user['profile_picture'] == null
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
                  '${user['rank']}',
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
            user['name'],
            style: pBold14.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          '${user['total_pages']} Hal',
          style: pMedium12.copyWith(color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildUserList(LeaderboardController controller) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Obx(
        () => ListView.separated(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.otherUsers.length,
          separatorBuilder: (context, index) =>
              const Divider(height: 1, color: Color(0xFFF1F1F1)),
          itemBuilder: (context, index) {
            final user = controller.otherUsers[index];
            return _buildListTile(user);
          },
        ),
      ),
    );
  }

  Widget _buildListTile(Map<String, dynamic> user) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              '${user['rank']}',
              style: pBold14.copyWith(color: Colors.grey),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey[200],
            backgroundImage: user['profile_picture'] != null
                ? NetworkImage(user['profile_picture'])
                : null,
            child: user['profile_picture'] == null
                ? const Icon(IconlyBold.profile, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'],
                  style: pBold14,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            '${user['total_pages']} Hal',
            style: pBold14.copyWith(color: AppColor.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildMyRankFixed(LeaderboardController controller) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Obx(() {
          final me = controller.myStats;
          return Row(
            children: [
              Text(
                '${me['rank']}',
                style: pBold18.copyWith(color: AppColor.primaryColor),
              ),
              const SizedBox(width: 16),
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey[200],
                backgroundImage: me['profile_picture'] != null
                    ? NetworkImage(me['profile_picture'])
                    : null,
                child: me['profile_picture'] == null
                    ? const Icon(IconlyBold.profile, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Anda', style: pBold16),
                    Text(
                      'Terus semangat tilawahnya!',
                      style: pRegular12.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(IconlyLight.tick_square, color: Colors.green),
            ],
          );
        }),
      ),
    );
  }
}
