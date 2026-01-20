import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find<AuthController>();

  RxBool isLogin = false.obs;
  RxBool isLoading = false.obs;
  RxString token = ''.obs;
  RxMap userData = {}.obs;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  void checkLoginStatus() async {
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
            '319156609776-sg6slus8rcdmde9uimh3ra61q4kbr86m.apps.googleusercontent.com',
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
          data: {'firebase_token': firebaseToken},
        );

        if (response.statusCode == 200) {
          final data = response.data;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', data['token']);
          await prefs.setString('user_data', jsonEncode(data['user']));

          token.value = data['token'];
          userData.value = data['user'];
          isLogin.value = true;

          Get.back();
          Get.snackbar("Success", "Login berhasil");
        } else {
          print(response.data);
          Get.snackbar("Error", "Gagal sinkronasi ke server");
        }
      }

      return user;
    } catch (e) {
      print(e);
      Get.snackbar("Error", e.toString());
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> handleSignOut() async {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColor.backgroundColor,
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
                style: pBold18.copyWith(color: AppColor.primaryColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Apakah Anda yakin ingin keluar dari akun Anda?',
                style: pRegular14.copyWith(color: Colors.grey[700]),
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
                        style: pSemiBold14.copyWith(color: Colors.grey),
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
      const Center(
        child: CircularProgressIndicator(color: AppColor.primaryColor),
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
        Get.back(); // Back to Home or login screen
        Get.snackbar("Success", message ?? "Berhasil keluar");
      } else {
        Get.back(); // Close Loading Dialog
        Get.snackbar("Error", message ?? "Terjadi kesalahan");
      }
    } catch (error) {
      Get.back(); // Close Loading Dialog
      Get.snackbar("Error", "Logout gagal, silahkan coba lagi nanti");
      print("SignOut Error: $error");
    }
  }
}
