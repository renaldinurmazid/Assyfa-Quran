import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/models/event_model.dart';
import 'package:quran_app/widgets/app_toast.dart';
import 'package:quran_app/routes/app_routes.dart';

class EventDetailController extends GetxController {
  final event = Rxn<EventModel>();
  final isLoading = true.obs;
  final isRegistering = false.obs;

  @override
  void onInit() {
    super.onInit();
    final id = Get.arguments;
    if (id != null) {
      fetchEventDetail(id);
    } else {
      isLoading.value = false;
      AppToast.error(message: 'ID Event tidak ditemukan');
    }
  }

  Future<void> fetchEventDetail(int id) async {
    isLoading.value = true;
    try {
      final response = await Request().get('${Url.events}/$id');
      if (response.statusCode == 200) {
        event.value = EventModel.fromJson(response.data['data']);
      } else {
        AppToast.error(
          message: response.data['message'] ?? 'Gagal memuat detail event',
        );
      }
    } catch (e) {
      AppToast.error(message: 'Gagal memuat detail event');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> registerEvent() async {
    if (event.value == null) return;

    if (event.value!.price != null && event.value!.price! > 0) {
      Get.toNamed(Routes.eventPayment, arguments: event.value);
      return;
    }

    isRegistering.value = true;
    try {
      final response = await Request().post(
        '${Url.events}/${event.value!.id}/register',
      );
      if (response.statusCode == 200) {
        AppToast.success(
          message: response.data['message'] ?? 'Berhasil mendaftar event',
        );
        // Refresh event details to update quota and registration status
        fetchEventDetail(event.value!.id);
      } else {
        AppToast.error(
          message: response.data['message'] ?? 'Gagal mendaftar event',
        );
      }
    } catch (e) {
      print(e);
      AppToast.error(message: 'Gagal mendaftar event');
    } finally {
      isRegistering.value = false;
    }
  }
}
