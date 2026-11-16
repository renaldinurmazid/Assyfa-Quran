import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/models/haji_umrah_package_model.dart';
import 'package:quran_app/models/payment_method_model.dart';
import 'package:quran_app/widgets/app_toast.dart';

class JemaahInput {
  String name;
  String gender; // 'male' or 'female'
  String identityNumber;
  String phoneNumber;
  String relationship;

  JemaahInput({
    this.name = '',
    this.gender = 'male',
    this.identityNumber = '',
    this.phoneNumber = '',
    this.relationship = 'Diri Sendiri',
  });

  bool get isValid => name.trim().isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'name': name.trim(),
      'gender': gender,
      'identity_number': identityNumber.trim().isNotEmpty ? identityNumber.trim() : null,
      'passport_number': null,
      'relationship': relationship,
    };
  }
}

class HajiAndUmrahRegisterController extends GetxController {
  late final HajiUmrahPackageModel package;

  // Form states
  final RxString orderType = 'Perorangan'.obs; // 'Perorangan' or 'Keluarga'
  final RxList<JemaahInput> jemaahList = <JemaahInput>[].obs;
  final RxString paymentType = 'Lunas'.obs; // 'Lunas' or 'Bertahap'
  
  final RxList<PaymentMethod> paymentMethods = <PaymentMethod>[].obs;
  final Rxn<PaymentMethod> selectedPaymentMethod = Rxn<PaymentMethod>();

  final notesController = TextEditingController();
  final contactNameController = TextEditingController();
  final contactPhoneController = TextEditingController();

  final RxString contactName = ''.obs;
  final RxString contactPhone = ''.obs;

  final RxBool isLoading = false.obs;

  // Booking success states
  final RxBool isSuccess = false.obs;
  final RxMap<String, dynamic> bookingResult = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is HajiUmrahPackageModel) {
      package = Get.arguments as HajiUmrahPackageModel;
    } else {
      AppToast.error(message: 'Paket tidak valid');
      Get.back();
      return;
    }

    // Default: Add one empty candidate
    jemaahList.add(JemaahInput(relationship: 'Diri Sendiri'));

    contactNameController.addListener(() {
      contactName.value = contactNameController.text;
    });
    contactPhoneController.addListener(() {
      contactPhone.value = contactPhoneController.text;
    });

    // Pre-fill contact data if user is logged in
    if (AuthController.to.isLogin.value) {
      contactNameController.text = AuthController.to.userData['name'] ?? '';
      contactName.value = contactNameController.text;
      contactPhoneController.text = AuthController.to.userData['phone_number'] ?? '';
      contactPhone.value = contactPhoneController.text;
      // Also pre-fill the first candidate's name if empty
      jemaahList[0].name = AuthController.to.userData['name'] ?? '';
      jemaahList[0].phoneNumber = AuthController.to.userData['phone_number'] ?? '';
    }

    fetchPaymentMethods();
  }

  @override
  void onClose() {
    notesController.dispose();
    contactNameController.dispose();
    contactPhoneController.dispose();
    super.onClose();
  }

  void setOrderType(String type) {
    orderType.value = type;
    if (type == 'Perorangan' && jemaahList.length > 1) {
      // Truncate to only the first candidate
      jemaahList.removeRange(1, jemaahList.length);
    }
  }

  void addJemaah(JemaahInput jemaah) {
    if (orderType.value == 'Perorangan') {
      AppToast.warning(message: 'Pemesanan perorangan hanya untuk 1 jemaah');
      return;
    }
    jemaahList.add(jemaah);
  }

  void updateJemaah(int index, JemaahInput jemaah) {
    if (index >= 0 && index < jemaahList.length) {
      jemaahList[index] = jemaah;
    }
  }

  void removeJemaah(int index) {
    if (jemaahList.length <= 1) {
      AppToast.warning(message: 'Minimal harus ada 1 calon jemaah');
      return;
    }
    jemaahList.removeAt(index);
  }

  Future<void> fetchPaymentMethods() async {
    try {
      isLoading.value = true;
      final response = await Request().get(Url.paymentMethodes);
      if (response.statusCode == 200) {
        final model = PaymentMethodModel.fromJson(response.data);
        paymentMethods.assignAll(model.data);
        if (paymentMethods.isNotEmpty) {
          selectedPaymentMethod.value = paymentMethods.first;
        }
      }
    } catch (e) {
      debugPrint('Error loading payment methods: $e');
    } finally {
      isLoading.value = false;
    }
  }

  double get packagePriceAmount {
    return double.tryParse(package.price ?? '') ?? 0.0;
  }

  double get totalPrice {
    return jemaahList.length * packagePriceAmount;
  }

  bool get isFormValid {
    if (contactName.value.trim().isEmpty) return false;
    if (contactPhone.value.trim().isEmpty) return false;
    if (selectedPaymentMethod.value == null) return false;
    // All jemaah details must be filled (name at least)
    for (var jemaah in jemaahList) {
      if (!jemaah.isValid) return false;
    }
    return true;
  }

  Future<void> submitBooking() async {
    if (contactNameController.text.trim().isEmpty) {
      AppToast.warning(message: 'Nama kontak penanggung jawab wajib diisi');
      return;
    }
    if (contactPhoneController.text.trim().isEmpty) {
      AppToast.warning(message: 'Nomor HP kontak wajib diisi');
      return;
    }
    for (int i = 0; i < jemaahList.length; i++) {
      if (!jemaahList[i].isValid) {
        AppToast.warning(message: 'Mohon isi nama lengkap calon jemaah ke-${i + 1}');
        return;
      }
    }
    if (selectedPaymentMethod.value == null) {
      AppToast.warning(message: 'Mohon pilih metode pembayaran');
      return;
    }

    try {
      isLoading.value = true;

      // Construct booking request data
      final data = {
        'umrah_package_id': package.id,
        'booking_type': orderType.value == 'Perorangan' ? 'individual' : 'family',
        'contact_name': contactNameController.text.trim(),
        'contact_phone': contactPhoneController.text.trim(),
        'notes': notesController.text.trim().isNotEmpty 
            ? '${notesController.text.trim()} (Tipe Pembayaran: ${paymentType.value})'
            : 'Tipe Pembayaran: ${paymentType.value}',
        'payment_methode_id': selectedPaymentMethod.value!.id,
        'participants': jemaahList.map((e) => e.toJson()).toList(),
      };

      final response = await Request().post('${Url.umrah}/bookings', data: data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final payload = response.data;
        if (payload['status'] == 'success') {
          bookingResult.value = payload['data'] as Map<String, dynamic>;
          isSuccess.value = true;
          AppToast.success(message: payload['message'] ?? 'Pemesanan berhasil dibuat');
        } else {
          AppToast.error(message: payload['message'] ?? 'Gagal membuat pemesanan');
        }
      } else {
        AppToast.error(message: response.data['message'] ?? 'Terjadi kesalahan pada server');
      }
    } catch (e) {
      debugPrint('Error placing booking: $e');
      AppToast.error(message: 'Gagal membuat pemesanan. Coba beberapa saat lagi.');
    } finally {
      isLoading.value = false;
    }
  }
}
