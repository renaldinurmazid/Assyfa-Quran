import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/models/campaign_detail_model.dart';
import 'package:quran_app/models/payment_method_model.dart';
import 'package:quran_app/models/donation_response_model.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/widgets/app_toast.dart';

class CharityPaymentController extends GetxController {
  final int campaignId = Get.arguments['id'];
  final String formType = Get.arguments['formType'];
  final int? qurbanPrice = Get.arguments['qurbanPrice'];
  final List<CampaignOption>? campaignOptions =
      Get.arguments['campaignOptions'];
  final int? withOption = Get.arguments['withOption'];

  var selectedOption = Rxn<CampaignOption>();

  var isLoading = false.obs;
  var paymentMethods = <PaymentMethod>[].obs;
  var selectedPaymentMethod = Rxn<PaymentMethod>();

  final nominalController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  // Qurban specific
  var quantity = 1.obs;
  var qurbanNameControllers = <TextEditingController>[
    TextEditingController(),
  ].obs;

  var selectedNominal = ''.obs;
  var selectedName = ''.obs;
  var selectedPhone = ''.obs;
  var isAnonymous = false.obs;

  @override
  void onInit() {
    super.onInit();

    if (withOption == 1 &&
        campaignOptions != null &&
        campaignOptions!.isNotEmpty) {
      selectedOption.value = campaignOptions![0];
      updateNominal();
    } else if (formType != 'regular' && qurbanPrice != null) {
      nominalController.text = qurbanPrice.toString();
      selectedNominal.value = qurbanPrice.toString();
    }

    nominalController.addListener(() {
      selectedNominal.value = nominalController.text;
    });
    selectedNominal.value = nominalController.text;
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
      qurbanNameControllers[0].text = nameController.text;
    }
    fetchPaymentMethods();
  }

  void incrementQuantity() {
    if (formType == 'patungan' && quantity.value >= 7) {
      AppToast.info(message: 'Maksimal 7 nama untuk paket patungan');
      return;
    }
    quantity.value++;
    qurbanNameControllers.add(TextEditingController());
    updateNominal();
  }

  void decrementQuantity() {
    if (quantity.value > 1) {
      quantity.value--;
      qurbanNameControllers.removeLast();
      updateNominal();
    }
  }

  int parsePrice(String price) {
    return int.tryParse(price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }

  void updateNominal() {
    int? basePrice;
    if (withOption == 1 && selectedOption.value != null) {
      basePrice = parsePrice(selectedOption.value!.price);
    } else {
      basePrice = qurbanPrice;
    }

    if (basePrice != null) {
      final total = formType == 'patungan'
          ? basePrice
          : basePrice * quantity.value;
      final formatter = NumberFormat.decimalPattern('id');
      nominalController.text = formatter.format(total);
    }
  }

  void selectOption(CampaignOption option) {
    selectedOption.value = option;
    updateNominal();
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
        if (formType != 'regular') ...{
          'quantity': quantity.value,
          'participant_names': qurbanNameControllers
              .map((c) => c.text)
              .toList(),
          if (selectedOption.value != null)
            'campaign_option_id': selectedOption.value!.id,
        },
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
