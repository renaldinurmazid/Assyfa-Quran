import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/models/arabic_learning/arabic_lesson_model.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/screen/arabic-quran/arabic_quiz_controller.dart';
import 'package:quran_app/screen/arabic-quran/arabic_quran_controller.dart';
import 'package:quran_app/screen/arabic-quran/arabic_widgets.dart';
import 'package:quran_app/theme/font.dart';

/// Lesson overview: objectives, the material blocks and the quiz entry points.
/// Route argument: the lesson id.
class ArabicLessonDetailScreen extends StatefulWidget {
  const ArabicLessonDetailScreen({super.key});

  @override
  State<ArabicLessonDetailScreen> createState() =>
      _ArabicLessonDetailScreenState();
}

class _ArabicLessonDetailScreenState extends State<ArabicLessonDetailScreen> {
  final ArabicQuranController controller = Get.find<ArabicQuranController>();
  late final int lessonId = Get.arguments as int;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchLessonDetail(lessonId);
    });
  }

  void _startQuiz(ArabicQuizMode mode) {
    Get.toNamed(
      Routes.arabicQuiz,
      arguments: {'lessonId': lessonId, 'mode': mode},
    );
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
        title: Text('Pelajaran', style: pSemiBold16),
        centerTitle: false,
      ),
      body: Obx(() {
        final detail = controller.lessonDetail.value;
        if (detail == null || detail.lesson.id != lessonId) {
          if (controller.isLoadingDetail.value) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                ArabicShimmerBox(height: 220),
                ArabicShimmerBox(height: 120),
                ArabicShimmerBox(height: 160),
              ],
            );
          }
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.wifiOff,
                  size: 32,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 10),
                Text('Pelajaran belum bisa dimuat', style: pSemiBold14),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () => controller.fetchLessonDetail(lessonId),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Muat ulang',
                    style: pSemiBold14.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }

        final color = arabicColor(detail.color);
        return Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => controller.fetchLessonDetail(lessonId),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  children: [
                    ArabicReveal(
                      child: _Header(detail: detail, color: color),
                    ),
                    if (detail.objectives.isNotEmpty || detail.target != null)
                      ArabicReveal(
                        delay: 1,
                        child: _Objectives(detail: detail, color: color),
                      ),
                    if (detail.contents.isNotEmpty) ...[
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Text('Materi', style: pBold20),
                          const SizedBox(width: 8),
                          ArabicChip(
                            label: '${detail.contents.length} bagian',
                            color: color,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      for (var i = 0; i < detail.contents.length; i++)
                        ArabicReveal(
                          delay: i.clamp(0, 3),
                          child: _ContentCard(
                            content: detail.contents[i],
                            color: color,
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
            _Actions(
              detail: detail,
              color: color,
              onPractice: () => _startQuiz(ArabicQuizMode.practice),
              onMain: () => _startQuiz(ArabicQuizMode.main),
              onReview: () => _startQuiz(ArabicQuizMode.review),
            ),
          ],
        );
      }),
    );
  }
}

// ─── Header ─────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final ArabicLessonDetail detail;
  final Color color;
  const _Header({required this.detail, required this.color});

  @override
  Widget build(BuildContext context) {
    final lesson = detail.lesson;
    final trail = [
      detail.themeTitle,
      detail.levelName,
    ].where((e) => e.isNotEmpty).join(' • ');

    return ArabicGradientCard(
      color: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (trail.isNotEmpty)
                Flexible(
                  child: _GlassPill(icon: LucideIcons.sparkles, label: trail),
                ),
              if (lesson.isReviewLesson) ...[
                const SizedBox(width: 6),
                const _GlassPill(icon: LucideIcons.rotateCcw, label: 'Review'),
              ],
            ],
          ),
          const SizedBox(height: 14),
          Text(
            lesson.title,
            style: pBold24.copyWith(color: Colors.white, height: 1.2),
          ),
          if (lesson.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              lesson.description,
              style: pMedium12.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              if (lesson.durationMinutes > 0) ...[
                Expanded(
                  child: _HeaderStat(
                    icon: LucideIcons.clock,
                    value: '${lesson.durationMinutes}',
                    label: 'menit',
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: _HeaderStat(
                  icon: LucideIcons.flag,
                  value: '${detail.passScore}',
                  label: 'skor lulus',
                ),
              ),
              if (lesson.maxXp > 0) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: _HeaderStat(
                    icon: LucideIcons.zap,
                    value: '${lesson.maxXp}',
                    label: 'XP maks',
                  ),
                ),
              ],
            ],
          ),
          if (lesson.attempts > 0) ...[
            const SizedBox(height: 12),
            _GlassPill(
              icon: LucideIcons.trophy,
              label: 'Skor terbaikmu ${lesson.score}',
            ),
          ],
        ],
      ),
    );
  }
}

class _GlassPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _GlassPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              style: pSemiBold10.copyWith(color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _HeaderStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(height: 6),
          Text(value, style: pBold16.copyWith(color: Colors.white)),
          Text(
            label,
            style: pMedium10.copyWith(
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Objectives ─────────────────────────────────────────────────────────────

class _Objectives extends StatelessWidget {
  final ArabicLessonDetail detail;
  final Color color;
  const _Objectives({required this.detail, required this.color});

  @override
  Widget build(BuildContext context) {
    final scheme = context.theme.colorScheme;
    final hasTarget = detail.target != null && detail.target!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: arabicCardDecoration(context, accent: color),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasTarget) ...[
            _SectionLabel(
              icon: LucideIcons.target,
              label: 'Target',
              color: color,
            ),
            const SizedBox(height: 6),
            Text(detail.target!, style: pMedium12.copyWith(height: 1.5)),
            if (detail.objectives.isNotEmpty) const SizedBox(height: 16),
          ],
          if (detail.objectives.isNotEmpty) ...[
            _SectionLabel(
              icon: LucideIcons.listChecks,
              label: 'Tujuan pembelajaran',
              color: color,
            ),
            const SizedBox(height: 10),
            for (final objective in detail.objectives)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 1),
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(LucideIcons.check, size: 11, color: color),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        objective,
                        style: pMedium12.copyWith(
                          height: 1.45,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _SectionLabel({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 6),
        Text(label, style: pBold12.copyWith(color: color)),
      ],
    );
  }
}

// ─── Material blocks ────────────────────────────────────────────────────────

/// One material block; layout depends on its type.
class _ContentCard extends StatelessWidget {
  final ArabicContent content;
  final Color color;
  const _ContentCard({required this.content, required this.color});

  bool _has(String? value) => value != null && value.trim().isNotEmpty;

  ({String label, IconData icon}) get _meta => switch (content.type) {
    'vocab_card' => (label: 'Kartu Kata', icon: LucideIcons.languages),
    'verse' => (label: 'Contoh Ayat', icon: LucideIcons.bookOpen),
    'insight' => (label: 'Insight', icon: LucideIcons.lightbulb),
    _ => (label: 'Materi', icon: LucideIcons.fileText),
  };

  @override
  Widget build(BuildContext context) {
    final scheme = context.theme.colorScheme;
    final isDark = context.isDarkMode;
    final isInsight = content.type == 'insight';
    final accent = isInsight ? Colors.amber.shade800 : color;
    final centered = content.type == 'vocab_card' || content.type == 'verse';
    final meta = _meta;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: arabicCardDecoration(context, accent: accent).copyWith(
        color: isInsight
            ? Color.alphaBlend(
                Colors.amber.withValues(alpha: isDark ? 0.12 : 0.10),
                isDark ? scheme.surfaceContainer : Colors.white,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: centered
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Align(
            alignment: centered ? Alignment.center : Alignment.centerLeft,
            child: ArabicChip(
              label: meta.label,
              icon: meta.icon,
              color: accent,
            ),
          ),
          const SizedBox(height: 12),
          if (_has(content.image)) ...[
            ArabicImage(url: content.image!, height: 160),
            const SizedBox(height: 12),
          ],
          if (_has(content.title))
            Text(
              content.title!,
              style: pSemiBold14,
              textAlign: centered ? TextAlign.center : TextAlign.start,
            ),
          if (_has(content.arabicText)) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                content.arabicText!,
                style: arabicTextStyle(
                  size: content.type == 'vocab_card' ? 36 : 26,
                  color: accent,
                ),
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
            ),
          ],
          if (_has(content.transliteration)) ...[
            const SizedBox(height: 8),
            Text(
              content.transliteration!,
              style: pSemiBold12.copyWith(color: accent),
              textAlign: TextAlign.center,
            ),
          ],
          if (_has(content.translation)) ...[
            const SizedBox(height: 6),
            Text(
              content.translation!,
              style: pMedium12.copyWith(
                fontStyle: FontStyle.italic,
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (_has(content.reference)) ...[
            const SizedBox(height: 4),
            Text(
              content.reference!,
              style: pMedium10.copyWith(color: scheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
          if (_has(content.body)) ...[
            if (_has(content.title) || _has(content.arabicText))
              const SizedBox(height: 8),
            Text(
              content.body!,
              style: pMedium12.copyWith(height: 1.55),
              textAlign: centered ? TextAlign.center : TextAlign.start,
            ),
          ],
          if (_has(content.audio)) ...[
            const SizedBox(height: 12),
            ArabicAudioButton(url: content.audio!, color: accent),
          ],
        ],
      ),
    );
  }
}

// ─── Bottom actions ─────────────────────────────────────────────────────────

class _Actions extends StatelessWidget {
  final ArabicLessonDetail detail;
  final Color color;
  final VoidCallback onPractice;
  final VoidCallback onMain;
  final VoidCallback onReview;

  const _Actions({
    required this.detail,
    required this.color,
    required this.onPractice,
    required this.onMain,
    required this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.theme.colorScheme;
    final hasMain = detail.mainCount > 0;
    final hasPractice = detail.practiceCount > 0;
    final hasReview = detail.needReviewCount > 0;

    if (!hasMain && !hasPractice) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.info, size: 14, color: scheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                'Pelajaran ini belum memiliki soal.',
                style: pMedium12.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    }

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );
    const pad = EdgeInsets.symmetric(vertical: 15);

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
          top: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.35)),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasReview) ...[
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onReview,
                    icon: const Icon(LucideIcons.rotateCcw, size: 18),
                    label: Text(
                      'Ulangi ${detail.needReviewCount} Soal yang Salah',
                      style: pSemiBold14.copyWith(color: Colors.white),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
                      padding: pad,
                      shape: shape,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  if (hasPractice)
                    Expanded(
                      flex: 2,
                      child: OutlinedButton.icon(
                        onPressed: onPractice,
                        icon: Icon(
                          LucideIcons.dumbbell,
                          size: 18,
                          color: color,
                        ),
                        label: Text(
                          'Latihan',
                          style: pSemiBold14.copyWith(color: color),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: pad,
                          shape: shape,
                          side: BorderSide(color: color.withValues(alpha: 0.5)),
                        ),
                      ),
                    ),
                  if (hasPractice && hasMain) const SizedBox(width: 8),
                  if (hasMain)
                    Expanded(
                      flex: hasPractice ? 3 : 1,
                      child: FilledButton.icon(
                        onPressed: onMain,
                        icon: const Icon(LucideIcons.play, size: 18),
                        label: Text(
                          detail.lesson.attempts > 0
                              ? 'Kerjakan Lagi'
                              : 'Mulai Kuis',
                          style: pSemiBold14.copyWith(color: Colors.white),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: color,
                          padding: pad,
                          shape: shape,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
