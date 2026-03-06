import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/models/payment_method_model.dart';
import 'package:quran_app/models/donation_response_model.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/widgets/app_toast.dart';

class CharityPaymentController extends GetxController {
  final int campaignId = Get.arguments['id'];
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
        'campaign_id': campaignId,
        'payment_methode_id': selectedPaymentMethod.value!.id,
        'amount': int.parse(nominalController.text.replaceAll('.', '')),
        'guest_name': nameController.text,
        'guest_phone': phoneController.text,
        'referral_code': AuthController.to.referralCode.value,
        'is_anonymous': isAnonymous.value,
      };

      final response = await Request().post(Url.donations, data: data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = DonationResponseModel.fromJson(response.data);
        Get.offNamed(Routes.charityPaymentDetail, arguments: result.data);
        AppToast.success(message: response.data['message']);
      } else {
        AppToast.error(message: response.data['message']);
      }
    } catch (e) {
      AppToast.error(message: 'Terjadi kesalahan, silahkan coba lagi.');
    } finally {
      isLoading.value = false;
    }
  }
}
