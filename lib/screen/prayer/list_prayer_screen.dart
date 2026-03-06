import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/controller/prayer/list_prayer_controller.dart';
import 'package:quran_app/models/prayer_model.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/screen/home_screen.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';
import 'package:shimmer/shimmer.dart';

class ListPrayerScreen extends StatefulWidget {
  const ListPrayerScreen({super.key});

  @override
  State<ListPrayerScreen> createState() => _ListPrayerScreenState();
}

class _ListPrayerScreenState extends State<ListPrayerScreen> {
  final controller = Get.put(ListPrayerController());
  final ScrollController _allScrollController = ScrollController();
  final ScrollController _myScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _allScrollController.addListener(() {
      if (_allScrollController.position.pixels >=
          _allScrollController.position.maxScrollExtent - 200) {
        controller.fetchAllPrayers(isRefresh: false);
      }
    });
    _myScrollController.addListener(() {
      if (_myScrollController.position.pixels >=
          _myScrollController.position.maxScrollExtent - 200) {
        controller.fetchMyPrayers(isRefresh: false);
      }
    });
  }

  @override
  void dispose() {
    _allScrollController.dispose();
    _myScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Saling Mendoakan',
          style: pBold18.copyWith(color: AppColor.primaryColor),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade100, width: 1),
              ),
            ),
            child: TabBar(
              controller: controller.tabController,
              labelColor: AppColor.primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColor.primaryColor,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelStyle: pBold14,
              unselectedLabelStyle: pRegular14,
              tabs: const [
                Tab(text: 'Semua Doa'),
                Tab(text: 'Doa Saya'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: controller.tabController,
        children: [
          _buildPrayerList(
            context,
            controller,
            isAll: true,
            scrollController: _allScrollController,
          ),
          _buildPrayerList(
            context,
            controller,
            isAll: false,
            scrollController: _myScrollController,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (AuthController.to.isLogin.value) {
            Get.toNamed(Routes.createPrayer);
          } else {
            Get.dialog(const HomeScreen().buildLoginDialog(Get.find()));
          }
        },
        backgroundColor: AppColor.primaryColor,
        elevation: 8,
        icon: const Icon(IconlyBold.plus, color: Colors.white, size: 20),
        label: Text('Buat Doa', style: pBold14.copyWith(color: Colors.white)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      ),
    );
  }

  Widget _buildPrayerList(
    BuildContext context,
    ListPrayerController controller, {
    required bool isAll,
    required ScrollController scrollController,
  }) {
    return Obx(() {
      final isLoading = isAll
          ? controller.isLoadingAll.value
          : controller.isLoadingMy.value;
      final isLoadingMore = isAll
          ? controller.isLoadingMoreAll.value
          : controller.isLoadingMoreMy.value;
      final prayers = isAll ? controller.allPrayers : controller.myPrayers;

      if (isLoading && prayers.isEmpty) {
        return _buildShimmerList();
      }

      if (prayers.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColor.primaryColor.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  IconlyLight.chat,
                  size: 64,
                  color: AppColor.primaryColor.withOpacity(0.4),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isAll ? 'Belum Ada Doa Hari Ini' : 'Kamu Belum Membuat Doa',
                style: pBold16.copyWith(color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                isAll
                    ? 'Jadilah yang pertama mendoakan saudara kita'
                    : 'Ayo mulai bagikan doamu sekarang',
                style: pRegular12.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () =>
            isAll ? controller.fetchAllPrayers() : controller.fetchMyPrayers(),
        color: AppColor.primaryColor,
        child: ListView.separated(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          physics: const BouncingScrollPhysics(),
          itemCount: prayers.length + (isLoadingMore ? 1 : 0),
          separatorBuilder: (context, index) => const SizedBox(height: 18),
          itemBuilder: (context, index) {
            if (index == prayers.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: CircularProgressIndicator(
                    color: AppColor.primaryColor,
                    strokeWidth: 2,
                  ),
                ),
              );
            }
            final prayer = prayers[index];
            return _buildPrayerCard(context, controller, prayer);
          },
        ),
      );
    });
  }

  Widget _buildPrayerCard(
    BuildContext context,
    ListPrayerController controller,
    PrayerItem prayer,
  ) {
    return GestureDetector(
      onTap: () {
        if (AuthController.to.isLogin.value) {
          Get.toNamed(Routes.showPrayer, arguments: prayer.id);
        } else {
          Get.dialog(const HomeScreen().buildLoginDialog(Get.find()));
        }
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColor.primaryColor.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background Ornament
            Positioned(
              right: -15,
              top: -15,
              child: Opacity(
                opacity: 0.04,
                child: Icon(
                  IconlyLight.chat,
                  size: 100,
                  color: AppColor.primaryColor,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColor.primaryColor.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColor.primaryColor.withOpacity(
                            0.1,
                          ),
                          backgroundImage:
                              (prayer.isAnonymous == false &&
                                  prayer.userProfile != null)
                              ? NetworkImage(prayer.userProfile!)
                              : null,
                          child:
                              (prayer.isAnonymous == true ||
                                  prayer.userProfile == null)
                              ? Text(
                                  (prayer.isAnonymous == true)
                                      ? 'H'
                                      : (prayer.userName?[0].toUpperCase() ??
                                            'U'),
                                  style: pBold14.copyWith(
                                    color: AppColor.primaryColor,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              prayer.isAnonymous == true
                                  ? 'Hamba Allah'
                                  : prayer.isMyPrayer == true
                                  ? 'Kamu'
                                  : prayer.userName ?? 'User',
                              style: pBold14.copyWith(color: Colors.black87),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              prayer.publishedAt ?? '-',
                              style: pRegular10.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    prayer.content ?? '-',
                    style: pMedium14.copyWith(
                      color: AppColor.primaryColor,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (prayer.amensCount != 0)
                        Row(
                          children: [
                            if (prayer.latestAmens != null &&
                                prayer.latestAmens!.isNotEmpty) ...[
                              SizedBox(
                                width:
                                    (prayer.latestAmens!.length > 3
                                            ? 3
                                            : prayer.latestAmens!.length) *
                                        14.0 +
                                    10,
                                height: 20,
                                child: Stack(
                                  children: List.generate(
                                    prayer.latestAmens!.length > 3
                                        ? 3
                                        : prayer.latestAmens!.length,
                                    (idx) {
                                      final amenUser = prayer.latestAmens![idx];
                                      return Positioned(
                                        left: idx * 14.0,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: CircleAvatar(
                                            radius: 8,
                                            backgroundColor: AppColor
                                                .primaryColor
                                                .withOpacity(0.2),
                                            backgroundImage:
                                                amenUser.userProfile != null
                                                ? NetworkImage(
                                                    amenUser.userProfile!,
                                                  )
                                                : null,
                                            child: amenUser.userProfile == null
                                                ? Text(
                                                    amenUser.userName?[0]
                                                            .toUpperCase() ??
                                                        'A',
                                                    style: pBold10.copyWith(
                                                      fontSize: 6,
                                                      color:
                                                          AppColor.primaryColor,
                                                    ),
                                                  )
                                                : null,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              '${prayer.amensCount ?? 0} Aamiin',
                              style: pRegular10.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        )
                      else
                        const SizedBox.shrink(),
                      if (prayer.isMyPrayer != true)
                        InkWell(
                          onTap: () {
                            if (AuthController.to.isLogin.value) {
                              controller.toggleAmen(prayer.id!);
                            } else {
                              Get.dialog(
                                const HomeScreen().buildLoginDialog(Get.find()),
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(100),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: prayer.isAmened == true
                                  ? AppColor.primaryColor
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: AppColor.primaryColor,
                                width: 1,
                              ),
                              boxShadow: prayer.isAmened == true
                                  ? [
                                      BoxShadow(
                                        color: AppColor.primaryColor
                                            .withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  prayer.isAmened == true
                                      ? Icons.check_circle
                                      : IconlyLight.heart,
                                  size: 14,
                                  color: prayer.isAmened == true
                                      ? Colors.white
                                      : AppColor.primaryColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  prayer.isAmened == true
                                      ? 'Diaminkan'
                                      : 'Aamiinkan',
                                  style: pSemiBold10.copyWith(
                                    color: prayer.isAmened == true
                                        ? Colors.white
                                        : AppColor.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: 5,
      separatorBuilder: (context, index) => const SizedBox(height: 18),
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey[200]!,
        highlightColor: Colors.grey[50]!,
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }
}
