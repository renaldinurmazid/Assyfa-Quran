import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/models/event_registration_list_model.dart';
import 'package:quran_app/widgets/app_toast.dart';

class EventRegistrationListController extends GetxController {
  final isLoading = false.obs;
  final registrations = <EventRegistrationItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchRegistrations();
  }

  Future<void> fetchRegistrations() async {
    isLoading.value = true;
    try {
      final response = await Request().get(Url.myEventRegistrations);
      final model = EventRegistrationListResponseModel.fromJson(response.data);
      if (model.status == 'success') {
        registrations.value = model.data;
      } else {
        AppToast.error(message: model.message);
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        AppToast.error(
          message: e.response?.data['message'] ?? 'Gagal memuat data event',
        );
      } else {
        AppToast.error(message: 'Terjadi kesalahan jaringan');
      }
    } catch (e) {
      AppToast.error(message: 'Terjadi kesalahan sistem');
    } finally {
      isLoading.value = false;
    }
  }
}
