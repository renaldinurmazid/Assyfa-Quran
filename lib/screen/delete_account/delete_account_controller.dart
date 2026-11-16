import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/widgets/app_toast.dart';
import 'package:quran_app/controller/global/auth_controller.dart';

class DeleteAccountController extends GetxController {
  RxBool isLoading = false.obs;

  Future<void> deleteAccount() async {
    try {
      isLoading.value = true;
      final response = await Request().post(Url.deleteAccount);

      if (response.statusCode == 200) {
        AppToast.success(
          message: response.data['message'] ??
              'Akun Anda telah berhasil dihapus secara permanen. Terima kasih telah menggunakan layanan kami.',
          title: 'Berhasil',
        );

        // Hapus data lokal dan paksa keluar
        await AuthController.to.forceSignOut();

        // Kembali ke halaman awal
        Get.offAllNamed('/');
      } else {
        AppToast.error(
          message: response.data['message'] ?? 'Gagal menghapus akun. Silakan coba lagi nanti.',
          title: 'Gagal',
        );
      }
    } catch (e) {
      AppToast.error(
        message: 'Terjadi kesalahan sistem saat menghapus akun. Silakan coba lagi nanti.',
        title: 'Error',
      );
    } finally {
      isLoading.value = false;
    }
  }
}
