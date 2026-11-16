import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/models/arabic_learning/arabic_lesson_model.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/screen/arabic-quran/arabic_quran_controller.dart';
import 'package:quran_app/screen/arabic-quran/arabic_widgets.dart';
import 'package:quran_app/theme/font.dart';

/// Lessons of one level. Route argument: the level id.
class ArabicLessonScreen extends StatefulWidget {
  const ArabicLessonScreen({super.key});

  @override
  State<ArabicLessonScreen> createState() => _ArabicLessonScreenState();
}

class _ArabicLessonScreenState extends State<ArabicLessonScreen> {
  final ArabicQuranController controller = Get.find<ArabicQuranController>();
  late final int levelId = Get.arguments as int;

  @override
  void initState() {
    super.initState();
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
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Get.back(),
        ),
        title: Text('Daftar Pelajaran', style: pSemiBold16),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchLessons(levelId),
        child: Obx(() {
          final data = controller.levelLessons.value;

          if (data == null || data.levelId != levelId) {
            if (controller.isLoadingLessons.value) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: const [
                  ArabicShimmerBox(height: 190),
                  ArabicShimmerBox(height: 110),
                  ArabicShimmerBox(height: 110),
                  ArabicShimmerBox(height: 110),
                ],
              );
            }
            return _Message(
              icon: LucideIcons.wifiOff,
              title: 'Pelajaran belum bisa dimuat',
              subtitle: 'Tarik layar ke bawah untuk mencoba lagi.',
            );
          }

          final color = arabicColor(data.color);
          // The lesson to continue with: first one that is open and unfinished.
          final current = data.lessons
              .where((l) => !l.isLocked && !l.isCompleted)
              .firstOrNull;
          final done = data.lessons.where((l) => l.isCompleted).length;

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
            children: [
              ArabicReveal(
                child: _LevelHeader(data: data, color: color, done: done),
              ),
              const SizedBox(height: 24),
              if (data.lessons.isEmpty)
                const _Message(
                  icon: LucideIcons.bookOpen,
                  title: 'Belum ada pelajaran',
                  subtitle: 'Pelajaran di level ini sedang disiapkan.',
                  shrink: true,
                ),
              for (var i = 0; i < data.lessons.length; i++)
                ArabicReveal(
                  delay: i.clamp(0, 4),
                  child: _LessonNode(
                    lesson: data.lessons[i],
                    number: i + 1,
                    color: color,
                    isCurrent: identical(data.lessons[i], current),
                    isLast: i == data.lessons.length - 1,
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool shrink;
  const _Message({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.shrink = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.theme.colorScheme;
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: scheme.primary),
          ),
          const SizedBox(height: 14),
          Text(title, style: pBold16),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: pMedium12.copyWith(color: scheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
    if (shrink) return Center(child: content);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(child: content),
        ),
      ],
    );
  }
}

class _LevelHeader extends StatelessWidget {
  final ArabicLevelLessons data;
  final Color color;
  final int done;
  const _LevelHeader({
    required this.data,
    required this.color,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    final total = data.lessons.length;
    final pct = total > 0 ? done / total : 0.0;

    return ArabicGradientCard(
      color: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data.themeTitle != null && data.themeTitle!.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    LucideIcons.sparkles,
                    size: 12,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      data.themeTitle!,
                      style: pSemiBold10.copyWith(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 14),
          Text(
            data.name,
            style: pBold24.copyWith(color: Colors.white, height: 1.2),
          ),
          if (data.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              data.description,
              style: pMedium12.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: pct),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, __) => LinearProgressIndicator(
                      value: v,
                      minHeight: 8,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$done/$total selesai',
                style: pSemiBold12.copyWith(color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LessonNode extends StatelessWidget {
  final ArabicLesson lesson;
  final int number;
  final Color color;
  final bool isCurrent;
  final bool isLast;

  const _LessonNode({
    required this.lesson,
    required this.number,
    required this.color,
    required this.isCurrent,
    required this.isLast,
  });

  void _open() {
    if (lesson.isLocked) {
      Get.snackbar(
        'Pelajaran Terkunci',
        'Selesaikan pelajaran sebelumnya terlebih dahulu.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }
    Get.toNamed(Routes.arabicLessonDetail, arguments: lesson.id);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.theme.colorScheme;
    final isDark = context.isDarkMode;
    final locked = lesson.isLocked;
    final done = lesson.isCompleted;
    final tone = locked ? scheme.onSurfaceVariant : color;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline rail.
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: done
                        ? color
                        : isCurrent
                        ? color.withValues(alpha: 0.16)
                        : scheme.surfaceContainerHighest.withValues(
                            alpha: isDark ? 0.5 : 0.8,
                          ),
                    shape: BoxShape.circle,
                    border: isCurrent
                        ? Border.all(color: color, width: 2)
                        : null,
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.35),
                              blurRadius: 12,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: locked
                        ? Icon(LucideIcons.lock, size: 16, color: tone)
                        : done
                        ? const Icon(
                            LucideIcons.check,
                            size: 18,
                            color: Colors.white,
                          )
                        : Text(
                            '$number',
                            style: pBold14.copyWith(
                              color: isCurrent ? color : tone,
                            ),
                          ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: done
                            ? color.withValues(alpha: 0.5)
                            : scheme.outlineVariant.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
              child: Opacity(
                opacity: locked ? 0.6 : 1,
                child: InkWell(
                  onTap: _open,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration:
                        arabicCardDecoration(
                          context,
                          accent: isCurrent ? color : null,
                        ).copyWith(
                          color: isCurrent
                              ? Color.alphaBlend(
                                  color.withValues(alpha: isDark ? 0.14 : 0.06),
                                  isDark
                                      ? scheme.surfaceContainer
                                      : Colors.white,
                                )
                              : null,
                          border: Border.all(
                            color: isCurrent
                                ? color.withValues(alpha: 0.55)
                                : scheme.outlineVariant.withValues(alpha: 0.35),
                            width: isCurrent ? 1.5 : 1,
                          ),
                        ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(lesson.title, style: pSemiBold14),
                            ),
                            if (isCurrent)
                              _Badge(label: 'Lanjut', color: color, solid: true)
                            else if (done)
                              _Badge(label: 'Selesai', color: color)
                            else if (!locked)
                              Icon(
                                LucideIcons.chevronRight,
                                size: 16,
                                color: scheme.onSurfaceVariant,
                              ),
                          ],
                        ),
                        if (lesson.description.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            lesson.description,
                            style: pMedium10.copyWith(
                              color: scheme.onSurfaceVariant,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            if (lesson.isReviewLesson)
                              ArabicChip(
                                label: 'Review',
                                icon: LucideIcons.rotateCcw,
                                color: Colors.orange.shade700,
                              ),
                            ArabicChip(
                              label: '${lesson.totalQuizzes} soal',
                              icon: LucideIcons.listChecks,
                              color: tone,
                            ),
                            if (lesson.durationMinutes > 0)
                              ArabicChip(
                                label: '${lesson.durationMinutes} menit',
                                icon: LucideIcons.clock,
                                color: tone,
                              ),
                            if (lesson.maxXp > 0)
                              ArabicChip(
                                label: '${lesson.maxXp} XP',
                                icon: LucideIcons.zap,
                                color: Colors.amber.shade800,
                              ),
                            if (lesson.attempts > 0)
                              ArabicChip(
                                label: 'Skor ${lesson.score}',
                                icon: LucideIcons.trophy,
                                color: Colors.green.shade700,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final bool solid;
  const _Badge({required this.label, required this.color, this.solid = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: solid ? color : color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: pSemiBold10.copyWith(color: solid ? Colors.white : color),
      ),
    );
  }
}
