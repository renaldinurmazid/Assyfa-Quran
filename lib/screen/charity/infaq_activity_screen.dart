import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:quran_app/controller/charity/infaq_activity_controller.dart';
import 'package:quran_app/theme/font.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:shimmer/shimmer.dart';

class InfaqActivityScreen extends StatelessWidget {
  const InfaqActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InfaqActivityController());

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Aktivitas Infaq',
          style: pSemiBold16.copyWith(color: context.theme.colorScheme.onSurface),
        ),
        leading: IconButton(
          icon: Icon(
            IconlyLight.arrow_left_2,
            color: context.theme.colorScheme.primary,
          ),
          onPressed: () => Get.back(),
        ),
        backgroundColor: context.theme.scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          _buildTabs(context, controller),
          Expanded(
            child: Obx(() {
              if (controller.selectedTab.value == 0) {
                return _buildInfaqList(context, controller);
              } else {
                return _buildMosqueInfaqList(context, controller);
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(BuildContext context, InfaqActivityController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
        ),
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
                context,
                label: 'Infaq',
                isSelected: controller.selectedTab.value == 0,
                onTap: () => controller.changeTab(0),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTabItem(
                context,
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

  Widget _buildTabItem(
    BuildContext context, {
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
          color: isSelected ? context.theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: pBold14.copyWith(
              color: isSelected ? Colors.white : context.theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfaqList(BuildContext context, InfaqActivityController controller) {
    return Obx(() {
      if (controller.isLoading.value && controller.donations.isEmpty) {
        return _buildLoadingState(context);
      }

      if (controller.donations.isEmpty) {
        return _buildEmptyState(context);
      }

      return RefreshIndicator(
        onRefresh: () => controller.fetchDonationHistory(isRefresh: true),
        color: context.theme.colorScheme.primary,
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
              context,
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

  Widget _buildMosqueInfaqList(
    BuildContext context,
    InfaqActivityController controller,
  ) {
    return Obx(() {
      if (controller.isLoading.value && controller.mosqueDonations.isEmpty) {
        return _buildLoadingState(context);
      }

      if (controller.mosqueDonations.isEmpty) {
        return _buildEmptyState(context);
      }

      return RefreshIndicator(
        onRefresh: () => controller.fetchMosqueDonationHistory(isRefresh: true),
        color: context.theme.colorScheme.primary,
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
              context,
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

  Widget _buildHistoryCard(
    BuildContext context, {
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
        statusColor = context.theme.colorScheme.primary;
        statusText = 'Berhasil';
        break;
      default:
        statusColor = Colors.red;
        statusText = status;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
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
                      color: context.theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        IconlyLight.image,
                        color: context.theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                      ),
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
                              style: pBold14.copyWith(
                                color: context.theme.colorScheme.onSurface,
                              ),
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
                        style: pMedium10.copyWith(
                          color: context.theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            amount,
                            style: pBold14.copyWith(
                              color: context.theme.colorScheme.primary,
                            ),
                          ),
                          Text(
                            formattedDate,
                            style: pRegular10.copyWith(
                              color: context.theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
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
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              IconlyLight.chart,
              size: 64,
              color: context.theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Belum Ada Riwayat',
            style: pBold18.copyWith(color: context.theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            'Infaq yang Anda berikan akan muncul di sini',
            style: pRegular14.copyWith(
              color: context.theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 5,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor:
            context.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200,
        highlightColor:
            context.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 100,
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
