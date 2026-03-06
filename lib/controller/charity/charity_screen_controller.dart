import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/models/charity_model.dart';
import 'package:quran_app/widgets/app_toast.dart';

class CharityScreenController extends GetxController {
  var charityList = <Datum>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCharityList();
  }

  Future<void> fetchCharityList() async {
    try {
      isLoading.value = true;
      final response = await Request().get(Url.campaigns);
      if (response.statusCode == 200) {
        final data = Charity.fromJson(response.data);
        charityList.value = data.data;
      } else {
        AppToast.error(message: response.data['message']);
      }
    } catch (e) {
      print(e);
      AppToast.error(message: 'Terjadi kesalahan, silahkan coba lagi.');
    } finally {
      isLoading.value = false;
    }
  }
}
