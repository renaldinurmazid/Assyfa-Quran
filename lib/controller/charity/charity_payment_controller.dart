import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/models/payment_method_model.dart';
import 'package:quran_app/models/donation_response_model.dart';
import 'package:quran_app/routes/app_routes.dart';

class CharityPaymentController extends GetxController {
  final int campaignId = Get.arguments['id'];
  var isLoading = false.obs;
  var paymentMethods = <PaymentMethod>[].obs;
  var selectedPaymentMethod = Rxn<PaymentMethod>();

  final nominalController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  var selectedNominal = ''.obs;

  @override
  void onInit() {
    super.onInit();
    nominalController.addListener(() {
      selectedNominal.value = nominalController.text;
    });
    // Pre-fill user data if logged in
    if (AuthController.to.isLogin.value) {
      nameController.text = AuthController.to.userData['name'] ?? '';
      phoneController.text = AuthController.to.userData['phone'] ?? '';
    }
    fetchPaymentMethods();
  }

  Future<void> fetchPaymentMethods() async {
    try {
      isLoading.value = true;
      final response = await Request().get(Url.paymentMethodes);
      if (response.statusCode == 200) {
        final model = PaymentMethodModel.fromJson(response.data);
        paymentMethods.assignAll(model.data);
      }
    } catch (e) {
      print("Error fetching payment methods: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void selectPaymentMethod(PaymentMethod method) {
    selectedPaymentMethod.value = method;
  }

  Future<void> submitDonation() async {
    if (nominalController.text.isEmpty) {
      Get.snackbar('Input Error', 'Nominal infaq tidak boleh kosong');
      return;
    }
    if (selectedPaymentMethod.value == null) {
      Get.snackbar('Input Error', 'Pilih metode pembayaran terlebih dahulu');
      return;
    }

    try {
      isLoading.value = true;
      final data = {
        'campaign_id': campaignId,
        'payment_methode_id': selectedPaymentMethod.value!.id,
        'amount': int.parse(nominalController.text),
        'guest_name': nameController.text,
        'guest_phone': phoneController.text,
      };

      final response = await Request().post(Url.donations, data: data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = DonationResponseModel.fromJson(response.data);
        Get.offNamed(Routes.charityPaymentDetail, arguments: result.data);
      } else {
        Get.snackbar(
          'Error',
          'Gagal memproses infaq: ${response.data['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memproses infaq: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
