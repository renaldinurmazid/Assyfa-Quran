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
    final args = Get.arguments;
    int? eventId;
    if (args is int) {
      eventId = args;
    } else if (args is String) {
      eventId = int.tryParse(args);
    } else if (args is EventModel) {
      eventId = args.id;
      event.value = args;
    } else if (args is Map && args['id'] != null) {
      eventId = int.tryParse(args['id'].toString());
    }

    if (eventId != null) {
      fetchEventDetail(eventId);
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

    Get.toNamed(Routes.eventRegistrationForm, arguments: event.value);
  }
}
