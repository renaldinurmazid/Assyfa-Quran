import 'package:get/get.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/controller/global/global_audio_controller.dart';
import 'package:quran_app/screen/quran_mp3/quran_mp3_controller.dart';
import 'package:quran_app/services/connectivity_service.dart';

class GlobalBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController(), permanent: true);
    Get.put(ConnectivityService(), permanent: true);
    Get.put(GlobalAudioController(), permanent: true);
    Get.put(QuranMp3Controller(), permanent: true);
  }
}
