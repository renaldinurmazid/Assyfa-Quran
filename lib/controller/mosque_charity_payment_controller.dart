import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/models/payment_method_model.dart';
import 'package:quran_app/models/mosque_donation_response_model.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/widgets/app_toast.dart';

class MosqueCharityPaymentController extends GetxController {
  final int mosqueCharityId = Get.arguments['id'];
  var isLoading = false.obs;
  var paymentMethods = <PaymentMethod>[].obs;
  var selectedPaymentMethod = Rxn<PaymentMethod>();

  final nominalController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  var selectedNominal = ''.obs;
  var selectedName = ''.obs;
  var selectedPhone = ''.obs;
  var isAnonymous = false.obs;

  @override
  void onInit() {
    super.onInit();
    nominalController.addListener(() {
      selectedNominal.value = nominalController.text;
    });
    nameController.addListener(() {
      selectedName.value = nameController.text;
    });
    phoneController.addListener(() {
      selectedPhone.value = phoneController.text;
    });
    // Pre-fill user data if logged in
    if (AuthController.to.isLogin.value) {
      nameController.text = AuthController.to.userData['name'] ?? '';
      selectedName.value = nameController.text;
      phoneController.text = AuthController.to.userData['phone_number'] ?? '';
      selectedPhone.value = phoneController.text;
    }
    fetchPaymentMethods();
  }

  bool get isFormValid =>
      selectedNominal.value.isNotEmpty &&
      selectedName.value.isNotEmpty &&
      selectedPhone.value.isNotEmpty &&
      selectedPaymentMethod.value != null;

  Future<void> fetchPaymentMethods() async {
    try {
      isLoading.value = true;
      final response = await Request().get(Url.paymentMethodes);
      if (response.statusCode == 200) {
        final model = PaymentMethodModel.fromJson(response.data);
        paymentMethods.assignAll(model.data);
      } else {
        AppToast.error(
          message: response.data['message'] ?? 'Gagal memuat metode pembayaran',
        );
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

  Future<void> submitDonation() async {
    if (nominalController.text.isEmpty) {
      AppToast.warning(message: 'Nominal infaq tidak boleh kosong');
      return;
    }
    if (selectedPaymentMethod.value == null) {
      AppToast.warning(message: 'Pilih metode pembayaran terlebih dahulu');
      return;
    }

    try {
      isLoading.value = true;
      final data = {
        'mosque_charity_id': mosqueCharityId,
        'payment_methode_id': selectedPaymentMethod.value!.id,
        'amount': int.parse(nominalController.text.replaceAll('.', '')),
        'guest_name': nameController.text,
        'guest_phone': phoneController.text,
        'referral_code': AuthController.to.referralCode.value,
        'is_anonymous': isAnonymous.value,
      };

      final response = await Request().post(
        Url.mosqueCharityPayment,
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = MosqueDonationResponseModel.fromJson(response.data);
        Get.offNamed(Routes.mosqueCharityPaymentDetail, arguments: result.data);
      } else {
        AppToast.error(
          message: response.data['message'] ?? 'Gagal memproses infaq',
        );
      }
    } catch (e) {
      AppToast.error(message: 'Gagal memproses infaq: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
