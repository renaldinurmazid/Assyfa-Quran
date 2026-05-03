import 'package:get/get.dart';
import 'package:quran_app/controller/mosque_add_controller.dart';

class MosqueAddBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MosqueAddController>(() => MosqueAddController());
  }
}
