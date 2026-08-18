import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:quran_app/screen/blog/blog_comment_controller.dart';
import 'package:quran_app/models/blog_comment_model.dart';
import 'package:quran_app/theme/font.dart';

class CommentScreen extends StatelessWidget {
  const CommentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BlogCommentController>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).iconTheme.color,
            size: 20,
          ),
        ),
        title: Text(
          'Komentar',
          style: pSemiBold16.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // List Komentar
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ),
                );
              }

              if (controller.comments.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 48,
                        color: Theme.of(context).disabledColor.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada komentar',
                        style: pRegular14.copyWith(
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: controller.comments.length,
                separatorBuilder: (context, index) =>
                    Divider(height: 32, color: Theme.of(context).dividerColor),
                itemBuilder: (context, index) {
                  final comment = controller.comments[index];
                  return _buildCommentItem(comment, controller);
                },
              );
            }),
          ),

          // Form Input Komentar
          Obx(
            () => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (controller.parentId.value != null)
                  _buildReplyIndicator(controller),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        offset: const Offset(0, -4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[900]
                                  : Colors.grey[50],
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Theme.of(context).dividerColor,
                              ),
                            ),
                            child: TextField(
                              controller: controller.commentController,
                              decoration: InputDecoration(
                                hintText: controller.parentId.value == null
                                    ? 'Tulis komentar...'
                                    : 'Balas komentar...',
                                hintStyle: pRegular12.copyWith(
                                  color: Theme.of(context).hintColor,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              style: pRegular12.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        controller.isSubmitting.value
                            ? const SizedBox(
                                height: 40,
                                width: 40,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  onPressed: () => controller.submitComment(),
                                  icon: const Icon(
                                    Icons.send_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(
    BlogComment comment,
    BlogCommentController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CommentTile(
          comment: comment,
          onReply: () => controller.setReply(comment.id),
        ),
        if (comment.replies != null && comment.replies!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 44, top: 16),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comment.replies!.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final reply = comment.replies![index];
                return _CommentTile(
                  comment: reply,
                  isReply: true,
                  onReply: () => controller.setReply(comment.id),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildReplyIndicator(BlogCommentController controller) {
    final isDark = Get.isDarkMode;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      color: isDark ? Colors.grey[900] : Colors.grey[100],
      child: Row(
        children: [
          Icon(Icons.reply, size: 16, color: Theme.of(Get.context!).hintColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Membalas komentar...',
              style: pRegular12.copyWith(
                color: Theme.of(Get.context!).hintColor,
              ),
            ),
          ),
          IconButton(
            onPressed: () => controller.setReply(null),
            icon: Icon(
              Icons.close,
              size: 16,
              color: Theme.of(Get.context!).hintColor,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final BlogComment comment;
  final bool isReply;
  final VoidCallback onReply;

  const _CommentTile({
    required this.comment,
    this.isReply = false,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = comment.createdAt != null
        ? DateFormat('dd MMM yyyy, HH:mm').format(comment.createdAt!)
        : '-';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: isReply ? 14 : 20,
          backgroundImage: comment.user?.photo != null
              ? NetworkImage(comment.user!.photo!)
              : null,
          backgroundColor: Theme.of(context).dividerColor,
          child: comment.user?.photo == null
              ? Icon(
                  Icons.person,
                  size: isReply ? 14 : 20,
                  color: Theme.of(context).hintColor,
                )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    comment.user?.name ?? 'Anonim',
                    style: (isReply ? pSemiBold12 : pSemiBold14).copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        dateStr,
                        style: pRegular10.copyWith(
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      if (Get.find<BlogCommentController>().isOwner(
                        comment.userId,
                      )) ...[
                        const SizedBox(width: 4),
                        PopupMenuButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            Icons.more_vert,
                            size: 16,
                            color: Theme.of(context).hintColor,
                          ),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'delete',
                              child: Text(
                                'Hapus',
                                style: pRegular12.copyWith(color: Colors.red),
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'delete') {
                              Get.find<BlogCommentController>().deleteComment(
                                comment.id!,
                              );
                            }
                          },
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                comment.comment ?? '',
                style: pRegular12.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(
                        0.8,
                      ),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              if (!isReply)
                GestureDetector(
                  onTap: onReply,
                  child: Text(
                    'Balas',
                    style: pSemiBold12.copyWith(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
