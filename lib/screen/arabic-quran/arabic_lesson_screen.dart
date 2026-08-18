import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:quran_app/models/arabic_learning/arabic_lesson_model.dart';
import 'package:quran_app/screen/arabic-quran/arabic_quran_controller.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/theme/font.dart';
import 'package:quran_app/screen/arabic-quran/arabic_quran_screen.dart'; // for HexColor

class ArabicLessonScreen extends StatefulWidget {
  const ArabicLessonScreen({super.key});

  @override
  State<ArabicLessonScreen> createState() => _ArabicLessonScreenState();
}

class _ArabicLessonScreenState extends State<ArabicLessonScreen> {
  final ArabicQuranController controller = Get.find<ArabicQuranController>();
  late int levelId;

  @override
  void initState() {
    super.initState();
    levelId = Get.arguments as int;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchLessons(levelId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorScheme.onSurface,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: Obx(() {
          final level = controller.currentLevel.value;
          return Text(
            level != null ? level.name : "Daftar Pelajaran",
            style: pSemiBold16.copyWith(color: colorScheme.onSurface),
          );
        }),
        centerTitle: false,
      ),
      body: Obx(() {
        if (controller.isLoadingLessons.value && controller.lessons.isEmpty) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 4,
            itemBuilder: (context, index) => _buildShimmerCard(context),
          );
        }

        if (controller.lessons.isEmpty) {
          return Center(
            child: Text(
              "Belum ada pelajaran di level ini.",
              style: pRegular14.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          );
        }

        final levelColor = controller.currentLevel.value != null
            ? HexColor(controller.currentLevel.value!.color)
            : Colors.teal;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.lessons.length,
          itemBuilder: (context, index) {
            final lesson = controller.lessons[index];
            return _buildLessonItem(context, lesson, levelColor, index + 1);
          },
        );
      }),
    );
  }

  Widget _buildShimmerCard(BuildContext context) {
    final isDark = context.isDarkMode;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Shimmer.fromColors(
        baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
        highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildLessonItem(
    BuildContext context,
    ArabicLesson lesson,
    Color baseColor,
    int number,
  ) {
    final colorScheme = context.theme.colorScheme;
    final isDark = context.isDarkMode;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Get.toNamed(Routes.arabicQuiz, arguments: lesson.id);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? colorScheme.surfaceContainer : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: lesson.isCompleted
                    ? baseColor.withValues(alpha: 0.5)
                    : colorScheme.outlineVariant.withValues(alpha: 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: lesson.isCompleted
                        ? baseColor
                        : colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: lesson.isCompleted
                        ? const Icon(Icons.check_rounded, color: Colors.white)
                        : Text(
                            "$number",
                            style: pSemiBold16.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson.title,
                        style: pSemiBold14.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${lesson.totalQuizzes} Pertanyaan",
                        style: pRegular12.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
