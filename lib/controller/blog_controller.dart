import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/models/blog_model.dart';

class BlogController extends GetxController {
  static BlogController get to => Get.find();

  final blogs = <BlogItem>[].obs;
  final categories = <BlogCategory>[].obs;
  final isLoading = false.obs;
  final isLoadingCategories = false.obs;
  final isLoadingMore = false.obs;
  final currentPage = 1.obs;
  final hasNextPage = true.obs;
  final selectedCategoryId = RxnInt();

  final scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchBlogs();
    scrollController.addListener(_scrollListener);
  }

  @override
  void onClose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    super.onClose();
  }

  void _scrollListener() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      if (!isLoadingMore.value && hasNextPage.value) {
        fetchMoreBlogs();
      }
    }
  }

  Future<void> fetchCategories() async {
    isLoadingCategories.value = true;
    try {
      final response = await Request().get(Url.blogCategories);
      if (response.statusCode == 200) {
        final categoryResponse = BlogCategoryResponse.fromJson(response.data);
        categories.assignAll(categoryResponse.data ?? []);
      }
    } catch (e) {
      debugPrint("Error fetching blog categories: $e");
    } finally {
      isLoadingCategories.value = false;
    }
  }

  void filterByCategory(int? categoryId) {
    if (selectedCategoryId.value == categoryId) return;
    selectedCategoryId.value = categoryId;
    fetchBlogs();
  }

  Future<void> fetchBlogs() async {
    isLoading.value = true;
    currentPage.value = 1;
    blogs.clear();
    try {
      final queryParams = <String, dynamic>{'page': currentPage.value};
      if (selectedCategoryId.value != null) {
        queryParams['category_id'] = selectedCategoryId.value;
      }

      final response = await Request().get(
        Url.blogs,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final blogResponse = BlogResponse.fromJson(response.data);
        if (blogResponse.data != null) {
          blogs.assignAll(blogResponse.data!.data ?? []);
          hasNextPage.value = blogResponse.data!.nextPageUrl != null;
        }
      }
    } catch (e) {
      debugPrint("Error fetching blogs: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMoreBlogs() async {
    if (isLoadingMore.value || !hasNextPage.value) return;

    isLoadingMore.value = true;
    currentPage.value++;
    try {
      final queryParams = <String, dynamic>{'page': currentPage.value};
      if (selectedCategoryId.value != null) {
        queryParams['category_id'] = selectedCategoryId.value;
      }

      final response = await Request().get(
        Url.blogs,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final blogResponse = BlogResponse.fromJson(response.data);
        if (blogResponse.data != null) {
          blogs.addAll(blogResponse.data!.data ?? []);
          hasNextPage.value = blogResponse.data!.nextPageUrl != null;
        }
      }
    } catch (e) {
      debugPrint("Error fetching more blogs: $e");
      currentPage.value--;
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshBlogs() async {
    await fetchBlogs();
  }
}
