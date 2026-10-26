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
  late final int campaignId;
  late final String formType;
  late final int? qurbanPrice;
  late final List<CampaignOption>? campaignOptions;
  late final int? withOption;

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
    _initArgs();

    if (!isGeneral && hasOptions) {
      selectedOption.value = campaignOptions![0];
      updateNominal();
    } else if (qurbanPrice != null) {
      final formatter = NumberFormat.decimalPattern('id');
      nominalController.text = formatter.format(qurbanPrice);
      selectedNominal.value = nominalController.text;
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

  void _initArgs() {
    try {
      final dynamic args = Get.arguments;
      if (args is Map) {
        final dynamic rawId = args['id'] ?? args['campaignId'];
        if (rawId is int) {
          campaignId = rawId;
        } else if (rawId is String) {
          campaignId = int.tryParse(rawId) ?? 0;
        } else {
          campaignId = 0;
        }

        formType = (args['formType'] as String?) ?? 'general';
        final dynamic rawQurban = args['qurbanPrice'];
        if (rawQurban is int) {
          qurbanPrice = rawQurban;
        } else if (rawQurban is String) {
          qurbanPrice = int.tryParse(rawQurban);
        } else {
          qurbanPrice = null;
        }

        if (args['campaignOptions'] is List<CampaignOption>) {
          campaignOptions = args['campaignOptions'];
        } else if (args['campaignOptions'] is List) {
          campaignOptions = (args['campaignOptions'] as List)
              .whereType<CampaignOption>()
              .toList();
        } else {
          campaignOptions = null;
        }

        withOption = args['withOption'] is int ? args['withOption'] : null;
      } else if (args is int) {
        campaignId = args;
        formType = 'general';
        qurbanPrice = null;
        campaignOptions = null;
        withOption = null;
      } else {
        campaignId = 0;
        formType = 'general';
        qurbanPrice = null;
        campaignOptions = null;
        withOption = null;
      }
    } catch (_) {
      campaignId = 0;
      formType = 'general';
      qurbanPrice = null;
      campaignOptions = null;
      withOption = null;
    }
  }

  bool get isGeneral => formType == 'general';

  /// Opsi dipilih dari daftar `campaignOptions` (form patungan/satuan dengan opsi).
  bool get hasOptions =>
      withOption == 1 && campaignOptions != null && campaignOptions!.isNotEmpty;

  /// Nominal dihitung otomatis dari harga opsi/qurban, bukan diketik donatur.
  bool get isNominalFixed => !isGeneral && (hasOptions || qurbanPrice != null);

  /// Patungan: jumlah nama dibatasi "Max Slot" pada opsi yang dipilih.
  int get maxParticipants =>
      formType == 'patungan' ? (selectedOption.value?.slot ?? 7) : 1 << 30;

  void incrementQuantity() {
    if (quantity.value >= maxParticipants) {
      AppToast.info(
        message: 'Maksimal $maxParticipants nama untuk paket patungan',
      );
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
    while (quantity.value > maxParticipants && quantity.value > 1) {
      quantity.value--;
      qurbanNameControllers.removeLast();
    }
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
    if (!isGeneral && qurbanNameControllers.any((c) => c.text.trim().isEmpty)) {
      AppToast.warning(message: 'Lengkapi semua nama terlebih dahulu');
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
        if (!isGeneral) ...{
          'quantity': quantity.value,
          'participant_names': qurbanNameControllers
              .map((c) => c.text)
              .where((text) => text.isNotEmpty)
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
      print(e);
      AppToast.error(message: 'Terjadi kesalahan, silahkan coba lagi.');
    } finally {
      isLoading.value = false;
    }
  }
}
