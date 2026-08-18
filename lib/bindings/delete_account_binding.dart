import 'package:get/get.dart';
import 'package:quran_app/screen/delete_account/delete_account_controller.dart';

class DeleteAccountBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeleteAccountController>(() => DeleteAccountController());
  }
}
