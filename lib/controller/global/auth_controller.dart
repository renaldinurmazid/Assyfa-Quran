import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/theme/font.dart';
import 'package:quran_app/widgets/app_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:quran_app/services/fcm_service.dart';
import 'package:quran_app/services/referrer_service.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find<AuthController>();

  RxBool isLogin = false.obs;
  RxBool isLoading = false.obs;
  RxString token = ''.obs;
  RxMap userData = {}.obs;
  RxString referralCode = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initAsync();

    // Auto save referral code when changed
    ever(referralCode, (String code) async {
      if (code.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('referral_code_temp', code);
      }
    });
  }

  Future<void> _initAsync() async {
    await checkLoginStatus();
    await _loadReferralCode();
    ReferrerService.checkReferrer(this);
  }

  Future<void> _loadReferralCode() async {
    final prefs = await SharedPreferences.getInstance();
    referralCode.value = prefs.getString('referral_code_temp') ?? '';
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    token.value = prefs.getString('access_token') ?? '';
    if (token.value.isNotEmpty) {
      isLogin.value = true;
      String? userJson = prefs.getString('user_data');
      if (userJson != null) {
        userData.value = jsonDecode(userJson);
      }
    }
  }

  Future<User?> handleSignIn() async {
    try {
      isLoading.value = true;

      await GoogleSignIn.instance.initialize(
        serverClientId:
            '801779467180-a86s8gt9catgv8eagncpibe6n6o9ui6c.apps.googleusercontent.com',
      );

      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance
          .authenticate();

      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final user = userCredential.user;

      // Get Firebase ID Token and send to backend
      final String? firebaseToken = await user?.getIdToken();

      if (firebaseToken != null) {
        final response = await Request().post(
          Url.loginGoogle,
          useToken: false,
          data: {
            'firebase_token': firebaseToken,
            if (referralCode.value.isNotEmpty)
              'referral_code': referralCode.value,
          },
        );

        if (response.statusCode == 200) {
          final data = response.data;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', data['token']);
          await prefs.setString('user_data', jsonEncode(data['user']));

          token.value = data['token'];
          userData.value = data['user'];
          isLogin.value = true;

          // Reset FCM unauthorized flag for fresh session
          FcmService.resetUnauthorizedError();
          // Save FCM Token after successful login
          FcmService.saveToken();

          // Clear referral code after success
          referralCode.value = '';
          final prefsClear = await SharedPreferences.getInstance();
          await prefsClear.remove('referral_code_temp');

          Get.back();
          AppToast.success(message: response.data['message']);
        } else {
          AppToast.error(message: response.data['message']);
        }
      }

      return user;
    } catch (e) {
      AppToast.error(message: 'Terjadi kesalahan, silahkan coba lagi.');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> handleSignOut() async {
    if (!isLogin.value) return;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(Get.context!).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.red,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Keluar Akun',
                style: pBold18.copyWith(
                  color: Theme.of(Get.context!).primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Apakah Anda yakin ingin keluar dari akun Anda?',
                style: pRegular14.copyWith(
                  color: Theme.of(Get.context!).hintColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: pSemiBold14.copyWith(
                          color: Theme.of(Get.context!).hintColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back(); // Close confirmation dialog
                        _executeSignOut();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Keluar',
                        style: pSemiBold14.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _executeSignOut() async {
    // Show Loading Dialog
    Get.dialog(
      Center(
        child: CircularProgressIndicator(
          color: Theme.of(Get.context!).primaryColor,
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final response = await Request().post(Url.logout);
      final message = response.data['message'];

      if (response.statusCode == 200) {
        await GoogleSignIn.instance.signOut();
        await FirebaseAuth.instance.signOut();

        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('access_token');
        await prefs.remove('user_data');

        token.value = '';
        userData.value = {};
        isLogin.value = false;

        Get.back(); // Close Loading Dialog
        Get.offAllNamed('/');
        AppToast.success(message: message ?? "Berhasil keluar");
      } else {
        Get.back(); // Close Loading Dialog
        AppToast.error(message: message ?? "Terjadi kesalahan");
      }
    } catch (error) {
      Get.back(); // Close Loading Dialog
      AppToast.error(message: "Logout gagal, silahkan coba lagi nanti");
    }
  }

  void forceSignOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('user_data');

    token.value = '';
    userData.value = {};
    isLogin.value = false;

    // Optional: Back to initial screen if needed
    // Get.offAllNamed(Routes.initial);
  }
}
