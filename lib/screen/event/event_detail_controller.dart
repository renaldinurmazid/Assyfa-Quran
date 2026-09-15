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
    dynamic identifier;
    if (args is int) {
      identifier = args;
    } else if (args is String) {
      identifier = args;
    } else if (args is EventModel) {
      identifier = args.slug.isNotEmpty ? args.slug : args.id;
      event.value = args;
    } else if (args is Map) {
      identifier = args['slug'] ?? args['id'];
    }

    if (identifier != null && identifier.toString().isNotEmpty) {
      fetchEventDetail(identifier);
    } else {
      isLoading.value = false;
      AppToast.error(message: 'Event tidak ditemukan');
    }
  }

  Future<void> fetchEventDetail(dynamic identifier) async {
    isLoading.value = true;
    try {
      final response = await Request().get('${Url.events}/$identifier');
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
