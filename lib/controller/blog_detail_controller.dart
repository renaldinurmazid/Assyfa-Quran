import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/models/blog_model.dart';

class BlogDetailController extends GetxController {
  final slug = Get.arguments as String;
  final blog = Rxn<BlogItem>();
  final isLoading = true.obs;
  final isLiking = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBlogDetail();
  }

  Future<void> fetchBlogDetail() async {
    isLoading.value = true;
    try {
      final response = await Request().get(Url.blogDetail(slug));
      if (response.statusCode == 200) {
        final blogDetailResponse = BlogDetailResponse.fromJson(response.data);
        blog.value = blogDetailResponse.data;
        // Record view automatically when detail is fetched
        recordView();
      }
    } catch (e) {
      debugPrint("Error fetching blog detail: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> recordView() async {
    try {
      await Request().post(Url.recordView(slug), data: {});
    } catch (e) {
      debugPrint("Error recording view: $e");
    }
  }

  Future<void> toggleLike() async {
    if (blog.value == null || isLiking.value) return;

    isLiking.value = true;
    try {
      final response = await Request().post(
        Url.toggleLike(blog.value!.id!),
        data: {},
      );
      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data != null) {
          // Update the reactive blog object with new likes and liked status
          blog.value = BlogItem(
            id: blog.value!.id,
            slug: blog.value!.slug,
            title: blog.value!.title,
            thumbnail: blog.value!.thumbnail,
            categoryId: blog.value!.categoryId,
            likes: data['likes'],
            views: blog.value!.views,
            content: blog.value!.content,
            author: blog.value!.author,
            publishedAt: blog.value!.publishedAt,
            createdAt: blog.value!.createdAt,
            category: blog.value!.category,
            otherPrograms: blog.value!.otherPrograms,
            isLiked: data['liked'] ?? data['is_liked'],
          );
        }
      }
    } catch (e) {
      debugPrint("Error toggling like: $e");
    } finally {
      isLiking.value = false;
    }
  }
}
