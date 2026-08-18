import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/models/charity_model.dart';
import 'package:quran_app/models/campaign_category_model.dart';
import 'package:quran_app/widgets/app_toast.dart';

class CharityScreenController extends GetxController {
  var charityList = <Datum>[].obs;
  var latestCharityList = <Datum>[].obs;
  var campaignCategories = <CategoryDatum>[].obs;
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var isLoadingCategory = false.obs;
  var selectedCategoryId = Rxn<int>();

  // Pagination
  var currentPage = 1;
  var hasMoreData = true.obs;
  late ScrollController scrollController;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController()..addListener(_scrollListener);
    fetchCharityList();
    fetchLatestCharityList();
    fetchCampaignCategories();
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
        fetchMoreCharityList();
      }
    }
  }

  Future<void> fetchCharityList() async {
    try {
      isLoading.value = true;
      currentPage = 1;
      hasMoreData.value = true;
      final response = await Request().get(
        Url.campaigns,
        queryParameters: {
          'page': currentPage,
          if (selectedCategoryId.value != null)
            'category': selectedCategoryId.value,
        },
      );
      if (response.statusCode == 200) {
        final data = Charity.fromJson(response.data);
        charityList.value = data.data.data;
        if (data.data.nextPageUrl == null) {
          hasMoreData.value = false;
        }
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

  Future<void> fetchMoreCharityList() async {
    try {
      isLoadingMore.value = true;
      currentPage++;
      final response = await Request().get(
        Url.campaigns,
        queryParameters: {
          'page': currentPage,
          if (selectedCategoryId.value != null)
            'category': selectedCategoryId.value,
        },
      );
      if (response.statusCode == 200) {
        final data = Charity.fromJson(response.data);
        charityList.addAll(data.data.data);
        if (data.data.nextPageUrl == null) {
          hasMoreData.value = false;
        }
      } else {
        AppToast.error(message: response.data['message']);
      }
    } catch (e) {
      AppToast.error(message: 'Terjadi kesalahan, silahkan coba lagi.');
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> filterByCategory(int? categoryId) async {
    selectedCategoryId.value = categoryId;
    await fetchCharityList();
  }

  Future<void> fetchCampaignCategories() async {
    try {
      isLoadingCategory.value = true;
      final response = await Request().get(Url.campaignCategories);
      if (response.statusCode == 200) {
        final data = CampaignCategory.fromJson(response.data);
        campaignCategories.value = data.data;
      } else {
        AppToast.error(message: response.data['message']);
      }
    } catch (e) {
      AppToast.error(message: 'Terjadi kesalahan saat mengambil kategori.');
    } finally {
      isLoadingCategory.value = false;
    }
  }

  Future<void> fetchLatestCharityList() async {
    try {
      isLoading.value = true;
      final response = await Request().get(
        Url.campaigns,
        queryParameters: {'sort': 'latest', 'per_page': 5},
      );
      if (response.statusCode == 200) {
        final data = Charity.fromJson(response.data);
        latestCharityList.value = data.data.data;
      } else {
        AppToast.error(message: response.data['message']);
      }
    } catch (e) {
      AppToast.error(message: 'Terjadi kesalahan, silahkan coba lagi.');
    } finally {
      isLoading.value = false;
    }
  }
}
