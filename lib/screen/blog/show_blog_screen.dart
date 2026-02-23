import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:quran_app/controller/blog_detail_controller.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';
import 'package:shimmer/shimmer.dart';

class ShowBlogScreen extends StatelessWidget {
  const ShowBlogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BlogDetailController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 20,
          ),
        ),
        title: Text(
          'Detail Blog',
          style: pSemiBold16.copyWith(color: Colors.black87),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingShimmer();
        }

        final blog = controller.blog.value;
        if (blog == null) {
          return const Center(child: Text('Gagal memuat data blog.'));
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
                    color: AppColor.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    blog.category!.name ?? '-',
                    style: pSemiBold10.copyWith(color: AppColor.primaryColor),
                  ),
                ),
              const SizedBox(height: 12),

              // Title
              Text(
                blog.title ?? '-',
                style: pBold20.copyWith(color: Colors.black87, height: 1.3),
              ),
              const SizedBox(height: 16),

              // Author & Time
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColor.primaryColor.withOpacity(0.1),
                    child: const Icon(
                      Icons.person,
                      color: AppColor.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        blog.author ?? 'Admin',
                        style: pSemiBold12.copyWith(color: Colors.black87),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            blog.publishedAt ?? '-',
                            style: pRegular10.copyWith(color: Colors.grey),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '•',
                            style: pRegular10.copyWith(color: Colors.grey),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${blog.views.toString()} Views',
                            style: pRegular10.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () => controller.toggleLike(),
                    child: Column(
                      children: [
                        Icon(
                          blog.isLiked == true
                              ? Icons.thumb_up_alt
                              : Icons.thumb_up_alt_outlined,
                          color: blog.isLiked == true
                              ? AppColor.primaryColor
                              : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          blog.likes.toString(),
                          style: pRegular12.copyWith(
                            color: blog.isLiked == true
                                ? AppColor.primaryColor
                                : Colors.grey,
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
                      color: Colors.grey[100],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              // Content
              HtmlWidget(
                blog.content ?? '',
                textStyle: pRegular14.copyWith(
                  color: Colors.black.withOpacity(0.8),
                  height: 1.6,
                ),
                customStylesBuilder: (element) {
                  if (element.localName == 'strong') {
                    return {'font-weight': 'bold', 'color': 'black'};
                  }
                  if (element.localName == 'blockquote') {
                    return {
                      'padding': '16px',
                      'background-color': '#f8f9fa',
                      'border-left':
                          '4px solid ${AppColor.primaryColor.value.toRadixString(16).substring(2)}',
                      'font-style': 'italic',
                    };
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),

              // Other Programs (Related Blogs)
              if (blog.otherPrograms != null &&
                  blog.otherPrograms!.isNotEmpty) ...[
                Text(
                  'Program Lainnya',
                  style: pBold16.copyWith(color: Colors.black87),
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
                          border: Border.all(color: Colors.grey.shade100),
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
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.broken_image,
                                        color: Colors.grey,
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
                                        color: Colors.black87,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      item.publishedAt ?? '-',
                                      style: pRegular12.copyWith(
                                        color: Colors.grey,
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

  Widget _buildLoadingShimmer() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[200]!,
        highlightColor: Colors.grey[50]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 100,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            const SizedBox(height: 12),
            Container(width: double.infinity, height: 30, color: Colors.white),
            const SizedBox(height: 8),
            Container(width: 200, height: 30, color: Colors.white),
            const SizedBox(height: 24),
            Row(
              children: [
                const CircleAvatar(radius: 18),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 100, height: 16, color: Colors.white),
                    const SizedBox(height: 4),
                    Container(width: 60, height: 12, color: Colors.white),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                color: Colors.white,
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
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
