import 'package:get/get.dart';
import 'package:quran_app/screen/arabic-quran/arabic_quran_controller.dart';

class ArabicQuranBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ArabicQuranController>(
      () => ArabicQuranController(),
    );
  }
}
