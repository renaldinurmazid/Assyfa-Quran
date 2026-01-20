import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy Data for System Notifications
    final List<Map<String, dynamic>> systemNotifications = [
      {
        'id': 1,
        'title': 'Target Tercapai!',
        'message':
            'Selamat! Kamu telah menyelesaikan target tilawah hari ini (Surat Al-Baqarah: 1-20).',
        'type': 'achievement',
        'time': '10:30',
        'isRead': false,
        'icon': IconlyBold.star,
        'color': Colors.amber,
      },
      {
        'id': 2,
        'title': 'Waktunya Dzikir',
        'message':
            'Sudahkah kamu berdzikir pagi ini? Luangkan waktu 5 menit untuk menenangkan jiwa.',
        'type': 'reminder',
        'time': '08:00',
        'isRead': true,
        'icon': IconlyBold.time_circle,
        'color': AppColor.primaryColor,
      },
      {
        'id': 3,
        'title': 'Info Update',
        'message':
            'Fitur Grup Ngaji kini lebih stabil. Cek pembaruan terbaru di Play Store.',
        'type': 'system',
        'time': 'Kemarin',
        'isRead': true,
        'icon': IconlyBold.info_square,
        'color': Colors.blue,
      },
      {
        'id': 4,
        'title': 'Donasi Diterima',
        'message':
            'Infaq Anda untuk "Renovasi Masjid Al-Ikhlas" telah berhasil diverifikasi. Syukran!',
        'type': 'transaction',
        'time': 'Kemarin',
        'isRead': false,
        'icon': IconlyBold.wallet,
        'color': Colors.green,
      },
      {
        'id': 5,
        'title': 'Anggota Baru',
        'message':
            'Seorang anggota baru saja bergabung ke grup ngaji "Assyfa Community".',
        'type': 'group',
        'time': 'Kemarin',
        'isRead': true,
        'icon': IconlyBold.add_user,
        'color': Colors.purple,
      },
    ];

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Notifikasi Terbaru', style: pBold18),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Tandai Dibaca',
                      style: pMedium12.copyWith(color: AppColor.primaryColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final notification = systemNotifications[index];
                return _buildNotificationTile(notification);
              }, childCount: systemNotifications.length),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      stretch: true,
      backgroundColor: AppColor.primaryColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(IconlyLight.arrow_left_2, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      title: Text('Pesan Sistem', style: pBold18.copyWith(color: Colors.white)),
      actions: [
        IconButton(
          icon: const Icon(IconlyLight.setting, color: Colors.white),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/png/bg-palestine.png',
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    AppColor.primaryColor.withOpacity(0.9),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'يٰٓاَيُّهَا الَّذِيْنَ اٰمَنُوا اذْكُرُوا اللّٰهَ ذِكْرًا كَثِيْرًاۙ',
                    style: pBold18.copyWith(color: Colors.white, fontSize: 20),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Informasi dan pengingat penting untuk aktivitas ibadahmu.',
                    style: pRegular12.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: -1,
              left: 0,
              right: 0,
              child: Container(
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColor.backgroundColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTile(Map<String, dynamic> notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notification['isRead']
            ? Colors.white
            : AppColor.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: notification['isRead']
              ? Colors.grey.shade50
              : AppColor.primaryColor.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: notification['color'].withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    notification['icon'],
                    color: notification['color'],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            notification['title'],
                            style: pBold14.copyWith(
                              color: notification['isRead']
                                  ? Colors.black87
                                  : AppColor.primaryColor,
                            ),
                          ),
                          Text(
                            notification['time'],
                            style: pRegular10.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification['message'],
                        style: pRegular12.copyWith(
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!notification['isRead'])
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(left: 8, top: 4),
                    decoration: const BoxDecoration(
                      color: AppColor.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
