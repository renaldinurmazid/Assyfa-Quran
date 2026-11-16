import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/models/public_group_model.dart';
import 'package:quran_app/widgets/app_toast.dart';

class GroupSearchController extends GetxController {
  var publicGroups = <PublicGroupItem>[].obs;
  var isLoading = false.obs;
  var query = ''.obs;

  void searchGroups(String q) async {
    if (q.isEmpty) {
      publicGroups.clear();
      return;
    }

    query.value = q;
    try {
      isLoading.value = true;
      final response = await Request().get('${Url.publicGroups}?search=$q');
      if (response.statusCode == 200) {
        final model = PublicGroupModel.fromJson(response.data);
        publicGroups.value = model.data.data;
      } else {
        AppToast.error(message: response.data['message']);
        publicGroups.clear();
      }
    } catch (e) {
      print(e);
      AppToast.error(message: 'Terjadi kesalahan, silahkan coba lagi.');
      publicGroups.clear();
    } finally {
      isLoading.value = false;
    }
  }
}
