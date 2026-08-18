import 'dart:io';
import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/widgets/app_toast.dart';
import 'package:share_plus/share_plus.dart';

class ProfileScreenController extends GetxController {
  final isLoadingShare = false.obs;

  Future<void> shareApp() async {
    if (isLoadingShare.value) return;

    isLoadingShare.value = true;
    try {
      final String platform = Platform.isIOS ? 'ios' : 'android';
      final response = await Request().get(
        '${Url.myReferral}?platform=$platform',
      );

      if (response.statusCode == 200) {
        final String? referralLink = response.data['data']['referral_link'];
        if (referralLink != null) {
          await Share.share(
            'Yuk download aplikasi Quranuna dan mulai tilawah bersama! Gunakan link berikut untuk mendaftar: $referralLink',
            subject: 'Berbagi Kebaikan dengan Quranuna',
          );
        } else {
          AppToast.error(message: 'Link referral tidak ditemukan');
        }
      } else {
        AppToast.error(
          message: response.data['message'] ?? 'Gagal mengambil link referral',
        );
      }
    } catch (e) {
      AppToast.error(message: 'Terjadi kesalahan saat mencoba berbagi');
    } finally {
      isLoadingShare.value = false;
    }
  }
}
