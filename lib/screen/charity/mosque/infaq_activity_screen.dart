import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:quran_app/screen/charity/mosque/infaq_activity_controller.dart';
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
        title: Text('Aktivitas Infaq', style: pSemiBold16),
        centerTitle: true,
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
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
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
            const SizedBox(width: 4),
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
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? context.theme.colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: pSemiBold14.copyWith(
              color: isSelected
                  ? Colors.white
                  : context.theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfaqList(
    BuildContext context,
    InfaqActivityController controller,
  ) {
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
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount:
              controller.donations.length +
              (controller.hasNextPage.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.donations.length) {
              controller.loadMore();
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: context.theme.colorScheme.primary,
                    ),
                  ),
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
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount:
              controller.mosqueDonations.length +
              (controller.mosqueHasNextPage.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.mosqueDonations.length) {
              controller.loadMore();
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: context.theme.colorScheme.primary,
                    ),
                  ),
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
              onTap: () => Get.toNamed(
                Routes.mosqueInfaqActivityDetail,
                arguments: donation.id,
              ),
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: context.isDarkMode
                ? Colors.grey.shade800
                : Colors.grey.shade100,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                image,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    IconlyLight.image,
                    color: Colors.grey,
                    size: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + Status Badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: pSemiBold12.copyWith(
                            color: context.theme.colorScheme.onSurface,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
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
                  const SizedBox(height: 8),

                  // Amount + Date
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
                          color: context.theme.colorScheme.onSurfaceVariant,
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.theme.colorScheme.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              IconlyLight.chart,
              size: 48,
              color: context.theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Belum Ada Riwayat',
            style: pBold16.copyWith(color: context.theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            'Infaq yang Anda berikan akan muncul di sini',
            style: pRegular12.copyWith(
              color: context.theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 5,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: context.isDarkMode
            ? Colors.grey.shade900
            : Colors.grey.shade200,
        highlightColor: context.isDarkMode
            ? Colors.grey.shade800
            : Colors.grey.shade100,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 84,
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
