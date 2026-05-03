import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:quran_app/controller/blog_detail_controller.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/services/deep_link_service.dart';
import 'package:quran_app/theme/font.dart';
import 'package:shimmer/shimmer.dart';

class ShowBlogScreen extends StatelessWidget {
  const ShowBlogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BlogDetailController());

    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          'Detail Blog',
          style: pSemiBold16.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingShimmer(context);
        }

        final blog = controller.blog.value;
        if (blog == null) {
          return Center(
            child: Text(
              'Gagal memuat data blog.',
              style: pRegular14.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category
              if (blog.category != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    blog.category!.name ?? '-',
                    style: pSemiBold10.copyWith(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              const SizedBox(height: 12),

              // Title
              Text(
                blog.title ?? '-',
                style: pBold20.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),

              // Author & Time
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Theme.of(
                      context,
                    ).primaryColor.withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        blog.author?.name ?? 'Admin',
                        style: pSemiBold12.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            blog.publishedAt ?? '-',
                            style: pRegular10.copyWith(
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '•',
                            style: pRegular10.copyWith(
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${blog.views.toString()} Views',
                            style: pRegular10.copyWith(
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () async {
                      await Get.toNamed(
                        Routes.comment,
                        arguments: {'blog_id': blog.id},
                      );
                      controller.fetchBlogDetail(showLoading: false);
                    },
                    child: Column(
                      children: [
                        Icon(
                          Icons.comment_outlined,
                          color: Theme.of(context).primaryColor,
                          size: 20,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          blog.commentsCount.toString(),
                          style: pRegular12.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () => controller.toggleLike(),
                    child: Column(
                      children: [
                        Icon(
                          blog.isLiked == true
                              ? Icons.thumb_up_alt
                              : Icons.thumb_up_alt_outlined,
                          color: Theme.of(context).primaryColor,
                          size: 20,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          blog.likes.toString(),
                          style: pRegular12.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () => controller.shareBlog(),
                    child: Column(
                      children: [
                        Icon(
                          Icons.share,
                          color: Theme.of(context).primaryColor,
                          size: 20,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          (blog.shares ?? 0).toString(),
                          style: pRegular12.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Thumbnail
              if (blog.thumbnail != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    blog.thumbnail!,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 220,
                      color: isDark ? Colors.grey[800] : Colors.grey[100],
                      child: Icon(
                        Icons.broken_image,
                        color: isDark ? Colors.grey[600] : Colors.grey,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              // Content
              HtmlWidget(
                (blog.content ?? '')
                    .replaceAll('&nbsp;', ' ')
                    .replaceAll('\u00A0', ' ')
                    .replaceAll('word-break: break-all', 'word-break: normal')
                    .replaceAll('word-break: break-word', 'word-break: normal'),
                textStyle: pRegular14.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.8),
                  height: 1.6,
                ),
                onTapUrl: (url) async {
                  await DeepLinkService.handlePayload(url);
                  return true;
                },
                customStylesBuilder: (element) {
                  final styles = <String, String>{};

                  if (element.localName == 'strong') {
                    styles['font-weight'] = 'bold';
                    styles['color'] = isDark ? '#ffffff' : '#000000';
                  } else if (element.localName == 'blockquote') {
                    styles['padding'] = '16px';
                    styles['background-color'] = isDark ? '#1e1e1e' : '#f8f9fa';
                    styles['border-left'] =
                        '4px solid ${Theme.of(context).primaryColor.value.toRadixString(16).substring(2)}';
                    styles['font-style'] = 'italic';
                  }

                  return styles;
                },
              ),
              const SizedBox(height: 40),

              // Other Programs (Related Blogs)
              if (blog.otherPrograms != null &&
                  blog.otherPrograms!.isNotEmpty) ...[
                Text(
                  'Program Lainnya',
                  style: pBold16.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: blog.otherPrograms!.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = blog.otherPrograms![index];
                    return InkWell(
                      onTap: () {
                        // Replace the current detail with a new one
                        Get.offNamed(
                          Get.currentRoute,
                          arguments: item.slug,
                          preventDuplicates: false,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).dividerColor.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                item.thumbnail ?? '',
                                height: 80,
                                width: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      height: 80,
                                      width: 80,
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? Colors.grey[800]
                                            : Colors.grey[100],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.broken_image,
                                        color: isDark
                                            ? Colors.grey[600]
                                            : Colors.grey,
                                        size: 24,
                                      ),
                                    ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: SizedBox(
                                height: 80,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item.title ?? '-',
                                      style: pSemiBold14.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      item.publishedAt ?? '-',
                                      style: pRegular12.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).textTheme.bodySmall?.color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildLoadingShimmer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Shimmer.fromColors(
        baseColor: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        highlightColor: isDark ? Colors.grey[700]! : Colors.grey[50]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 100,
              height: 24,
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.white,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 30,
              color: isDark ? Colors.white10 : Colors.white,
            ),
            const SizedBox(height: 8),
            Container(
              width: 200,
              height: 30,
              color: isDark ? Colors.white10 : Colors.white,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: isDark ? Colors.white10 : Colors.white,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 16,
                      color: isDark ? Colors.white10 : Colors.white,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 60,
                      height: 12,
                      color: isDark ? Colors.white10 : Colors.white,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 24),
            ...List.generate(
              5,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  width: double.infinity,
                  height: 16,
                  color: isDark ? Colors.white10 : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
