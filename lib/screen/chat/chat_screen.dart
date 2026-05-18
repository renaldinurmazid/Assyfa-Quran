import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:quran_app/controller/notification_controller.dart';
import 'package:quran_app/models/notification_model.dart';
import 'package:quran_app/services/deep_link_service.dart';
import 'package:quran_app/theme/font.dart';
import 'package:shimmer/shimmer.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final controller = Get.put(NotificationController());
  final RxnInt selectedCategoryId = RxnInt();
  final RxSet<int> expandedImageIds =
      <int>{}.obs; // Melacak ID yang sedang di-expand
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        controller.fetchNotifications(
          categoryId: selectedCategoryId.value,
          loadMore: true,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.colorScheme.background,
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: context.theme.colorScheme.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text('Notifikasi', style: pSemiBold18),
        // actions: [
        //   Obx(() {
        //     if (controller.notifications.isEmpty) return const SizedBox();
        //     return TextButton(
        //       onPressed: () => controller.markAllAsRead(),
        //       child: Text(
        //         'Mark as read',
        //         style: pMedium14.copyWith(
        //           color: context.theme.colorScheme.primary,
        //         ),
        //       ),
        //     );
        //   }),
        // ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.fetchNotifications();
          await controller.fetchCategories();
        },
        color: context.theme.colorScheme.primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryFilters(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value &&
                    controller.notifications.isEmpty) {
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: 5,
                    itemBuilder: (context, index) => _buildShimmerTile(context),
                  );
                }

                if (controller.notifications.isEmpty) {
                  return _buildEmptyState(context);
                }

                return _buildNotificationList();
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return Obx(() {
      if (controller.isCategoriesLoading.value &&
          controller.categories.isEmpty) {
        return const SizedBox(height: 50);
      }

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _buildFilterChip(
              label: 'All',
              isSelected: selectedCategoryId.value == null,
              onTap: () {
                selectedCategoryId.value = null;
                controller.fetchNotifications();
              },
            ),
            ...controller.categories.map((cat) {
              return _buildFilterChip(
                label: cat.name ?? '-',
                isSelected: selectedCategoryId.value == cat.id,
                onTap: () {
                  selectedCategoryId.value = cat.id;
                  controller.fetchNotifications(categoryId: cat.id);
                },
              );
            }),
          ],
        ),
      );
    });
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? context.theme.colorScheme.primary
              : context.isDarkMode
              ? context.theme.colorScheme.surfaceVariant.withOpacity(0.3)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : context.isDarkMode
                ? Colors.white10
                : Colors.grey.shade200,
          ),
        ),
        child: Text(
          label,
          style: pMedium14.copyWith(
            color: isSelected
                ? Colors.white
                : context.theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationList() {
    final filteredNotifications = controller.notifications;

    if (filteredNotifications.isEmpty) return _buildEmptyState(context);

    // Grouping logic
    final now = DateTime.now();
    final today = filteredNotifications.where((n) {
      if (n.createdAt == null) return false;
      return n.createdAt!.year == now.year &&
          n.createdAt!.month == now.month &&
          n.createdAt!.day == now.day;
    }).toList();

    final earlier = filteredNotifications.where((n) {
      if (n.createdAt == null) return false;
      return n.createdAt!.isBefore(DateTime(now.year, now.month, now.day));
    }).toList();

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        if (today.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text('Hari Ini,', style: pMedium14),
          ),
          ...today.map((n) => _buildNotificationTile(context, n, controller)),
        ],
        if (earlier.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 8),
            child: Text('Sebelumnya', style: pMedium14),
          ),
          ...earlier.map((n) => _buildNotificationTile(context, n, controller)),
        ],
        Obx(() {
          if (controller.isMoreLoading.value) {
            return Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: context.theme.colorScheme.primary,
                  ),
                ),
              ),
            );
          }
          return const SizedBox(height: 100);
        }),
      ],
    );
  }

  Widget _buildNotificationTile(
    BuildContext context,
    NotificationModel notification,
    NotificationController controller,
  ) {
    final category = notification.scheduledNotification?.categoryNotification;
    final bool isRead = notification.isRead ?? true;

    final Color iconBgColor = category?.bgColor != null
        ? _HexColor(category!.bgColor!)
        : context.isDarkMode
        ? context.theme.colorScheme.primary.withOpacity(0.15)
        : const Color(0xFFFDF4F4);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          if (notification.id != null) {
            controller.markAsRead(notification.id!);
          }

          final action = notification.scheduledNotification?.action;
          if (action != null && action.isNotEmpty) {
            await DeepLinkService.handlePayload(action);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: category?.icon != null
                    ? Image.network(category!.icon!)
                    : Icon(
                        _getIconForCategory(category?.name),
                        color: context.isDarkMode
                            ? context.theme.colorScheme.primary
                            : const Color(0xFF2D3243),
                        size: 24,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title ?? '-',
                            style: pSemiBold14.copyWith(
                              color: context.theme.colorScheme.onBackground,
                              fontWeight: isRead
                                  ? FontWeight.w600
                                  : FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          notification.formatedcreated ?? '',
                          style: pRegular12.copyWith(
                            color: context.theme.colorScheme.onSurfaceVariant
                                .withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body ?? '-',
                      style: pRegular12.copyWith(
                        color: context.theme.colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    if (notification.imageUrl != null) ...[
                      const SizedBox(height: 8),
                      Obx(() {
                        final bool isExpanded = expandedImageIds.contains(
                          notification.id,
                        );
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () {
                                if (isExpanded) {
                                  expandedImageIds.remove(notification.id);
                                } else {
                                  expandedImageIds.add(notification.id!);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: context.isDarkMode
                                        ? Colors.grey.shade500
                                        : Colors.grey.shade600,
                                  ),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                  isExpanded ? 'Tutup gambar' : 'Lihat gambar',
                                  style: pRegular10.copyWith(
                                    color: context.isDarkMode
                                        ? Colors.grey.shade500
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ),
                            if (isExpanded) ...[
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  notification.imageUrl!,
                                  width: double.infinity,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;
                                    return Container(
                                      height: 150,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Center(
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ],
                        );
                      }),
                    ],
                  ],
                ),
              ),
              if (!isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(left: 8, top: 4),
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForCategory(String? name) {
    switch (name?.toLowerCase()) {
      case 'payment':
        return Icons.credit_card_outlined;
      case 'booking':
        return Icons.inventory_2_outlined;
      case 'remainders':
        return IconlyLight.notification;
      default:
        return IconlyLight.notification;
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/svg/notification.svg',
            width: 180,
            height: 180,
            colorFilter: ColorFilter.mode(
              context.theme.colorScheme.onSurfaceVariant,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada notifikasi',
            style: pRegular14.copyWith(
              color: context.theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerTile(BuildContext context) {
    final bool isDark = context.isDarkMode;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Shimmer.fromColors(
        baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
        highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: isDark ? Colors.white10 : Colors.white,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 150,
                    height: 14,
                    color: isDark ? Colors.white10 : Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 12,
                    color: isDark ? Colors.white10 : Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return int.parse(hexColor, radix: 16);
  }

  _HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
