import 'package:get/get.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/services/connectivity_service.dart';

class GlobalBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController(), permanent: true);
    Get.put(ConnectivityService(), permanent: true);
  }
}
