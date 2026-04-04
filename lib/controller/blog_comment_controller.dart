import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:quran_app/models/blog_comment_model.dart';
import 'package:quran_app/widgets/app_toast.dart';

class BlogCommentController extends GetxController {
  final int blogId = Get.arguments['blog_id'];
  final comments = <BlogComment>[].obs;
  final isLoading = true.obs;
  final isSubmitting = false.obs;

  final commentController = TextEditingController();
  final parentId = Rxn<int>();

  @override
  void onInit() {
    super.onInit();
    fetchComments();
  }

  Future<void> fetchComments() async {
    isLoading.value = true;
    try {
      final response = await Request().get(Url.blogComments(blogId));
      if (response.statusCode == 200) {
        final commentResponse = BlogCommentResponse.fromJson(response.data);
        comments.value = commentResponse.data?.data ?? [];
      } else {
        AppToast.error(message: response.data['message'] ?? 'Gagal memuat komentar');
      }
    } catch (e) {
      print(e);
      AppToast.error(message: 'Terjadi kesalahan saat mengambil data');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitComment() async {
    if (!AuthController.to.isLogin.value) {
      AppToast.error(message: 'Silahkan login terlebih dahulu untuk berkomentar');
      return;
    }

    if (commentController.text.trim().isEmpty) return;

    isSubmitting.value = true;
    try {
      final response = await Request().post(
        Url.blogCommentsStore,
        data: {
          'blog_id': blogId,
          'comment': commentController.text,
          'parent_id': parentId.value,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        commentController.clear();
        parentId.value = null;
        fetchComments();
        AppToast.success(message: 'Komentar berhasil dikirim');
      } else {
        AppToast.error(message: response.data['message'] ?? 'Gagal mengirim komentar');
      }
    } catch (e) {
      print(e);
      AppToast.error(message: 'Terjadi kesalahan saat mengirim komentar');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> deleteComment(int id) async {
    if (!AuthController.to.isLogin.value) return;

    try {
      final response = await Request().delete(Url.blogCommentDelete(id));
      if (response.statusCode == 200) {
        fetchComments();
        AppToast.success(message: 'Komentar berhasil dihapus');
      } else {
        AppToast.error(message: response.data['message'] ?? 'Gagal menghapus komentar');
      }
    } catch (e) {
      AppToast.error(message: 'Terjadi kesalahan saat menghapus komentar');
    }
  }

  bool isOwner(int? commentUserId) {
    if (!AuthController.to.isLogin.value) return false;
    return AuthController.to.userData['id'] == commentUserId;
  }

  void setReply(int? id) {
    parentId.value = id;
  }

  @override
  void onClose() {
    commentController.dispose();
    super.onClose();
  }
}
