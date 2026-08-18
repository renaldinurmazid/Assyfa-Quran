import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/models/event_model.dart';
import 'package:quran_app/models/payment_method_model.dart';
import 'package:quran_app/models/event_payment_response_model.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/widgets/app_toast.dart';
import 'package:quran_app/screen/event/event_detail_controller.dart';

class EventPaymentController extends GetxController {
  final event = Rxn<EventModel>();
  final isLoading = false.obs;
  final isRegistering = false.obs;

  final paymentMethods = <PaymentMethod>[].obs;
  final selectedPaymentMethod = Rxn<PaymentMethod>();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is EventModel) {
      event.value = args;
    }
    fetchPaymentMethods();
  }

  Future<void> fetchPaymentMethods() async {
    try {
      isLoading.value = true;
      final response = await Request().get(Url.paymentMethodes);
      if (response.statusCode == 200) {
        final data = PaymentMethodModel.fromJson(response.data);
        paymentMethods.assignAll(data.data);
      }
    } catch (e) {
      AppToast.error(message: 'Gagal memuat metode pembayaran');
    } finally {
      isLoading.value = false;
    }
  }

  void selectPaymentMethod(PaymentMethod method) {
    selectedPaymentMethod.value = method;
  }

  Future<void> registerAndPay() async {
    if (event.value == null) return;
    
    if (selectedPaymentMethod.value == null) {
      AppToast.warning(message: 'Silakan pilih metode pembayaran');
      return;
    }

    isRegistering.value = true;
    try {
      final data = {
        'payment_methode_id': selectedPaymentMethod.value!.id,
      };

      final response = await Request().post(
        '${Url.events}/${event.value!.id}/register',
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = EventPaymentResponseModel.fromJson(response.data);
        
        AppToast.success(
          message: response.data['message'] ?? 'Berhasil mendaftar event',
        );

        // Refresh event details in previous screen
        try {
          Get.find<EventDetailController>().fetchEventDetail(event.value!.id);
        } catch (e) {
          // ignore if controller not found
        }

        // Navigate to payment detail
        if (result.data != null && result.data!.payment != null) {
          Get.offNamed(Routes.eventPaymentDetail, arguments: result.data);
        } else {
          // Fallback if no payment returned (e.g. price 0)
          Get.back();
        }
      } else {
        AppToast.error(
          message: response.data['message'] ?? 'Gagal mendaftar event',
        );
      }
    } catch (e) {
      print(e);
      AppToast.error(message: 'Gagal mendaftar event. Silakan coba lagi.');
    } finally {
      isRegistering.value = false;
    }
  }
}
