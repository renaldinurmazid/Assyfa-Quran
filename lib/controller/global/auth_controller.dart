import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:quran_app/api/url.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        final response = await http.post(
          Uri.parse(Url.baseUrl + Url.loginGoogle),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'firebase_token': firebaseToken}),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', data['token']);
          await prefs.setString('user_data', jsonEncode(data['user']));

          token.value = data['token'];
          userData.value = data['user'];
          isLogin.value = true;

          Get.back();
          Get.snackbar("Success", "Login berhasil");
        } else {
          print(response.body);
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
    try {
      await GoogleSignIn.instance.signOut();
      await FirebaseAuth.instance.signOut();

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('user_data');

      token.value = '';
      userData.value = {};
      isLogin.value = false;

      Get.back();
      Get.snackbar("Success", "Berhasil logout");
    } catch (error) {
      print("Error logout: $error");
      Get.snackbar("Error", "Gagal logout: $error");
    }
  }
}
