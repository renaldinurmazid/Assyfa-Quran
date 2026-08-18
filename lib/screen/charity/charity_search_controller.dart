import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/models/charity_model.dart';
import 'package:quran_app/widgets/app_toast.dart';

class CharitySearchController extends GetxController {
  var searchResults = <Datum>[].obs;
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var query = ''.obs;

  // Pagination
  var currentPage = 1;
  var hasMoreData = true.obs;
  late ScrollController scrollController;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController()..addListener(_scrollListener);
  }

  @override
  void onClose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    super.onClose();
  }

  void _scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      if (!isLoadingMore.value && hasMoreData.value) {
        searchMoreCharity();
      }
    }
  }

  void searchCharity(String q) async {
    if (q.isEmpty) {
      searchResults.clear();
      return;
    }

    query.value = q;
    try {
      isLoading.value = true;
      currentPage = 1;
      hasMoreData.value = true;
      final response = await Request().get(
        Url.campaigns,
        queryParameters: {
          'search': q,
          'page': currentPage,
        },
      );
      if (response.statusCode == 200) {
        final data = Charity.fromJson(response.data);
        searchResults.value = data.data.data;
        if (data.data.nextPageUrl == null) {
          hasMoreData.value = false;
        }
      } else {
        searchResults.clear();
      }
    } catch (e) {
      AppToast.error(message: 'Terjadi kesalahan, silahkan coba lagi.');
      searchResults.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void searchMoreCharity() async {
    try {
      isLoadingMore.value = true;
      currentPage++;
      final response = await Request().get(
        Url.campaigns,
        queryParameters: {
          'search': query.value,
          'page': currentPage,
        },
      );
      if (response.statusCode == 200) {
        final data = Charity.fromJson(response.data);
        searchResults.addAll(data.data.data);
        if (data.data.nextPageUrl == null) {
          hasMoreData.value = false;
        }
      }
    } catch (e) {
      // Slient fail for more data
    } finally {
      isLoadingMore.value = false;
    }
  }
}
