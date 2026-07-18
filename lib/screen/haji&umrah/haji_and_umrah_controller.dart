import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/models/haji_umrah_package_model.dart';
import 'package:quran_app/widgets/app_toast.dart';

class HajiAndUmrahController extends GetxController {
  final RxList<HajiUmrahPackageModel> packagesList =
      <HajiUmrahPackageModel>[].obs;

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isLoadingFilters = false.obs;

  // Search state
  late TextEditingController searchController;
  final RxString searchQuery = ''.obs;
  Timer? _searchDebounce;

  // Filter state
  final RxInt selectedSort =
      1.obs; // 1 = Harga Terendah, 2 = Waktu Terdekat, 3 = Waktu Terjauh
  final RxString selectedMonthLabel = 'Semua'.obs;
  final RxString selectedCityId = 'Semua'.obs;

  // Pagination state
  int currentPage = 1;
  final RxBool hasMoreData = true.obs;
  late ScrollController scrollController;

  // Dropdown lists loaded dynamically from API
  final RxList<Map<String, dynamic>> apiMonths = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> apiCities = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    searchController = TextEditingController();
    scrollController = ScrollController()..addListener(_scrollListener);

    // Fetch filter options first, then load packages
    fetchFilterOptions().then((_) {
      fetchUmrahPackages(refresh: true);
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    _searchDebounce?.cancel();
    super.onClose();
  }

  void _scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      if (!isLoadingMore.value && hasMoreData.value && !isLoading.value) {
        fetchMoreUmrahPackages();
      }
    }
  }

  void debounceSearch() {
    if (_searchDebounce?.isActive ?? false) _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      fetchUmrahPackages(refresh: true);
    });
  }

  Future<void> fetchFilterOptions() async {
    try {
      isLoadingFilters.value = true;
      final response = await Request().get(Url.umrahFilters);

      if (response.statusCode == 200) {
        final payload = response.data;
        if (payload['status'] == 'success') {
          final data = payload['data'] as Map<String, dynamic>?;

          if (data != null) {
            // Parse cities
            final citiesList = data['cities'] as List<dynamic>? ?? [];
            final List<Map<String, dynamic>> parsedCities = citiesList
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList();

            // Sort cities alphabetically by name
            parsedCities.sort(
              (a, b) => (a['name']?.toString() ?? '').compareTo(
                b['name']?.toString() ?? '',
              ),
            );

            apiCities.assignAll(parsedCities);

            // Parse months
            final monthsList = data['months'] as List<dynamic>? ?? [];
            final List<Map<String, dynamic>> parsedMonths = monthsList
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList();

            apiMonths.assignAll(parsedMonths);
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching filters: $e');
    } finally {
      isLoadingFilters.value = false;
    }
  }

  // Map sort option value to Laravel query parameter value
  String _getSortParamValue(int sortOption) {
    switch (sortOption) {
      case 1:
        return 'harga_terendah';
      case 2:
        return 'waktu_terdekat';
      case 3:
        return 'waktu_terjauh';
      default:
        return 'latest';
    }
  }

  Map<String, dynamic> _buildQueryParams(int page) {
    final Map<String, dynamic> params = {
      'page': page,
      'sort': _getSortParamValue(selectedSort.value),
    };

    if (searchQuery.value.isNotEmpty) {
      params['search'] = searchQuery.value;
    }

    // Month & Year filter mapping
    if (selectedMonthLabel.value != 'Semua') {
      final matchedMonthObj = apiMonths.firstWhereOrNull(
        (m) => m['label'] == selectedMonthLabel.value,
      );
      if (matchedMonthObj != null) {
        params['month'] = matchedMonthObj['month']?.toString() ?? 'all';
        params['year'] = matchedMonthObj['year']?.toString() ?? 'all';
      }
    }

    // City ID filter mapping (Larval resolves ID if numeric)
    if (selectedCityId.value != 'Semua') {
      params['city'] = selectedCityId.value;
    }

    return params;
  }

  Future<void> fetchUmrahPackages({bool refresh = false}) async {
    try {
      if (refresh) {
        isLoading.value = true;
        currentPage = 1;
        hasMoreData.value = true;
      }

      final response = await Request().get(
        Url.umrah,
        queryParameters: _buildQueryParams(currentPage),
      );

      if (response.statusCode == 200) {
        final payload = response.data;
        if (payload['status'] == 'success') {
          final dataObj = payload['data'] as Map<String, dynamic>;
          final listJson = dataObj['data'] as List<dynamic>;

          final List<HajiUmrahPackageModel> loaded = listJson
              .map(
                (item) => HajiUmrahPackageModel.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList();

          if (refresh) {
            packagesList.assignAll(loaded);
          } else {
            packagesList.addAll(loaded);
          }

          // Pagination check
          final nextPageUrl = dataObj['next_page_url'];
          if (nextPageUrl == null) {
            hasMoreData.value = false;
          }
        } else {
          AppToast.error(message: payload['message'] ?? 'Gagal memuat data');
        }
      } else {
        AppToast.error(message: 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching packages: $e');
      AppToast.error(message: 'Gagal menghubungkan ke server.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMoreUmrahPackages() async {
    try {
      isLoadingMore.value = true;
      currentPage++;

      final response = await Request().get(
        Url.umrah,
        queryParameters: _buildQueryParams(currentPage),
      );

      if (response.statusCode == 200) {
        final payload = response.data;
        if (payload['status'] == 'success') {
          final dataObj = payload['data'] as Map<String, dynamic>;
          final listJson = dataObj['data'] as List<dynamic>;

          final List<HajiUmrahPackageModel> loaded = listJson
              .map(
                (item) => HajiUmrahPackageModel.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList();

          packagesList.addAll(loaded);

          final nextPageUrl = dataObj['next_page_url'];
          if (nextPageUrl == null) {
            hasMoreData.value = false;
          }
        } else {
          AppToast.error(message: payload['message'] ?? 'Gagal memuat data');
        }
      }
    } catch (e) {
      debugPrint('Error fetching more: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  void applyFilter() {
    fetchUmrahPackages(refresh: true);
  }

  void resetFilters() {
    selectedSort.value = 1;
    selectedMonthLabel.value = 'Semua';
    selectedCityId.value = 'Semua';
    fetchUmrahPackages(refresh: true);
  }
}
