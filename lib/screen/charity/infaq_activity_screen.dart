import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:quran_app/controller/charity/infaq_activity_controller.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:shimmer/shimmer.dart';

class InfaqActivityScreen extends StatelessWidget {
  const InfaqActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InfaqActivityController());

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Aktivitas Infaq',
          style: pBold18.copyWith(color: AppColor.primaryColor),
        ),
        leading: IconButton(
          icon: const Icon(
            IconlyLight.arrow_left_2,
            color: AppColor.primaryColor,
          ),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          _buildTabs(controller),
          Expanded(
            child: Obx(() {
              if (controller.selectedTab.value == 0) {
                return _buildInfaqList(controller);
              } else {
                return _buildMosqueInfaqList(controller);
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(InfaqActivityController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(
        () => Row(
          children: [
            Expanded(
              child: _buildTabItem(
                label: 'Infaq',
                isSelected: controller.selectedTab.value == 0,
                onTap: () => controller.changeTab(0),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTabItem(
                label: 'Infaq Masjid',
                isSelected: controller.selectedTab.value == 1,
                onTap: () => controller.changeTab(1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: pBold14.copyWith(
              color: isSelected ? Colors.white : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfaqList(InfaqActivityController controller) {
    return Obx(() {
      if (controller.isLoading.value && controller.donations.isEmpty) {
        return _buildLoadingState();
      }

      if (controller.donations.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        onRefresh: () => controller.fetchDonationHistory(isRefresh: true),
        color: AppColor.primaryColor,
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          itemCount:
              controller.donations.length +
              (controller.hasNextPage.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.donations.length) {
              controller.loadMore();
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final donation = controller.donations[index];
            return _buildHistoryCard(
              title: donation.campaign.title,
              image: donation.campaign.coverImage,
              orderId: donation.orderId,
              amount: donation.formattedAmount,
              status: donation.status,
              date: donation.createdAt,
              onTap: () => Get.toNamed(
                Routes.infaqActivityDetail,
                arguments: donation.id,
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildMosqueInfaqList(InfaqActivityController controller) {
    return Obx(() {
      if (controller.isLoading.value && controller.mosqueDonations.isEmpty) {
        return _buildLoadingState();
      }

      if (controller.mosqueDonations.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        onRefresh: () => controller.fetchMosqueDonationHistory(isRefresh: true),
        color: AppColor.primaryColor,
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          itemCount:
              controller.mosqueDonations.length +
              (controller.mosqueHasNextPage.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.mosqueDonations.length) {
              controller.loadMore();
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final donation = controller.mosqueDonations[index];
            return _buildHistoryCard(
              title: donation.mosqueCharity.name,
              image: donation.mosqueCharity.coverImage,
              orderId: donation.orderId,
              amount: donation.formattedAmount,
              status: donation.status,
              date: donation.createdAt,
              onTap: () {
                Get.toNamed(
                  Routes.mosqueInfaqActivityDetail,
                  arguments: donation.id,
                );
              },
            );
          },
        ),
      );
    });
  }

  Widget _buildHistoryCard({
    required String title,
    required String image,
    required String orderId,
    required String amount,
    required String status,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(date);

    Color statusColor;
    String statusText;

    switch (status.toLowerCase()) {
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'Menunggu';
        break;
      case 'success':
        statusColor = AppColor.primaryColor;
        statusText = 'Berhasil';
        break;
      default:
        statusColor = Colors.red;
        statusText = status;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    image,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[200],
                      child: const Icon(IconlyLight.image, color: Colors.grey),
                    ),
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
                          Expanded(
                            child: Text(
                              title,
                              style: pBold14,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              statusText,
                              style: pBold10.copyWith(color: statusColor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        orderId,
                        style: pMedium10.copyWith(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            amount,
                            style: pBold14.copyWith(
                              color: AppColor.primaryColor,
                            ),
                          ),
                          Text(
                            formattedDate,
                            style: pRegular10.copyWith(color: Colors.grey),
                          ),
                        ],
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColor.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              IconlyLight.chart,
              size: 64,
              color: AppColor.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text('Belum Ada Riwayat', style: pBold18),
          const SizedBox(height: 8),
          Text(
            'Infaq yang Anda berikan akan muncul di sini',
            style: pRegular14.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 5,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
