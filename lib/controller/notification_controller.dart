import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/models/notification_model.dart';

class NotificationController extends GetxController {
  static NotificationController get to => Get.find();

  RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;
      final response = await Request().get(Url.notifications);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data']['data'];
        notifications.value = data
            .map((e) => NotificationModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      print("Error fetching notifications: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      final response = await Request().post(Url.markAsRead(id));

      if (response.statusCode == 200) {
        final index = notifications.indexWhere((element) => element.id == id);
        if (index != -1) {
          notifications[index].isRead = true;
          notifications.refresh();
        }
      }
    } catch (e) {
      print("Error marking notification as read: $e");
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final response = await Request().post(Url.markAllAsRead);

      if (response.statusCode == 200) {
        for (var notification in notifications) {
          notification.isRead = true;
        }
        notifications.refresh();
      }
    } catch (e) {
      print("Error marking all notifications as read: $e");
    }
  }
}
