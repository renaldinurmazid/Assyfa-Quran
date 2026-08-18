import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/models/notification_model.dart';
import 'package:quran_app/widgets/app_toast.dart';
import 'package:quran_app/controller/global/auth_controller.dart';

class NotificationController extends GetxController {
  static NotificationController get to => Get.find();

  RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  RxList<CategoryNotification> categories = <CategoryNotification>[].obs;
  RxBool isLoading = false.obs;
  RxBool isMoreLoading = false.obs;
  RxBool isCategoriesLoading = false.obs;

  // Pagination state
  int _currentPage = 1;
  bool _hasMore = true;
  int? _lastCategoryId;

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<AuthController>()) {
      if (AuthController.to.isLogin.value) {
        fetchCategories();
        fetchNotifications();
      }

      ever(AuthController.to.isLogin, (bool loggedIn) {
        if (loggedIn) {
          fetchNotifications();
          fetchCategories();
        } else {
          notifications.clear();
          categories.clear();
        }
      });
    }
  }

  Future<void> fetchCategories() async {
    try {
      isCategoriesLoading.value = true;
      final response = await Request().get(Url.notificationsCategories);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        categories.value = data
            .map((e) => CategoryNotification.fromJson(e))
            .toList();
      }
    } catch (e) {
      print("Error fetching categories: $e");
    } finally {
      isCategoriesLoading.value = false;
    }
  }

  Future<void> fetchNotifications({
    int? categoryId,
    bool loadMore = false,
  }) async {
    if (!Get.isRegistered<AuthController>() ||
        !AuthController.to.isLogin.value) {
      return;
    }

    // If changing category, reset pagination
    if (_lastCategoryId != categoryId) {
      _lastCategoryId = categoryId;
      _currentPage = 1;
      _hasMore = true;
      notifications.clear();
    }

    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
    } else {
      if (!_hasMore || isMoreLoading.value) return;
    }

    try {
      if (loadMore) {
        isMoreLoading.value = true;
      } else {
        isLoading.value = true;
      }

      Map<String, dynamic> queryParams = {'page': _currentPage};
      if (categoryId != null) {
        queryParams['category'] = categoryId;
      }

      final response = await Request().get(
        Url.notifications,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> paginatedData = response.data['data'];
        final List<dynamic> data = paginatedData['data'];

        final newNotifications = data
            .map((e) => NotificationModel.fromJson(e))
            .toList();

        if (loadMore) {
          notifications.addAll(newNotifications);
        } else {
          notifications.value = newNotifications;
        }

        // Update pagination info
        _currentPage = paginatedData['current_page'] + 1;
        _hasMore = paginatedData['next_page_url'] != null;
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
      isMoreLoading.value = false;
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
