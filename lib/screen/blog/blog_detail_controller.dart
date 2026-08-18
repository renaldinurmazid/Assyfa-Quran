import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/models/blog_model.dart';
import 'package:quran_app/widgets/app_toast.dart';
import 'package:share_plus/share_plus.dart';

class BlogDetailController extends GetxController {
  final slug = Get.arguments as String;
  final blog = Rxn<BlogItem>();
  final isLoading = true.obs;
  final isLiking = false.obs;
  final isSharing = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBlogDetail();
  }

  Future<void> fetchBlogDetail({bool showLoading = true}) async {
    if (showLoading) isLoading.value = true;
    try {
      final response = await Request().get(Url.blogDetail(slug));
      if (response.statusCode == 200) {
        final blogDetailResponse = BlogDetailResponse.fromJson(response.data);
        blog.value = blogDetailResponse.data;
        // Record view automatically when detail is fetched
        recordView();
      } else {
        AppToast.error(message: response.data['message']);
      }
    } catch (e) {
      print(e);
      AppToast.error(message: 'Terjadi kesalahan saat mengambil data');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> recordView() async {
    try {
      await Request().post(Url.recordView(slug), data: {});
    } catch (e) {
      AppToast.error(message: 'Terjadi kesalahan saat merekam view');
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
          blog.value = BlogItem(
            id: blog.value!.id,
            slug: blog.value!.slug,
            title: blog.value!.title,
            thumbnail: blog.value!.thumbnail,
            categoryId: blog.value!.categoryId,
            likes: data['likes'],
            shares: blog.value!.shares,
            views: blog.value!.views,
            commentsCount: blog.value!.commentsCount,
            content: blog.value!.content,
            author: blog.value!.author,
            publishedAt: blog.value!.publishedAt,
            createdAt: blog.value!.createdAt,
            category: blog.value!.category,
            otherPrograms: blog.value!.otherPrograms,
            isLiked: data['liked'] ?? data['is_liked'],
            shareUrl: blog.value!.shareUrl,
          );
        }
      } else {
        AppToast.error(message: response.data['message']);
      }
    } catch (e) {
      AppToast.error(message: 'Terjadi kesalahan saat menyukai');
    } finally {
      isLiking.value = false;
    }
  }

  Future<void> shareBlog() async {
    if (blog.value == null || isSharing.value) return;

    final shareUrl =
        blog.value!.shareUrl ?? '${Url.baseUrl}/b/${blog.value!.slug}';
    final title = blog.value!.title ?? 'Baca blog ini di Quranuna';

    isSharing.value = true;
    try {
      // Record share to API
      final response = await Request().post(
        Url.blogShare(blog.value!.id!),
        data: {},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data != null) {
          // Update local share count
          blog.value = BlogItem(
            id: blog.value!.id,
            slug: blog.value!.slug,
            title: blog.value!.title,
            thumbnail: blog.value!.thumbnail,
            categoryId: blog.value!.categoryId,
            likes: blog.value!.likes,
            shares: data['shares'] ?? (blog.value!.shares ?? 0) + 1,
            views: blog.value!.views,
            commentsCount: blog.value!.commentsCount,
            content: blog.value!.content,
            author: blog.value!.author,
            publishedAt: blog.value!.publishedAt,
            createdAt: blog.value!.createdAt,
            category: blog.value!.category,
            otherPrograms: blog.value!.otherPrograms,
            isLiked: blog.value!.isLiked,
            shareUrl: blog.value!.shareUrl,
          );
        }
      }

      // Trigger native share sheet
      await Share.share('$title\n\n$shareUrl');
    } catch (e) {
      print(e);
      // Even if API fails, still try to share
      await Share.share('$title\n\n$shareUrl');
    } finally {
      isSharing.value = false;
    }
  }
}
