import 'package:get/get.dart';
import 'package:quran_app/screen/find_mosque/find_mosque_controller.dart';

class FindMosqueBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FindMosqueController>(() => FindMosqueController());
  }
}
