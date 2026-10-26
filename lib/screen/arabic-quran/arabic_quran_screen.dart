import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/models/arabic_learning/arabic_level_model.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/screen/arabic-quran/arabic_quran_controller.dart';
import 'package:quran_app/screen/arabic-quran/arabic_widgets.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';

/// Course roadmap: Phase > Theme > Level, with the user's XP and progress.
class ArabicQuranScreen extends StatelessWidget {
  const ArabicQuranScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final controller = Get.find<ArabicQuranController>();

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
        title: Text('Belajar Bahasa Arab', style: pSemiBold16),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Leaderboard',
            icon: const Icon(LucideIcons.trophy),
            onPressed: () => Get.toNamed(Routes.arabicLeaderboard),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.fetchRoadmap,
        child: Obx(() {
          if (controller.isLoadingRoadmap.value && controller.phases.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: const [
                ArabicShimmerBox(height: 210),
                ArabicShimmerBox(height: 260),
                ArabicShimmerBox(height: 260),
              ],
            );
          }

          if (controller.phases.isEmpty) {
            return _EmptyState(
              failed: controller.roadmapFailed.value,
              onRetry: controller.fetchRoadmap,
            );
          }

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
            children: [
              if (controller.stats.value != null)
                ArabicReveal(child: _Hero(stats: controller.stats.value!)),
              const SizedBox(height: 14),
              const ArabicReveal(delay: 1, child: _LeaderboardTile()),
              for (var p = 0; p < controller.phases.length; p++) ...[
                const SizedBox(height: 28),
                ArabicReveal(
                  delay: 1,
                  child: _PhaseHeader(
                    phase: controller.phases[p],
                    number: p + 1,
                  ),
                ),
                for (final theme in controller.phases[p].themes)
                  ArabicReveal(delay: 2, child: _ThemeCard(theme: theme)),
              ],
            ],
          );
        }),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool failed;
  final Future<void> Function() onRetry;
  const _EmptyState({required this.failed, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      failed ? LucideIcons.wifiOff : LucideIcons.bookOpen,
                      size: 32,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    failed ? 'Materi belum bisa dimuat' : 'Materi segera hadir',
                    style: pBold16,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    failed
                        ? 'Periksa koneksi internet, lalu coba lagi.'
                        : 'Materi bahasa Arab sedang disiapkan.',
                    style: pMedium12.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (failed) ...[
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: onRetry,
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Coba lagi',
                        style: pSemiBold14.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Hero ───────────────────────────────────────────────────────────────────

class _Hero extends StatelessWidget {
  final ArabicStats stats;
  const _Hero({required this.stats});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final base = isDark ? AppColor.primaryColorDark : AppColor.primaryColor;
    final pct = stats.totalLessons > 0
        ? stats.completedLessons / stats.totalLessons
        : 0.0;
    final nextId = stats.nextLessonId;
    final finished = nextId == null && stats.totalLessons > 0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(base, Colors.white, 0.12)!,
              Color.lerp(base, Colors.black, 0.35)!,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Decorative glow shapes.
            const Positioned(
              right: -40,
              top: -50,
              child: _Blob(size: 170, opacity: 0.10),
            ),
            const Positioned(
              left: -30,
              bottom: -60,
              child: _Blob(size: 140, opacity: 0.07),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
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
                        Text(
                          'Bahasa Arab Al-Quran',
                          style: pSemiBold10.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Total XP',
                    style: pMedium12.copyWith(
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TweenAnimationBuilder<int>(
                        tween: IntTween(begin: 0, end: stats.totalXp),
                        duration: const Duration(milliseconds: 900),
                        curve: Curves.easeOutCubic,
                        builder: (_, value, __) => Text(
                          '$value',
                          style: pBold24.copyWith(
                            color: Colors.white,
                            fontSize: 40,
                            height: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 7),
                        child: Icon(
                          LucideIcons.zap,
                          size: 20,
                          color: AppColor.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _HeroStat(
                          icon: LucideIcons.bookCheck,
                          value:
                              '${stats.completedLessons}/${stats.totalLessons}',
                          label: 'Pelajaran selesai',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _HeroStat(
                          icon: LucideIcons.target,
                          value: '${(pct * 100).round()}%',
                          label: 'Total progres',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: pct),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeOutCubic,
                      builder: (_, value, __) => LinearProgressIndicator(
                        value: value,
                        minHeight: 8,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation(
                          AppColor.secondaryColor,
                        ),
                      ),
                    ),
                  ),
                  if (nextId != null || finished) ...[
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: nextId == null
                            ? null
                            : () => Get.toNamed(
                                Routes.arabicLessonDetail,
                                arguments: nextId,
                              ),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          disabledBackgroundColor: Colors.white.withValues(
                            alpha: 0.85,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              finished
                                  ? 'Semua pelajaran selesai'
                                  : stats.completedLessons == 0
                                  ? 'Mulai Belajar'
                                  : 'Lanjutkan Belajar',
                              style: pBold14.copyWith(color: base),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              finished
                                  ? LucideIcons.trophy
                                  : LucideIcons.arrowRight,
                              size: 18,
                              color: base,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final double opacity;
  const _Blob({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _HeroStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: pBold14.copyWith(color: Colors.white)),
                Text(
                  label,
                  style: pMedium10.copyWith(
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  const _LeaderboardTile();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    return InkWell(
      onTap: () => Get.toNamed(Routes.arabicLeaderboard),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: arabicCardDecoration(context, radius: 20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColor.secondaryColor.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.trophy,
                size: 20,
                color: AppColor.secondaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Leaderboard', style: pSemiBold14),
                  Text(
                    'Lihat peringkat XP semua pelajar',
                    style: pMedium10.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Phase ──────────────────────────────────────────────────────────────────

class _PhaseHeader extends StatelessWidget {
  final ArabicPhase phase;
  final int number;
  const _PhaseHeader({required this.phase, required this.number});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'FASE $number',
              style: pBold10.copyWith(
                color: colorScheme.primary,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(phase.title, style: pBold20),
          if (phase.subtitle != null && phase.subtitle!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              phase.subtitle!,
              style: pMedium12.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Theme card with level timeline ─────────────────────────────────────────

enum _NodeState { locked, available, current, completed }

class _ThemeCard extends StatelessWidget {
  final ArabicTheme theme;
  const _ThemeCard({required this.theme});

  _NodeState _stateOf(ArabicLevel level, ArabicLevel? current) {
    if (level.isLocked) return _NodeState.locked;
    if (level.isCompleted) return _NodeState.completed;
    return identical(level, current)
        ? _NodeState.current
        : _NodeState.available;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final isDark = context.isDarkMode;
    final color = arabicColor(theme.color);
    // The level to continue with: first one that is open and unfinished.
    final current = theme.levels
        .where((l) => !l.isLocked && !l.isCompleted)
        .firstOrNull;

    return Opacity(
      opacity: theme.isLocked ? 0.65 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: isDark ? colorScheme.surfaceContainer : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.35),
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: color.withValues(alpha: 0.07),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tinted header.
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withValues(alpha: isDark ? 0.22 : 0.14),
                      color.withValues(alpha: 0.02),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    _ProgressRing(
                      value: theme.progressPct / 100,
                      color: color,
                      size: 56,
                      child: _GlyphIcon(
                        url: theme.icon,
                        color: color,
                        fallback: theme.isLocked
                            ? LucideIcons.lock
                            : LucideIcons.bookOpen,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(theme.title, style: pBold16),
                          if (theme.goal != null && theme.goal!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              theme.goal!,
                              style: pMedium12.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 8),
                          _Pill(
                            label:
                                '${theme.completedLessons}/${theme.totalLessons} pelajaran • ${theme.progressPct}%',
                            color: color,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Column(
                  children: [
                    for (var i = 0; i < theme.levels.length; i++)
                      _LevelNode(
                        level: theme.levels[i],
                        state: _stateOf(theme.levels[i], current),
                        isLast: i == theme.levels.length - 1,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelNode extends StatelessWidget {
  final ArabicLevel level;
  final _NodeState state;
  final bool isLast;

  const _LevelNode({
    required this.level,
    required this.state,
    required this.isLast,
  });

  void _open() {
    if (state == _NodeState.locked) {
      Get.snackbar(
        'Level Terkunci',
        'Selesaikan pelajaran sebelumnya terlebih dahulu.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }
    Get.toNamed(Routes.arabicLesson, arguments: level.id);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final isDark = context.isDarkMode;
    final locked = state == _NodeState.locked;
    final current = state == _NodeState.current;
    final done = state == _NodeState.completed;
    final color = locked
        ? colorScheme.onSurfaceVariant
        : arabicColor(level.color);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline rail: node + connector to the next level.
          SizedBox(
            width: 36,
            child: Column(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: done
                        ? color
                        : current
                        ? color.withValues(alpha: 0.16)
                        : colorScheme.surfaceContainerHighest.withValues(
                            alpha: isDark ? 0.5 : 0.8,
                          ),
                    shape: BoxShape.circle,
                    border: current ? Border.all(color: color, width: 2) : null,
                    boxShadow: current
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.35),
                              blurRadius: 12,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: _GlyphIcon(
                      url: done || locked ? null : level.icon,
                      color: done ? Colors.white : color,
                      fallback: locked
                          ? LucideIcons.lock
                          : done
                          ? LucideIcons.check
                          : current
                          ? LucideIcons.play
                          : LucideIcons.star,
                      size: 16,
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
                            : colorScheme.outlineVariant.withValues(alpha: 0.5),
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
              padding: EdgeInsets.only(bottom: isLast ? 8 : 14),
              child: InkWell(
                onTap: _open,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: current
                        ? color.withValues(alpha: isDark ? 0.14 : 0.07)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: current
                          ? color.withValues(alpha: 0.5)
                          : colorScheme.outlineVariant.withValues(alpha: 0.3),
                      width: current ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              level.name,
                              style: pSemiBold14.copyWith(
                                color: locked
                                    ? colorScheme.onSurfaceVariant
                                    : colorScheme.onSurface,
                              ),
                            ),
                          ),
                          if (current)
                            _Pill(label: 'Lanjut', color: color, solid: true)
                          else if (done)
                            _Pill(label: 'Selesai', color: color)
                          else
                            Icon(
                              locked
                                  ? LucideIcons.lock
                                  : LucideIcons.chevronRight,
                              size: 16,
                              color: colorScheme.onSurfaceVariant,
                            ),
                        ],
                      ),
                      if (level.description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          level.description,
                          style: pMedium10.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (!locked && level.totalLessons > 0) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween(
                                    begin: 0,
                                    end: level.progressPct / 100,
                                  ),
                                  duration: const Duration(milliseconds: 700),
                                  curve: Curves.easeOutCubic,
                                  builder: (_, v, __) =>
                                      LinearProgressIndicator(
                                        value: v,
                                        minHeight: 5,
                                        backgroundColor: colorScheme
                                            .surfaceContainerHighest
                                            .withValues(
                                              alpha: isDark ? 0.6 : 1,
                                            ),
                                        valueColor: AlwaysStoppedAnimation(
                                          color,
                                        ),
                                      ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${level.completedLessons}/${level.totalLessons}',
                              style: pSemiBold10.copyWith(color: color),
                            ),
                          ],
                        ),
                      ],
                    ],
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

// ─── Small building blocks ──────────────────────────────────────────────────

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  final bool solid;
  const _Pill({required this.label, required this.color, this.solid = false});

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

/// Circular progress with [child] centred inside.
class _ProgressRing extends StatelessWidget {
  final double value;
  final Color color;
  final double size;
  final Widget child;

  const _ProgressRing({
    required this.value,
    required this.color,
    required this.size,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value.clamp(0, 1)),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (_, v, __) => SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: v,
                strokeWidth: 4,
                strokeCap: StrokeCap.round,
                backgroundColor: color.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

/// Remote icon from the admin when set, otherwise a Lucide fallback.
class _GlyphIcon extends StatelessWidget {
  final String? url;
  final Color color;
  final IconData fallback;
  final double size;

  const _GlyphIcon({
    required this.url,
    required this.color,
    required this.fallback,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final icon = Icon(fallback, color: color, size: size);
    if (url == null || url!.isEmpty) return icon;

    return CachedNetworkImage(
      imageUrl: url!,
      width: size,
      height: size,
      errorWidget: (_, __, ___) => icon,
    );
  }
}
