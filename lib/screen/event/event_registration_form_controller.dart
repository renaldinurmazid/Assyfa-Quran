import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/models/event_model.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/widgets/app_toast.dart';
import 'package:dio/dio.dart' as dio;

class EventRegistrationFormController extends GetxController {
  final event = Rxn<EventModel>();

  // Form Controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final domicileController = TextEditingController();
  final jobActivityController = TextEditingController();
  final infoSourceController = TextEditingController();
  final communityController = TextEditingController();
  final operationalDonationController = TextEditingController();

  final instagramFollowed = false.obs;
  final transferProof = Rxn<File>();

  final isSubmitting = false.obs;
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is EventModel) {
      event.value = args;
    }

    // Pre-fill user data
    final user = AuthController.to.userData;
    if (user.isNotEmpty) {
      nameController.text = user['name'] ?? '';
      emailController.text = user['email'] ?? '';
      phoneController.text = user['phone_number'] ?? '';
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    domicileController.dispose();
    jobActivityController.dispose();
    infoSourceController.dispose();
    communityController.dispose();
    operationalDonationController.dispose();
    super.onClose();
  }

  Future<void> pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        transferProof.value = File(pickedFile.path);
      }
    } catch (e) {
      AppToast.error(message: 'Gagal memilih gambar');
    }
  }

  void submitForm() {
    if (!formKey.currentState!.validate()) return;

    if (event.value == null) return;

    // If event is paid, go to payment screen and pass form data
    if (event.value!.price != null && event.value!.price! > 0) {
      Get.toNamed(
        Routes.eventPayment,
        arguments: {
          'event': event.value,
          'formData': _getFormDataMap(),
        },
      );
    } else {
      // If event is free, submit directly
      _submitRegistration();
    }
  }

  Map<String, dynamic> _getFormDataMap() {
    final map = <String, dynamic>{
      'name': nameController.text.trim(),
      'email': emailController.text.trim(),
      'phone_number': phoneController.text.trim(),
      'instagram_followed': instagramFollowed.value.toString(),
    };
    
    if (domicileController.text.trim().isNotEmpty) {
      map['domicile'] = domicileController.text.trim();
    }
    if (jobActivityController.text.trim().isNotEmpty) {
      map['job_or_activity'] = jobActivityController.text.trim();
    }
    if (infoSourceController.text.trim().isNotEmpty) {
      map['info_source'] = infoSourceController.text.trim();
    }
    if (communityController.text.trim().isNotEmpty) {
      map['community'] = communityController.text.trim();
    }

    final donationText = operationalDonationController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (donationText.isNotEmpty) {
      map['operational_donation'] = donationText;
    }

    if (transferProof.value != null) {
      map['transfer_proof'] = transferProof.value; // Store the File object to be processed in Dio
    }

    return map;
  }

  Future<void> _submitRegistration() async {
    isSubmitting.value = true;
    try {
      final formDataMap = _getFormDataMap();
      final formData = dio.FormData.fromMap({});
      
      for (final entry in formDataMap.entries) {
        if (entry.value is File) {
           formData.files.add(MapEntry(
            entry.key,
            await dio.MultipartFile.fromFile((entry.value as File).path),
          ));
        } else {
          formData.fields.add(MapEntry(entry.key, entry.value.toString()));
        }
      }

      final response = await Request().post(
        '${Url.events}/${event.value!.id}/register',
        data: formData,
      );

      if (response.statusCode == 200) {
        AppToast.success(
          message: response.data['message'] ?? 'Berhasil mendaftar event',
        );
        Get.until((route) => route.settings.name == Routes.showEvent);
      } else {
        AppToast.error(
          message: response.data['message'] ?? 'Gagal mendaftar event',
        );
      }
    } catch (e) {
      AppToast.error(message: 'Gagal mendaftar event');
    } finally {
      isSubmitting.value = false;
    }
  }
}
