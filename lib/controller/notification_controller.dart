import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/models/notification_model.dart';
import 'package:quran_app/widgets/app_toast.dart';
import 'package:quran_app/controller/global/auth_controller.dart';

class NotificationController extends GetxController {
  static NotificationController get to => Get.find();

  RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<AuthController>()) {
      if (AuthController.to.isLogin.value) {
        fetchNotifications();
      }

      ever(AuthController.to.isLogin, (bool loggedIn) {
        if (loggedIn) {
          fetchNotifications();
        } else {
          notifications.clear();
        }
      });
    }
  }

  Future<void> fetchNotifications() async {
    if (!Get.isRegistered<AuthController>() ||
        !AuthController.to.isLogin.value) {
      return;
    }
    try {
      isLoading.value = true;
      final response = await Request().get(Url.notifications);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data']['data'];
        notifications.value = data
            .map((e) => NotificationModel.fromJson(e))
            .toList();
      } else {
        AppToast.error(
          message: response.data['message'] ?? 'Gagal mengambil notifikasi',
        );
      }
    } catch (e) {
      print(e);
      AppToast.error(message: 'Terjadi kesalahan koneksi');
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
      } else {
        AppToast.error(message: response.data['message']);
      }
    } catch (e) {
      AppToast.error(message: 'Gagal menandai notifikasi');
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
      } else {
        AppToast.error(message: response.data['message']);
      }
    } catch (e) {
      AppToast.error(message: 'Gagal menandai semua notifikasi');
    }
  }
}
